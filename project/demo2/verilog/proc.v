/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
`default_nettype none
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   // Can't use assign with reg - output reg err;
   output wire err;

   // None of the above lines can be modified

   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines

   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire rst_d;
   wire [15:0] instruction_f, instruction_d, instruction_e;
   wire [2:0] writeRegSel_d, writeRegSel_e, writeRegSel_m, writeRegSel_wb;
   wire [15:0] writeData;
   wire [15:0] read1Data_d, read1Data_e, read1Data_m;
   wire [15:0] read2Data_d, read2Data_e, read2Data_m;
   wire err_decode;
   wire [15:0] immExt_d, immExt_e, immExt_m;
   wire [3:0] aluSel;
   wire [15:0] PC_f, PC_d, PC_e, PC_m, PC_wb;

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   assign err = err_decode;
   
   // hazard signals
   wire control_hazard, data_hazard, structural_hazard;

   // control signals
   wire halt_d, halt_e, halt_m, haltxout;
   wire jumpImm_d, jumpImm_e, jumpImm_m;
   wire link_d, link_e, link_m, link_wb;
   wire jump_d, jump_e, jump_m;
   wire memRead_d, memRead_e, memRead_m;
   wire memToReg_d, memToReg_e, memToReg_m, memToReg_wb;
   wire memWrite_d, memWrite_e, memWrite_m;
   wire aluSrc_d, aluSrc_e;
   wire regWrite_d, regWrite_e, regWrite_m, regWrite_wb;
   wire exception;
   wire br_contr_e, br_contr_m;
   wire internal_clock;
   wire [2:0] branch_d, branch_e;
   wire [1:0] regDst;
   wire [2:0] immExtSel;

   //Execute Signals
   wire zero_flag, signed_flag, overflow_flag, carry_flag;
   wire [15:0] aluOut_e, aluOut_m, aluOut_wb;

   // Memory Signals
   wire [15:0] readData_m, readData_wb;

   //Fetch
   fetch fetch0(// Inputs
               .clk(clk), 
               .rst(rst), 
               .nop(structural_hazard),             // still a little confused on control_hazard/data_hazard/nop
               .halt_sig(haltxout), 
               .jump_imm_sig(jumpImm_m), 
               .jump_sig(jump_m), 
               .except_sig(exception), 
               .br_contr_sig(br_contr_m), 
               .imm_jump_reg_val(read1Data_m), 
               .extend_val(immExt_m),
               // Outputs
               .instr(instruction_f), 
               .output_clk(internal_clock), 
               .PC_2(PC_f));
   
   fetch_decode_latch iFDLATCH0( // Inputs
                                 .clk(internal_clock), 
                                 .rst(rst), 
                                 .nop(data_hazard | (structural_hazard & ~control_hazard)), 
                                 .nop_ctrl(control_hazard),
                                 .rst_d(rst_d),
                                 .PC_f(PC_f),
                                 .PC_d(PC_d),
                                 .instruction_f(instruction_f), 
                                 .instruction_d(instruction_d));  // still a little confused on control_hazard/data_hazard/nop
   
   hdu iHDU_0( // Inputs
               .clk(internal_clock), 
               .rst(rst), 
               .PC_f(PC_f),
               .PC_m(PC_m),
               .ifIdReadRegister1({1'b0, instruction_d[10:8]}), 
               .ifIdReadRegister2({1'b0, instruction_d[7:5]}), 
               .ifIdWriteRegister({1'b0, writeRegSel_d}), 
               .opcode(instruction_f[15:11]), 
               // Outputs
               .data_hazard(data_hazard), 
               .control_hazard(control_hazard),
               .structural_hazard(structural_hazard));

   // determine control signals based on opcode
   control iCONTROL0(// Inputs
                     .rst_d(rst_d),
                     .opcode(instruction_d[15:11]),
                     // Outputs 
                     .halt(halt_d), 
                     .jumpImm(jumpImm_d), 
                     .link(link_d), 
                     .regDst(regDst), 
                     .jump(jump_d), 
                     .branch(branch_d), 
                     .memRead(memRead_d), 
                     .memToReg(memToReg_d), 
                     .memWrite(memWrite_d), 
                     .aluSrc(aluSrc_d), 
                     .regWrite(regWrite_d), 
                     .immExtSel(immExtSel), 
                     .exception(exception));
   
   //----Want inside decode----
   assign writeRegSel_d = (regDst == 2'b00) ? instruction_d[4:2] :
                           (regDst == 2'b01) ? instruction_d[7:5] :
                           (regDst == 2'b10) ? instruction_d[10:8] :
                           3'b111;
                        
   // assign writeData = (link) ? PC + 2 : wbData;
   //----END----

   decode decode0(// Inputs
                  .clk(internal_clock), 
                  .rst(rst), 
                  .read1RegSel(instruction_d[10:8]), 
                  .read2RegSel(instruction_d[7:5]), 
                  .writeregsel(writeRegSel_wb), 
                  .writedata(writeData), 
                  .write(regWrite_wb),
                  .imm_5(instruction_d[4:0]), 
                  .imm_8(instruction_d[7:0]), 
                  .imm_11(instruction_d[10:0]), 
                  .immExtSel(immExtSel), 
                  // Outputs
                  .read1Data(read1Data_d), 
                  .read2Data(read2Data_d), 
                  .err(err_decode), 
                  .immExt(immExt_d));

   decode_execute_latch iDELATCH0(// Inputs 
                                 .clk(internal_clock), 
                                 .rst(rst), 
                                 .nop(data_hazard),
                                 // Input followed by latched output
                                 .PC_d(PC_d),
                                 .PC_e(PC_e),
                                 .instruction_d(instruction_d), 
                                 .instruction_e(instruction_e), 
                                 .read1Data_d(read1Data_d), 
                                 .read1Data_e(read1Data_e), 
                                 .read2Data_d(read2Data_d), 
                                 .read2Data_e(read2Data_e), 
                                 .immExt_d(immExt_d), 
                                 .immExt_e(immExt_e), 
                                 .aluSrc_d(aluSrc_d),
                                 .aluSrc_e(aluSrc_e), 
                                 .branch_d(branch_d), 
                                 .branch_e(branch_e), 
                                 .memRead_d(memRead_d), 
                                 .memRead_e(memRead_e), 
                                 .memToReg_d(memToReg_d),
                                 .memToReg_e(memToReg_e), 
                                 .memWrite_d(memWrite_d), 
                                 .memWrite_e(memWrite_e), 
                                 .halt_d(halt_d), 
                                 .halt_e(halt_e), 
                                 .link_d(link_d), 
                                 .link_e(link_e),
                                 .jumpImm_d(jumpImm_d), 
                                 .jumpImm_e(jumpImm_e), 
                                 .jump_d(jump_d), 
                                 .jump_e(jump_e), 
                                 .writeRegSel_d(writeRegSel_d), 
                                 .writeRegSel_e(writeRegSel_e),
                                 .regWrite_d(regWrite_d),
                                 .regWrite_e(regWrite_e));

   alu_control iCONTROL_ALU0(// Inputs
                              .opcode(instruction_e[15:11]), 
                              .extension(instruction_e[1:0]), 
                              // Outputs
                              .aluOp(aluSel));

   execute iEXECUTE0(// Inputs
                     .read1Data(read1Data_e), 
                     .read2Data(read2Data_e), 
                     .aluOp(aluSel), 
                     .aluSrc(aluSrc_e), 
                     .immExt(immExt_e), 
                     // Outputs
                     .aluOut(aluOut_e), 
                     .zf(zero_flag), 
                     .sf(signed_flag), 
                     .of(overflow_flag), 
                     .cf(carry_flag));

   br_control iBRANCH_CONTROL0(// Inputs
                              .zf(zero_flag), 
                              .sf(signed_flag), 
                              .of(overflow_flag), 
                              .cf(carry_flag), 
                              .br_sig(branch_e), 
                              // Outputs
                              .br_contr_sig(br_contr_e));

   execute_memory_latch iEMLATCH0(// Inputs
                                 .clk(internal_clock), 
                                 .rst(rst), 
                                 // Input followed by latched output
                                 .PC_e(PC_e),
                                 .PC_m(PC_m),
                                 .aluOut_e(aluOut_e), 
                                 .aluOut_m(aluOut_m), 
                                 .read2Data_e(read2Data_e), 
                                 .read2Data_m(read2Data_m), 
                                 .memRead_e(memRead_e), 
                                 .memRead_m(memRead_m), 
                                 .memToReg_e(memToReg_e), 
                                 .memToReg_m(memToReg_m), 
                                 .memWrite_e(memWrite_e), 
                                 .memWrite_m(memWrite_m), 
                                 .halt_e(halt_e), 
                                 .halt_m(halt_m), 
                                 .link_e(link_e), 
                                 .link_m(link_m), 
                                 .jumpImm_e(jumpImm_e), 
                                 .jumpImm_m(jumpImm_m), 
                                 .jump_e(jump_e), 
                                 .jump_m(jump_m), 
                                 .read1Data_e(read1Data_e), 
                                 .read1Data_m(read1Data_m), 
                                 .immExt_e(immExt_e), 
                                 .immExt_m(immExt_m), 
                                 .writeRegSel_e(writeRegSel_e), 
                                 .writeRegSel_m(writeRegSel_m),
                                 .regWrite_e(regWrite_e),
                                 .regWrite_m(regWrite_m),
                                 .br_contr_e(br_contr_e),
                                 .br_contr_m(br_contr_m));

   memory memory0(// Inputs
                  .clk(internal_clock), 
                  .rst(rst), 
                  .aluResult(aluOut_m), 
                  .writeData(read2Data_m), 
                  .memWrite(memWrite_m), 
                  .memRead(memRead_m), 
                  .halt(halt_m), 
                  // Outputs
                  .readData(readData_m));

   memory_wb_latch iMWLATCH0(// Inputs
                              .clk(internal_clock), 
                              .rst(rst), 
                              // Input followed by latched output
                              .PC_m(PC_m),
                              .PC_wb(PC_wb),
                              .readData_m(readData_m), 
                              .readData_wb(readData_wb), 
                              .aluOut_m(aluOut_m), 
                              .aluOut_wb(aluOut_wb), 
                              .memToReg_m(memToReg_m), 
                              .memToReg_wb(memToReg_wb),
                              .link_m(link_m), 
                              .link_wb(link_wb), 
                              .writeRegSel_m(writeRegSel_m), 
                              .writeRegSel_wb(writeRegSel_wb),
                              .regWrite_m(regWrite_m),
                              .regWrite_wb(regWrite_wb),
                              .halt_m(halt_m),
                              .halt_wb(haltxout));

   wb iWRITEBACK0(// Inputs
                  .readData(readData_wb), 
                  .addr(aluOut_wb), 
                  .nextPC(PC_wb), 
                  .memToReg(memToReg_wb), 
                  .link(link_wb), 
                  // Outputs
                  .writeData(writeData));
   
endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
