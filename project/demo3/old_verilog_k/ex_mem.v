module ex_mem (
   input clk,
   input rst,
   input wire        halt_fetch,
   input wire			halt,
   input wire			PCSrc,
   input wire [15:0]    exec_out,
   input wire [15:0]    pc_jmp_out,
   input wire [15:0]    pc_plus_2,
   input wire [15:0]    instruction,
   input wire           MemEn,
   input wire           MemWrt,
   input wire			RegWrt,
   input wire [2:0]		writeRegSel,
   input wire [15:0]    read_data2,
   input wire [15:0]    imm8_ext,
   input wire [1:0]     RegSrc,
   input wire           flush_in,
   input wire           stall_mem_stg,
   output wire          halt_fetch_q,
   output wire			halt_q,
   output wire			PCSrc_q,
   output wire [15:0]   exec_out_q,
   output wire [15:0]   instruction_q,
   output wire [15:0]   pc_jmp_out_q,
   output wire [15:0]   pc_plus_2_q,
   output wire          MemEn_q,
   output wire          MemWrt_q,
   output wire			RegWrt_q,
   output wire [2:0]	writeRegSel_q,
   output wire [15:0]   read_data2_q,
   output wire [15:0]   imm8_ext_q,
   output wire [1:0]    RegSrc_q
);

dff halt_fetch_ff          (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_fetch_q : halt_fetch), .q(halt_fetch_q)); 
dff halt_ff                (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_q : halt),       .q(halt_q));
dff PCSrc_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? PCSrc_q : PCSrc),      .q(PCSrc_q));
dff exec_out_ff     [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? exec_out_q : exec_out),   .q(exec_out_q));
dff pc_jmp_out_ff   [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? pc_jmp_out_q : pc_jmp_out), .q(pc_jmp_out_q));
dff pc_plus_2_ff    [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? pc_plus_2_q : pc_plus_2),  .q(pc_plus_2_q));
dff instruction_ff  [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? instruction_q : instruction),  .q(instruction_q));
dff MemEn_ff               (.clk(clk), .rst(rst), .d(stall_mem_stg ? MemEn_q : MemEn),      .q(MemEn_q));
dff MemWrt_ff              (.clk(clk), .rst(rst), .d(stall_mem_stg ? MemWrt_q : MemWrt),     .q(MemWrt_q));
dff RegWrt_ff              (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegWrt_q : RegWrt),     .q(RegWrt_q));
dff writeRegSel_ff  [2:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? writeRegSel_q : writeRegSel),.q(writeRegSel_q)); //NO
dff read_data2_ff   [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? read_data2_q : read_data2), .q(read_data2_q)); //NO
dff imm8_ext_ff     [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? imm8_ext_q : imm8_ext),   .q(imm8_ext_q)); //NO
dff RegSrc_ff       [1:0]  (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegSrc_q : RegSrc),     .q(RegSrc_q)); 

endmodule
