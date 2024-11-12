module fetch_decode_latch(clk, rst, nop, nop_ctrl, rst_d, PC_f, PC_d, instruction_f, instruction_d);

    input wire clk, rst;
    input wire nop, nop_ctrl;
    input wire [15:0] PC_f, instruction_f;
    output wire rst_d;
    output wire [15:0] PC_d, instruction_d;

    wire [15:0] instruction_fd_int;
    //wire [15:0] pc_fd_int;

    wire latch_nop_ctrl_1, latch_nop_ctrl_2;
    register #(.REGISTER_WIDTH(1)) CtrlLatch1(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(nop_ctrl), .readData(latch_nop_ctrl_1));
    register #(.REGISTER_WIDTH(1)) CtrlLatch2(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(latch_nop_ctrl_1), .readData(latch_nop_ctrl_2));

    register #(.REGISTER_WIDTH(1)) iRST_LATCH_FD(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(rst), .readData(rst_d));
    register iPC_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(PC_f), .readData(PC_d));
    //assign PC_d = (nop) ? PC_d : pc_fd_int;
    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_f), .readData(instruction_fd_int));
    assign instruction_d = (latch_nop_ctrl_2) ? 16'b0000_1000_0000_0000 : ((nop) ? instruction_d : instruction_fd_int);

endmodule