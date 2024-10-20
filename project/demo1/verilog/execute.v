/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (read1Data, read2Data, aluOp, aluSrc, immExt, aluOut, zf, sf, of, cf);

   input wire [15:0]   read1Data;     // input wire operand A
   input wire [15:0]   read2Data;     // output wire of the 2nd read of the register file
   input wire [3:0]    aluOp;
   input wire          aluSrc;        // Indicates if inB to ALU should be the output wire of the register file
                                 // or the output wire of the extension module
   input wire [15:0]   immExt ;       // output wire of the immediate extension module
   
   output wire   [15:0]   aluOut;  // ALU output wire value
   output wire   sf; // Signal if Out is negative or positive
   output wire   zf; // Signal if Out is 0
   output wire   of; // Signal if overflow occured
   output wire   cf; // Signal if carry out is 1

   // B input wire to ALU
   wire [15:0] InB;

   // Assign InB based on aluSrc value
   assign InB = (aluSrc) ? immExt : read2Data;

   

   // Create the ALU
   alu #(.NUM_OPERATIONS(4)) 
      iALU(// input wires
         .InA(read1Data), 
         .InB(InB), 
         .Oper(aluOp), 
         // output wires 
         .Out(aluOut), 
         .zf(zf), 
         .sf(sf),
         .of(of),
         .cf(cf));
   
endmodule
`default_nettype wire
