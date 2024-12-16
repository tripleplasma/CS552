module hdu (clk, rst, 
                    opcode_f, opcode_d, opcode_e, opcode_m,
                    ifIdReadRegister1, ifIdReadRegister2,
                    PC_e, PC_m, PC_wb,
                    idExWriteRegister, exMemWriteRegister, memWbWriteRegister,
                    disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP, br_contr_sig, predict_taken, taken_flush);

    input wire clk, rst;
    input wire br_contr_sig;
    input wire[15:0] PC_e, PC_m, PC_wb;
    input wire [4:0] opcode_f, opcode_d, opcode_e, opcode_m;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    output wire disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP, predict_taken;
    output reg taken_flush;

    //                                                                                  LD
    wire immediates = opcode_d[4:2] == 3'b010 | opcode_d[4:2] == 3'b101 | opcode_d == 5'b10001;

    //TODO: Check if the opcodes are a valid R type instruction so that we don't confuse immediate bits for register names
    //                                 JMP                    JAL           NOP                        LBI                 HALT 
    wire ignoreReg1 = (opcode_d == 5'b00100 | opcode_d == 5'b00110 | opcode_d == 5'b00001 | opcode_d == 5'b11000 | opcode_d == 5'b00000);

    //                                    JMP                       BR                    LBI                    SLBI                   BTR             NOP             HALT
    wire ignoreReg2 = (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011 | opcode_d == 5'b11000 | opcode_d == 5'b10010 | opcode_d == 5'b11001 | opcode_d == 5'b00001 | opcode_d == 5'b00000 | immediates);

    wire RAW_ID_EX = (((idExWriteRegister == ifIdReadRegister1) & ~ignoreReg1) | ((idExWriteRegister == ifIdReadRegister2) & ~ignoreReg2)) & |PC_e;
    wire RAW_EX_MEM = (((exMemWriteRegister == ifIdReadRegister1) & ~ignoreReg1) | ((exMemWriteRegister == ifIdReadRegister2) & ~ignoreReg2)) & |PC_m;
    // wire RAW_MEM_WB = (((memWbWriteRegister == ifIdReadRegister1) & ~ignoreReg1) | ((memWbWriteRegister == ifIdReadRegister2) & ~ignoreReg2)) & |PC_wb;
    //TODO: make a check to make sure that the instructions at those stages aren't NOPs otherwise it'll think R0 is being used
    wire RAW_hazard = RAW_ID_EX | RAW_EX_MEM; //| RAW_MEM_WB;

    wire data_hazard = (rst == 1'b0) & RAW_hazard;


    wire control_hazard =   (opcode_f[4:2] == 3'b001) | // (opcode_f[4:2] == 3'b011 & predict_taken)) | 
                            (opcode_d[4:2] == 3'b001) | // (opcode_d[4:2] == 3'b011 & predict_taken)) |
                            (opcode_e[4:2] == 3'b001) | // (opcode_e[4:2] == 3'b011 & predict_taken)) | 
                            (opcode_m[4:2] == 3'b001);  // (opcode_m[4:2] == 3'b011 & predict_taken))

    //NOTE: We're disabling the PCWrite when the HALT is read because otherwise we'll get XXXX's as the instruction and it will break everything, thats whay the opcode_f== is for
    // TODO breaks branch no taken if we flush
    assign disablePCWrite = (data_hazard | control_hazard | (opcode_f == 5'b00000)) & (~br_contr_sig | predict_taken);

    //NOTE: If we setExNOP, we need to keep the decode instruction at the IFID latch so that when the hazard is gone, the instruction is still there
    //NOTE: We don't disableIFID write during a control hazard becuse we want the BR/JMP to propagate through the pipeline
    assign disableIFIDWrite = data_hazard & (~br_contr_sig | predict_taken);   

    assign setExNOP = data_hazard & (~br_contr_sig | predict_taken);

    //These signals require a register because they need to be delayed a cycle to properly tell the pipeline to input a NOP during the E or F phase
    // wire l = data_hazard & opcode_f == 5'b00001;
    wire setFetchNOP_int = ((control_hazard & ~data_hazard) | (control_hazard & data_hazard & opcode_f == 5'b00001)) & (~br_contr_sig | predict_taken);
    register #(.REGISTER_WIDTH(1)) setFetchNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(setFetchNOP_int), .readData(setFetchNOP));

    // 00 and 01 not taken, 10 and 11 predict taken
    wire [1:0] state, nxt_state;
    reg [1:0] nxt_state_reg;
    assign nxt_state = nxt_state_reg;
    register #(.REGISTER_WIDTH(2)) state_latch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(nxt_state), .readData(state));
    
    assign predict_taken = (state == 2'b10) | (state == 2'b11);

    // TODO (~br_contr_sig & ~predict_taken) one level above

    always @(opcode_e) begin

        // Default stay in current state
        nxt_state_reg = state;
        taken_flush = 1'b0;

        case(state)
            // Predict not take
            2'b00: begin
                if (opcode_e[4:2] == 3'b011) begin
                    if (br_contr_sig) begin
                        // Branch taken so go to weak not taken
                        nxt_state_reg = 2'b01;
                    end
                end
            end

            // Weak predict not taken
            2'b01: begin
                if (opcode_e[4:2] == 3'b011) begin
                    if (br_contr_sig) begin
                        // Branch taken so go to weak taken
                        nxt_state_reg = 2'b10;
                    end else begin 
                        // Branch not taken so go to strong predict not taken
                        nxt_state_reg = 2'b00;
                    end
                end
            end

            // Weak predict taken
            2'b10: begin
                if (opcode_e[4:2] == 3'b011) begin
                    if (!br_contr_sig) begin
                        // Branch not taken so go to weak not taken
                        nxt_state_reg = 2'b01;
                        taken_flush = 1'b1;
                    end else begin
                        // Branch taken so go to strong predict taken
                        nxt_state_reg = 2'b11;
                    end
                end
            end

            // Predict taken
            2'b11: begin
                if (opcode_e[4:2] == 3'b011) begin
                    if (!br_contr_sig) begin
                        // Branch not taken so go to weak taken
                        taken_flush = 1'b1;
                        nxt_state_reg = 2'b10;
                    end
                end
            end
        endcase
    end


endmodule