module fetch_decode_latch(clk, rst, nop, rst_d, PC_f, PC_d, instruction_f, instruction_d);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] PC_f, instruction_f;
    output wire rst_d;
    output wire [15:0] PC_d, instruction_d;

    wire [15:0] instruction_fd_int;
    // wire [15:0] PC_fd_int;

    register #(.REGISTER_WIDTH(1)) iRST_LATCH_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(rst), .readData(rst_d));
    
    register iPC_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(PC_f), .readData(PC_d));
    // assign PC_d = (nop) ? PC_d : PC_fd_int;

    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(instruction_f), .readData(instruction_d));
    // assign instruction_d = (nop) ? instruction_d : instruction_fd_int;

endmodule