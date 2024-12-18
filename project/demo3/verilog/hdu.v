module hdu (clk, rst, 
                    //Inputs
                    opcode_f, opcode_d, opcode_e, opcode_m,
                    ifIdReadRegister1, ifIdReadRegister2,
                    PC_e, PC_m, PC_wb,
                    idExWriteRegister, exMemWriteRegister, memWbWriteRegister,
                    data_mem_done, data_mem_stall, data_mem_cache_hit,
                    disablePCWrite, setFetchNOP, disableIFIDWrite, disableIDEXWrite, setExNOP, disableEXMEMWrite, setMemNOP);

    input wire clk, rst;
    input wire[15:0] PC_e, PC_m, PC_wb;
    input wire [4:0] opcode_f, opcode_d, opcode_e, opcode_m;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    input wire data_mem_done, data_mem_stall, data_mem_cache_hit;
    output wire disablePCWrite, setFetchNOP, disableIFIDWrite, disableIDEXWrite, setExNOP, disableEXMEMWrite, setMemNOP;

    //                                                                                  LD
    wire immediates = opcode_d[4:2] == 3'b010 | opcode_d[4:2] == 3'b101 | opcode_d == 5'b10001;

    //TODO: Check if the opcodes are a valid R type instruction so that we don't confuse immediate bits for register names
    //                                 JMP                    JAL           NOP                        LBI                 HALT
    wire ignoreReg1 = (opcode_d == 5'b00100 | opcode_d == 5'b00110 | opcode_d == 5'b00001 | opcode_d == 5'b11000 | opcode_d == 5'b00000);

    //                                    JMP                       BR                    LBI                    SLBI                   BTR             NOP             HALT
    wire ignoreReg2 = (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011 | opcode_d == 5'b11000 | opcode_d == 5'b10010 | opcode_d == 5'b11001 | opcode_d == 5'b00001 | opcode_d == 5'b00000 | immediates);

    wire RAW_ID_EX = (((ifIdReadRegister1 == idExWriteRegister) & ~ignoreReg1) | ((ifIdReadRegister2 == idExWriteRegister) & ~ignoreReg2)) & |PC_e;
    wire RAW_EX_MEM = (((ifIdReadRegister1 == exMemWriteRegister) & ~ignoreReg1) | ((ifIdReadRegister2 == exMemWriteRegister) & ~ignoreReg2)) & |PC_m;
    // wire RAW_MEM_WB = (((memWbWriteRegister == ifIdReadRegister1) & ~ignoreReg1) | ((memWbWriteRegister == ifIdReadRegister2) & ~ignoreReg2)) & |PC_wb;

    //                                                                                                                                      LD
    wire canExExForward = (((ifIdReadRegister1 == idExWriteRegister) | (ifIdReadRegister2 == idExWriteRegister)) & (|PC_e) & (opcode_e != 5'b10001));
    wire canMemExForward = ((ifIdReadRegister1 == exMemWriteRegister) | (ifIdReadRegister2 == exMemWriteRegister) & (|PC_m));

    //TODO: make a check to make sure that the instructions at those stages aren't NOPs otherwise it'll think R0 is being used
    //TODO: Change the RAW_hazard signal so that if we do EX-EX forwarding, it doesn't count as a hazard
    wire RAW_hazard = (RAW_ID_EX & (~canExExForward)) | (RAW_EX_MEM & (~canMemExForward)); //| RAW_MEM_WB;
    // wire RAW_hazard = 1'b0;

    wire data_hazard = (rst == 1'b0) & RAW_hazard;


    wire control_hazard =   (opcode_f[4:2] == 3'b001 | opcode_f[4:2] == 3'b011) | 
                            (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011) |
                            (opcode_e[4:2] == 3'b001 | opcode_e[4:2] == 3'b011) | 
                            (opcode_m[4:2] == 3'b001 | opcode_m[4:2] == 3'b011) ;


    //NOTE: We're disabling the PCWrite when the HALT is read because otherwise we'll get XXXX's as the instruction and it will break everything, thats whay the opcode_f== is for
    assign disablePCWrite = data_hazard | control_hazard | (opcode_f == 5'b00000) | (data_mem_stall & ~(data_mem_done & data_mem_cache_hit));

    //NOTE: If we setExNOP, we need to keep the decode instruction at the IFID latch so that when the hazard is gone, the instruction is still there
    //NOTE: We don't disableIFID write during a control hazard becuse we want the BR/JMP to propagate through the pipeline
    assign disableIFIDWrite = data_hazard | (data_mem_stall & ~(data_mem_done & data_mem_cache_hit)); 
    
    assign disableIDEXWrite = 1'b0;
    assign disableEXMEMWrite = (data_mem_stall & ~(data_mem_done & data_mem_cache_hit));

    assign setExNOP = data_hazard;

    assign setMemNOP = (data_mem_stall & ~(data_mem_done & data_mem_cache_hit));

    //These signals require a register because they need to be delayed a cycle to properly tell the pipeline to input a NOP during the E or F phase
    wire setFetchNOP_int = (control_hazard & ~data_hazard) | (control_hazard & data_hazard & opcode_f == 5'b00001);
    register #(.REGISTER_WIDTH(1)) setFetchNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(setFetchNOP_int), .readData(setFetchNOP));
endmodule