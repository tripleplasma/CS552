/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 3

    A wrapper for a multi-bit ALU module combined with clkrst.
*/
module alu_hier(InA, InB, Cin, Oper, sign, Out, zf, sf, of, cf);

    // declare constant for size of inputs, outputs, and operations
    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      zf  ; // Signal if Out is 0
    output                      sf  ; // Signal if Out is negative or positive
    output                      of  ; // Signal if overflow occured
    output                      cf  ; // Signal if carry out is 1

    // clkrst signals
    wire clk;
    wire rst;
    wire err;

    assign err = 1'b0;

    alu #(.OPERAND_WIDTH(OPERAND_WIDTH),
          .NUM_OPERATIONS(NUM_OPERATIONS)) 
        DUT (// Outputs
             .Out(Out),
             .zf(zf),
             .sf(sf),
             .cf(cf),
             .of(of), 
             // Inputs
             .InA(InA),
             .InB(InB), 
             .Cin(Cin), 
             .Oper(Oper), 
             .sign(sign));
   
    clkrst c0(// Outputs
              .clk                       (clk),
              .rst                       (rst),
              // Inputs
              .err                       (err)
              );

endmodule // alu_hier
