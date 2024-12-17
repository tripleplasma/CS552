/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (
  input  wire         clk, 
  input  wire         rst,
  input  wire         stall_mem_stg,
  input  wire         stall_fetch,
  input  wire [15:0]  instruction_in,
  input  wire [15:0]  instruction_f,
  input  wire			    RegWrt_in,
  input  wire [2:0]	  writeRegSel_in,
  input  wire [15:0]  write_data,
  input  wire         PCSrc_X,
  input  wire [2:0]   write_reg_id_ex, 
  input  wire [2:0]   write_reg_ex_mem,
  input  wire [2:0]   write_reg_mem_wb,
  input  wire         write_en_id_ex,    
  input  wire         write_en_ex_mem,   
  input  wire         write_en_mem_wb,   
  input  wire         MemRd,
  input  wire [2:0]   RegisterRs_id_ex,
  input  wire [2:0]   RegisterRt_id_ex,
  output wire [15:0]  read_data1,
  output wire [15:0]  read_data2,
  output wire [15:0]  imm5_ext,
  output wire [15:0]  imm8_ext,
  output wire [15:0]  imm11_ext,
  output wire         ImmSrc,				
  output wire [1:0]   BSrc,				
  output wire [1:0]   RegSrc,			
  output wire [1:0]   Instr_Funct_out,	// Instruction[1:0]
  output wire [1:0]	  Instr_BrchCnd_sel,  // Instruction[12:11] 
  output wire [3:0]   ALUOp,
  output wire         InvA,
  output wire         InvB,
  output wire         MemWrt,
  output wire			    RegWrt_out,
  output wire [2:0]	  RegisterRs,
  output wire [2:0]	  RegisterRt,
  output wire [2:0]	  writeRegSel_out,
  output wire         Branch,
  output wire         Set, 
  output wire         Sub,
  output wire         MemEn,
  output wire         ALUJmp,
  output wire         SLBI,
  output wire         halt,
  output wire         btr,
  output wire 			  jmp,
  output wire         hazard,
  output wire         flush_out,
  output wire [15:0]        instruction_out
);
   
wire [1:0]  RegDst, RegDst_haz;
wire        err;
wire        ZeroExt;
wire [15:0] instruction;

wire [15:0] prev_instr;
wire prev_haz;
dff instr_ff [15:0] (.clk(clk), .rst(rst), .d(instruction_in), .q(prev_instr));
dff haz_ff (.clk(clk), .rst(rst), .d(hazard), .q(prev_haz));

assign instruction = (hazard | flush_out | stall_mem_stg) ? 16'h0800 : (prev_haz & prev_instr!=16'h0800) ? prev_instr : instruction_in; 
assign RegisterRs = instruction[10:8];
assign RegisterRt = instruction[7:5];
assign instruction_out = instruction;
// Decode logic 
instruction_decoder my_instruction_decoder (
  .Opcode(instruction[15:11]),   //Input
  .ALUOp(ALUOp),  //FLUSH                 
  .RegSrc(RegSrc),  //FLUSH              
  .BSrc(BSrc), //FLUSH                   
  .RegDst(RegDst),     //Dealth with in Decode           
  .RegWrt(RegWrt_out),  //FLUSH              
  .SLBI(SLBI),             //FLUSH       
  .Branch(Branch),      //FLUSH          
  .ZeroExt(ZeroExt),   //Dealth with in Decode          
  .Set(Set),       //FLUSH
  .Sub(Sub),      //FLUSH
  .MemEn(MemEn),  //FLUSH
  .InvA(InvA),    //FLUSH
  .InvB(InvB),    //FLUSH
  .MemWrt(MemWrt), //FLUSH
  .ImmSrc(ImmSrc), //FLUSH
  .ALUJmp(ALUJmp), //FLUSH
  .halt(halt), //FLUSH
  .btr(btr), //FLUSH
  .jmp(jmp) //FLUSH
);

// Sign or Zero extend the immediate values from I type instructions
assign imm5_ext  = (ZeroExt) ? {11'h000, instruction[4:0]} : {{11{instruction[4]}}, instruction[4:0]};
assign imm8_ext  = (ZeroExt) ? {8'h00, instruction[7:0]}   : {{8{instruction[7]}}, instruction[7:0]};
assign imm11_ext = {{5{instruction[10]}}, instruction[10:0]};

// Mux to select write register
assign writeRegSel_out = (RegDst == 0) ? instruction[10:8] :
                         (RegDst == 1) ? instruction[7:5]  :
                         (RegDst == 2) ? instruction[4:2]  : 3'h7;

// Pass through signals from fetch to next stages
assign Instr_Funct_out = instruction[1:0];
assign Instr_BrchCnd_sel = instruction[12:11];

// Register file with bypass logic
regFile_bypass regfile(
  // Inputs
  .clk              (clk),
  .rst              (rst),
  .read1RegSel      (RegisterRs),
  .read2RegSel      (RegisterRt),
  .writeRegSel      (writeRegSel_in),
  .writeData        (write_data),
  .writeEn          (RegWrt_in),
  // Outputs
  .read1Data        (read_data1),
  .read2Data        (read_data2),
  .err              (err)
);

hazard_detect hazard_detect(
  .clk                (clk),
  .rst                (rst),
  .stall              (stall_mem_stg | stall_fetch),
  .MemRd              (MemRd),
  .PCSrc_X            (PCSrc_X),
  .RegisterRt_id_ex   (RegisterRt_id_ex),
  .read_reg1          (instruction_in[10:8]),
  .read_reg2          (instruction_in[7:5]),
  .hazard_out         (hazard),
  .flush_out          (flush_out)
);
   
endmodule
`default_nettype wire
