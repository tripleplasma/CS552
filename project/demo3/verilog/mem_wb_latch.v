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
   output wire [1:0]	RegSrcSel_wb,
   output wire			RegWrtSel_wb,
   output wire [2:0]	writeRegSel_wb,
   output wire [15:0]   read_data_wb,
   output wire [15:0]   PC_wb,
   output wire [15:0]   exec_out_wb,
   output wire [15:0]   imm8_ext_wb,
   output wire [15:0]   instruction_wb,
   output wire          halt_fetch_q,
   output wire          halt_q
);

dff halt_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? halt_q : halt_m), .q(halt_q));
// register ihalt(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(halt_m), .readData(halt_q));

dff halt_fetch_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? halt_fetch_q : halt_fetch_m), .q(halt_fetch_q));
dff RegSrc__ff [1:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? RegSrcSel_wb : RegSrcSel_m), .q(RegSrcSel_wb));
dff RegWrt_ff (.clk(clk), .rst(rst), .d(dataMem_stall ? RegWrtSel_wb : RegWrtSel_m), .q(RegWrtSel_wb));
dff writeRegSel_ff [2:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? writeRegSel_wb : writeRegSel_m), .q(writeRegSel_wb));
dff read_data_ff [15:0] (.clk(clk), .rst(rst), .d(done_mem ? read_data_m : dataMem_stall ? read_data_wb : read_data_m), .q(read_data_wb));
dff pc_out_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? PC_wb : PC_m), .q(PC_wb));
dff exec_out_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? exec_out_wb : exec_out_m), .q(exec_out_wb));
dff imm8_ext_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? imm8_ext_wb : imm8_ext_m), .q(imm8_ext_wb));
dff instruction_ff [15:0] (.clk(clk), .rst(rst), .d(dataMem_stall ? instruction_wb : instruction_m), .q(instruction_wb));

endmodule
