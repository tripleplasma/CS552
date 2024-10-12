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
    
    wire [OPERAND_WIDTH-1:0] left_shift_rot_result, shift_right_arith_log_result;

    // shift/rotate left logic
    left_shift_rot iLSR(.In(In), .ShAmt(ShAmt), .Rot(~Oper[0]), .Out(left_shift_rot_result));

    // arithmetic/logical shift right logic
    right_shift_arith_log iRSAL(.In(In), .ShAmt(ShAmt), .Arith(~Oper[0]), .Out(shift_right_arith_log_result));

    // determine if we're shifting left or right
    assign Out = (Oper[1]) ? shift_right_arith_log_result : left_shift_rot_result;

endmodule // shifter