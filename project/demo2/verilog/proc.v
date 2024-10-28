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

   output reg err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
   wire [15:0] instruction_f, instruction_d, instruction_e;
   wire [2:0] writeRegSel;
   wire [15:0] writeData;
   wire [15:0] read1Data_d, read1Data_e, read1Data_m;
   wire [15:0] read2Data_d, read2Data_e, read2Data_m;
   wire err_decode;
   wire [15:0] immExt_d, immExt_e, immExt_m;
   wire [3:0] aluSel;   // change bounds, probably made this too big
   wire [15:0] PC; 
   
   // hazard signals
   wire control_hazard, data_hazard;

   // control signals
   wire halt_d, halt_e, halt_m;
   wire jumpImm_d, jumpImm_e, jumpImm_m;
   wire link_d, link_e, link_m, link_wb;
   wire jump_d, jump_e, jump_m;
   wire memRead_d, memRead_e, memRead_m;
   wire memToReg_d, memToReg_e, memToReg_m, memToReg_wb;
   wire memWrite_d, memWrite_e, memWrite_m;
   wire aluSrc_d, aluSrc_e;
   wire regWrite;
   wire exception;
   wire br_contr;
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
   fetch fetch0(.clk(clk), .rst(rst), .nop(control_hazard | data_hazard),                                                                    // still a little confused on control_hazard/data_hazard/nop
               .halt_sig(halt_m), .jump_imm_sig(jumpImm_m), .jump_sig(jump_m), .except_sig(exception), .br_contr_sig(br_contr), 
               .imm_jump_reg_val(read1Data_m), .extend_val(immExt_m),
               .instr(instruction_f), .output_clk(internal_clock), .PC_2(PC));
   
   fetch_decode_latch iFDLATCH0(.clk(internal_clock), .rst(rst), .nop(control_hazard), .instruction_f(instruction_f), .instruction_d(instruction_d));  // still a little confused on control_hazard/data_hazard/nop
   
   // determine control signals based on opcode
   control iCONTROL0(.opcode(instruction_d[15:11]), .halt(halt_d), .jumpImm(jumpImm_d), .link(link_d), .regDst(regDst), .jump(jump_d), .branch(branch_d), .memRead(memRead_d), 
                    .memToReg(memToReg_d), .memWrite(memWrite_d), .aluSrc(aluSrc_d), .regWrite(regWrite), .immExtSel(immExtSel), .exception(exception));
   
   //----Want inside decode----
   assign writeRegSel = (regDst == 2'b00) ? instruction_d[4:2] :
                        (regDst == 2'b01) ? instruction_d[7:5] :
                        (regDst == 2'b10) ? instruction_d[10:8] :
                        3'b111;
                        
   // assign writeData = (link) ? PC + 2 : wbData;
   //----END----

   decode decode0(.clk(internal_clock), .rst(rst), .read1RegSel(instruction_d[10:8]), .read2RegSel(instruction_d[7:5]), .writeregsel(writeRegSel), .writedata(writeData), 
                  .write(regWrite), .imm_5(instruction_d[4:0]), .imm_8(instruction_d[7:0]), .imm_11(instruction_d[10:0]), .immExtSel(immExtSel), .read1Data(read1Data_d), 
                  .read2Data(read2Data_d), .err(err_decode), .immExt(immExt_d));

   decode_execute_latch iDELATCH0(.clk(internal_clock), .rst(rst), .nop(data_hazard), .instruction_d(instruction_d), .instruction_e(instruction_e), .read1Data_d(read1Data_d), 
                                 .read1Data_e(read1Data_e), .read2Data_d(read2Data_d), .read2Data_e(read2Data_e), .immExt_d(immExt_d), .immExt_e(immExt_e), .aluSrc_d(aluSrc_d),
                                 .aluSrc_e(aluSrc_e), .branch_d(branch_d), .branch_e(branch_e), .memRead_d(memRead_d), .memRead_e(memRead_e), .memToReg_d(memToReg_d),
                                 .memToReg_e(memToReg_e), .memWrite_d(memWrite_d), .memWrite_e(memWrite_e), .halt_d(halt_d), .halt_e(halt_e), .link_d(link_d), .link_e(link_e),
                                 .jumpImm_d(jumpImm_d), .jumpImm_e(jumpImm_e), .jump_d(jump_d), .jump_e(jump_e));

   alu_control iCONTROL_ALU0(.opcode(instruction_e[15:11]), .extension(instruction_e[1:0]), .aluOp(aluSel));

   execute iEXECUTE0(.read1Data(read1Data_e), .read2Data(read2Data_e), .aluOp(aluSel), .aluSrc(aluSrc_e), .immExt(immExt_e), .aluOut(aluOut_e), 
                     .zf(zero_flag), .sf(signed_flag), .of(overflow_flag), .cf(carry_flag));

   br_control iBRANCH_CONTROL0(.zf(zero_flag), .sf(signed_flag), .of(overflow_flag), .cf(carry_flag), .br_sig(branch_e), .br_contr_sig(br_contr));

   execute_memory_latch iEMLATCH0(.clk(internal_clock), .rst(rst), .aluOut_e(aluOut_e), .aluOut_m(aluOut_m), .read2Data_e(read2Data_e), .read2Data_m(read2Data_m), 
                                 .memRead_e(memRead_e), .memRead_m(memRead_m), .memToReg_e(memToReg_e), .memToReg_m(memToReg_m), .memWrite_e(memWrite_e), .memWrite_m(memWrite_m), 
                                 .halt_e(halt_e), .halt_m(halt_m), .link_e(link_e), .link_m(link_m), .jumpImm_e(jumpImm_e), .jumpImm_m(jumpImm_m), .jump_e(jump_e), .jump_m(jump_m), 
                                 .read1Data_e(read1Data_e), .read1Data_m(read1Data_m), .immExt_e(immExt_e), .immExt_m(immExt_m));

   memory memory0(.aluResult(aluOut_m), .writeData(read2Data_m), .memWrite(memWrite_m), .memRead(memRead_m), .halt(halt_m), .clk(internal_clock), .rst(rst), .readData(readData_m));

   memory_wb_latch iMWLATCH0(.clk(internal_clock), .rst(rst), .readData_m(readData_m), .readData_wb(readData_wb), .aluOut_m(aluOut_m), .aluOut_wb(aluOut_wb), .memToReg_m(memToReg_m), .memToReg_wb(memToReg_wb)
                              .link_m(link_m), .link_wb(link_wb));

   wb iWRITEBACK0(.readData(readData_wb), .addr(aluOut_wb), .nextPC(PC), .memToReg(memToReg_wb), .link(link_wb), .writeData(writeData));
   
endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
