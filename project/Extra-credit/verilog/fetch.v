/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch ( clk, rst, hazard, setFetchNOP, PC_2_br, br_extend,
               halt_sig, jump_imm_sig, jump_sig, except_sig, br_contr_sig, 
               imm_jump_reg_val, extend_val, predict_taken, taken_flush, PC_e,
               PC_2, instr, output_clk);
   input wire clk;
   input wire rst;

   input wire hazard, setFetchNOP, predict_taken, taken_flush;
   input wire [15:0] PC_2_br, br_extend, PC_e;
   input wire halt_sig;
   input wire jump_imm_sig;
   input wire jump_sig;
   input wire except_sig;
   input wire br_contr_sig; //This will come from branch control that has the bne, beq,

   input wire [15:0] imm_jump_reg_val; //The jump value from Rs
   input wire [15:0] extend_val;

   output wire [15:0] instr;
   output wire output_clk;

   output wire [15:0] PC_2;
   wire [15:0] pcCurrent;
   // wire[15:0] EPC = 16'b0;
   wire [15:0] nextPC;
   wire [15:0] instr_int;

   register PC(.clk(output_clk), .rst(rst), .writeEn(1'b1), .writeData(nextPC), .readData(pcCurrent));
   
   // increment PC
   cla_16b iPC_ADDER(.sum(PC_2), .c_out(), .a(pcCurrent), .b(16'd2), .c_in(1'b0));
   
   // wire[15:0] disp_jump;
   // Don't think we use since different from MIPS, we do relative jumping
   // wire[15:0] PC_jump_Imm = {PC_2[15:9], (instr[7:0]<<1)};

   wire[15:0] extend_imm_jump_reg_val;
   wire[15:0] extend_PC_2, br_extend_PC_2;
   wire[15:0] br_extend_taken = (predict_taken) ? {{8{instr_int[7]}}, instr_int[7:0]} : br_extend;
   wire[15:0] br_extend_PC_2_taken = (predict_taken) ? PC_2 : PC_2_br;
   cla_16b iJUMP_EXTEND(.sum(extend_imm_jump_reg_val), .c_out(), .a(imm_jump_reg_val), .b(extend_val), .c_in(1'b0));
   cla_16b iBR_EXTEND(.sum(br_extend_PC_2), .c_out(), .a(br_extend_PC_2_taken), .b(br_extend_taken), .c_in(1'b0));
   cla_16b iPC_EXTEND(.sum(extend_PC_2), .c_out(), .a(PC_2), .b(extend_val), .c_in(1'b0));

   wire[15:0] jump_imm_addr = jump_imm_sig ? extend_imm_jump_reg_val : extend_PC_2; 
   wire[15:0] br_imm_addr = (br_contr_sig & ~predict_taken) ? br_extend_PC_2 : PC_2;

   wire[15:0] addr_pre_exception = jump_sig ? jump_imm_addr : br_imm_addr;

   //output_clk is for managing the Halt instruction
   assign output_clk = halt_sig ? 1'b0 : clk;
   // assign nextPC = rst ? 16'b0 : (except_sig ? 16'h02 : addr_pre_exception);
   assign nextPC = (rst) ? 16'b0 : (taken_flush ? PC_e : ((hazard) ? pcCurrent : (predict_taken & (instr_int[15:13] == 3'b011)) ? br_extend_PC_2 : addr_pre_exception));
   // assign EPC = except_sig ? PC_2 : EPC;

   assign instr = (setFetchNOP) ? 16'b0000_1000_0000_0000 : instr_int;
   memory2c instr_mem(.data_out(instr_int), .data_in(16'b0), .addr(pcCurrent), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(output_clk), .rst(rst));

endmodule
`default_nettype wire
