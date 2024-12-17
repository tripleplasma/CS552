/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (clk, rst, aluResult, writeData, memWrite, memRead, halt, readData, align_err, data_mem_done, data_mem_stall, data_mem_cache_hit);

   input wire          clk;
   input wire          rst;
   input wire [15:0]   aluResult;   // aluResult to memory
   input wire [15:0]   writeData;   // Data to write into the ALU
   input wire          memWrite;    // Controls if memory writes
   input wire          memRead;     // Controls if memory reads
   input wire          halt;        // Dumps the memory to a file

   output wire [15:0]  readData;    // Read data from memory
   output wire         align_err;   // error if unaligned word access occurs
   output wire         data_mem_done;  
   output wire         data_mem_stall;  
   output wire         data_mem_cache_hit;  

   // Enable on reading and writing
   wire memReadorWrite;
   assign memReadorWrite = memWrite | memRead;

   // wire memRead_prev, memRead_int, memWrite_prev, memWrite_int;
   // wire [15:0] aluResult_prev, addr_int, writeData_prev, writeData_int;

   // register #(.REGISTER_WIDTH(1)) iMEMREAD_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memRead), .readData(memRead_prev));
   // register #(.REGISTER_WIDTH(1)) iMEMWRITE_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memWrite), .readData(memWrite_prev));
   // register iALURESULT_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluResult), .readData(aluResult_prev));
   // register iWRITEDATA_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeData), .readData(writeData_prev));

   // assign memRead_int = (data_mem_stall) ? memRead_prev : memRead;
   // assign memWrite_int = (data_mem_stall) ? memWrite_prev : memWrite;
   // assign addr_int = (data_mem_stall) ? aluResult_prev : aluResult;
   // assign writeData_int = (data_mem_stall) ? writeData_prev : writeData;

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
   // mem_system #(1) data_mem(// Outputs
   stallmem data_mem(// Outputs
                      .DataOut(readData), 
                      .Done(data_mem_done), 
                      .Stall(data_mem_stall), 
                      .CacheHit(data_mem_cache_hit), 
                      .err(align_err), 
                      // Inputs
                      .Addr(aluResult), // addr_int
                      .DataIn(writeData), // writeData_int
                      .Rd(memRead), // memRead_int
                      .Wr(memWrite), // memWrite_int
                      .createdump(halt), 
                      .clk(clk), 
                      .rst(rst));
   
endmodule
`default_nettype wire
