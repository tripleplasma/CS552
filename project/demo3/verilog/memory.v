/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (clk, rst, aluResult, writeData, memWrite, memRead, halt, readData, align_err, mem_done, mem_stall, mem_cache_hit);

   input wire          clk;
   input wire          rst;
   input wire [15:0]   aluResult;   // aluResult to memory
   input wire [15:0]   writeData;   // Data to write into the ALU
   input wire          memWrite;    // Controls if memory writes
   input wire          memRead;     // Controls if memory reads
   input wire          halt;        // Dumps the memory to a file

   output wire [15:0]  readData;    // Read data from memory
   output wire         align_err;   // error if unaligned word access occurs
   output wire         mem_done;  
   output wire         mem_stall;  
   output wire         mem_cache_hit;  

   // Enable on reading and writing
   wire memReadorWrite;
   assign memReadorWrite = memWrite | memRead;

   // memory2c_align iMEMORY( // output wires
   //                   .data_out(readData), 
   //                   .err(align_err),
   //                   // input wires
   //                   .data_in(writeData), 
   //                   .addr(aluResult), 
   //                   .enable(memReadorWrite), 
   //                   .wr(memWrite), 
   //                   .createdump(halt), 
   //                   .clk(clk), 
   //                   .rst(rst));
   stallmem data_mem(// Outputs
                      .DataOut(readData), 
                      .Done(mem_done), 
                      .Stall(mem_stall), 
                      .CacheHit(mem_cache_hit), 
                      .err(align_err), 
                      // Inputs
                      .Addr(aluResult), 
                      .DataIn(writeData), 
                      .Rd(memRead), // memReadorWrite? don't think so
                      .Wr(memWrite), 
                      .createdump(halt), 
                      .clk(clk), 
                      .rst(rst));
   
endmodule
`default_nettype wire
