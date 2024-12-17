module if_id (
	input clk,
	input rst,
	input wire [15:0]  pc_out,
	input wire [15:0]  instruction,
	input wire         flush_in,
	input wire		   halt_fetch,
	input wire		   stall_mem_stg,
	input wire		   stall_fetch,
	input wire		   done_fetch,
	output wire		   halt_fetch_q,
	output wire [15:0] pc_out_q,
	output wire [15:0] instruction_q
);

wire [15:0] instruction_d, instruction_flush, instruction_q_i;

dff pc_out_ff [15:0] (.clk(clk), .rst(rst), .d((stall_mem_stg) ? pc_out_q : pc_out), .q(pc_out_q)); 
dff halt_fetch_ff (.clk(clk), .rst(rst), .d(stall_mem_stg ? halt_fetch_q : halt_fetch), .q(halt_fetch_q)); 

//TODO flush out contents when branching or jumping

// do this to fix halt from asserting early
// set instruction to NOP on reset instead of HALT
assign instruction_d = (rst | flush_in) ? 16'h0800 : (done_fetch) ? instruction : (stall_mem_stg) ? instruction_q : 16'h0800;
dff instruction_ff [15:0] (.clk(clk), .rst(1'b0), .d(instruction_d), .q(instruction_q));

//Flushing Logic




endmodule
