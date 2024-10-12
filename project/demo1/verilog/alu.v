/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 3

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input  [OPERAND_WIDTH-1:0]  InA ; // Input operand A
    input  [OPERAND_WIDTH-1:0]  InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH-1:0]  Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0

    /* YOUR CODE HERE */
    // Intermediate signals
    wire [OPERAND_WIDTH-1:0] A_int, B_int;
    wire [OPERAND_WIDTH-1:0] shift_result, sum, and_result, or_result, xor_result;
    wire                     carry_out;
    
    // Invert A and B if specified (for substraction or rotate/shift)
    assign A_int = (invA) ? ~InA : InA;
    assign B_int = (invB) ? ~InB : InB;
    
    // Barrel shifter 
    shifter iSHIFTER(.In(A_int), .ShAmt(B_int[3:0]), .Oper(Oper[1:0]), .Out(shift_result));
    
    // Arithmetic addition
    cla_16b iCLA_16b(.sum(sum), .c_out(carry_out),.a(A_int), .b(B_int), .c_in(Cin));
    
    // Bitwise AND, OR, XOR
    assign and_result = A_int & B_int;
    assign or_result  = A_int | B_int;
    assign xor_result = A_int ^ B_int;
    
    // Overflow detection
    overflow iOVERFLOW(.A(A_int), .B(B_int), .sum(sum), .carry_out(carry_out), .Oper(Oper), .sign(sign), .Ofl(Ofl));
    
    // Zero flag
    assign Zero = (Out == 16'b0) ? 1'b1 : 1'b0;

    // Output mux to select the correct operation result
    assign Out = (Oper[2] == 0)   ? shift_result :  // use barrel shifter
                 (Oper == 3'b100) ? sum :           // A + B
                 (Oper == 3'b101) ? and_result :    // A AND B
                 (Oper == 3'b110) ? or_result :     // A OR B
                 xor_result;                        // A XOR B
endmodule
