/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch ( clk, rst, 
               halt_sig, jump_imm_sig, jump_sig, except_sig, br_contr_sig, 
               imm_jump_reg_val, imm_br_val,
               PC_2, instr, output_clk);
   input wire clk;
   input wire rst;

   input wire halt_sig;
   input wire jump_imm_sig;
   input wire jump_sig;
   input wire except_sig;
   input wire br_contr_sig; //This will come from branch control that has the bne, beq,

   input wire [15:0] imm_jump_reg_val; //The jump value when adding Rs with the Jump's Imm
   input wire [15:0] imm_br_val;

   output wire [15:0] instr;
   output wire output_clk;

   output wire [15:0] PC_2;
   // wire[15:0] EPC = 16'b0;
   wire[15:0] pcCurrent;

   register PC(.clk(output_clk), .rst(rst), .writeEn(1'b1), .writeData(nextPC), .readData(pcCurrent));
   
   PC_2 = pcCurrent + 2;
   wire[15:0] PC_jump_Imm = {PC_2[15:9], (instr[7:0]>>1)};

   wire[15:0] jump_imm_addr = jump_imm_sig ? PC_jump_Imm : imm_jump_reg_val; 
   wire[15:0] br_imm_addr = br_contr_sig ? PC_2 + imm_br_val : PC_2;

   wire[15:0] addr_pre_exception = jump_sig ? jump_imm_addr : br_imm_addr;

   //output_clk is for managing the Halt instruction
   assign output_clk = halt_sig ? 1'b0 : clk;
   // assign nextPC = rst ? 16'b0 : (except_sig ? 16'h02 : addr_pre_exception);
   assign nextPC = rst ? 16'b0 : addr_pre_exception;
   // assign EPC = except_sig ? PC_2 : EPC;

   memory2c instr_mem(.data_out(instr), .data_in(16'b0), .addr(pcCurrent), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(output_clk), .rst(rst));
endmodule
`default_nettype wire
