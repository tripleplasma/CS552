/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (addr, writeData, memWrite, memRead, memDump, clk, rst, readData);

   input [15:0]   addr;          // Address to memory
   input [15:0]   writeData;     // Data to write into the ALU
   input          memWrite;      // Controls if memory writes
   input          memRead;       // Controls if memory reads
   input          memDump;       // Dumps the memory to a file
   input          clk;
   input          rst;

   output   [15:0]   readData;   // Read data from memory

   // Enable on reading and writing
   wire enable;
   assign enable = readData | writeData;

   memory2c iMEMORY( // Outputs
                     .data_out(readData), 
                     // Inputs
                     .data_in(writeData), 
                     .addr(addr), 
                     .enable(enable), 
                     .wr(writeData), 
                     .createdump(memDump), 
                     .clk(clk), 
                     .rst(rst));
   
endmodule
`default_nettype wire
