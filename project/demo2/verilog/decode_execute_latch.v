module decode_execute_latch(clk, rst, nop, PC_d, PC_e, instruction_d, instruction_e, read1Data_d, read1Data_e, read2Data_d, read2Data_e, immExt_d, immExt_e, aluSrc_d,
                            aluSrc_e, branch_d, branch_e, memRead_d, memRead_e, memToReg_d, memToReg_e, memWrite_d, memWrite_e, halt_d, halt_e, link_d, link_e, 
                            jumpImm_d, jumpImm_e, jump_d, jump_e, writeRegSel_d, writeRegSel_e, exception_d, exception_e, regWrite_d, regWrite_e);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] PC_d, instruction_d, read1Data_d, read2Data_d, immExt_d;
    input wire halt_d, link_d, memRead_d, memToReg_d, memWrite_d, aluSrc_d, jumpImm_d, jump_d, exception_d, regWrite_d;
    input wire [2:0] branch_d, writeRegSel_d;
    output wire [15:0] PC_e, instruction_e, read1Data_e, read2Data_e, immExt_e;
    output wire halt_e, link_e, memRead_e, memToReg_e, memWrite_e, aluSrc_e, jumpImm_e, jump_e, exception_e, regWrite_e;
    output wire [2:0] branch_e, writeRegSel_e;

    wire [15:0] instruction_de_int;

    register iPC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PC_d), .readData(PC_e));
    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_d), .readData(instruction_de_int));              // rchanged writeEn from ~nop to 1, unsure about it here due to other signals
    assign instruction_e = (nop) ? 16'b0000_1000_0000_0000 : instruction_de_int;

    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read1Data_d), .readData(read1Data_e));
    register iREAD2DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read2Data_d), .readData(read2Data_e));
    register iIMMEXT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(immExt_d), .readData(immExt_e));

    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_d), .readData(halt_e));
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_d), .readData(link_e));
    register #(.REGISTER_WIDTH(1)) iMEMREAD_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memRead_d), .readData(memRead_e));
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_d), .readData(memToReg_e));
    register #(.REGISTER_WIDTH(1)) iMEMWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memWrite_d), .readData(memWrite_e));
    register #(.REGISTER_WIDTH(1)) iALUSRC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluSrc_d), .readData(aluSrc_e));
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jumpImm_d), .readData(jumpImm_e));
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jump_d), .readData(jump_e));
    register #(.REGISTER_WIDTH(1)) iEXCEPTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exception_d), .readData(exception_e));
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_d), .readData(regWrite_e));

    register #(.REGISTER_WIDTH(3)) iBRANCH_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(branch_d), .readData(branch_e));
    register #(.REGISTER_WIDTH(3)) iWRITEREGSEL_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_d), .readData(writeRegSel_e));

endmodule