module mem_wb_latch (clk, rst, 
         RegSrcSel_m, RegWrtSel_m, writeRegSel_m, 
         read_data_m, PC_m, exec_out_m, imm8_ext_m, instruction_m, 
         halt_fetch_m, dataMem_stall, done_mem, halt_m, 
         RegSrcSel_wb, RegWrtSel_wb, writeRegSel_wb, read_data_wb, PC_wb, exec_out_wb, imm8_ext_wb, instruction_wb, halt_fetch_q, halt_q
);
input wire		    clk;
input wire		    rst;
input wire  [1:0]	RegSrcSel_m;
input wire			RegWrtSel_m;
input wire  [2:0]	writeRegSel_m;
input wire  [15:0]   read_data_m;
input wire  [15:0]   PC_m;
input wire  [15:0]   exec_out_m;
input wire  [15:0]   imm8_ext_m;
input wire  [15:0]  instruction_m;
input wire           halt_fetch_m;
input wire           dataMem_stall;
input wire           done_mem;
input wire           halt_m;
output wire [1:0]	RegSrcSel_wb;
output wire			RegWrtSel_wb;
output wire [2:0]	writeRegSel_wb;
output wire [15:0]   read_data_wb;
output wire [15:0]   PC_wb;
output wire [15:0]   exec_out_wb;
output wire [15:0]   imm8_ext_wb;
output wire [15:0]   instruction_wb;
output wire          halt_fetch_q;
output wire          halt_q;

register #(.REGISTER_WIDTH(1)) ihalt(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(halt_m), .readData(halt_q));

register #(.REGISTER_WIDTH(1)) ihalt_fetch(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(halt_fetch_m), .readData(halt_fetch_q));

register #(.REGISTER_WIDTH(2)) iregsrcsel(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(RegSrcSel_m), .readData(RegSrcSel_wb));

register #(.REGISTER_WIDTH(1)) iregwrtsel(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(RegWrtSel_m), .readData(RegWrtSel_wb));

register #(.REGISTER_WIDTH(3)) iwriteregsel(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(writeRegSel_m), .readData(writeRegSel_wb));

register ireadData(.clk(clk), .rst(rst), .writeEn(~(dataMem_stall & ~done_mem)), .writeData(read_data_m), .readData(read_data_wb));

register iPCWB(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(PC_m), .readData(PC_wb));

register iexecOut(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(exec_out_m), .readData(exec_out_wb));

register iImm8Ext(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(imm8_ext_m), .readData(imm8_ext_wb));

register iinstructionWB(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(instruction_m), .readData(instruction_wb));

endmodule
