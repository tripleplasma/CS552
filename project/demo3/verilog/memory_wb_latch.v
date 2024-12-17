module memory_wb_latch(clk, rst, disableMEMWBWrite,
                        PC_m, PC_wb, 
                        readData_m, readData_wb, aluOut_m, aluOut_wb, memToReg_m, memToReg_wb, 
                        link_m, link_wb, writeRegSel_m, writeRegSel_wb, regWrite_m, regWrite_wb, halt_m, halt_wb,
                        instruction_m, instruction_wb,
                        immExt_m, immExt_wb,
                        read1Data_m, read1Data_wb,
                        br_contr_m, br_contr_wb,
                        jump_m, jump_wb,
                        jumpImm_m, jumpImm_wb,
                        instr_mem_align_err_m, instr_mem_align_err_wb,
                        data_mem_align_err_m, data_mem_align_err_wb);

    input wire clk, rst, disableMEMWBWrite;
    input wire [15:0] PC_m, readData_m, aluOut_m;
    input wire memToReg_m, link_m, regWrite_m, halt_m;
    input wire [3:0] writeRegSel_m;
    input wire [15:0] instruction_m, immExt_m, read1Data_m;
    input wire br_contr_m, jump_m, jumpImm_m, instr_mem_align_err_m, data_mem_align_err_m;
    output wire [15:0] PC_wb, readData_wb, aluOut_wb;
    output wire memToReg_wb, link_wb, regWrite_wb, halt_wb;
    output wire [3:0] writeRegSel_wb;
    output wire [15:0] instruction_wb, immExt_wb, read1Data_wb;
    output wire br_contr_wb, jump_wb, jumpImm_wb, instr_mem_align_err_wb, data_mem_align_err_wb;

    wire br_contr_mw_int, jump_mw_int, jumpImm_mw_int, instr_mem_align_err_mw_int, data_mem_align_err_mw_int, memToReg_mw_int, link_mw_int, regWrite_mw_int, halt_mw_int;
    wire [3:0] writeRegSel_mw_int;
    wire [15:0] immExt_mw_int, read1Data_mw_int, instruction_mw_int, PC_mw_int, readData_mw_int, aluOut_mw_int;
    // wire regWrite_mw_int;


    assign immExt_mw_int = (disableMEMWBWrite) ? 16'hffff : immExt_m;
    register iIMMEXT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(immExt_mw_int), .readData(immExt_wb));

    assign read1Data_mw_int = (disableMEMWBWrite) ? 16'hffff : read1Data_m;
    register iREAD1DATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read1Data_mw_int), .readData(read1Data_wb));

    assign br_contr_mw_int = (disableMEMWBWrite) ? 1'b0 : br_contr_m;
    register #(.REGISTER_WIDTH(1)) iBR_CONTR_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(br_contr_mw_int), .readData(br_contr_wb));

    assign jump_mw_int = (disableMEMWBWrite) ? 1'b0 : jump_m;
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jump_mw_int), .readData(jump_wb));

    assign jumpImm_mw_int = (disableMEMWBWrite) ? 1'b0 : jumpImm_m;
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jumpImm_mw_int), .readData(jumpImm_wb));

    assign instr_mem_align_err_mw_int = (disableMEMWBWrite) ? 1'b0 : instr_mem_align_err_m;
    register #(.REGISTER_WIDTH(1)) iINSTR_MEM_ALIGN_ERR_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instr_mem_align_err_mw_int), .readData(instr_mem_align_err_wb));

    assign data_mem_align_err_mw_int = (disableMEMWBWrite) ? 1'b0 : data_mem_align_err_m;
    register #(.REGISTER_WIDTH(1)) iDATA_MEM_ALIGN_ERR_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_mem_align_err_mw_int), .readData(data_mem_align_err_wb));


    assign instruction_mw_int = (disableMEMWBWrite) ? 16'b0000_1000_0000_0000 : instruction_m;
    register iINSTRUCTION_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_mw_int), .readData(instruction_wb));


    assign PC_mw_int = (disableMEMWBWrite) ? 16'hffff : PC_m;
    register iPC_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PC_mw_int), .readData(PC_wb));

    assign readData_mw_int = (disableMEMWBWrite) ? 16'hffff : readData_m;
    register iREADDATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(readData_mw_int), .readData(readData_wb));  // use ~disableMEMWBWrite for writeEn?
    
    assign aluOut_mw_int = (disableMEMWBWrite) ? 16'hffff : aluOut_m;
    register iALUOUT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_mw_int), .readData(aluOut_wb));
    
    
    assign memToReg_mw_int = (disableMEMWBWrite) ? 1'b0 : memToReg_m;
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_mw_int), .readData(memToReg_wb));
    
    assign link_mw_int = (disableMEMWBWrite) ? 1'b0 : link_m;
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_mw_int), .readData(link_wb));

    assign regWrite_mw_int = (disableMEMWBWrite) ? 1'b0 : regWrite_m & ~(halt_m | instr_mem_align_err_m | data_mem_align_err_mw_int);
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_mw_int), .readData(regWrite_wb));
    
    assign halt_mw_int = (disableMEMWBWrite) ? 1'b0 : halt_m;
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_mw_int), .readData(halt_wb));
    
    assign writeRegSel_mw_int = (disableMEMWBWrite) ? 4'hf : writeRegSel_m;
    register #(.REGISTER_WIDTH(4)) iWRITEREGSEL_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_mw_int), .readData(writeRegSel_wb));

endmodule