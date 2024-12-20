/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (readData, addr, nextPC, memToReg, link, instr_mem_align_err, data_mem_align_err, halt, writeData, haltxout);

   input wire    [15:0]   readData;   // Read data from memory
   input wire    [15:0]   addr;       // ALU output wire
   input wire    [15:0]   nextPC;     // Address of the next instruction
                                 // for linking
   input wire             memToReg;   // Write memory output wire to reg
   input wire             link;       // Save PC+2 to reg
   input wire             instr_mem_align_err, data_mem_align_err, halt;

   output wire   [15:0]   writeData;  // Data to be written to register
   output wire            haltxout;

   // Assign what data gets written to the registers based on control signals
   assign writeData = (link) ? nextPC : ((memToReg) ? readData : addr); 
   assign haltxout = halt | instr_mem_align_err | data_mem_align_err;
   
endmodule
`default_nettype wire
