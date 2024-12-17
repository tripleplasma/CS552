module shft_left (In, ShAmt, Out);
	input [15:0] In;
	input [3:0] ShAmt;
	output [15:0] Out;

	wire [15:0] mux_a, mux_b, mux_c;

	assign mux_a = ShAmt[3] ? {In[7:0], 8'h00} : In;
	assign mux_b = ShAmt[2] ? {mux_a[11:0], 4'h0} : mux_a;
	assign mux_c = ShAmt[1] ? {mux_b[13:0], 2'b00} : mux_b;
	assign Out = ShAmt[0] ? {mux_c[14:0], 1'b0} : mux_c;

endmodule 
