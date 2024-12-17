module fulladder1 (
    input  A,
    input  B, 
    input  Cin,
    output S,
    output Cout
);

// Sum
assign S = A ^ B ^ Cin;

// Cout
assign Cout = (A & B) | (A & Cin) | (B & Cin);

endmodule