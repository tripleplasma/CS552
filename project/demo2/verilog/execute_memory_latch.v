module execute_memory_latch(clk, rst, aluOut_e, aluOut_m, read2Data_e, read2Data_m, 
                            memRead_e, memRead_m, memToReg_e, memToReg_m, memWrite_e, memWrite_m, 
                            halt_e, halt_m, link_e, link_m, jumpImm_e, jumpImm_m, jump_e, jump_m, 
                            read1Data_e, read1Data_m, immExt_e, immExt_m);

    input wire clk, rst;
    input wire memRead_e, memToReg_e, memWrite_e, halt_e, link_e, jumpImm_e, jump_e;
    input wire [15:0] aluOut_e, read1Data_e, read2Data_e, immExt_e;
    output wire memRead_m, memToReg_m, memWrite_m, halt_m, link_m, jumpImm_m, jump_m;
    output wire [15:0] aluOut_m, read1Data_m, read2Data_m, immExt_m;

    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(memRead_e), .readData(memRead_m));      // use ~nop for writeEn?
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(memToReg_e), .readData(memToReg_m));
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(memWrite_e), .readData(memWrite_m));
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(halt_e), .readData(halt_m));
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(link_e), .readData(link_m));
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(jumpImm_e), .readData(jumpImm_m));
    register #(REGISTER_WIDTH = 1) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(jump_e), .readData(jump_m));

    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(aluOut_e), .readData(aluOut_m));
    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(read1Data_e), .readData(read1Data_m));
    register iREAD2DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(read2Data_e), .readData(read2Data_m));
    register iIMMEXT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1), .writeData(immExt_e), .readData(immExt_m));

endmodule