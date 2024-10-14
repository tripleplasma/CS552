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
module alu (InA, InB, Cin, Oper, sign, Out, zf, sf, of, cf);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH-1:0]  InA ; // Input operand A
    input  [OPERAND_WIDTH-1:0]  InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH-1:0]  Out ; // Result of computation
    output                      of  ; // Signal if overflow occured
    output                      sf  ; // Signal if Out is negative or positive
    output                      zf  ; // Signal if Out is 0
    output                      cf  ; // Signal if carry out is 1

    /* YOUR CODE HERE */
    // Intermediate signals
    wire [OPERAND_WIDTH-1:0] A_int, B_int;
    wire [OPERAND_WIDTH-1:0] shift_result, sum, xor_result, andn_result;
    wire [3:0]               ShAmt;
    
    // Invert A and B if specified (for subtraction and ANDN)
    assign A_int = (Oper == 3'b0101) ? ~InA : InA;
    assign B_int = (Oper == 3'b0111 || Oper == 3'b10XX) ? ~InB : InB;
    
    // Barrel shifter, shift amount is 8 for SLBI, 4 lower bits of B otherwise
    assign ShAmt = (Oper == 4'b1100) ? 4'b1000 : B_int[3:0];
    shifter iSHIFTER(.InA(A_int), .ShAmt(ShAmt), .Oper(Oper[1:0]), .Out(shift_result));
    
    // Arithmetic addition
    cla_16b iCLA_16b(.sum(sum), .c_out(cf),.a(A_int), .b(B_int), .c_in(Cin));
    
    // Bitwise XOR and ANDN
    assign xor_result  = A_int ^ B_int;
    assign andn_result = A_int & B_int;
    
    // Overflow detection
    overflow iOVERFLOW(.A(A_int), .B(B_int), .sum(sum), .carry_out(cf), .Oper(Oper), .sign(sign), .of(Ofl));
    
    // Zero flag
    assign zf = (Out == 16'b0) ? 1'b1 : 1'b0;

    // Sign flag, equal to MSB of output
    assign sf = Out[OPERAND_WIDTH-1];

    // Carry flag
    assign cf = carry_out;

    // Assign bit reversal
    wire brt;
    assign brt = {InA[0], InA[1], InA[2], InA[3], InA[4], InA[5], InA[6], InA[7], InA[8], InA[9], InA[10], InA[11], InA[12], InA[13], InA[14], InA[15]};

    // Output mux to select the correct operation result
    assign Out =    (Oper[3] == 0)          ?                           // Check if make use of the functions
                    (Oper[2] == 0)          ? shift_result :            // use barrel shifter
                    (Oper[2:0] == 3'b100)   ? sum :                     // A + B
                    (Oper[2:0] == 3'b101)   ? sum :                     // B - A
                    (Oper[2:0] == 3'b110)   ? xor_result :              // A XOR B
                    andn_result             :                           // A AND ~B, else Oper[3] == 1
                    (Oper[2:0] == 3'b000)   ? zf :                      // Set if A = B
                    (Oper[2:0] == 3'b001)   ? sf :                      // Set if A < B
                    (Oper[2:0] == 3'b010)   ? (zf | sf) :               // Set if A <= B
                    (Oper[2:0] == 3'b100)   ? cf :                      // Set if A + B generates a carry out
                    (Oper[2:0] == 3'b101)   ? InB :                     // LBI: Out = InB
                    (Oper[2:0] == 3'b110)   ? brt :                     // Reverse the bits
                    (Oper[2:0] == 3'b111)   ? (shift_result | InB) :    // SLBI: Rs<<8 | I(zero ext.)
                    ;
endmodule
