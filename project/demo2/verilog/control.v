/*
   CS/ECE 552 Fall '24
  
   Filename        : control.v
   Description     : This is a module that handles all of the control signals.
*/
module control(instruction_d, opcode, halt, jumpImm, link, regDst, jump, branch, memRead, memToReg, memWrite, aluSrc, regWrite, immExtSel, exception);

    input [15:0] instruction_d;
    input [4:0] opcode;
    output halt, jumpImm, link, jump, memRead, memToReg, memWrite, aluSrc, regWrite, exception;
    output [1:0] regDst;
    output [2:0] branch;
    output [2:0] immExtSel;
   
    assign halt = (instruction_d != 16'h0000 & opcode == 5'b0_0000) ? 1'b1 : 1'b0; // need to fix, don't think instruction_d != 16'h0000 is going to work
   
    assign jumpImm = (opcode[4:2] == 3'b001 & opcode[0] == 1'b1) ? 1'b1 : 1'b0;
   
    assign link = (opcode[4:1] == 4'b0011) ? 1'b1 : 1'b0;
   
    assign regDst = (opcode[4:1] == 4'b0011) ? 2'b11 : 
                    (opcode[4:1] == 4'b1001 | opcode == 5'b1_1000) ? 2'b10 : 
                    (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b1_0001) ? 2'b01 :
                    2'b00;
                    // (opcode[4:2] == 3'b110 | opcode[4:2] == 3'b111) ? 2'b00 : // wrote this out before realizing I didn't need it and could just use an else statement
    
    assign jump = (opcode[4:2] == 3'b001) ? 1'b1 : 1'b0;
    
    assign branch = (opcode[4:2] == 3'b011) ? opcode[2:0] : 3'b000;
    
    assign memRead = (opcode == 5'b1_0001) ? 1'b1 : 1'b0;
    
    assign memToReg = (opcode == 5'b1_0001) ? 1'b1 : 1'b0;
    
    assign memWrite = (opcode == 5'b1_0000 | opcode == 5'b1_0011) ? 1'b1 : 1'b0;
    
    assign aluSrc = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode[4:2] == 3'b100 | opcode == 5'b11000 | opcode == 5'b10010) ? 1'b1 : 1'b0; // 3'b100 would include SLBI - ok? Should aluSrc be one if any immediate opcode is detected (like JR)?
    
    assign regWrite = (opcode[4:2] == 3'b010 | opcode[4:2] == 3'b101 | opcode == 5'b1_0001 | opcode == 4'b1001 | opcode[4:2] == 3'b110 | opcode[4:2] == 3'b111 | opcode[4:1] == 4'b1001 | opcode == 5'b00110 | opcode == 5'b00111) ? 1'b1 : 1'b0;
    
    assign immExtSel =  (opcode[4:2] == 3'b001 & opcode[0] == 1'b0) ? 3'b100 :
                        (opcode[4:2] == 3'b011 | opcode == 5'b1_1000 | (opcode[4:2] == 3'b001 & opcode[0] == 1'b1)) ? 3'b011 :
                        (opcode == 5'b1_0010) ? 3'b010 : 
                        (opcode[4:1] == 4'b0101) ? 3'b000 :
                        3'b001;
    
    assign exception = (opcode[4:2] == 3'b000) ? 1'b1 : 1'b0; // not active until final demo - comment out?

endmodule