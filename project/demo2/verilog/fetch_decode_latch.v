module fetch_decode_latch(clk, rst, nop, rst_d, PC_f, PC_d, instruction_f, instruction_d);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] PC_f, instruction_f;
    output wire rst_d;
    output wire [15:0] PC_d, instruction_d;

    wire [15:0] instruction_fd_int;

    register #(.REGISTER_WIDTH(1)) iRST_LATCH_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(rst), .readData(rst_d));
    register iPC_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(PC_f), .readData(PC_d));
    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_f), .readData(instruction_fd_int));
    assign instruction_d =  (nop) ? 16'b0000_1000_0000_0000 : instruction_fd_int;

endmodule