module execute_memory_latch(clk, rst, disableEXMEMWrite, PC_e, PC_m, aluOut_e, aluOut_m, read2Data_e, read2Data_m, 
                            memRead_e, memRead_m, memToReg_e, memToReg_m, memWrite_e, memWrite_m, 
                            halt_e, halt_m, link_e, link_m, jumpImm_e, jumpImm_m, jump_e, jump_m, 
                            read1Data_e, read1Data_m, immExt_e, immExt_m, writeRegSel_e, writeRegSel_m, 
                            regWrite_e, regWrite_m, br_contr_e, br_contr_m, instr_mem_align_err_e, instr_mem_align_err_m, instruction_e, instruction_m);

    input wire clk, rst, disableEXMEMWrite;
    input wire memRead_e, memToReg_e, memWrite_e, halt_e, link_e, jumpImm_e, jump_e, regWrite_e, br_contr_e, instr_mem_align_err_e;
    input wire [15:0] PC_e, aluOut_e, read1Data_e, read2Data_e, immExt_e;
    input wire [3:0] writeRegSel_e;
    input wire [15:0] instruction_e;
    output wire memRead_m, memToReg_m, memWrite_m, halt_m, link_m, jumpImm_m, jump_m, regWrite_m, br_contr_m, instr_mem_align_err_m;
    output wire [15:0] PC_m, aluOut_m, read1Data_m, read2Data_m, immExt_m;
    output wire [3:0] writeRegSel_m;
    output wire [15:0] instruction_m;

    // wire memRead_em_int, memToReg_em_int, memWrite_em_int, halt_em_int, link_em_int, jumpImm_em_int, jump_em_int, regWrite_em_int, br_contr_em_int, instr_mem_align_err_em_int;
    // wire [3:0] writeRegSel_em_int;
    // wire [15:0] instruction_em_int, PC_em_int, aluOut_em_int, read1Data_em_int, read2Data_em_int, immExt_em_int;

    // assign instruction_em_int = (nop) ? 16'b0000_1000_0000_0000 : instruction_e;
    register iINSTRUCTION_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(instruction_e), .readData(instruction_m));

    
    // assign memRead_em_int = (disableEXMEMWrite) ? 1'b0 : memRead_e;
    register #(.REGISTER_WIDTH(1)) iMEMREAD_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(memRead_e), .readData(memRead_m));

    // assign memToReg_em_int = (disableEXMEMWrite) ? 1'b0 : memToReg_e;
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(memToReg_e), .readData(memToReg_m));

    // assign memWrite_em_int = (disableEXMEMWrite) ? 1'b0 : memWrite_e;
    register #(.REGISTER_WIDTH(1)) iMEMWRITE_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(memWrite_e), .readData(memWrite_m));

    // assign halt_em_int = (nop) ? 1'b0 : halt_e;
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(halt_e), .readData(halt_m));

    // assign link_em_int = (nop) ? 1'b0 : link_e;
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(link_e), .readData(link_m));

    // assign jumpImm_em_int = (nop) ? 1'b0 : jumpImm_e;
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(jumpImm_e), .readData(jumpImm_m));

    // assign jump_em_int = (nop) ? 1'b0 : jump_e;
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(jump_e), .readData(jump_m));

    // assign regWrite_em_int = (nop) ? 1'b0 : regWrite_e;
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(regWrite_e), .readData(regWrite_m));

    // assign br_contr_em_int = (disableEXMEMWrite) ? 1'b0 : br_contr_e;   // check this for error when branching
    register #(.REGISTER_WIDTH(1)) iBR_CONTR_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(br_contr_e), .readData(br_contr_m));

    // assign instr_mem_align_err_em_int = (nop) ? 1'b0 : instr_mem_align_err_e;
    register #(.REGISTER_WIDTH(1)) iINSTR_MEM_ALIGN_ERR_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(instr_mem_align_err_e), .readData(instr_mem_align_err_m));

   
    // assign PC_em_int = (nop) ? 16'hffff : PC_e;
    register iPC_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(PC_e), .readData(PC_m));

    // assign aluOut_em_int = (nop) ? 16'hffff : aluOut_e;
    register iALUOUT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(aluOut_e), .readData(aluOut_m));

    // assign read1Data_em_int = (nop) ? 16'hffff : read1Data_e;
    register iREAD1DATA_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(read1Data_e), .readData(read1Data_m));

    // assign read2Data_em_int = (nop) ? 16'hffff : read2Data_e;
    register iREAD2DATA_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(read2Data_e), .readData(read2Data_m));

    // assign immExt_em_int = (nop) ? 16'hffff : immExt_e;
    register iIMMEXT_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(immExt_e), .readData(immExt_m));
    

    // assign writeRegSel_em_int = (nop) ? 4'hf : writeRegSel_e;
    register #(.REGISTER_WIDTH(4)) iWRITEREGSEL_LATCH_EM(.clk(clk), .rst(rst), .writeEn(~disableEXMEMWrite), .writeData(writeRegSel_e), .readData(writeRegSel_m));

endmodule