module memory_wb_latch(clk, rst, 
                        PC_m, PC_wb, 
                        readData_m, readData_wb, aluOut_m, aluOut_wb, memToReg_m, memToReg_wb, 
                        link_m, link_wb, writeRegSel_m, writeRegSel_wb, regWrite_m, regWrite_wb, halt_m, halt_wb,
                        instruction_m, instruction_wb,
                        immExt_m, immExt_wb,
                        read1Data_m, read1Data_wb,
                        br_contr_m, br_contr_wb,
                        jump_m, jump_wb,
                        jumpImm_m, jumpImm_wb,
                        align_err_fetch_m, align_err_fetch_wb,
                        align_err_memory_m, align_err_memory_wb);

    input wire clk, rst;
    input wire [15:0] PC_m, readData_m, aluOut_m;
    input wire memToReg_m, link_m, regWrite_m, halt_m;
    input wire [3:0] writeRegSel_m;
    input wire [15:0] instruction_m, immExt_m, read1Data_m;
    input wire br_contr_m, jump_m, jumpImm_m, align_err_fetch_m, align_err_memory_m;
    output wire [15:0] PC_wb, readData_wb, aluOut_wb;
    output wire memToReg_wb, link_wb, regWrite_wb, halt_wb;
    output wire [3:0] writeRegSel_wb;
    output wire [15:0] instruction_wb, immExt_wb, read1Data_wb;
    output wire br_contr_wb, jump_wb, jumpImm_wb, align_err_fetch_wb, align_err_memory_wb;

    register iIMMEXT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(immExt_m), .readData(immExt_wb));
    register iREAD1DATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read1Data_m), .readData(read1Data_wb));
    register #(.REGISTER_WIDTH(1)) iBR_CONTR_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(br_contr_m), .readData(br_contr_wb));
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jump_m), .readData(jump_wb));
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jumpImm_m), .readData(jumpImm_wb));
    register #(.REGISTER_WIDTH(1)) iALIGN_ERR_FETCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(align_err_fetch_m), .readData(align_err_fetch_wb));
    register #(.REGISTER_WIDTH(1)) iALIGN_ERR_MEMORY_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(align_err_memory_m), .readData(align_err_memory_wb));

    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_m), .readData(instruction_wb));

    register iPC_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PC_m), .readData(PC_wb));
    register iREADDATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(readData_m), .readData(readData_wb));  // use ~nop for writeEn?
    register iALUOUT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_m), .readData(aluOut_wb));
    
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_m), .readData(memToReg_wb));
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_m), .readData(link_wb));
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_m), .readData(regWrite_wb));
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_m), .readData(halt_wb));
    
    register #(.REGISTER_WIDTH(4)) iWRITEREGSEL_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_m), .readData(writeRegSel_wb));

endmodule