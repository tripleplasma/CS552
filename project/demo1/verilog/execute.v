/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (read1Data, read2Data, opcode, extention, aluSrc, immExt, aluOut, zf, sf, of, cf);

   input [15:0]   read1Data;     // Input operand A
   input [15:0]   read2Data;     // Output of the 2nd read of the register file
   input [4:0]    opcode;        // Top 5 bits of instruction
   input [1:0]    extention;     // Bottom 2 bits for R-format instructions
   input          aluSrc;        // Indicates if inB to ALU should be the output of the register file
                                 // or the output of the extention module
   input [15:0]   immExt ;       // Output of the immediate extention module

   
   output   [15:0]   aluOut;  // ALU output value
   output   sf; // Signal if Out is negative or positive
   output   zf; // Signal if Out is 0
   output   of; // Signal if overflow occured
   output   cf; // Signal if carry out is 1

   // Output of ALU control
   wire [3:0] aluOp;
   // B input to ALU
   wire  [15:0] InB;

   // Calculate the ALU opcode with the ALU controle module
   alu_control iALUCONTROL(.*);

   // Assign InB based on aluSrc value
   assign InB = (aluSrc) ? immExt : read2Data;

   // Create the ALU
   alu #(.NUM_OPERATIONS(4)) 
      iALU(// Inputs
         .InA(read1Data), 
         .InB(inB), 
         .Oper(aluOp), 
         // Outputs 
         .Out(aluOut), 
         .zf(zf), 
         .sf(sf),
         .of(of),
         .cf(cf));
   
endmodule
`default_nettype wire
