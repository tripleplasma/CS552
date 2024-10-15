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

   
   assign aluOp =
                     // I type instructions 
                    (opcode[4:2] == 3'b010)     ?               // If immediate instruction that uses ALU
                    (opcode[1:0] == 2'b00)      ?   4'b0100 :   // Add ALU Operation
                    (opcode[1:0] == 2'b01)      ?   4'b0101 :   // Subtract ALU Operation
                    (opcode[1:0] == 2'b10)      ?   4'b0110 :   // XOR ALU Operation     
                    4'b0111                     :               // ANDN ALU Operation
                    (opcode[4:2] == 3'b101)     ?               // If immediate shift/rotate instruction 
                    (opcode[1:0] == 2'b00)      ?   4'b0000 :   // ROL ALU Operation
                    (opcode[1:0] == 2'b01)      ?   4'b0001 :   // SLL ALU Operation
                    (opcode[1:0] == 2'b10)      ?   4'b0010 :   // ROR ALU Operation     
                    4'b0011                     :               // SRL ALU Operation
                    (opcode == 5'b1000X)        ?   4'b0100 :   // If immediate load/store instruction, add in ALU
                    (opcode == 5'b10011)        ?   4'b0100 :   // If STU instruction, add in ALU
                    // R Type instructions
                    (opcode == 5'b11001)        ?   4'b1110 :   // If BTR instruction
                    (opcode == 5'b11011)        ?               // If R instruction that uses ALU
                    (extention == 2'b00)        ?   4'b0100 :   // Add ALU Operation
                    (extention == 2'b01)        ?   4'b0101 :   // Subtract ALU Operation
                    (extention == 2'b10)        ?   4'b0110 :   // XOR ALU Operation     
                    4'b0111                     :               // ANDN ALU Operation
                    (opcode == 5'b11010)        ?               // If shift/rotate R instruction
                    (extention == 2'b00)        ?   4'b0000 :   // ROL ALU Operation
                    (extention == 2'b01)        ?   4'b0001 :   // SLL ALU Operation
                    (extention == 2'b10)        ?   4'b0010 :   // ROR ALU Operation     
                    4'b0011                     :               // SRL ALU Operation
                    (opcode[4:2] == 3'b111)     ?               // If R set instruction
                    (opcode[1:0] == 2'b00)      ?   4'b1000 :   // SEQ ALU Operation
                    (opcode[1:0] == 2'b01)      ?   4'b1001 :   // SLT ALU Operation
                    (opcode[1:0] == 2'b10)      ?   4'b1010 :   // SLE ALU Operation     
                    4'b1100                     :               // SCO ALU Operation
                    // Branch instructions
                    

                    

   
endmodule
`default_nettype wire
