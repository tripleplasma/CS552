/*
   CS/ECE 552 Spring '24

   Filename        : instruction_decode.v
   Description     : Module Designed for decoding the opt code and generating the correct signals
*/
`default_nettype none
module instruction_decoder(
    input  wire [4:0]   Opcode, //5 bit opcode from instruction
    output reg  [3:0]   ALUOp,
    output reg  [1:0]   RegSrc,
    output reg  [1:0]   BSrc,
    output reg  [1:0]   RegDst,
    output reg          RegWrt,
    output reg          SLBI,
    output reg          Branch,
    output reg          ZeroExt,
    output reg          Set,
    output reg          Sub, //Subtraction
    output reg          MemEn,
    output reg          InvA,
    output reg          InvB,
    output reg          MemWrt,
    output reg          ImmSrc,
    output reg          ALUJmp,
    output reg          halt,
    output reg          btr,
    output reg          jmp
);

//IMPLEMENTATION

always @(*) begin
    ALUOp   = 0;
    RegSrc  = 0;
    BSrc    = 0;
    RegDst  = 0;
    RegWrt  = 0;
    SLBI    = 0;
    Branch  = 0;
    ZeroExt = 0;
    Set     = 0;
    Sub     = 0;
    MemEn   = 0;
    InvA    = 0;
    InvB    = 0;
    MemWrt  = 0;
    ImmSrc  = 0;
    ALUJmp  = 0;
    halt    = 0;
    btr     = 0;
    jmp     = 0;

    case(Opcode)
        // Special Instructions
        5'b00000 : begin // HALT: Cease instruction issue, dump memory state to file
            halt = 1'b1;
        end
        5'b00001 : begin // NOP: No operation
            //Empty Case
        end

        // I (type 1) Instructions
        5'b01000 : begin // ADDI: Rd <- Rs + I (sign extended)
            ALUOp = 4'b1000;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b01001 : begin // SUBI: Rd <- I (sign extended) - Rs
            ALUOp = 4'b1000;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
            InvA = 1'b1;
            Sub = 1'b1;
        end
        5'b01010 : begin // XORI: Rd <- Rs XOR I (zero extended)
            ALUOp = 4'b1100;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
            ZeroExt = 1'b1;
        end
        5'b01011 : begin // ANDNI: Rd <- Rs AND ~I (zero extended)
            ALUOp = 4'b1110;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
            InvB = 1'b1;
            ZeroExt = 1'b1;
        end
        5'b10100 : begin // ROLI: Rd <- Rs << (rotate) I (lowest 4 bits)
            ALUOp = 4'b0000;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10101 : begin // SLLI: Rd <- Rs << I (lowest 4 bits)
            ALUOp = 4'b0010;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10110 : begin // RORI: Rd <- Rs >> (rotate) I (lowest 4 bits)
            ALUOp = 4'b0100;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10111 : begin // SRLI: Rd <- Rs >> I (lowest 4 bits)
            ALUOp = 4'b0110;
            RegDst = 2'b01;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10000 : begin // ST: Mem[Rs + I (sign extended)] <- Rd
            ALUOp = 4'b1000;
            MemEn = 1'b1;
            MemWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10001 : begin // LD: Rd <- Mem[Rs + I (sign extended)]
            ALUOp = 4'b1000;
            MemEn = 1'b1;
            RegDst = 2'b01;
            RegSrc = 2'b01;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end
        5'b10011 : begin // STU: Mem[Rs + I (sign extended)] <- Rd, Rs <- Rs + I (sign extended)
            ALUOp = 4'b1000;
            MemEn = 1'b1;
            MemWrt = 1'b1;
            RegDst = 2'b00;
            RegSrc = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b01;
        end

        // I (type 2) Instructions

        5'b11000 : begin // LBI: Rs <- I (sign extended)
            RegDst = 2'b00;
            RegSrc = 2'b11;
            RegWrt = 1'b1;
        end
        5'b10010 : begin // SLBI: Rs <- (Rs << 8) | I (zero extended)
            ALUOp = 4'b1010;
            ZeroExt = 1'b1;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            SLBI = 1'b1;
            BSrc = 2'b10;
        end
        5'b01100 : begin //BEQZ: if (Rs == 0) then PC <- PC + 2 + I (sign extended)
            Branch = 1'b1;
        end
        5'b01101 : begin //BNEZ: if (Rs != 0) then PC <- PC + 2 + I (sign extended)
            Branch = 1'b1;
        end
        5'b01110 : begin //BLTZ: if (Rs < 0), then PC <- PC + 2 + I (sign extended)
            Branch = 1'b1;
        end
        5'b01111 : begin //BGEZ: if (Rs >= 0), then PC <- PC + 2 + I (sign extended)
            Branch = 1'b1;
        end
        5'b00101 : begin //JR: PC <- Rs + I (sign extended)
            ALUOp = 4'b1000;
            BSrc = 2'b10;
            ALUJmp = 1'b1;
        end
        5'b00111 : begin //JALR: R7 <- PC + 2 & PC <- PC + I(sign extended)
            ALUOp = 4'b1000;
            ALUJmp = 1'b1;
            BSrc = 2'b10;
            RegWrt = 1'b1;
            RegDst = 2'b11;
        end

        // J Instructions

        5'b00100 : begin //J: PC <- PC + 2 + D(sign extended)
            ImmSrc = 1'b1;
            jmp = 1'b1;
        end
        5'b00110 : begin //JAL: R7 <- PC + 2 & PC <- PC + 2 + D(sign extended)
            ImmSrc = 1'b1;
            jmp = 1'b1;
            RegWrt = 1'b1;
            RegDst = 2'b11;
        end

        // R Operations

        5'b11001 : begin //BTR: Rd[bit i] <- Rs[bit 15 - i] for i = 0..15
            ALUOp = 4'b0000;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            btr = 1'b1;
        end
        5'b11011 : begin //Arithmetic Ops: Rd <- Rs (OP) Rt | subtracton: Rd <- Rt - Rs
            ALUOp = 4'b1001;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
        end
        5'b11010 : begin //Shifting Ops: Rd <- Rs (Shift Type/Direction) Rt
            ALUOp = 4'b0001;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
        end
        5'b11100 : begin //SEQ : if (Rs == Rt), then Rd <- 1 else Rd <- 0
            ALUOp = 4'b1100;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            Set = 1'b1;
        end
        5'b11101 : begin //SLT : if (Rs < Rt), then Rd <- 1 else Rd <- 0
            ALUOp = 4'b1000;
            Sub = 1'b1;
            InvB = 1'b1;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            Set = 1'b1;
        end
        5'b11110 : begin //SLE : if (Rs <= Rt), then Rd <- 1 else Rd <- 0
            ALUOp = 4'b1000;
            Sub = 1'b1;
            InvB = 1'b1;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            Set = 1'b1;
        end
        5'b11111 : begin //SCO : if (Rs + Rt) generates carry out, then Rd <- 1 else Rd <- 0
            ALUOp = 4'b1000;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            RegSrc = 2'b10;
            Set = 1'b1;
        end
    endcase
end

endmodule
`default_nettype wire
