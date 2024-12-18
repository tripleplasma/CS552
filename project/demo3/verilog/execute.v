/*
   CS/ECE 552 Spring '22

   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (
   input  wire [15:0]   aluOut_fwd,
   input  wire [15:0]   writeData_wb,
   input  wire [15:0]   instruction_e,
   input  wire [15:0]   PC_e,
   input  wire [15:0]   read1Data_e,
   input  wire [15:0]   read2Data_e,
   input  wire [15:0]   imm5Ext_e,
   input  wire [15:0]   imm8Ext_e,
   input  wire [15:0]   imm11Ext_e,
   input  wire [2:0]    writeRegSel_m,
   input  wire [2:0]    writeRegSel_wb,
   input  wire [2:0]    regRs_e,
   input  wire [2:0]    regRt_e,
   input  wire          regWrite_m,
   input  wire          regWrite_wb,
   input  wire          immExtSel_e,
   input  wire [1:0]    B_int_e,
   input  wire [1:0]    extension_e,
   input  wire [3:0]    aluOp_e,
   input  wire          aluJmp_e,
   input  wire          invA_e,
   input  wire          invB_e,
   input  wire          subtract_e,
   input  wire          shift_e,
   input  wire          branch_e,
   input  wire          slbi_e,
   input  wire          btr_e,
   input  wire [1:0]    branchSel_e,
   input  wire          jmp_e,
   input  wire          dataMem_stall,
   output wire			   PCSrc,
   output wire [15:0]   aluOut_e,
   output wire [15:0]   read2Data_em,
   output wire [15:0]   PC_jmp_e
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
assign r_type = ((instruction_e[15:11] == 5'b10000) | (instruction_e[15:11] == 5'b10011)) | 
               ((instruction_e[15:14] == 2'b11) & (instruction_e[15:11] != 5'b11000));

forwarding forwarding_unit (
   .r_type              (r_type),
   .write_reg_ex_mem    (writeRegSel_m),
   .write_reg_mem_wb    (writeRegSel_wb),
   .RegisterRs_id_ex    (regRs_e),
   .RegisterRt_id_ex    (regRt_e),
   .write_en_ex_mem     (regWrite_m),
   .write_en_mem_wb     (regWrite_wb),
   .ForwardA            (ForwardA),
   .ForwardB            (ForwardB)
);
////////////////////////////////////////////

/////// A & B INPUT MUXES /////////////////

assign BaseA = (ForwardA == 2'b10) ? aluOut_fwd :
               (ForwardA == 2'b01) ? writeData_wb : 
               read1Data_e;

assign BaseB = (ForwardB == 2'b10) ? aluOut_fwd :
               (ForwardB == 2'b01) ? writeData_wb : 
               read2Data_e;

assign read2Data_em = BaseB;

// A signal mux
assign ALU_inA = slbi_e ? BaseA << 8 : BaseA;
assign ALU_inB = brch_zero;

//  mux for B signal w/ imms and read data 2
always @(*) begin
   case(B_int_e)
      2'b00: imm_rd2 = BaseB;
      2'b01: imm_rd2 = imm5Ext_e;
      2'b10: imm_rd2 = imm8Ext_e;
      2'b11: imm_rd2 = imm11Ext_e;
   endcase
end

// branch instr mux for B signal
assign brch_zero = branch_e ? 16'h0000 : imm_rd2;

////////////////////////////////////////////



//// BRANCHING MUXES //////////////////////////////////////////////////

// imm src mux for next instr
assign imm_mux = immExtSel_e ? imm11Ext_e : imm8Ext_e;

// add imm to pc
fulladder16 iFA (.A(imm_mux), .B(PC_e), .Cin(1'b0), .S(imm_plus_pc), .Cout());

// choose between current pc or calculated branch instr
assign brch_mux = (BRJmp | jmp_e) ? imm_plus_pc : PC_e;

// choose if we'll also be taking next instr addr from ALU
assign PC_jmp_e = aluJmp_e ? alu_out : brch_mux;

assign PCSrc = (~dataMem_stall) ? aluJmp_e | BRJmp | jmp_e : 1'b0;

//////////////////////////////////////////////////////////////////////

////////////////// ALU LOGIC (INCLUDING ALU OUT MUX & FORWARDING DECODER SIGNALS) /////////////////

// choose ALU oper
// checking for an R format subtraction op and setting OP bits to 3'b100 if true
// for R format instr (exclduing subtract_e) set last 2 bits to op code ext.
// else use 3 upper aluOp_e bits
assign ALUOp_mux = aluOp_e[0] ? ((extension_e == 2'b01) & aluOp_e[3] ? 3'b100 : {aluOp_e[3], extension_e}) : aluOp_e[3:1];

// set invA_e for R format SUB
assign InvA_ALU = aluOp_e[0] & (extension_e == 2'b01) & aluOp_e[3] ? 1'b1 : invA_e;

// set invB_e for R format ANDN
assign InvB_ALU = aluOp_e[0] & (extension_e == 2'b11) & aluOp_e[3] ? 1'b1 : invB_e;

// set Sub for R format SUB
assign Sub_ALU = aluOp_e[0] & (extension_e == 2'b01) & aluOp_e[3] ? 1'b1 : subtract_e;

// instantiate ALU & set flags
alu iALU (.InA(ALU_inA), .InB(ALU_inB), .Cin(Sub_ALU), .Oper(ALUOp_mux), .invA(InvA_ALU), .invB(InvB_ALU), .Out(alu_out), .Zero(ZF), .Ofl(OF), .Cout(CF));
assign SF = alu_out[15];

// BTR instr mux
assign btr_mux = btr_e ? {BaseA[0], BaseA[1], BaseA[2], BaseA[3], BaseA[4], BaseA[5], BaseA[6], BaseA[7], BaseA[8], BaseA[9], BaseA[10], BaseA[11], BaseA[12], BaseA[13], BaseA[14], BaseA[15]} : alu_out;

// output mux
assign aluOut_e = shift_e ? set_out : btr_mux;

/////////////////////////////////////////////////////////////////////



////////// BRANCHING & SET LOGIC ///////////////////////////////////

// branching logic (take bits [12:11] of instr)
always @(*) begin
   case (branchSel_e)
      2'b00 : BRJmp_mux = ZF; //BEQZ
      2'b01 : BRJmp_mux = ~ZF; //BNEZ
      2'b10 : BRJmp_mux = SF; //BLTZ
      2'b11 : BRJmp_mux = ~SF | ZF; //BGEZ
   endcase
end
assign BRJmp = BRJmp_mux & branch_e;

// set instr logic
always @(*) begin
   case (branchSel_e)
      2'b00 : set_out = ZF ? 16'h0001 : 16'h0000; // SEQ (Rs^Rt)
      2'b01 : set_out = (ALU_inA[15] & ~ALU_inB[15]) | (SF & ~OF) ? 16'h0001 : 16'h0000; // SLT (Rs-Rt)
      2'b10 : set_out = (ALU_inA[15] & ~ALU_inB[15]) | ((SF | ZF) & ~OF) ? 16'h0001 : 16'h0000; // SLE (Rs-Rt)
      2'b11 : set_out = CF ? 16'h0001 : 16'h0000; // SCO (Rs+Rt)
   endcase
end

///////////////////////////////////////////////////////////////////

endmodule
`default_nettype wire
