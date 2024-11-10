module memory_wb_latch(clk, rst, PC_m, PC_wb, readData_m, readData_wb, aluOut_m, aluOut_wb, memToReg_m, memToReg_wb, link_m, link_wb, writeRegSel_m, writeRegSel_wb, regWrite_m, regWrite_wb, halt_m, halt_wb);

    input wire clk, rst;
    input wire [15:0] PC_m, readData_m, aluOut_m;
    input wire memToReg_m, link_m, regWrite_m, halt_m;
    input wire [2:0] writeRegSel_m;
    output wire [15:0] PC_wb, readData_wb, aluOut_wb;
    output wire memToReg_wb, link_wb, regWrite_wb, halt_wb;
    output wire [2:0] writeRegSel_wb;

    register iPC_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PC_m), .readData(PC_wb));
    register iREADDATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(readData_m), .readData(readData_wb));  // use ~nop for writeEn?
    register iALUOUT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_m), .readData(aluOut_wb));
    
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_m), .readData(memToReg_wb));
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_m), .readData(link_wb));
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_m), .readData(regWrite_wb));
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_m), .readData(halt_wb));
    
    register #(.REGISTER_WIDTH(3)) iWRITEREGSEL_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_m), .readData(writeRegSel_wb));

endmodule