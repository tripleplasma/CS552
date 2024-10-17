/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (readData, addr, nextPC, memToReg, link, writeData);

   input    [15:0]   readData;   // Read data from memory
   input    [15:0]   addr;       // ALU output
   input    [15:0]   nextPC;     // Address of the next instruction
                                 // for linking
   input             memToReg;   // Write memory output to reg
   input             link;       // Save PC+2 to reg

   output   [15:0]   writeData;  // Data to be written to register

   // Assign what data gets written to the registers based on control signals
   assign writeData = (link) ? nextPC : ((memToReg) ? readData : addr); 
   
endmodule
`default_nettype wire
