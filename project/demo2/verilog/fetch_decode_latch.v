module fetch_decode_latch(clk, rst, nop, instruction_f, instruction_d);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] instruction_f;
    output wire [15:0] instruction_d;

    register iINSTRUCTION_LATCH_FD(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(instruction_f), .readData(instruction_d)); // might remove nop depending on fetch logic

endmodule