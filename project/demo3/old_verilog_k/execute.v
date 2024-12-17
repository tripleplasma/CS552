/*
   CS/ECE 552 Spring '22

   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (
   input  wire [15:0]   exec_out_fmem,
   input  wire [15:0]   write_data,
   input  wire [15:0]   instruction,
   input  wire [15:0]   pc_in,
   input  wire [15:0]   read_data1,
   input  wire [15:0]   read_data2,
   input  wire [15:0]   imm5_ext,
   input  wire [15:0]   imm8_ext,
   input  wire [15:0]   imm11_ext,
   input  wire [2:0]    write_reg_ex_mem,
   input  wire [2:0]    write_reg_mem_wb,
   input  wire [2:0]    RegisterRs_id_ex,
   input  wire [2:0]    RegisterRt_id_ex,
   input  wire          write_en_ex_mem,
   input  wire          write_en_mem_wb,
   input  wire          ImmSrc,
   input  wire [1:0]    BSrc,
   input  wire [1:0]    Instr_Funct_out,     //  = Instruction[1:0]
   input  wire [3:0]    ALUOp,
   input  wire          ALUJump,
   input  wire          InvB,
   input  wire          InvA,
   input  wire          Sub,
   input  wire          Set,
   input  wire          Branch,
   input  wire          SLBI,
   input  wire          BTR,
   input  wire [1:0]    Instr_BrchCnd_sel, // = Instruction[12:11]
   input  wire          jmp,
   input  wire          stall_mem_stg,
   output wire			PCSrc,
   output wire [15:0]   exec_out,
   output wire [15:0]   mem_addr_out,
   output wire [15:0]   pc_jmp_out
);

   reg  [15:0] imm_rd2;
   wire [15:0] brch_zero;
   wire [15:0] btr_mux;
   wire [15:0] imm_mux;
   wire [15:0] imm_plus_pc;
   wire [15:0] brch_mux;
   wire [2:0]  ALUOp_mux;
   wire [15:0] ALU_inA;
   wire [15:0] ALU_inB;
   wire [15:0] BaseA;
   wire [15:0] BaseB;
   wire InvA_ALU;
   wire InvB_ALU;
   wire Sub_ALU;

   wire [15:0] alu_out;
   reg  [15:0] set_out;
   reg         BRJmp_mux;
   wire        BRJmp;
   wire [1:0]  ForwardA;
   wire [1:0]  ForwardB;
   wire        r_type;

   // ALU Flags
   wire SF, ZF, OF, CF;


/////// Forwarding Unit ///////////////////

// Check if operation is R type or a ST/STU
assign r_type = ((instruction[15:14] == 2'b11) & (instruction[15:11] != 5'b11000)) | 
                ((instruction[15:11] == 5'b10000) | (instruction[15:11] == 5'b10011));

forwarding forwarding_unit (
   .r_type              (r_type),
   .write_reg_ex_mem    (write_reg_ex_mem),
   .write_reg_mem_wb    (write_reg_mem_wb),
   .RegisterRs_id_ex    (RegisterRs_id_ex),
   .RegisterRt_id_ex    (RegisterRt_id_ex),
   .write_en_ex_mem     (write_en_ex_mem),
   .write_en_mem_wb     (write_en_mem_wb),
   .ForwardA            (ForwardA),
   .ForwardB            (ForwardB)
);
////////////////////////////////////////////

/////// A & B INPUT MUXES /////////////////

assign BaseA = (ForwardA == 2'b10) ? exec_out_fmem :
               (ForwardA == 2'b01) ? write_data    : read_data1;

assign BaseB = (ForwardB == 2'b10) ? exec_out_fmem :
               (ForwardB == 2'b01) ? write_data    : read_data2;

assign mem_addr_out = BaseB;

// A signal mux
assign ALU_inA = SLBI ? BaseA << 8 : BaseA;
assign ALU_inB = brch_zero;

//  mux for B signal w/ imms and read data 2
always @(*) begin
   case(BSrc)
      2'b00: imm_rd2 = BaseB;
      2'b01: imm_rd2 = imm5_ext;
      2'b10: imm_rd2 = imm8_ext;
      2'b11: imm_rd2 = imm11_ext;
   endcase
end

// branch instr mux for B signal
assign brch_zero = Branch ? 16'h0000 : imm_rd2;

////////////////////////////////////////////



//// BRANCHING MUXES //////////////////////////////////////////////////

// imm src mux for next instr
assign imm_mux = ImmSrc ? imm11_ext : imm8_ext;

// add imm to pc
fulladder16 iFA (.A(imm_mux), .B(pc_in), .Cin(1'b0), .S(imm_plus_pc), .Cout());

// choose between current pc or calculated branch instr
assign brch_mux = (BRJmp | jmp) ? imm_plus_pc : pc_in;

// choose if we'll also be taking next instr addr from ALU
assign pc_jmp_out = ALUJump ? alu_out : brch_mux;

assign PCSrc = (~stall_mem_stg) ? ALUJump | BRJmp | jmp : 1'b0;

//////////////////////////////////////////////////////////////////////

////////////////// ALU LOGIC (INCLUDING ALU OUT MUX & FORWARDING DECODER SIGNALS) /////////////////

// choose ALU oper
// checking for an R format subtraction op and setting OP bits to 3'b100 if true
// for R format instr (exclduing sub) set last 2 bits to op code ext.
// else use 3 upper ALUOp bits
assign ALUOp_mux = ALUOp[0] ? ((Instr_Funct_out == 2'b01) & ALUOp[3] ? 3'b100 : {ALUOp[3], Instr_Funct_out}) : ALUOp[3:1];

// set InvA for R format SUB
assign InvA_ALU = ALUOp[0] & (Instr_Funct_out == 2'b01) & ALUOp[3] ? 1'b1 : InvA;

// set InvB for R format ANDN
assign InvB_ALU = ALUOp[0] & (Instr_Funct_out == 2'b11) & ALUOp[3] ? 1'b1 : InvB;

// set Sub for R format SUB
assign Sub_ALU = ALUOp[0] & (Instr_Funct_out == 2'b01) & ALUOp[3] ? 1'b1 : Sub;

// instantiate ALU & set flags
alu iALU (.InA(ALU_inA), .InB(ALU_inB), .Cin(Sub_ALU), .Oper(ALUOp_mux), .invA(InvA_ALU), .invB(InvB_ALU), .Out(alu_out), .Zero(ZF), .Ofl(OF), .Cout(CF));
assign SF = alu_out[15];

// BTR instr mux
assign btr_mux = BTR ? {BaseA[0], BaseA[1], BaseA[2], BaseA[3], BaseA[4], BaseA[5], BaseA[6], BaseA[7], BaseA[8], BaseA[9], BaseA[10], BaseA[11], BaseA[12], BaseA[13], BaseA[14], BaseA[15]} : alu_out;

// output mux
assign exec_out = Set ? set_out : btr_mux;

/////////////////////////////////////////////////////////////////////



////////// BRANCHING & SET LOGIC ///////////////////////////////////

// branching logic (take bits [12:11] of instr)
always @(*) begin
   case (Instr_BrchCnd_sel)
      2'b00 : BRJmp_mux = ZF; //BEQZ
      2'b01 : BRJmp_mux = ~ZF; //BNEZ
      2'b10 : BRJmp_mux = SF; //BLTZ
      2'b11 : BRJmp_mux = ~SF | ZF; //BGEZ
   endcase
end
assign BRJmp = BRJmp_mux & Branch;

// set instr logic
always @(*) begin
   case (Instr_BrchCnd_sel)
      2'b00 : set_out = ZF ? 16'h0001 : 16'h0000; // SEQ (Rs^Rt)
      2'b01 : set_out = (ALU_inA[15] & ~ALU_inB[15]) | (SF & ~OF) ? 16'h0001 : 16'h0000; // SLT (Rs-Rt)
      2'b10 : set_out = (ALU_inA[15] & ~ALU_inB[15]) | ((SF | ZF) & ~OF) ? 16'h0001 : 16'h0000; // SLE (Rs-Rt)
      2'b11 : set_out = CF ? 16'h0001 : 16'h0000; // SCO (Rs+Rt)
   endcase
end

///////////////////////////////////////////////////////////////////

endmodule
`default_nettype wire
