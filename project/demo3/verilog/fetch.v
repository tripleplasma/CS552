/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch (clk, rst, halt_sig, data_hazard, flush, dataMem_stall, PCSrc_m, PC_jmp_m, 
               instrMem_err_f, instrMem_stall, instrMem_done, PC_f, instruction_f);

input wire clk;
input wire rst;
input wire halt_sig;
input wire data_hazard;
input wire flush;
input wire dataMem_stall;
input wire PCSrc_m;
input wire [15:0] PC_jmp_m;

output wire          instrMem_err_f;
output wire          instrMem_stall;
output wire          instrMem_done;
output wire [15:0]   PC_f;
output wire [15:0]   instruction_f;

wire [15:0] pcSel, nextPC, currentPC, pc_data_hazard, pc_flush;
wire [15:0] instrMem_addr;

wire instrMem_done_int, instrMem_cache_hit;

// branch logic
assign pcSel = PCSrc_m ? PC_jmp_m : PC_f; 

// stop PC if halt, hazard, or flush
assign nextPC =   (halt_sig | data_hazard) ? currentPC : 
                  (flush) ? pc_flush : 
                  pcSel;

// PC registers
register iPC(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(nextPC), .readData(currentPC)); 
register iPC_HAZARD(.clk(clk), .rst(rst), .writeEn(~(data_hazard | instrMem_stall | dataMem_stall)), .writeData(currentPC), .readData(pc_data_hazard)); 
register iPC_FLUSH(.clk(clk), .rst(rst), .writeEn(PCSrc_m), .writeData(PC_jmp_m), .readData(pc_flush));

// Increment PC
cla_16b iPC_INCREMENT(.sum(PC_f), .c_out(), .a(flush ? PC_jmp_m : currentPC), .b((data_hazard | instrMem_stall | dataMem_stall) ? 16'h0 : 16'h2), .c_in(1'b0));

// Calculate address for instruction memory
assign instrMem_addr =  (data_hazard | instrMem_stall | dataMem_stall) ? pc_data_hazard : 
                        (flush) ? pc_flush : 
                        currentPC;

assign instrMem_done = instrMem_done_int & ~flush;

mem_system #(0) instr_mem( // Outputs
                           .DataOut    (instruction_f),
                           .err        (instrMem_err_f),
                           .Done       (instrMem_done_int),
                           .Stall      (instrMem_stall),
                           .CacheHit   (instrMem_cache_hit),
                           // Inputs
                           .clk        (clk),
                           .rst        (rst),
                           .createdump (1'b0),
                           .Rd         (~(data_hazard | instrMem_stall | dataMem_stall | flush)),
                           .Wr         (1'b0), 
                           .Addr       (instrMem_addr),
                           .DataIn     (16'h0000)
                        );

endmodule
`default_nettype wire
