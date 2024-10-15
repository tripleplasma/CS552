/*
   CS/ECE 552 Spring '22
  
   Filename        : alu_control.v
   Description     : This module generates the alu opcode.
*/
`default_nettype none
module execute (opcode, extention, aluOp);

   input [4:0]    opcode;        // Top 5 bits of instruction
   input [1:0]    extention;     // Bottom 2 bits for R-format instructions

   
   output   [15:0]   aluOp;      // Opcode going to the alu

   
   assign aluOp =   (opcode[4:2] == 3'b010)     ?               // If immediate instruction
                    (opcode[1:0] == 2'b00)      ?   4'b0100 :   // Add ALU Operation
                    (opcode[1:0] == 2'b01)      ?   4'b0101 :   // Subtract ALU Operation
                    (opcode[1:0] == 2'b10)      ?   4'b0110 :   // XOR ALU Operation     
                    4'b0111                     :               // ANDN ALU Operation
                    (opcode[4:2] == 3'b101)     ?               // If immediate shift/rotate instruction 
                    (opcode[1:0] == 2'b00)      ?   4'b0000 :   // ROL ALU Operation
                    (opcode[1:0] == 2'b01)      ?   4'b0001 :   // SLL ALU Operation
                    (opcode[1:0] == 2'b10)      ?   4'b0010 :   // ROR ALU Operation     
                    4'b0011                     :               // SRL ALU Operation
                    

   
endmodule
`default_nettype wire
