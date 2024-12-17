module shft_right_log (In, ShAmt, Out);
 	input [15:0] In;
	input [3:0] ShAmt;
	output [15:0] Out;

	wire [15:0] mux_a, mux_b, mux_c;

	assign mux_a = ShAmt[3] ? {8'h00, In[15:8]} : In;
	assign mux_b = ShAmt[2] ? {4'h0, mux_a[15:4]} : mux_a;
	assign mux_c = ShAmt[1] ? {2'b00, mux_b[15:2]} : mux_b;
	assign Out = ShAmt[0] ? {1'b0, mux_c[15:1]} : mux_c;

endmodule 
