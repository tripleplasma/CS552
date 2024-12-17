/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch (
   input  wire          clk,
   input  wire          rst,
   input  wire          PCSrc,
   input  wire          halt,
   input  wire          hazard,
   input  wire          flush,
   input  wire [15:0]   pc_in,
   input  wire          stall_mem_stg,
   output wire          halt_out,
   output wire          stall_out,
   output wire          done_out,
   output wire [15:0]   pc_out,
   output wire [15:0]   instruction_out
);

wire [15:0] pc_mux, pc_d, pc_q, pc_haz, pc_flush;
wire [15:0] instr_addr;
wire hazard_stall;

wire done, cache_hit, stall;

// mux incoming branch instr w/ next instr
assign pc_mux = PCSrc ? pc_in : pc_out; 

assign hazard_stall = hazard | stall_out | stall_mem_stg; 

// Cutoff incoming PC if processor is halted or flushing
assign pc_d = (halt | hazard) ? pc_q : (flush ? pc_flush : pc_mux);

// Program count registers
dff pc_ff      [15:0](.clk(clk), .rst(rst), .d(pc_d[15:0]),                                  .q(pc_q[15:0]));
dff pc_ff_haz  [15:0](.clk(clk), .rst(rst), .d((hazard_stall) ? pc_haz[15:0] : pc_q[15:0]),  .q(pc_haz[15:0]));
dff pc_ff_flush[15:0](.clk(clk), .rst(rst), .d(PCSrc ? pc_in : pc_flush),                    .q(pc_flush[15:0]));

// Increment program count to next by 2 bytes
fulladder16 adder(.A(flush ? pc_in : pc_q), .B(hazard_stall ? 16'h0 : 16'h2), .Cin(1'b0), .S(pc_out), .Cout());

// Calculate next instruction address
assign instr_addr = hazard_stall ? pc_haz : (flush ? pc_flush : pc_q);

assign done_out = done & ~flush;
assign stall_out = stall; 

mem_system #(0) instr_mem(
   .clk        (clk),
   .rst        (rst),
   .err        (halt_out),
   .Rd         (~(hazard_stall | flush)),
   .Addr       (instr_addr),
   .DataOut    (instruction_out),
   .Done       (done),
   .Stall      (stall),
   .CacheHit   (cache_hit),

   // Tied to 0 as memory is read only
   .Wr         (1'b0), 
   .createdump (1'b0),
   .DataIn     (16'h0000)
);

endmodule
`default_nettype wire
