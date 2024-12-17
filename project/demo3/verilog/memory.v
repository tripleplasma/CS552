/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (clk, rst, mem_en,
               write_en, addr_in,
               write_data_in, stall_out, done_out, halt_mem, read_data
);
input  wire          clk;
input  wire          rst;
input  wire          mem_en;
input  wire          write_en;
input  wire [15:0]   addr_in;
input  wire [15:0]   write_data_in;
output wire          stall_out;
output wire          done_out;
output wire          halt_mem;
output wire [15:0]   read_data;

//Required downward paths
wire done, stall, cache_hit;
assign stall_out = stall;
assign done_out = done;

wire [15:0] addr_in_delayed, write_data_in_delayed;
wire write_en_delayed, mem_en_delayed;

register #(.REGISTER_WIDTH(1)) iwriteEn(.clk(clk), .rst(rst), .writeEn(~stall_out), .writeData(write_en), .readData(write_en_delayed));

register #(.REGISTER_WIDTH(1)) imemEn(.clk(clk), .rst(rst), .writeEn(~stall_out), .writeData(mem_en), .readData(mem_en_delayed));

register addr(.clk(clk), .rst(rst), .writeEn(~stall_out), .writeData(addr_in), .readData(addr_in_delayed));

register writeData(.clk(clk), .rst(rst), .writeEn(~stall_out), .writeData(write_data_in), .readData(write_data_in_delayed));

wire readMem, writeMem;
wire [15:0] addr_mem, data_in_mem;

assign readMem = stall_out ? mem_en_delayed & ~write_en_delayed : mem_en & ~write_en;
assign writeMem = stall_out ? mem_en_delayed & write_en_delayed : mem_en & write_en;
assign addr_mem = stall_out ? addr_in_delayed : addr_in;
assign data_in_mem = stall_out ? write_data_in_delayed : write_data_in;

mem_system #(1) data_mem(
   .clk        (clk),
   .rst        (rst),
   .err        (halt_mem),
   .Rd         (readMem),
   .Wr         (writeMem),
   .Addr       (addr_mem),
   .DataIn     (data_in_mem), 
   .createdump (1'b0),
   //Outputs
   .DataOut    (read_data),
   .Done       (done),
   .Stall      (stall),
   .CacheHit   (cache_hit)   
);

endmodule
`default_nettype wire
