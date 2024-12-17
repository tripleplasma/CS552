/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (
   input  wire          clk,
   input  wire          rst,
   input  wire          mem_en,
   input  wire          write_en,
   input  wire [15:0]   addr_in,
   input  wire [15:0]   write_data_in,
   output wire          stall_out,
   output wire          done_out,
   output wire          halt_mem,
   output wire [15:0]   read_data
);

wire done, stall, cache_hit;

assign stall_out = stall;
assign done_out = done;

wire [15:0] addr_in_q, write_data_in_q;
wire write_en_q, mem_en_q;
dff write_en_ff (.clk(clk), .rst(rst), .d(stall_out ? write_en_q : write_en), .q(write_en_q));
dff mem_en_ff (.clk(clk), .rst(rst), .d(stall_out ? mem_en_q : mem_en), .q(mem_en_q));
dff addr_in_ff [15:0] (.clk(clk), .rst(rst), .d(stall_out ? addr_in_q : addr_in), .q(addr_in_q));
dff write_data_in_ff [15:0] (.clk(clk), .rst(rst), .d(stall_out ? write_data_in_q : write_data_in), .q(write_data_in_q));

wire rd_set, wr_set;
wire [15:0] addr_set, data_in_set;

assign rd_set = stall_out ? mem_en_q & ~write_en_q : mem_en & ~write_en;
assign wr_set = stall_out ? mem_en_q & write_en_q : mem_en & write_en;
assign addr_set = stall_out ? addr_in_q : addr_in;
assign data_in_set = stall_out ? write_data_in_q : write_data_in;

mem_system #(1) data_mem(
   .clk        (clk),
   .rst        (rst),
   .err        (halt_mem),
   .Rd         (rd_set),
   .Wr         (wr_set),
   .Addr       (addr_set),
   .DataIn     (data_in_set),
   .DataOut    (read_data), 
   .createdump (1'b0),
   .Done       (done),
   .Stall      (stall),
   .CacheHit   (cache_hit)   
);

endmodule
`default_nettype wire
