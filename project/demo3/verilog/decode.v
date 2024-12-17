/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (
  input  wire         clk, 
  input  wire         rst,
  input  wire         dataMem_stall,
  input  wire         instrMem_stall,
  input  wire [15:0]  instruction_fd,
  input  wire			    regWrite_wb,
  input  wire [2:0]	  writeRegSel_wb,
  input  wire [15:0]  writeData,
  input  wire         PCSrc_X,  
  input  wire         memRead,
  input  wire [2:0]   regRt_e,
  output wire [15:0]  read1Data_d,
  output wire [15:0]  read2Data_d,
  output wire [15:0]  imm5Ext_d,
  output wire [15:0]  imm8Ext_d,
  output wire [15:0]  imm11Ext_d,
  output wire         immExtSel_d,				
  output wire [1:0]   B_int_d,				
  output wire [1:0]   wbSel_d,			
  output wire [1:0]   extension_d,
  output wire [1:0]	  branchSel_d, 
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
dff instr_ff [15:0] (.clk(clk), .rst(rst), .d(instruction_fd), .q(prev_instr));
dff haz_ff (.clk(clk), .rst(rst), .d(hazard), .q(prev_haz));

assign instruction = (hazard | flush_out | dataMem_stall) ? 16'h0800 : (prev_haz & prev_instr!=16'h0800) ? prev_instr : instruction_fd; 
assign RegisterRs = instruction[10:8];
assign RegisterRt = instruction[7:5];
assign instruction_out = instruction;
// Decode logic 
instruction_decoder my_instruction_decoder (
  .Opcode(instruction[15:11]),   //Input
  .ALUOp(ALUOp),  //FLUSH                 
  .RegSrc(wbSel_d),  //FLUSH              
  .BSrc(B_int_d), //FLUSH                   
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
  .ImmSrc(immExtSel_d), //FLUSH
  .ALUJmp(ALUJmp), //FLUSH
  .halt(halt), //FLUSH
  .btr(btr), //FLUSH
  .jmp(jmp) //FLUSH
);

// Sign or Zero extend the immediate values from I type instructions
assign imm5Ext_d  = (ZeroExt) ? {11'h000, instruction[4:0]} : {{11{instruction[4]}}, instruction[4:0]};
assign imm8Ext_d  = (ZeroExt) ? {8'h00, instruction[7:0]}   : {{8{instruction[7]}}, instruction[7:0]};
assign imm11Ext_d = {{5{instruction[10]}}, instruction[10:0]};

// Mux to select write register
assign writeRegSel_out = (RegDst == 0) ? instruction[10:8] :
                         (RegDst == 1) ? instruction[7:5]  :
                         (RegDst == 2) ? instruction[4:2]  : 3'h7;

// Pass through signals from fetch to next stages
assign extension_d = instruction[1:0];
assign branchSel_d = instruction[12:11];

// Register file with bypass logic
regFile_bypass regfile(
  // Inputs
  .clk              (clk),
  .rst              (rst),
  .read1RegSel      (RegisterRs),
  .read2RegSel      (RegisterRt),
  .writeRegSel      (writeRegSel_wb),
  .writeData        (writeData),
  .writeEn          (regWrite_wb),
  // Outputs
  .read1Data        (read1Data_d),
  .read2Data        (read2Data_d),
  .err              (err)
);

hazard_detect hazard_detect(
  .clk                (clk),
  .rst                (rst),
  .stall              (dataMem_stall | instrMem_stall),
  .MemRd              (memRead),
  .PCSrc_X            (PCSrc_X),
  .RegisterRt_id_ex   (regRt_e),
  .read_reg1          (instruction_fd[10:8]),
  .read_reg2          (instruction_fd[7:5]),
  .hazard_out         (hazard),
  .flush_out          (flush_out)
);
   
endmodule
`default_nettype wire
