module br_control(zf, sf, of, cf, br_sig, br_contr_sig)
    input zf; //Zero flag
    input sf; //Signed flag
    input of; //Overflow flag
    input cf; //Carry flag
    input [1:0] br_sig; //The signal determining if the instruction was a ==, >=, !=, <, 0

    output br_contr_sig; 

    assign br_contr_sig = (zf & br_sig[1] == 0);
endmodule