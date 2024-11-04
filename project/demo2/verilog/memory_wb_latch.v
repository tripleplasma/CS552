module memory_wb_latch(clk, rst, readData_m, readData_wb, aluOut_m, aluOut_wb, memToReg_m, memToReg_wb, link_m, link_wb, writeRegSel_m, writeRegSel_wb, exception_m, exception_wb, regWrite_m, regWrite_wb);

    input wire clk, rst;
    input wire [15:0] readData_m, aluOut_m;
    input wire memToReg_m, link_m, exception_m, regWrite_m;
    input wire [2:0] writeRegSel_m;
    output wire [15:0] readData_wb, aluOut_wb;
    output wire memToReg_wb, link_wb, exception_wb, regWrite_wb;
    output wire [2:0] writeRegSel_wb;

    register iREADDATA_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(readData_m), .readData(readData_wb));  // use ~nop for writeEn?
    register iALUOUT_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_m), .readData(aluOut_wb));
    
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_m), .readData(memToReg_wb));
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_m), .readData(link_wb));
    register #(.REGISTER_WIDTH(1)) iEXCEPTION_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exception_m), .readData(exception_wb));
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_m), .readData(regWrite_wb));
    
    register #(.REGISTER_WIDTH(3)) iWRITEREGSEL_LATCH_MW(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_m), .readData(writeRegSel_wb));

endmodule