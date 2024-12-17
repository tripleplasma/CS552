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
  input  wire         PCSrc_d,   
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
  output wire [3:0]   aluOp_d,
  output wire         invA_d,
  output wire         invB_d,
  output wire         memWrite_d,
  output wire			    regWrite_d,
  output wire [2:0]	  regRs_d,
  output wire [2:0]	  regRt_d,
  output wire [2:0]	  writeRegSel_d,
  output wire         branch_d,
  output wire         shift_d, 
  output wire         subtract_d,
  output wire         memEnable_d,
  output wire         aluJmp_d,
  output wire         slbi_d,
  output wire         halt_d,
  output wire         btr_d,
  output wire 			  jmp_d,
  output wire         data_hazard,
  output wire         flush,
  output wire [15:0]        instruction_d
);
   
wire err;
wire [1:0]  regDst;
wire zeroExt, data_hazard_prev;
wire [15:0] instruction_fd_prev, instruction_d_int;

register iINSTRUCTION_FD_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_fd), .readData(instruction_fd_prev));
register #(.REGISTER_WIDTH(1)) iHAZARD_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_hazard), .readData(data_hazard_prev));

assign instruction_d_int = (data_hazard | flush | dataMem_stall) ? 16'h0800 : 
                           (data_hazard_prev & instruction_fd_prev != 16'h0800) ? instruction_fd_prev : 
                           instruction_fd; 

assign regRs_d = instruction_d_int[10:8];
assign regRt_d = instruction_d_int[7:5];
assign instruction_d = instruction_d_int;
// Decode logic 
instruction_decoder my_instruction_decoder (
  .Opcode(instruction[15:11]),   //Input
  .ALUOp(aluOp_d),  //FLUSH                 
  .RegSrc(wbSel_d),  //FLUSH              
  .BSrc(B_int_d), //FLUSH                   
  .RegDst(RegDst),     //Dealth with in Decode           
  .RegWrt(regWrite_d),  //FLUSH              
  .SLBI(slbi_d),             //FLUSH       
  .Branch(branch_d),      //FLUSH          
  .ZeroExt(ZeroExt),   //Dealth with in Decode          
  .Set(shift_d),       //FLUSH
  .Sub(subtract_d),      //FLUSH
  .MemEn(memEnable_d),  //FLUSH
  .InvA(invA_d),    //FLUSH
  .InvB(invB_d),    //FLUSH
  .MemWrt(memWrite_d), //FLUSH
  .ImmSrc(immExtSel_d), //FLUSH
  .ALUJmp(aluJmp_d), //FLUSH
  .halt(halt_d), //FLUSH
  .btr(btr_d), //FLUSH
  .jmp(jmp_d) //FLUSH
);

assign extension_d = instruction_d_int[1:0];
assign branchSel_d = instruction_d_int[12:11];

assign imm5_ext_d  = (zeroExt) ? {11'h000, instruction_d_int[4:0]} : 
                     {{11{instruction_d_int[4]}}, instruction_d_int[4:0]};
assign imm8_ext_d  = (zeroExt) ? {8'h00, instruction_d_int[7:0]} : 
                     {{8{instruction_d_int[7]}}, instruction_d_int[7:0]};
assign imm11_ext_d = {{5{instruction_d_int[10]}}, instruction_d_int[10:0]};

assign writeRegSel_d =  (regDst == 2'b00) ? instruction_d_int[4:2] :
                        (regDst == 2'b01) ? instruction_d_int[7:5] :
                        (regDst == 2'b10) ? instruction_d_int[10:8] : 
                        4'b0111;

// Register file with bypass logic
regFile_bypass regfile(
  // Inputs
  .clk              (clk),
  .rst              (rst),
  .read1RegSel      (regRs_d),
  .read2RegSel      (regRt_d),
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
  .PCSrc_X            (PCSrc_d),
  .RegisterRt_id_ex   (regRt_e),
  .read_reg1          (instruction_fd[10:8]),
  .read_reg2          (instruction_fd[7:5]),
  .hazard_out         (data_hazard),
  .flush_out          (flush)
);
   
endmodule
`default_nettype wire
