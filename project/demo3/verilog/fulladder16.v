module fulladder16 (
    input  [15:0] A,
    input  [15:0] B,
	input		  Cin,
    output [15:0] S,
    output        Cout
);

wire Cout0, Cout1, Cout2;

fulladder4 fulladder0(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(Cout0));
fulladder4 fulladder1(.A(A[7:4]), .B(B[7:4]), .Cin(Cout0), .S(S[7:4]), .Cout(Cout1));
fulladder4 fulladder2(.A(A[11:8]), .B(B[11:8]), .Cin(Cout1), .S(S[11:8]), .Cout(Cout2));
fulladder4 fulladder3(.A(A[15:12]), .B(B[15:12]), .Cin(Cout2), .S(S[15:12]), .Cout(Cout));

endmodule
