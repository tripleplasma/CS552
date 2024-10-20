module br_control(zf, sf, of, cf, br_sig, br_contr_sig);
    input wire zf; //Zero flag
    input wire sf; //Signed flag
    input wire of; //Overflow flag
    input wire cf; //Carry flag
    input wire [2:0] br_sig; //The signal determining if the instruction was a ==, >=, !=, <, 0

    output br_contr_sig; 

    wire beqz = (zf & br_sig == 3'b100);
    wire bnez = (~zf & br_sig == 3'b101);
    wire bltz = (sf & br_sig == 3'b110);
    wire bgtz = (~sf & br_sig == 3'b111);

    assign br_contr_sig = beqz | bnez | bltz | bgtz;
endmodule