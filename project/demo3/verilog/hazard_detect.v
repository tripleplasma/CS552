module hazard_detect(
    input  wire         clk,               
    input  wire         rst,
    input  wire         stall,
    input  wire         PCSrc_X,       
    input  wire         MemRd,       
    input  wire [2:0]   RegisterRt_id_ex,
    input  wire [2:0]   read_reg1,
    input  wire [2:0]   read_reg2,
    output wire         hazard_out,
    output wire         flush_out
);

wire PCSrc_X_q, PCSrc_X_q1, flush_d, flush_q;

// Data Hazard detection logic
assign hazard_out = MemRd & ((RegisterRt_id_ex == read_reg1) | (RegisterRt_id_ex == read_reg2));

// Control Hazard detection
dff pc_src_ff(.clk(clk), .rst(rst), .d(PCSrc_X), .q(PCSrc_X_q));
dff pc_src_ff1(.clk(clk), .rst(rst), .d(PCSrc_X_q), .q(PCSrc_X_q1));

// Assert flush for 3 clock cycles or longer while stalled
assign flush_d = PCSrc_X | PCSrc_X_q | PCSrc_X_q1;

dff flush_ff(.clk(clk), .rst(rst), .d((stall & flush_q) ? flush_q : flush_d), .q(flush_q));

assign flush_out = flush_q | flush_d;



endmodule
