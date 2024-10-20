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
   wire [15:0] instruction;
   wire [2:0] writeRegSel;
   wire [15:0] writeData;
   wire [15:0] read1Data;
   wire [15:0] read2Data;
   wire err_decode;
   wire [15:0] immExt;
   wire [3:0] aluSel;   // change bounds, probably made this too big
   wire [15:0] PC; 
   
   // control signals
   wire halt, jumpImm, link, jump, memRead, memToReg, memWrite, aluSrc, regWrite, invB, exception, br_contr;
   wire internal_clock;
   wire [2:0] branch;
   wire [1:0] regDst;
   wire [2:0] immExtSel;

   //Execute Signals
   wire zero_flag, signed_flag, overflow_flag, carry_flag;
   wire [15:0] aluOut;
   
   // determine control signals based on opcode
   control iCONTROL0(.opcode(instruction[15:11]), .halt(halt), .jumpImm(jumpImm), .link(link), .regDst(regDst), .jump(jump), .branch(branch), .memRead(memRead), 
                    .memToReg(memToReg), .memWrite(memWrite), .aluSrc(aluSrc), .regWrite(regWrite), .immExtSel(immExtSel), .invB(invB), .exception(exception));
   

   br_control iBRANCH_CONTROL0(.zf(zero_flag), .sf(signed_flag), .of(overflow_flag), .cf(carry_flag), .br_sig(branch), .br_contr_sig(br_contr));

   //Fetch
   fetch iFETCH0(.clk(clk), .rst(rst), 
               .halt_sig(halt), .jump_imm_sig(jumpImm), .jump_sig(jump), .except_sig(exception), .br_contr_sig(br_contr), 
               .imm_jump_reg_val(aluOut), .imm_br_val(immExt),
               .instr(instruction), .output_clk(internal_clock), .PC(PC));

   
   //----Want inside decode----
   assign writeRegSel = (regDst == 2'b00) ? instruction[4:2] :
                        (regDst == 2'b01) ? instruction[7:5] :
                        (regDst == 2'b10) ? instruction[10:8] :
                        2'b11;
                        
   // assign writeData = (link) ? PC + 2 : wbData;
   //----END----
   
   decode iDECODE0(.clk(internal_clock), .rst(rst), .read1RegSel(instruction[10:8]), .read2RegSel(instruction[7:5]), .writeRegSel(writeRegSel), .writeData(writeData), .writeEn(regWrite), 
                    .imm_5(instruction[4:0]), .imm_8(instruction[7:0]), .imm_11(instruction[10:0]), .immExtSel(immExtSel), .read1Data(read1Data), .read2Data(read2Data), .err(err_decode), .immExt(immExt));
                    
   alu_control iCONTROL_ALU0(.opcode(instruction[15:11]), .extension(instruction[1:0]), .aluOp(aluSel));

   execute iEXECUTE0(.read1Data(read1Data), .read2Data(read2Data), .aluOp(aluSel), .aluSrc(aluSrc), .immExt(immExt), .aluOut(aluOut), 
                     .zf(zero_flag), .sf(signed_flag), .of(overflow_flag), .cf(carry_flag));

   wire [15:0] readData;
   memory iMEMORY0(.addr(aluOut), .writeData(read2Data), .memWrite(memWrite), .memRead(memRead), .memDump(halt), .clk(internal_clock), .rst(rst), .readData(readData));

   wb iWRITEBACK0(.readData(readData), .addr(aluOut), .nextPC(PC), .memToReg(memToReg), .link(link), .writeData(writeData));
   
endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
