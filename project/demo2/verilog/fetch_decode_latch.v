module fetch_decode_latch(clk, rst, nop, instruction_f, instruction_d);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] instruction_f;
    output wire [15:0] instruction_d;

    wire [15:0] instruction_fd_int;

    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(1), .writeData(instruction_f), .readData(instruction_fd_int));
    assign instruction_f = (nop) ? 16'b0000_1000_0000_0000 : instruction_fd_int;

endmodule