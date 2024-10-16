/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch ( clk, rst, 
               halt_sig, jump_imm_sig, jump_sig, except_sig, br_contr_sig, 
               imm_jump_val,
               instr, output_clk);
   input clk;
   input rst;

   input halt_sig;
   input jump_imm_sig;
   input jump_sig;
   input except_sig;
   input br_contr_sig; //This will come from branch control that has the bne, beq,

   input imm_jump_val;
   input alu_addr_val;

   output [15:0] instr;
   output output_clk;

   wire[15:0] PC;
   // TODO: 
   // 1. Implement most of the branch/jump logic that doesn't require the ALU
   // 2. Figure out how to read instruction memory and output that as a wire for decode module
   // 3. Figure out the PC and Halt logic

   wire[15:0] PC_2 = PC + 2;
   wire[15:0] PC_Jump_Imm = PC + (imm_jump_val < 1)
   wire[15:0] jump_imm_addr = jump_imm_sig ? alu_addr_val : 16'b0; 

   //output_clk is for managing the Halt instruction
   assign output_clk = halt_sig ? 1'b0 : clk;
   
endmodule
`default_nettype wire
