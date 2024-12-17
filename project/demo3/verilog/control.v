/*
   CS/ECE 552 Spring '24

   Filename        : instruction_decode.v
   Description     : Module Designed for decoding the opt code and generating the correct signals
*/
`default_nettype none
module control(
    input  wire [4:0]   opcode, //5 bit opcode from instruction
    output reg  [3:0]   aluOp,
    output reg  [1:0]   wbSel,
    output reg  [1:0]   B_int,
    output reg  [1:0]   regDst,
    output reg          regWrite,
    output reg          slbi,
    output reg          branch,
    output reg          zeroExt,
    output reg          shift,
    output reg          subtract, //Subtraction
    output reg          memEnable,
    output reg          invA,
    output reg          invB,
    output reg          memWrite,
    output reg          immExtSel,
    output reg          aluJmp,
    output reg          halt,
    output reg          btr,
    output reg          jmp
);

//IMPLEMENTATION

always @(*) begin
    aluOp   = 0;
    wbSel  = 0;
    B_int    = 0;
    regDst  = 0;
    regWrite  = 0;
    slbi    = 0;
    branch  = 0;
    zeroExt = 0;
    shift     = 0;
    subtract     = 0;
    memEnable   = 0;
    invA    = 0;
    invB    = 0;
    memWrite  = 0;
    immExtSel  = 0;
    aluJmp  = 0;
    halt    = 0;
    btr     = 0;
    jmp     = 0;

    case(opcode)
        // Special Instructions
        5'b00000 : begin // HALT: Cease instruction issue, dump memory state to file
            halt = 1'b1;
        end
        5'b00001 : begin // NOP: No operation
            //Empty Case
        end

        // I (type 1) Instructions
        5'b01000 : begin // ADDI: Rd <- Rs + I (sign extended)
            aluOp = 4'b1000;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b01001 : begin // SUBI: Rd <- I (sign extended) - Rs
            aluOp = 4'b1000;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
            invA = 1'b1;
            subtract = 1'b1;
        end
        5'b01010 : begin // XORI: Rd <- Rs XOR I (zero extended)
            aluOp = 4'b1100;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
            zeroExt = 1'b1;
        end
        5'b01011 : begin // ANDNI: Rd <- Rs AND ~I (zero extended)
            aluOp = 4'b1110;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
            invB = 1'b1;
            zeroExt = 1'b1;
        end
        5'b10100 : begin // ROLI: Rd <- Rs << (rotate) I (lowest 4 bits)
            aluOp = 4'b0000;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10101 : begin // SLLI: Rd <- Rs << I (lowest 4 bits)
            aluOp = 4'b0010;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10110 : begin // RORI: Rd <- Rs >> (rotate) I (lowest 4 bits)
            aluOp = 4'b0100;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10111 : begin // SRLI: Rd <- Rs >> I (lowest 4 bits)
            aluOp = 4'b0110;
            regDst = 2'b01;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10000 : begin // ST: Mem[Rs + I (sign extended)] <- Rd
            aluOp = 4'b1000;
            memEnable = 1'b1;
            memWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10001 : begin // LD: Rd <- Mem[Rs + I (sign extended)]
            aluOp = 4'b1000;
            memEnable = 1'b1;
            regDst = 2'b01;
            wbSel = 2'b01;
            regWrite = 1'b1;
            B_int = 2'b01;
        end
        5'b10011 : begin // STU: Mem[Rs + I (sign extended)] <- Rd, Rs <- Rs + I (sign extended)
            aluOp = 4'b1000;
            memEnable = 1'b1;
            memWrite = 1'b1;
            regDst = 2'b00;
            wbSel = 2'b10;
            regWrite = 1'b1;
            B_int = 2'b01;
        end

        // I (type 2) Instructions

        5'b11000 : begin // LBI: Rs <- I (sign extended)
            regDst = 2'b00;
            wbSel = 2'b11;
            regWrite = 1'b1;
        end
        5'b10010 : begin // slbi: Rs <- (Rs << 8) | I (zero extended)
            aluOp = 4'b1010;
            zeroExt = 1'b1;
            regDst = 2'b00;
            regWrite = 1'b1;
            wbSel = 2'b10;
            slbi = 1'b1;
            B_int = 2'b10;
        end
        5'b01100 : begin //BEQZ: if (Rs == 0) then PC <- PC + 2 + I (sign extended)
            branch = 1'b1;
        end
        5'b01101 : begin //BNEZ: if (Rs != 0) then PC <- PC + 2 + I (sign extended)
            branch = 1'b1;
        end
        5'b01110 : begin //BLTZ: if (Rs < 0), then PC <- PC + 2 + I (sign extended)
            branch = 1'b1;
        end
        5'b01111 : begin //BGEZ: if (Rs >= 0), then PC <- PC + 2 + I (sign extended)
            branch = 1'b1;
        end
        5'b00101 : begin //JR: PC <- Rs + I (sign extended)
            aluOp = 4'b1000;
            B_int = 2'b10;
            aluJmp = 1'b1;
        end
        5'b00111 : begin //JALR: R7 <- PC + 2 & PC <- PC + I(sign extended)
            aluOp = 4'b1000;
            aluJmp = 1'b1;
            B_int = 2'b10;
            regWrite = 1'b1;
            regDst = 2'b11;
        end

        // J Instructions

        5'b00100 : begin //J: PC <- PC + 2 + D(sign extended)
            immExtSel = 1'b1;
            jmp = 1'b1;
        end
        5'b00110 : begin //JAL: R7 <- PC + 2 & PC <- PC + 2 + D(sign extended)
            immExtSel = 1'b1;
            jmp = 1'b1;
            regWrite = 1'b1;
            regDst = 2'b11;
        end

        // R Operations

        5'b11001 : begin //BTR: Rd[bit i] <- Rs[bit 15 - i] for i = 0..15
            aluOp = 4'b0000;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
            btr = 1'b1;
        end
        5'b11011 : begin //Arithmetic Ops: Rd <- Rs (OP) Rt | subtracton: Rd <- Rt - Rs
            aluOp = 4'b1001;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
        end
        5'b11010 : begin //Shifting Ops: Rd <- Rs (Shift Type/Direction) Rt
            aluOp = 4'b0001;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
        end
        5'b11100 : begin //SEQ : if (Rs == Rt), then Rd <- 1 else Rd <- 0
            aluOp = 4'b1100;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
            shift = 1'b1;
        end
        5'b11101 : begin //SLT : if (Rs < Rt), then Rd <- 1 else Rd <- 0
            aluOp = 4'b1000;
            subtract = 1'b1;
            invB = 1'b1;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
            shift = 1'b1;
        end
        5'b11110 : begin //SLE : if (Rs <= Rt), then Rd <- 1 else Rd <- 0
            aluOp = 4'b1000;
            subtract = 1'b1;
            invB = 1'b1;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
            shift = 1'b1;
        end
        5'b11111 : begin //SCO : if (Rs + Rt) generates carry out, then Rd <- 1 else Rd <- 0
            aluOp = 4'b1000;
            regDst = 2'b10;
            regWrite = 1'b1;
            wbSel = 2'b10;
            shift = 1'b1;
        end
    endcase
end

endmodule
`default_nettype wire
