module hdu (clk, rst, stall, PCSrc, memRead, regRt_e, ifIdReadRegister1, ifIdReadRegister2, data_hazard, flush);

input wire clk, rst, stall, PCSrc, memRead;
input wire [2:0] regRt_e, ifIdReadRegister1, ifIdReadRegister2;

output wire data_hazard, flush;

wire PCSrc_int1, PCSrc_int2, flush_int1, flush_int2;

// data hazards
assign data_hazard = memRead & ((regRt_e == ifIdReadRegister1) | (regRt_e == ifIdReadRegister2));

// control hazards
register #(.REGISTER_WIDTH(1)) iPCSRC_INT1(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PCSrc), .readData(PCSrc_int1));
register #(.REGISTER_WIDTH(1)) iPCSRC_INT2(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(PCSrc_int1), .readData(PCSrc_int2));

// flush on mispredict
assign flush_int1 = PCSrc | PCSrc_int1 | PCSrc_int2;
register #(.REGISTER_WIDTH(1)) iFLUSH(.clk(clk), .rst(rst), .writeEn(~(stall & flush_int2)), .writeData(flush_int1), .readData(flush_int2));
assign flush = flush_int1 | flush_int2;



endmodule
