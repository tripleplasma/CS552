/* Filename: overflow.v
 * Description: determines if an overflow occurred through either signed or unsigned addition
 * Author: Khiem Vu
 */
module overflow(A, B, sum, carry_out, Oper, sign, of);

    input [15:0] A;
    input [15:0] B;
    input [15:0] sum;
    input        carry_out;
    input [2:0]  Oper;
    input        sign;
    output       of;
    
    // intermediate signals
    wire signed_overflow, unsigned_overflow;
    
    // Overflow detection for signed addition
    assign signed_overflow = (Oper == 3'b100 & sign) ? ((A[15] & B[15] & ~sum[15]) | (~A[15] & ~B[15] & sum[15])) : 1'b0;

    // Overflow detection for unsigned addition (check carry out from MSB)
    assign unsigned_overflow = (Oper == 3'b100 & ~sign) ? carry_out : 1'b0;

    // Combine signed and unsigned overflow detection
    assign of = signed_overflow | unsigned_overflow;

endmodule