module mem_wb (
   input wire		    clk,
   input wire		    rst,
   input wire  [1:0]	RegSrc,
   input wire			RegWrt,
   input wire  [2:0]	writeRegSel,
   input wire  [15:0]   read_data,
   input wire  [15:0]   pc_out,
   input wire  [15:0]   exec_out,
   input wire  [15:0]   imm8_ext,
   input wire  [15:0]  instruction,
   input wire           halt_fetch,
   input wire           stall_mem_stg,
   input wire           done_mem,
   input wire           halt,
   output wire [1:0]	RegSrc_q,
   output wire			RegWrt_q,
   output wire [2:0]	writeRegSel_q,
   output wire [15:0]   read_data_q,
   output wire [15:0]   pc_out_q,
   output wire [15:0]   exec_out_q,
   output wire [15:0]   imm8_ext_q,
   output wire [15:0]   instruction_q,
   output wire          halt_fetch_q,
   output wire          halt_q
);

dff halt_ff (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_q : halt), .q(halt_q));
dff halt_fetch_ff (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_fetch_q : halt_fetch), .q(halt_fetch_q));
dff RegSrc__ff [1:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegSrc_q : RegSrc), .q(RegSrc_q));
dff RegWrt_ff (.clk(clk), .rst(rst), .d(stall_mem_stg ? RegWrt_q : RegWrt), .q(RegWrt_q));
dff writeRegSel_ff [2:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? writeRegSel_q : writeRegSel), .q(writeRegSel_q));
dff read_data_ff [15:0] (.clk(clk), .rst(rst), .d(done_mem ? read_data : stall_mem_stg ? read_data_q : read_data), .q(read_data_q));
dff pc_out_ff [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? pc_out_q : pc_out), .q(pc_out_q));
dff exec_out_ff [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? exec_out_q : exec_out), .q(exec_out_q));
dff imm8_ext_ff [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? imm8_ext_q : imm8_ext), .q(imm8_ext_q));
dff instruction_ff [15:0] (.clk(clk), .rst(rst), .d(stall_mem_stg ? instruction_q : instruction), .q(instruction_q));

endmodule
