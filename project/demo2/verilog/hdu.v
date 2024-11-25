module hdu (clk, rst, 
                    opcode_f, opcode_d, opcode_e, opcode_m,
                    ifIdReadRegister1, ifIdReadRegister2,
                    PC_e, PC_m, PC_wb,

                    memRead_m,
                    idExReadRegister1, idExReadRegister2, exMemReadRegister,

                    idExWriteRegister, exMemWriteRegister, memWbWriteRegister,
                    disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP,
                    useExExFowardReg1, useExExFowardReg2, useMemExFowardReg1, useMemExFowardReg2, useMemMemForward);

    input wire clk, rst;
    input wire memRead_m;
    input wire[15:0] PC_e, PC_m, PC_wb;
    input wire [4:0] opcode_f, opcode_d, opcode_e, opcode_m;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [3:0] idExReadRegister1, idExReadRegister2, exMemReadRegister;
    input wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    output wire disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP;
    output wire useExExFowardReg1, useExExFowardReg2, useMemExFowardReg1, useMemExFowardReg2, useMemMemForward;
    //MemMem fowarding is used when we have: lw $1, 0($2) -> sw $1, 0($3)

    //                                                                                  LD
    wire immediates = opcode_d[4:2] == 3'b010 | opcode_d[4:2] == 3'b101 | opcode_d == 5'b10001;

    //TODO: Check if the opcodes are a valid R type instruction so that we don't confuse immediate bits for register names
    //                                 JMP                    JAL           NOP                        LBI                 HALT
    wire ignoreReg1_d = (opcode_d == 5'b00100 | opcode_d == 5'b00110 | opcode_d == 5'b00001 | opcode_d == 5'b11000 | opcode_d == 5'b00000);

    //                                    JMP                       BR                    LBI                    SLBI                   BTR             NOP             HALT
    wire ignoreReg2_d = (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011 | opcode_d == 5'b11000 | opcode_d == 5'b10010 | opcode_d == 5'b11001 | opcode_d == 5'b00001 | opcode_d == 5'b00000 | immediates);

    // Expand ignoreReg to other stages in the pipeline
    wire ignoreReg1_e = (opcode_e == 5'b00100 | opcode_e == 5'b00110 | opcode_e == 5'b00001 | opcode_e == 5'b11000 | opcode_e == 5'b00000);
    wire ignoreReg2_e = (opcode_e[4:2] == 3'b001 | opcode_e[4:2] == 3'b011 | opcode_e == 5'b11000 | opcode_e == 5'b10010 | opcode_e == 5'b11001 | opcode_e == 5'b00001 | opcode_e == 5'b00000 | opcode_e[4:2] == 3'b010 | opcode_e[4:2] == 3'b101 | opcode_e == 5'b10001);
    //wire ignoreReg1_m = (opcode_m == 5'b00100 | opcode_m == 5'b00110 | opcode_m == 5'b00001 | opcode_m == 5'b11000 | opcode_m == 5'b00000);
    wire ignoreReg2_m = (opcode_m[4:2] == 3'b001 | opcode_m[4:2] == 3'b011 | opcode_m == 5'b11000 | opcode_m == 5'b10010 | opcode_m == 5'b11001 | opcode_m == 5'b00001 | opcode_m == 5'b00000 | opcode_m[4:2] == 3'b010 | opcode_m[4:2] == 3'b101 | opcode_m == 5'b10001);

    //assign useExExFowardReg1 = (idExReadRegister1 == exMemWriteRegister) & ~memRead_m;
    //assign useExExFowardReg2 = (idExReadRegister2 == exMemWriteRegister) & ~memRead_m;
    //assign useMemExFowardReg1 = idExReadRegister1 == memWbWriteRegister;
    //assign useMemExFowardReg2 = idExReadRegister2 == memWbWriteRegister;
    //assign useMemMemForward = exMemReadRegister == memWbWriteRegister;
    // New forwarding assignment with latched reg select
    assign useExExFowardReg1 = (idExReadRegister1 == exMemWriteRegister) & ~memRead_m & ~ignoreReg1_e;
    assign useExExFowardReg2 = (idExReadRegister2 == exMemWriteRegister) & ~memRead_m & ~ignoreReg2_e;
    assign useMemExFowardReg1 = (idExReadRegister1 == memWbWriteRegister) & ~ignoreReg1_e;
    assign useMemExFowardReg2 = (idExReadRegister2 == memWbWriteRegister) & ~ignoreReg2_e;
    assign useMemMemForward = (exMemReadRegister == memWbWriteRegister) & ~ignoreReg2_m;

    // Need to predict if will be able to be forwarded
    wire reg1Forwarding = ((ifIdReadRegister1 == idExWriteRegister) | (ifIdReadRegister1 == exMemWriteRegister)) & ~ignoreReg1_d;
    wire reg2Forwarding = ((ifIdReadRegister2 == idExWriteRegister) | (ifIdReadRegister2 == exMemWriteRegister)) & ~ignoreReg2_d;

    //wire useForwarding = useExExFowardReg1 | useExExFowardReg2 | useMemExFowardReg1 | useMemExFowardReg2 | useMemMemForward;

    wire RAW_ID_EX = (((idExWriteRegister == ifIdReadRegister1) & ~ignoreReg1_d & ~reg1Forwarding) | ((idExWriteRegister == ifIdReadRegister2) & ~ignoreReg2_d & ~reg2Forwarding)) & |PC_e;
    wire RAW_EX_MEM = (((exMemWriteRegister == ifIdReadRegister1) & ~ignoreReg1_d & ~reg1Forwarding) | ((exMemWriteRegister == ifIdReadRegister2) & ~ignoreReg2_d & ~reg2Forwarding)) & |PC_m;
    // wire RAW_MEM_WB = (((memWbWriteRegister == ifIdReadRegister1) & ~ignoreReg1) | ((memWbWriteRegister == ifIdReadRegister2) & ~ignoreReg2)) & |PC_wb;
    //TODO: make a check to make sure that the instructions at those stages aren't NOPs otherwise it'll think R0 is being used
    wire RAW_hazard = RAW_ID_EX | RAW_EX_MEM; //| RAW_MEM_WB;

    wire data_hazard = (rst == 1'b0) & RAW_hazard; // ~useForwarding


    wire control_hazard =   (opcode_f[4:2] == 3'b001 | opcode_f[4:2] == 3'b011) | 
                            (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011) |
                            (opcode_e[4:2] == 3'b001 | opcode_e[4:2] == 3'b011) | 
                            (opcode_m[4:2] == 3'b001 | opcode_m[4:2] == 3'b011) ;

    //NOTE: We're disabling the PCWrite when the HALT is read because otherwise we'll get XXXX's as the instruction and it will break everything, thats whay the opcode_f== is for
    assign disablePCWrite = data_hazard | control_hazard | (opcode_f == 5'b00000);

    //NOTE: If we setExNOP, we need to keep the decode instruction at the IFID latch so that when the hazard is gone, the instruction is still there
    //NOTE: We don't disableIFID write during a control hazard becuse we want the BR/JMP to propagate through the pipeline
    assign disableIFIDWrite = data_hazard;   

    assign setExNOP = data_hazard;

    //These signals require a register because they need to be delayed a cycle to properly tell the pipeline to input a NOP during the E or F phase
    // wire l = data_hazard & opcode_f == 5'b00001;
    wire setFetchNOP_int = (control_hazard & ~data_hazard) | (control_hazard & data_hazard & opcode_f == 5'b00001) ;
    register #(.REGISTER_WIDTH(1)) setFetchNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(setFetchNOP_int), .readData(setFetchNOP));
endmodule