/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (read1Data, read2Data, aluOp, aluSrc, immExt, aluOut_m, aluOut_wb, exExForward1, exExForward2, memExForward1, memExForward2, aluOut, zf, sf, of, cf);

   input wire [15:0]   read1Data;     // input wire operand A
   input wire [15:0]   read2Data;     // output wire of the 2nd read of the register file
   input wire [3:0]    aluOp;
   input wire          aluSrc;        // Indicates if inB to ALU should be the output wire of the register file
                                    // or the output wire of the extension module
   input wire [15:0]   immExt;       // output wire of the immediate extension module
   input wire [15:0]   aluOut_m;    // forwarded value of aluOut from beginning of memory
   input wire [15:0]   aluOut_wb;    // forwarded value of aluOut from beginning of wb
   input wire exExForward1, exExForward2, memExForward1, memExForward2; // forwardiing signals
   
   output wire   [15:0]   aluOut;  // ALU output wire value
   output wire   sf; // Signal if Out is negative or positive
   output wire   zf; // Signal if Out is 0
   output wire   of; // Signal if overflow occured
   output wire   cf; // Signal if carry out is 1

   // A and B input wires to ALU
   wire [15:0] InA;
   wire [15:0] InB;

   // Assign I nA based on if forwarded value is needed
   assign InA = (exExForward1) ? aluOut_m : 
                (memExForward1) ? aluOut_wb : 
                read1Data;

   // Assign InB based on aluSrc value
   assign InB = (aluSrc) ? immExt : 
                (exExForward2) ? aluOut_m : 
                (memExForward2) ? aluOut_wb : 
                read2Data;

   

   // Create the ALU
   alu #(.NUM_OPERATIONS(4))
      iALU(// input wires
         .InA(InA), 
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
