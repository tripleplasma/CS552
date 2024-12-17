/* Filename: fulladder4.v
 
Description: This design will add two 4-bit vectors plus a carry in to produce a sum and a carry out
Author: Khiem Vu
*/

module fulladder4(A, B, Cin, S, Cout);

    input[3:0] A,B; // two 4-bit vectors to be added
    input Cin;      // An optional carry in bit
    output[3:0] S;  // 4-bit Sum
    output Cout;    // carry out

    // carry intermediates
    wire C1, C2, C3;

    // ripple carry adder implementation
    fulladder1 iFULL_ADDER1_0(.a(A[0]), .b(B[0]), .c_in(Cin), .s(S[0]), .c_out(C1));
    fulladder1 iFULL_ADDER1_1(.a(A[1]), .b(B[1]), .c_in(C1), .s(S[1]), .c_out(C2));
    fulladder1 iFULL_ADDER1_2(.a(A[2]), .b(B[2]), .c_in(C2), .s(S[2]), .c_out(C3));
    fulladder1 iFULL_ADDER1_3(.a(A[3]), .b(B[3]), .c_in(C3), .s(S[3]), .c_out(Cout));

endmodule