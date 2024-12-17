module hdu (clk, rst, stall, PCSrc_d, memRead, regRt_e, ifIdReadRegister1, ifIdReadRegister2, 
            data_hazard, flush);

input wire clk, rst;
input wire stall, PCSrc_d, memRead;     
input wire [2:0] regRt_e, ifIdReadRegister1, ifIdReadRegister2;

output wire data_hazard, flush;

wire PCSrc_d_int1, PCSrc_d_int2, flush_int1, flush_int2;

// Data Hazard detection logic
assign data_hazard = memRead & ((regRt_e == ifIdReadRegister1) | (regRt_e == ifIdReadRegister2));

// Control Hazard detection
dff pc_src_ff(.clk(clk), .rst(rst), .d(PCSrc_d), .q(PCSrc_d_int1));
dff pc_src_ff1(.clk(clk), .rst(rst), .d(PCSrc_d_int1), .q(PCSrc_d_int2));

// Assert flush for 3 clock cycles or longer while stalled
assign flush_int1 = PCSrc_d | PCSrc_d_int1 | PCSrc_d_int2;

dff flush_ff(.clk(clk), .rst(rst), .d((stall & flush_int2) ? flush_int2 : flush_int1), .q(flush_int2));

assign flush = flush_int2 | flush_int1;

endmodule
