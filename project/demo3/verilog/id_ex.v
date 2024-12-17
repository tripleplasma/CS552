module id_ex  (
   input clk,
   input rst,
   input wire           halt_fetch,
   input wire [15:0]    pc_out,				//PC to X
   input wire [15:0]    read_data1,
   input wire [15:0]    read_data2,
   input wire [15:0]    imm5_ext,
   input wire [15:0]    imm8_ext,
   input wire [15:0]    imm11_ext,
   input wire [15:0]    instruction,
   input wire           ImmSrc,				
   input wire [1:0]     BSrc,				
   input wire [1:0]     RegSrc,			
   input wire [1:0]     Instr_Funct_out,	// Instruction[1:0]
   input wire [1:0]     Instr_BrchCnd_sel,  // Instruction[12:11] 
   input wire [3:0]     ALUOp,
   input wire           InvA,
   input wire           InvB,
   input wire           MemWrt,
   input wire			RegWrt,
   input wire [2:0]		writeRegSel,
   input wire           Branch,
   input wire           Set, 
   input wire           Sub,
   input wire           MemEn,
   input wire           ALUJmp,
   input wire           SLBI,
   input wire			halt,
   input wire           btr,
   input wire		    jmp,
   input wire           flush_in,
   input wire [2:0]     RegisterRs,
   input wire [2:0]     RegisterRt,
   input wire           stall_mem_stg,
   output wire          halt_fetch_q,
   output wire [15:0]   pc_out_q,				//PC to X
   output wire [15:0]   read_data1_q,
   output wire [15:0]   read_data2_q,
   output wire [15:0]   imm5_ext_q,
   output wire [15:0]   imm8_ext_q,
   output wire [15:0]   imm11_ext_q,
   output wire [15:0]   instruction_q,
   output wire          ImmSrc_q,				
   output wire [1:0]    BSrc_q,				
   output wire [1:0]    RegSrc_q,			
   output wire [1:0]    Instr_Funct_out_q,	  // Instruction[1:0]
   output wire [1:0]    Instr_BrchCnd_sel_q,  // Instruction[12:11] 
   output wire [3:0]    ALUOp_q,
   output wire          InvA_q,
   output wire          InvB_q,
   output wire          MemWrt_q,
   output wire			RegWrt_q,
   output wire [2:0]	writeRegSel_q,
   output wire          Branch_q,
   output wire          Set_q, 
   output wire          Sub_q,
   output wire          MemEn_q,
   output wire          ALUJmp_q,
   output wire          SLBI_q,
   output wire			halt_q,
   output wire          btr_q,
   output wire			jmp_q,
   output wire [2:0]    RegisterRs_q,
   output wire [2:0]    RegisterRt_q
);

//flush out contents when flush is high
dff halt_fetch_ff                   (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_fetch_q : halt_fetch), .q(halt_fetch_q)); 
dff pc_out_ff               [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? pc_out_q : pc_out), .q(pc_out_q));
dff read_data1_ff           [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? read_data1_q : read_data1), .q(read_data1_q));
dff read_data2_ff           [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? read_data2_q : read_data2), .q(read_data2_q));
dff imm5_ext_ff             [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? imm5_ext_q : imm5_ext), .q(imm5_ext_q));
dff imm8_ext_ff             [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? imm8_ext_q : imm8_ext), .q(imm8_ext_q));
dff imm11_ext_ff            [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? imm11_ext_q : imm11_ext), .q(imm11_ext_q));
dff instruction_ff          [15:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? instruction_q : flush_in ? 16'b0 : instruction), .q(instruction_q));
dff BSrc_ff                 [1:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? BSrc_q : flush_in ? 2'b0 : BSrc), .q(BSrc_q));
dff RegSrc_ff               [1:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegSrc_q : flush_in ? 2'b0 : RegSrc), .q(RegSrc_q));
dff Instr_Funct_out_ff      [1:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? Instr_Funct_out_q : flush_in ? 2'b0 : Instr_Funct_out), .q(Instr_Funct_out_q));
dff Instr_BrchCnd_sel_ff    [1:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? Instr_BrchCnd_sel_q : flush_in ? 2'b0 : Instr_BrchCnd_sel), .q(Instr_BrchCnd_sel_q));
dff ALUOp_ff                [3:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? ALUOp_q : flush_in ? 4'b0 : ALUOp), .q(ALUOp_q));
dff ImmSrc_ff                       (.clk(clk), .rst(rst), .d(stall_mem_stg ? ImmSrc_q : flush_in ? 1'b0 : ImmSrc), .q(ImmSrc_q));
dff writeRegSel_ff          [2:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? writeRegSel_q : writeRegSel), .q(writeRegSel_q));
dff RegisterRs_ff           [2:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegisterRs_q : RegisterRs), .q(RegisterRs_q));
dff RegisterRt_ff           [2:0]   (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegisterRt_q : RegisterRt), .q(RegisterRt_q));

dff InvA_ff                 (.clk(clk), .rst(rst), .d(stall_mem_stg ? InvA_q : flush_in ? 1'b0 : InvA),          .q(InvA_q));
dff InvB_ff                 (.clk(clk), .rst(rst), .d(stall_mem_stg ? InvB_q : flush_in ? 1'b0 : InvB),          .q(InvB_q));
dff MemWrt_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? MemWrt_q : flush_in ? 1'b0 : MemWrt),        .q(MemWrt_q));
dff Branch_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? Branch_q : flush_in ? 1'b0 : Branch),        .q(Branch_q));
dff RegWrt_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegWrt_q : flush_in ? 1'b0 : RegWrt),        .q(RegWrt_q));
dff Set_ff                  (.clk(clk), .rst(rst), .d(stall_mem_stg ? Set_q : flush_in ? 1'b0 : Set),           .q(Set_q));
dff Sub_ff                  (.clk(clk), .rst(rst), .d(stall_mem_stg ? Sub_q : flush_in ? 1'b0 : Sub),           .q(Sub_q));
dff MemEn_ff                (.clk(clk), .rst(rst), .d(stall_mem_stg ? MemEn_q : flush_in ? 1'b0 : MemEn),         .q(MemEn_q));
dff ALUJmp_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? ALUJmp_q : flush_in ? 1'b0 : ALUJmp),        .q(ALUJmp_q));
dff SLBI_ff                 (.clk(clk), .rst(rst), .d(stall_mem_stg ? SLBI_q : flush_in ? 1'b0 : SLBI),          .q(SLBI_q));
dff halt_ff                 (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_q : flush_in ? 1'b0 : halt),          .q(halt_q));
dff btr_ff                  (.clk(clk), .rst(rst), .d(stall_mem_stg ? btr_q : flush_in ? 1'b0 : btr),           .q(btr_q));
dff jmp_ff                  (.clk(clk), .rst(rst), .d(stall_mem_stg ? jmp_q : flush_in ? 1'b0 : jmp),           .q(jmp_q));

endmodule                                             