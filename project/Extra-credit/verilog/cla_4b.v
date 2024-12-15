/*
    CS/ECE 552 FALL'22
    Homework #2, Problem 1
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // YOUR CODE HERE
    wire [3:0] g;       // generate
    wire [3:0] p;       // propagate 
    wire [3:0] pc;      // propagate & carry intermediate
    wire [3:1] c;       // carry
    wire [3:0] g_NOT;   // generate intermediate
    wire [3:0] pc_NOT;  // propagate & carry intermediate
    wire [3:0] c_NOT;   // carry intermediate
    
    
    // adders (carry_outs handled by carry_4b)
    fullAdder_1b iFA0(.s(sum[0]), .c_out(), .a(a[0]), .b(b[0]), .c_in(c_in));
    fullAdder_1b iFA1(.s(sum[1]), .c_out(), .a(a[1]), .b(b[1]), .c_in(c[1]));
    fullAdder_1b iFA2(.s(sum[2]), .c_out(), .a(a[2]), .b(b[2]), .c_in(c[2]));
    fullAdder_1b iFA3(.s(sum[3]), .c_out(), .a(a[3]), .b(b[3]), .c_in(c[3]));

    // determines carry logic (c[1], c[2], c[3], c_out)
    carry_4b iCARRY_4b_0(.a(a), .b(b), .c_in(c_in), .c(c), .c_out(c_out));
    
endmodule
