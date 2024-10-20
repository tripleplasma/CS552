/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch ( clk, rst, 
               halt_sig, jump_imm_sig, jump_sig, except_sig, br_contr_sig, 
               imm_jump_reg_val, imm_br_val,
               instr, output_clk);
   input clk;
   input rst;

   input halt_sig;
   input jump_imm_sig;
   input jump_sig;
   input except_sig;
   input br_contr_sig; //This will come from branch control that has the bne, beq,

   input imm_jump_reg_val; //The jump value when adding Rs with the Jump's Imm
   input imm_br_val;

   output [15:0] instr;
   output output_clk;

   wire[15:0] PC = 16'b0;
   wire[15:0] ECP = 16'b0;

   //NOTE: do I need to add a clk here to update the PC on every clock cycle?

   wire[15:0] PC_2 = PC + 2;
   wire[15:0] PC_jump_Imm = {PC_2[15:9], (instr[7:0]>>1)};

   wire[15:0] jump_imm_addr = jump_imm_sig ? PC_jump_Imm : imm_jump_reg_val; 
   wire[15:0] br_imm_addr = br_contr_sig ? PC_2 + imm_br_val : PC_2;

   wire[15:0] addr_pre_exception = jump_sig ? jump_imm_addr : br_imm_addr;

   //output_clk is for managing the Halt instruction
   assign output_clk = halt_sig ? 1'b0 : clk;
   assign PC = except_sig ? 16'h02 : addr_pre_exception;
   assign ECP = except_sig ? PC_2 : ECP;

   memory2c instr_mem(.data_out(instr), .addr(PC), .enable(1'b1), .wr(1'b0), .clk(output_clk), .rst(rst));
endmodule
`default_nettype wire
