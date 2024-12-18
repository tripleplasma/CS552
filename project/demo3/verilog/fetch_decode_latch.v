module fetch_decode_latch(clk, rst, nop, stall, rst_d, PC_f, PC_d, instruction_f, instruction_d, instr_mem_align_err_f, instr_mem_align_err_d);

    input wire clk, rst;
    input wire nop, stall;
    input wire [15:0] PC_f, instruction_f;
    input wire instr_mem_align_err_f;
    output wire rst_d;
    output wire [15:0] PC_d, instruction_d;
    output wire instr_mem_align_err_d;

    wire [15:0] instruction_fd_int;
    wire instr_mem_align_err_fd_int;
    wire [15:0] PC_fd_int;

    register #(.REGISTER_WIDTH(1)) iRST_LATCH_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(rst), .readData(rst_d));
    
    assign PC_fd_int = (nop) ? 16'hffff : PC_f;
    register iPC_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~stall), .writeData(PC_fd_int), .readData(PC_d));

    assign instruction_fd_int = (nop) ? 16'b0000_1000_0000_0000 : instruction_f;
    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~stall), .writeData(instruction_fd_int), .readData(instruction_d));

    assign instr_mem_align_err_fd_int = (stall) ? 1'b0 : instr_mem_align_err_f;
    register #(.REGISTER_WIDTH(1)) iINSTR_MEM_ALIGN_ERR_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(instr_mem_align_err_fd_int), .readData(instr_mem_align_err_d));
    
endmodule