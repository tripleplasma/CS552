/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 2
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

   /* YOUR CODE HERE */

	wire [15:0] rl_out, sl_out, rr_out, srl_out;
	
	rot_left rl (.In(In), .ShAmt(ShAmt), .Out(rl_out));
	shft_left sl (.In(In), .ShAmt(ShAmt), .Out(sl_out));
	rot_right rr (.In(In), .ShAmt(ShAmt), .Out(rr_out));
	shft_right_log srl (.In(In), .ShAmt(ShAmt), .Out(srl_out));

	assign Out = Oper[1] ? (Oper[0] ? srl_out : rr_out) : (Oper[0] ? sl_out : rl_out);
   
endmodule
