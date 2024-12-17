module rot_right (In, ShAmt, Out);
	input [15:0] In;
	input [3:0] ShAmt;
	output [15:0] Out;

	wire [15:0] mux_a, mux_b, mux_c;

	assign mux_a = ShAmt[3] ? {In[7:0], In[15:8]} : In;
	assign mux_b = ShAmt[2] ? {mux_a[3:0], mux_a[15:4]} : mux_a;
	assign mux_c = ShAmt[1] ? {mux_b[1:0], mux_b[15:2]} : mux_b;
	assign Out = ShAmt[0] ? {mux_c[0], mux_c[15:1]} : mux_c;

endmodule
