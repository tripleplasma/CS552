/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (addr, writeData, memWrite, memRead, memDump, clk, rst, readData);

   input wire [15:0]   addr;          // Address to memory
   input wire [15:0]   writeData;     // Data to write into the ALU
   input wire          memWrite;      // Controls if memory writes
   input wire          memRead;       // Controls if memory reads
   input wire          memDump;       // Dumps the memory to a file
   input wire          clk;
   input wire          rst;

   output wire   [15:0]   readData;   // Read data from memory

   // Enable on reading and writing
   wire enable;
   assign enable = readData | writeData;

   memory2c iMEMORY( // output wires
                     .data_out(readData), 
                     // input wires
                     .data_in(writeData), 
                     .addr(addr), 
                     .enable(enable), 
                     .wr(writeData), 
                     .createdump(memDump), 
                     .clk(clk), 
                     .rst(rst));
   
endmodule
`default_nettype wire
