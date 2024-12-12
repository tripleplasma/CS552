/*
   CS/ECE 552 Fall '24
  
   Filename        : extension.v
   Description     : This is a submodule for the decode module that handles the 
                     zero/sign extending of the immediate values and determines
                     which one to use given the instruction.
*/
module extension(imm_5, imm_8, imm_11, immExtSel, immExt);

    input [4:0]  imm_5;
    input [7:0]  imm_8;
    input [10:0] imm_11;
    input [2:0]  immExtSel;
    
    output [15:0] immExt;
    
    // intermediates to hold zero/sign-extended values
    wire [15:0] zero_imm_5, signed_imm_5, zero_imm_8, signed_imm_8, signed_imm_11;
    
    assign zero_imm_5 = {11'b0, imm_5[4:0]};
    assign signed_imm_5 = {{11{imm_5[4]}}, imm_5[4:0]};
    assign zero_imm_8 = {8'b0, imm_8[7:0]};
    assign signed_imm_8 = {{8{imm_8[7]}}, imm_8[7:0]};
    assign signed_imm_11 = {{5{imm_11[10]}}, imm_11[10:0]};
    
    assign immExt = (immExtSel == 3'b000) ? zero_imm_5 : 
                    (immExtSel == 3'b001) ? signed_imm_5 :
                    (immExtSel == 3'b010) ? zero_imm_8 : 
                    (immExtSel == 3'b011) ? signed_imm_8 :
                    signed_imm_11;

endmodule