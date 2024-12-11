module execute_memory_latch(clk, rst, PC_e, PC_m, aluOut_e, aluOut_m, read2Data_e, read2Data_m, 
                            memRead_e, memRead_m, memToReg_e, memToReg_m, memWrite_e, memWrite_m, 
                            halt_e, halt_m, link_e, link_m, jumpImm_e, jumpImm_m, jump_e, jump_m, 
                            read1Data_e, read1Data_m, immExt_e, immExt_m, writeRegSel_e, writeRegSel_m, 
                            regWrite_e, regWrite_m, br_contr_e, br_contr_m, align_err_fetch_e, align_err_fetch_m, instruction_e, instruction_m);

    input wire clk, rst;
    input wire memRead_e, memToReg_e, memWrite_e, halt_e, link_e, jumpImm_e, jump_e, regWrite_e, br_contr_e, align_err_fetch_e;
    input wire [15:0] PC_e, aluOut_e, read1Data_e, read2Data_e, immExt_e;
    input wire [3:0] writeRegSel_e;
    input wire [15:0] instruction_e;
    output wire memRead_m, memToReg_m, memWrite_m, halt_m, link_m, jumpImm_m, jump_m, regWrite_m, br_contr_m, align_err_fetch_m;
    output wire [15:0] PC_m, aluOut_m, read1Data_m, read2Data_m, immExt_m;
    output wire [3:0] writeRegSel_m;
    output wire [15:0] instruction_m;

    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_e), .readData(instruction_m));

    register #(.REGISTER_WIDTH(1)) iMEMREAD_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memRead_e), .readData(memRead_m));      // use ~nop for writeEn?
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_e), .readData(memToReg_m));
    register #(.REGISTER_WIDTH(1)) iMEMWRITE_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memWrite_e), .readData(memWrite_m));
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_e), .readData(halt_m));
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_e), .readData(link_m));
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jumpImm_e), .readData(jumpImm_m));
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jump_e), .readData(jump_m));
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_e), .readData(regWrite_m));
    register #(.REGISTER_WIDTH(1)) iBR_CONTR_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(br_contr_e), .readData(br_contr_m));
    register #(.REGISTER_WIDTH(1)) iALIGN_ERR_FETCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(align_err_fetch_e), .readData(align_err_fetch_m));

    register iPC_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PC_e), .readData(PC_m));
    register iALUOUT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_e), .readData(aluOut_m));
    register iREAD1DATA_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read1Data_e), .readData(read1Data_m));
    register iREAD2DATA_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read2Data_e), .readData(read2Data_m));
    register iIMMEXT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(immExt_e), .readData(immExt_m));
    
    register #(.REGISTER_WIDTH(4)) iWRITEREGSEL_LATCH_EM(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_e), .readData(writeRegSel_m));

endmodule