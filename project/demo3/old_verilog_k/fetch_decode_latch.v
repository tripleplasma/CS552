module fetch_decode_latch (clk, rst, PC_f, instruction_f, flush, instrMem_err_f, instrMem_done, dataMem_stall,
							instrMem_err_d, PC_d,instruction_fd);

input clk, rst;
input wire [15:0] PC_f, instruction_f;
input wire flush, instrMem_err_f, instrMem_done, dataMem_stall;

output wire instrMem_err_d;
output wire [15:0] PC_d, instruction_fd;

wire [15:0] instruction_fd_int;

register iPC_FD(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(PC_f), .readData(PC_d));
register #(.REGISTER_WIDTH(1)) iINSTRMEM_ERR_FD(.clk(clk), .rst(rst), .writeEn(~dataMem_stall), .writeData(instrMem_err_f), .readData(instrMem_err_d));

assign instruction_fd_int = (rst | flush) ? 16'h0800 : 			// set instruction to NOP on reset or flush
							(instrMem_done) ? instruction_f : 	// logic to get correct instruction	
							(dataMem_stall) ? instruction_fd :
							16'h0800;
register iINSTRUCTION_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(instruction_fd_int), .readData(instruction_fd));

endmodule