module decode_execute_latch(clk, rst, nop, instruction_d, instruction_e, read1Data_d, read1Data_e, read2Data_d, read2Data_e, immExt_d, immExt_e, aluSrc_d,
                            aluSrc_e, branch_d, branch_e, memRead_d, memRead_e, memToReg_d, memToReg_e, memWrite_d, memWrite_e, halt_d, halt_e, link_d, link_e, 
                            jumpImm_d, jumpImm_e, jump_d, jump_e);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] instruction_d, read1Data_d, read2Data_d, immExt_d;
    input wire halt_d, link_d, memRead_d, memToReg_d, memWrite_d, aluSrc_d, jumpImm_d, jump_d;
    input wire [2:0] branch_d;
    output wire [15:0] instruction_e, read1Data_e, read2Data_e, immExt_e;
    output wire halt_e, link_e, memRead_e, memToReg_e, memWrite_e, aluSrc_e, jumpImm_e, jump_e;
    output wire [2:0] branch_e;

    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(instruction_d), .readData(instruction_e));              // might remove nop depending on fetch logic
    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(read1Data_d), .readData(read1Data_e));
    register iREAD2DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(read2Data_d), .readData(read2Data_e));
    register iIMMEXT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(immExt_d), .readData(immExt_e));

    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(halt_d), .readData(halt_e));
    register #(REGISTER_WIDTH = 1) iLINK_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(link_d), .readData(link_e));
    register #(REGISTER_WIDTH = 1) iMEMREAD_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(memRead_d), .readData(memRead_e));
    register #(REGISTER_WIDTH = 1) iMEMTOREG_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(memToReg_d), .readData(memToReg_e));
    register #(REGISTER_WIDTH = 1) iMEMWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(memWrite_d), .readData(memWrite_e));
    register #(REGISTER_WIDTH = 1) iALUSRC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(aluSrc_d), .readData(aluSrc_e));
    register #(REGISTER_WIDTH = 1) iJUMPIMM_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(jumpImm_d), .readData(jumpImm_e));
    register #(REGISTER_WIDTH = 1) iJUMP_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(jump_d), .readData(jump_e));

    register #(REGISTER_WIDTH = 3) iBRANCH_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(branch_d), .readData(branch_e));

endmodule