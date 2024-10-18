module br_control(zf, sf, of, cf, br_sig, br_contr_sig)
    input zf; //Zero flag
    input sf; //Signed flag
    input of; //Overflow flag
    input cf; //Carry flag
    input [2:0] br_sig; //The signal determining if the instruction was a ==, >=, !=, <, 0

    output br_contr_sig; 

    wire beqz = (zf & br_sig == 3'b100);
    wire bnez = (~zf & br_sig == 3'b101);
    wire bltz = (sf & br_sig == 3'b110);
    wire bgtz = (~sf & br_sig == 3'b111)

    assign br_contr_sig = beqz | bnez | bltz | bgtz;
endmodule