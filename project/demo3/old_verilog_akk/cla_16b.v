/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 16-bit CLA module
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // YOUR CODE HERE
    wire [3:1] c_4b;    // Carry signals between 4-bit carry modoules
    wire [11:0] c_1b;   // Carry signals between 1-bit carry modules
    
    // adder for each digit followed by carry logic for each digit
    cla_4b iCLA_4B_0(.sum(sum[3:0]), .c_out(), .a(a[3:0]), .b(b[3:0]), .c_in(c_in));
    carry_4b iCARRY_4b_0(.a(a[3:0]), .b(b[3:0]), .c_in(c_in), .c(c_1b[2:0]), .c_out(c_4b[1]));

    cla_4b iCLA_4B_1(.sum(sum[7:4]), .c_out(), .a(a[7:4]), .b(b[7:4]), .c_in(c_4b[1]));
    carry_4b iCARRY_4b_1(.a(a[7:4]), .b(b[7:4]), .c_in(c_4b[1]), .c(c_1b[5:3]), .c_out(c_4b[2]));
    
    cla_4b iCLA_4B_2(.sum(sum[11:8]), .c_out(), .a(a[11:8]), .b(b[11:8]), .c_in(c_4b[2]));
    carry_4b iCARRY_4b_2(.a(a[11:8]), .b(b[11:8]), .c_in(c_4b[2]), .c(c_1b[8:6]), .c_out(c_4b[3]));

    cla_4b iCLA_4B_3(.sum(sum[15:12]), .c_out(), .a(a[15:12]), .b(b[15:12]), .c_in(c_4b[3]));
    carry_4b iCARRY_4b_3(.a(a[15:12]), .b(b[15:12]), .c_in(c_4b[3]), .c(c_1b[11:9]), .c_out(c_out));

endmodule