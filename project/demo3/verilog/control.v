/*
   CS/ECE 552 Spring '24

   Filename        : instruction_decode.v
   Description     : Module Designed for decoding the opt code and generating the correct signals
*/
`default_nettype none
module control(opcode, aluOp, wbSel, B_int, regDst, regWrite, slbi, branch, zeroExt, shift, subtract, memEnable, invA, invB, memWrite, immExtSel, aluJmp, halt, btr, jmp);

input wire [4:0] opcode;
output wire [3:0] aluOp;
output wire [1:0] wbSel, B_int, regDst;
output wire regWrite, slbi, branch, zeroExt, shift, subtract, memEnable, invA, invB, memWrite, immExtSel, aluJmp, halt, btr, jmp;

assign halt = (opcode == 5'b00000) ? 1'b1 : 1'b0;

assign aluOp      = (opcode == 5'b01000 | opcode == 5'b01001 | opcode == 5'b10000 | opcode == 5'b10001 | 
                        opcode == 5'b10011 | opcode == 5'b00101 | opcode == 5'b00111 | opcode == 5'b11101 | 
                        opcode == 5'b11110 | opcode == 5'b11111) ? 4'b1000 :
                    (opcode == 5'b11010) ? 4'b0001 :
                    (opcode == 5'b10101) ? 4'b0010 :
                    (opcode == 5'b10110) ? 4'b0100 :
                    (opcode == 5'b10111) ? 4'b0110 :
                    (opcode == 5'b11011) ? 4'b1001 : 
                    (opcode == 5'b10010) ? 4'b1010 : 
                    (opcode == 5'b01010 | opcode == 5'b11100) ? 4'b1100 :
                    (opcode == 5'b01011) ? 4'b1110 : 4'b0000;

assign regDst     = (opcode[4:1] == 4'b0011) ? 2'b11 : 
                    (opcode[4:1] == 4'b1001 | opcode == 5'b11000 | opcode == 5'b10000) ? 2'b10 :
                    (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b10001) ? 2'b01 :
                    2'b00;

assign wbSel      = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b11001 | opcode == 5'b11010 | 
                        opcode == 5'b11011 | opcode[4:2] == 3'b111 | opcode[4:1] == 4'b1001) ? 2'b10 :
                    (opcode == 5'b10001) ? 2'b01 :
                    (opcode == 5'b11000) ? 2'b11 : 2'b00;

assign regWrite   = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | (opcode[4:2] == 3'b100 & opcode[0] == 1'b1) | 
                    opcode == 5'b10010 | opcode[4:2] == 3'b110 | opcode[4:2] == 3'b111 | opcode[4:1] == 4'b0011) ? 1'b1 : 1'b0;

assign B_int      = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode[4:1] == 4'b1000 | opcode == 5'b10011) ? 2'b01 :
                    (opcode == 5'b10010 | (opcode[4:2] == 3'b001 & opcode[0] == 1'b1)) ? 2'b10 : 
                    2'b00;

assign zeroExt    = (opcode[4:1] == 4'b0101 | opcode == 5'b10010) ? 1'b1 : 1'b0;
assign invA       = (opcode == 5'b01001) ? 1'b1 : 1'b0;
assign invB       = (opcode == 5'b01011 | opcode == 5'b11101 | opcode == 5'b11110) ? 1'b1 : 1'b0;
assign subtract   = (opcode == 5'b01001 | opcode == 5'b11101 | opcode == 5'b11110) ? 1'b1 : 1'b0;
assign memEnable  = (opcode[4:1] == 4'b1000 | opcode == 5'b10011) ? 1'b1 : 1'b0;
assign memWrite   = (opcode == 5'b10000 | opcode == 5'b10011) ? 1'b1 : 1'b0;
assign slbi       = (opcode == 5'b10010) ? 1'b1 : 1'b0;
assign branch     = (opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;
assign immExtSel  = (opcode[4:2] == 3'b001 & opcode[0] == 1'b0) ? 1'b1 : 1'b0;
assign jmp        = (opcode[4:2] == 3'b001 & opcode[0] == 1'b0) ? 1'b1 : 1'b0;
assign aluJmp     = (opcode[4:2] == 3'b001 & opcode[0] == 1'b1) ? 1'b1 : 1'b0;
assign shift      = (opcode[4:2] == 3'b111) ? 1'b1 : 1'b0;
assign btr        = (opcode == 5'b11001) ? 1'b1 : 1'b0;

endmodule
`default_nettype wire
