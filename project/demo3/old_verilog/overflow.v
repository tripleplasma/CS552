/* Filename: overflow.v
 * Description: determines if an overflow occurred through either signed or unsigned addition
 * Author: Khiem Vu
 */
module overflow(A, B, sum, carry_out, Oper, sign, of);

    input [15:0] A;
    input [15:0] B;
    input [15:0] sum;
    input        carry_out;
    input [3:0]  Oper;
    input        sign;
    output       of;
    
    // Check for these Opcodes: 0100, 0101, 1001, 1010, 1100

    // intermediate signals
    wire signed_overflow, unsigned_overflow;
    wire OpcodeCheck = Oper == 4'b0100 | Oper == 4'b0101 | Oper == 4'b1001 | Oper == 4'b1010 | Oper == 4'b1100; 
    // Overflow detection for signed addition
    assign signed_overflow = (OpcodeCheck & sign) ? ((A[15] & B[15] & ~sum[15]) | (~A[15] & ~B[15] & sum[15])) : 1'b0;

    // Overflow detection for unsigned addition (check carry out from MSB)
    assign unsigned_overflow = (OpcodeCheck & ~sign) ? carry_out : 1'b0;

    // Combine signed and unsigned overflow detection
    assign of = signed_overflow | unsigned_overflow;

endmodule