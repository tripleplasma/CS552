/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (clk, rst, aluResult, memMemForward, readData_wb, writeData, memWrite, memRead, halt, readData);

   input wire           clk;
   input wire           rst;
   input wire [15:0]    aluResult;     // aluResult to memory
   input wire           memMemForward; // forwarding between load and store
   input wire [15:0]    readData_wb;   // register data to be forwarded
   input wire [15:0]    writeData;     // Data to write into the ALU
   input wire           memWrite;      // Controls if memory writes
   input wire           memRead;       // Controls if memory reads
   input wire           halt;          // Dumps the memory to a file

   output wire [15:0]   readData;   // Read data from memory

   wire [15:0] data_in;

   // Enable on reading and writing
   wire memReadorWrite;
   assign memReadorWrite = memWrite | memRead;

   assign data_in (memMemForward) ? readData_wb : writeData;

   memory2c iMEMORY( // output wires
                     .data_out(readData), 
                     // input wires
                     .data_in(data_in), 
                     .addr(aluResult), 
                     .enable(memReadorWrite), 
                     .wr(memWrite), 
                     .createdump(halt), 
                     .clk(clk), 
                     .rst(rst));
   
endmodule
`default_nettype wire
