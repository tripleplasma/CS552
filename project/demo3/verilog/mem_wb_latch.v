module mem_wb_latch (
   input wire		    clk,
   input wire		    rst,
   input wire  [1:0]	RegSrcSel_m,
   input wire			RegWrtSel_m,
   input wire  [2:0]	writeRegSel_m,
   input wire  [15:0]   read_data_m,
   input wire  [15:0]   PC_m,
   input wire  [15:0]   exec_out_m,
   input wire  [15:0]   imm8_ext_m,
   input wire  [15:0]  instruction_m,
   input wire           halt_fetch_m,
   input wire           dataMem_stall,
   input wire           done_mem,
   input wire           halt_m,
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

dff halt_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? halt_q : halt_m), .q(halt_q));
dff halt_fetch_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? halt_fetch_q : halt_fetch_m), .q(halt_fetch_q));
dff RegSrc__ff [1:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? RegSrc_q : RegSrcSel_m), .q(RegSrc_q));
dff RegWrt_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? RegWrt_q : RegWrtSel_m), .q(RegWrt_q));
dff writeRegSel_ff [2:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? writeRegSel_q : writeRegSel_m), .q(writeRegSel_q));
dff read_data_ff [15:0] (.clk(clk), .rst(rst), .d(done_mem ? read_data_m : dataMem_stall ? read_data_q : read_data_m), .q(read_data_q));
dff pc_out_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? pc_out_q : PC_m), .q(pc_out_q));
dff exec_out_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? exec_out_q : exec_out_m), .q(exec_out_q));
dff imm8_ext_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? imm8_ext_q : imm8_ext_m), .q(imm8_ext_q));
dff instruction_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? instruction_q : instruction_m), .q(instruction_q));

endmodule
