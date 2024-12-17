module carry_1b(a, b, c_in, c_out);

    input a;
    input b;
    input c_in;
    output c_out;
    
    // Internal signals for generate and propagate
    wire g, p;

    // generate, propagate, and carry logic
    assign g = a & b;    // Generate: Gi = Ai & Bi
    assign p = a | b;    // Propagate: Pi = Ai | Bi
    assign c_out = g | (p & c_in);

endmodule