module memory_wb_latch(clk, rst, readData_m, readData_wb, aluOut_m, aluOut_wb, memToReg_m, memToReg_wb, link_m, link_wb, writeRegSel_m, writeRegSel_wb);

    input wire clk, rst;
    input wire [15:0] readData_m, aluOut_m;
    input wire memToReg_m, link_m;
    input wire [2:0] writeRegSel_m;
    output wire [15:0] readData_wb, aluOut_wb;
    output wire memToReg_wb, link_wb;
    output wire [2:0] writeRegSel_wb;

    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(readData_m), .readData(readData_wb));  // use ~nop for writeEn?
    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluOut_m), .readData(aluOut_wb));
    
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_m), .readData(memToReg_wb));
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_DE1(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_m), .readData(link_wb));
    
    register #(.REGISTER_WIDTH(3)) iBRANCH_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_m), .readData(writeRegSel_wb));

endmodule