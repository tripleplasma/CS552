module fulladder4 (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] S,
    output       Cout
);

wire Cout0, Cout1, Cout2;

fulladder1 fulladder0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(Cout0));
fulladder1 fulladder1(.A(A[1]), .B(B[1]), .Cin(Cout0), .S(S[1]), .Cout(Cout1));
fulladder1 fulladder2(.A(A[2]), .B(B[2]), .Cin(Cout1), .S(S[2]), .Cout(Cout2));
fulladder1 fulladder3(.A(A[3]), .B(B[3]), .Cin(Cout2), .S(S[3]), .Cout(Cout));

endmodule