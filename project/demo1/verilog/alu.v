/*
   CS/ECE 552 Spring '22
  
   Filename        : alu.v
   Description     : This module does the arthmetic for the processor.
*/
module alu (InA, InB, Oper, Out, zf, sf, of, cf);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH-1:0]  InA ; // Input operand A
    input  [OPERAND_WIDTH-1:0]  InB ; // Input operand B
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    output [OPERAND_WIDTH-1:0]  Out ; // Result of computation
    output                      of  ; // Signal if overflow occured
    output                      sf  ; // Signal if Out is negative or positive
    output                      zf  ; // Signal if Out is 0
    output                      cf  ; // Signal if carry out is 1

    /* YOUR CODE HERE */
    // Intermediate signals
    wire [OPERAND_WIDTH-1:0] A_int, B_int, btr;
    wire [OPERAND_WIDTH-1:0] shift_result, sum, xor_result, andn_result;
    wire [3:0]               ShAmt;
    wire Cin, sign;
    wire [1:0]               shifterOper;

    // SLBI unsigned, rest signed
    assign sign = (Oper == 4'b1111) ? 1'b0 : 1'b1;

    // Invert A and B if specified (for subtraction and ANDN)
    // 2's complement for subtraction, B - A
    assign A_int = (Oper == 4'b0101 | Oper[3:2] == 4'b10) ? ~InA : InA;
    assign Cin = (Oper == 4'b0101 | Oper[3:2] == 4'b10) ? 1'b1 : 1'b0;

    // Invert B for ANDN, 0 for branch instructions
    assign B_int = (Oper == 4'b0111) ? ~InB :
                   (Oper == 4'b1101) ? {OPERAND_WIDTH{1'b0}} : 
                   InB;
    
    // Barrel shifter, shift amount is 8 for SLBI, 4 lower bits of B otherwise
    assign ShAmt = (Oper == 4'b1111) ? 4'b1000 : B_int[3:0];
    // Shift operation is 10 for SLBI, otherise its the lower two bits of the opcode
    assign shifterOper = (Oper == 4'b1111) ? 2'b01 : Oper[1:0];

    shifter iSHIFTER(.In(A_int), .ShAmt(ShAmt), .Oper(shifterOper), .Out(shift_result));
    
    // Arithmetic addition
    cla_16b iCLA_16b(.sum(sum), .c_out(cf),.a(A_int), .b(B_int), .c_in(Cin));
    
    // Bitwise XOR and ANDN
    assign xor_result  = A_int ^ B_int;
    assign andn_result = A_int & B_int;
    
    // Overflow detection
    overflow iOVERFLOW(.A(A_int), .B(B_int), .sum(sum), .carry_out(cf), .Oper(Oper), .sign(sign), .of(Ofl));
    
    // Zero flag
    assign zf = (sum == 16'b0) ? 1'b1 : 1'b0;

    // Sign flag, equal to MSB of output, 1 when negative and 0 when positive
    assign sf = sum[OPERAND_WIDTH-1];

    // Assign bit reversal
    assign btr = {InA[0], InA[1], InA[2], InA[3], InA[4], InA[5], InA[6], InA[7], InA[8], InA[9], InA[10], InA[11], InA[12], InA[13], InA[14], InA[15]};

    // Output mux to select the correct operation result
    assign Out =    (Oper[3] == 0)          ?                           // Check if make use of the functions
                    (Oper[2] == 0)          ? shift_result :            // use barrel shifter
                    (Oper[2:0] == 3'b100)   ? sum :                     // A + B
                    (Oper[2:0] == 3'b101)   ? sum :                     // B - A
                    (Oper[2:0] == 3'b110)   ? xor_result :              // A XOR B
                    andn_result             :                           // A AND ~B, else Oper[3] == 1
                    (Oper[2:0] == 3'b000)   ? {15'b0, zf} :             // Set if A = B
                    (Oper[2:0] == 3'b001)   ? {15'b0, sf} :             // Set if A < B, B - A sign
                    (Oper[2:0] == 3'b010)   ? {15'b0, (zf | sf)} :      // Set if A <= B, B - A sign
                    (Oper[2:0] == 3'b100)   ? {15'b0, cf} :             // Set if A + B generates a carry out
                    (Oper[2:0] == 3'b101)   ? InB :                     // LBI: Out = InB
                    (Oper[2:0] == 3'b110)   ? btr :                     // Reverse the bits
                    (shift_result | InB);                               // SLBI: Rs<<8 | I(zero ext.)
endmodule
