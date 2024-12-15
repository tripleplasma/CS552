/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 1
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output s;
    output c_out;
    input  a, b;
    input  c_in;

    // YOUR CODE HERE
    
    // internal signals 
    wire xorAxB, nandAxB, andAxB, nandABxC, andABxC, c_out_NOT;
    
    // Full Adder implementation
    xor2 iXOR2_1(.in1(a), .in2(b), .out(xorAxB));
    nand2 iNAND2_1(.in1(a), .in2(b), .out(nandAxB));
    not1 iNOT1_1(.in1(nandAxB), .out(andAxB));
    xor2 iXOR2_2(.in1(xorAxB), .in2(c_in), .out(s));
    nand2 iNAND2_2(.in1(xorAxB), .in2(c_in), .out(nandABxC));
    not1 iNOT1_2(.in1(nandABxC), .out(andABxC));
    nor2 iNOR1_1(.in1(andABxC), .in2(andAxB), .out(c_out_NOT));
    not1 iNOT1_3(.in1(c_out_NOT), .out(c_out));

endmodule
