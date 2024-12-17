module reg1 (
    input clk,
    input rst,
    input reg [15:0] d,
    output    [15:0] q
);

dff ff_arr[15:0](.clk(clk), .rst(rst), .d(d[15:0]), .q(q[15:0]));

endmodule