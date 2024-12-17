/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (clk, rst, dataMem_stall, instrMem_stall, instruction_fd, regWrite_wb, writeRegSel_wb, writeData, PCSrc_d, 
              memRead, regRt_e, read1Data_d, read2Data_d, imm5Ext_d, imm8Ext_d, imm11Ext_d, immExtSel_d, B_int_d, wbSel_d, extension_d, 
              branchSel_d, aluOp_d, invA_d, invB_d, memWrite_d, regWrite_d, regRs_d, regRt_d, writeRegSel_d, branch_d, shift_d, 
              subtract_d, memEnable_d, aluJmp_d, slbi_d, halt_d, btr_d, jmp_d, data_hazard, flush, instruction_d);

input wire clk, rst;
input wire dataMem_stall, instrMem_stall, regWrite_wb, PCSrc_d, memRead;
input wire [2:0] writeRegSel_wb, regRt_e;
input wire [15:0] instruction_fd, writeData;

output wire immExtSel_d, invA_d, invB_d, memWrite_d, regWrite_d, branch_d, shift_d, subtract_d, memEnable_d, aluJmp_d, 
            slbi_d, halt_d, btr_d, jmp_d, data_hazard, flush;
output wire [1:0] B_int_d, wbSel_d,	extension_d, branchSel_d;
output wire [2:0] regRs_d, regRt_d, writeRegSel_d;
output wire [3:0] aluOp_d;
output wire [15:0] read1Data_d, read2Data_d, imm5Ext_d, imm8Ext_d, imm11Ext_d, instruction_d;
   
wire err, zeroExt, data_hazard_prev;
wire [1:0]  regDst;
wire [15:0] instruction_fd_prev, instruction_d_int;

// Extra register logic to ensure correctness of hazard/stalling/flushing
register iINSTRUCTION_FD_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_fd), .readData(instruction_fd_prev));
register #(.REGISTER_WIDTH(1)) iHAZARD_PREV(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_hazard), .readData(data_hazard_prev));

assign instruction_d_int = (data_hazard | flush | dataMem_stall) ? 16'h0800 : (data_hazard_prev & instruction_fd_prev!=16'h0800) ? instruction_fd_prev : instruction_fd; 
assign regRs_d = instruction_d_int[10:8];
assign regRt_d = instruction_d_int[7:5];
assign instruction_d = instruction_d_int;

// Hazard Detection Unit (HDU)
hdu iHDU0(// Inputs
          .clk(clk),
          .rst(rst),
          .stall(dataMem_stall | instrMem_stall),
          .memRead(memRead),
          .PCSrc_d(PCSrc_d),
          .regRt_e(regRt_e),
          .ifIdReadRegister1(instruction_fd[10:8]),
          .ifIdReadRegister2(instruction_fd[7:5]),
          // Outputs
          .data_hazard(data_hazard),
          .flush(flush));

// Decode logic 
control iCONTROL0(// Inputs
                  .opcode(instruction_d_int[15:11]),
                  // Outputs
                  .aluOp(aluOp_d),
                  .wbSel(wbSel_d),
                  .B_int(B_int_d),
                  .regDst(regDst),
                  .regWrite(regWrite_d), 
                  .slbi(slbi_d),
                  .branch(branch_d),
                  .zeroExt(zeroExt),
                  .shift(shift_d),
                  .subtract(subtract_d),
                  .memEnable(memEnable_d),
                  .invA(invA_d),
                  .invB(invB_d),
                  .memWrite(memWrite_d),
                  .immExtSel(immExtSel_d),
                  .aluJmp(aluJmp_d),
                  .halt(halt_d),
                  .btr(btr_d),
                  .jmp(jmp_d));

// Sign or Zero extend the immediate values from I type instructions
assign imm5Ext_d  = (zeroExt) ? {11'h000, instruction_d_int[4:0]} : {{11{instruction_d_int[4]}}, instruction_d_int[4:0]};
assign imm8Ext_d  = (zeroExt) ? {8'h00, instruction_d_int[7:0]}   : {{8{instruction_d_int[7]}}, instruction_d_int[7:0]};
assign imm11Ext_d = {{5{instruction_d_int[10]}}, instruction_d_int[10:0]};

// Mux to select write register
assign writeRegSel_d =  (regDst == 3'b000) ? instruction_d_int[4:2] :
                        (regDst == 3'b001) ? instruction_d_int[7:5]  :
                        (regDst == 3'b010) ? instruction_d_int[10:8]  : 3'b111;

// Pass through signals from fetch to next stages
assign extension_d = instruction_d_int[1:0];
assign branchSel_d = instruction_d_int[12:11];

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
   
endmodule
`default_nettype wire
