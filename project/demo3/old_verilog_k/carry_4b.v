module carry_4b(a, b, c_in, c, c_out);

    input [3:0] a;
    input [3:0] b;
    input c_in;
    output [3:1] c;  // Internal carry signals for bits 1, 2, 3
    output c_out;
    

    // Carry for bit 0
    carry_1b carry_bit_0(.a(a[0]), .b(b[0]), .c_in(c_in), .c_out(c[1]));

    // Carry for bit 1
    carry_1b carry_bit_1(.a(a[1]), .b(b[1]), .c_in(c[1]), .c_out(c[2]));

    // Carry for bit 2
    carry_1b carry_bit_2(.a(a[2]), .b(b[2]), .c_in(c[2]), .c_out(c[3]));

    // Carry for bit 3
    carry_1b carry_bit_3(.a(a[3]), .b(b[3]), .c_in(c[3]), .c_out(c_out));

endmodule