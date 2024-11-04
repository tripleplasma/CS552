/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (readData, addr, nextPC, memToReg, link, exception, writeData);

   input wire    [15:0]   readData;   // Read data from memory
   input wire    [15:0]   addr;       // ALU output wire
   input wire    [15:0]   nextPC;     // Address of the next instruction
                                 // for linking
   input wire             memToReg;   // Write memory output wire to reg
   input wire             link;       // Save PC+2 to reg
   input wire             exception;   // if exception occurs, write 0xBADD

   output wire   [15:0]   writeData;  // Data to be written to register

   // Assign what data gets written to the registers based on control signals
   assign writeData =   (exception) ? 16'hBADD : 
                        (link) ? nextPC : 
                        (memToReg) ? readData : 
                        addr; 
   
endmodule
`default_nettype wire
