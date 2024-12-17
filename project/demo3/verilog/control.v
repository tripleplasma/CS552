/*
   CS/ECE 552 Fall '24

   Filename        : control.v
   Description     : This is a module that handles all of the control signals.
*/
`default_nettype none
module control(opcode, aluOp, regSrc, B_int, regDst, regWrite, branch, zeroExt, shift, subtract, memEnable, invA, invB, memWrite, immSel, aluJmp, halt, slbi, btr, jmp);

input wire [4:0] opcode;

output wire [3:0] aluOp;
output wire [1:0] regSrc, B_int, regDst;
output wire regWrite, branch, zeroExt, shift, subtract, memEnable, invA, invB, memWrite, immSel, aluJmp, halt, slbi, btr, jmp;

assign halt       = (opcode == 5'b00000);

assign aluOp      = (opcode == 5'b01000) ? 4'b1000 : 
                    (opcode == 5'b01001) ? 4'b1000 :
                    (opcode == 5'b01010) ? 4'b1100 :
                    (opcode == 5'b01011) ? 4'b1110 :
                    (opcode == 5'b10100) ? 4'b0000 :
                    (opcode == 5'b10101) ? 4'b0010 :
                    (opcode == 5'b10110) ? 4'b0100 :
                    (opcode == 5'b10111) ? 4'b0110 :
                    (opcode == 5'b10000 | opcode == 5'b10001 | opcode == 5'b10011) ? 4'b1000 :
                    (opcode == 5'b00101 | opcode == 5'b00111) ? 4'b1000 :
                    (opcode == 5'b10010) ? 4'b1010 :
                    (opcode == 5'b11001) ? 4'b0000 :
                    (opcode == 5'b11011) ? 4'b1001 :
                    (opcode == 5'b11010) ? 4'b0001 :
                    (opcode == 5'b11100) ? 4'b1100 :
                    (opcode == 5'b11101 | opcode == 5'b11110 | opcode == 5'b11111) ? 4'b1000 : 4'b0000;

assign regDst     = (opcode[4:1] == 4'b0011) ? 2'b11 : 
                    (opcode[4:1] == 4'b1001 | opcode == 5'b1_1000 | opcode == 5'b1_0000) ? 2'b10 :
                    (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b1_0001) ? 2'b01 :
                    2'b00;

assign regSrc     = (opcode == 5'b01000 | opcode == 5'b01001 | opcode == 5'b01010 | 
                     opcode == 5'b01011 | opcode == 5'b10100 | opcode == 5'b10101 |
                     opcode == 5'b10110 | opcode == 5'b10111 | opcode == 5'b10010) ? 2'b10 :
                    (opcode == 5'b10001) ? 2'b01 :
                    (opcode == 5'b11001 | opcode == 5'b11011 | opcode == 5'b11010 | 
                     opcode == 5'b11100 | opcode == 5'b11101 | opcode == 5'b11110 | 
                     opcode == 5'b11111) ? 2'b10 :
                    (opcode == 5'b11000) ? 2'b11 : 2'b00;

assign regWrite   = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b1_0001 | 
                    opcode == 4'b1001 | opcode[4:2] == 3'b110 | opcode[4:2] == 3'b111 | 
                    opcode[4:1] == 4'b1001 | opcode == 5'b00110 | opcode == 5'b00111) ? 1'b1 : 1'b0;

assign B_int      = (opcode == 5'b01000 | opcode == 5'b01001 | opcode == 5'b01010 |
                     opcode == 5'b01011 | opcode == 5'b10100 | opcode == 5'b10101 |
                     opcode == 5'b10110 | opcode == 5'b10111 | opcode == 5'b10000 | 
                     opcode == 5'b10001 | opcode == 5'b10011) ? 2'b01 :
                    (opcode == 5'b00101 | opcode == 5'b00111 | opcode == 5'b10010) ? 2'b10 : 2'b00;

assign invA       = (opcode == 5'b01001);
assign subtract   = (opcode == 5'b01001 | opcode == 5'b11101 | opcode == 5'b11110);
assign invB       = (opcode == 5'b01011 | opcode == 5'b11101 | opcode == 5'b11110);
assign zeroExt    = (opcode == 5'b01010 | opcode == 5'b01011 | opcode == 5'b10010);
assign slbi       = (opcode == 5'b10010);
assign branch     = (opcode == 5'b01100 | opcode == 5'b01101 | opcode == 5'b01110 | opcode == 5'b01111);
assign memEnable  = (opcode == 5'b10000 | opcode == 5'b10001 | opcode == 5'b10011);
assign memWrite   = (opcode == 5'b10000 | opcode == 5'b10011);
assign immSel     = (opcode == 5'b00100 | opcode == 5'b00110);
assign aluJmp     = (opcode == 5'b00101 | opcode == 5'b00111);
assign jmp        = (opcode == 5'b00100 | opcode == 5'b00110);
assign btr        = (opcode == 5'b11001);
assign shift      = (opcode == 5'b11100 | opcode == 5'b11101 | opcode == 5'b11110 | opcode == 5'b11111);

endmodule
`default_nettype wire
