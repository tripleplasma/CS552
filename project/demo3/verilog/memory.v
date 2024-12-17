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

   // The NOP we throw in ID-EX have Addr and DataIn of xffff which throws an error in the cache. So we disable reads and writes while this is true
   wire nop = (aluResult == 16'hffff);

   wire[15:0] Addr_nop_check, DataIn_nop_check;
   assign Addr_nop_check = nop ? 16'b0 : aluResult;
   assign DataIn_nop_check = nop ? 16'b0 : writeData;

   mem_system #(1) data_mem(// Outputs
                      .DataOut(readData), 
                      .Done(mem_done), 
                      .Stall(mem_stall), 
                      .CacheHit(mem_cache_hit), 
                      .err(align_err), 
                      // Inputs
                      .Addr(Addr_nop_check), 
                      .DataIn(DataIn_nop_check), 
                      .Rd(memRead & ~nop), // memReadorWrite? don't think so
                      .Wr(memWrite & ~nop), 
                      .createdump(halt), 
                      .clk(clk), 
                      .rst(rst));
   
endmodule
`default_nettype wire
