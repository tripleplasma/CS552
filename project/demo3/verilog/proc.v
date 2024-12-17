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

// Signal declarations
wire [15:0] PC_jmp_m, PC_f, PC_d, PC_e, PC_m, PC_wb, PC_jmp_e;
wire [15:0] instruction_f, instruction_fd, instruction_d, instruction_e, instruction_m, instruction_wb;

wire [15:0] writeData;
wire [15:0] read1Data_d, read1Data_e;
wire [15:0] read2Data_d, read2Data_e, read2Data_em, read2Data_m;

//TODO: substitute
wire [15:0] imm5Ext_d, imm5Ext_e;
wire [15:0] imm8Ext_d, imm8Ext_e, imm8Ext_m, imm8Ext_wb;
wire [15:0] imm11Ext_d, imm11Ext_e;
wire immExtSel_d, immExtSel_e;

wire [15:0] aluOut_e, aluOut_m, aluOut_wb;
wire [15:0] readData_m, readData_wb;

wire [1:0] wbSel_d, wbSel_e, wbSel_m, wbSel_wb; // combo of link and memToReg signals
wire [1:0] B_int_d, B_int_e;
wire [1:0] extension_d, extension_e;
wire [1:0] branchSel_d, branchSel_e;
wire [3:0] aluOp_d, aluOp_e;
wire PCSrc_d, PCSrc_m;

wire invA_d, invA_e;
wire invB_d, invB_e;
wire subtract_d, subtract_e;
wire shift_d, shift_e;
wire branch_d, branch_e;
wire jmp_d, jmp_e;
wire aluJmp_d, aluJmp_e;
wire slbi_d, slbi_e;
wire btr_d, btr_e;
wire memEnable_d, memEnable_e, memEnable_m;
// wire memRead_d, memRead_e, memRead_m;
// wire memToReg_d, memToReg_e, memToReg_m, memToReg_wb; // might not need
wire memWrite_d, memWrite_e, memWrite_m;

wire regWrite_d, regWrite_e, regWrite_m, regWrite_wb;
wire [2:0] writeRegSel_d, writeRegSel_e, writeRegSel_m, writeRegSel_wb;
wire [2:0] regRs_d, regRt_d, regRs_e, regRt_e;
wire halt_d, halt_e, halt_m, halt_wb;

wire data_hazard, flush;

wire instrMem_err_f, instrMem_err_d, instrMem_err_e, instrMem_err_m, instrMem_err_wb;
wire dataMem_err_m;
wire dataMem_stall, instrMem_stall, instrMem_done, dataMem_done;

// Instantiate fetch module
fetch fetch (// Inputs
			.clk(clk),       
			.rst(rst),       
			.halt_sig(halt_m),
			.dataMem_stall(dataMem_stall),
			.data_hazard(data_hazard),
			.flush(flush),
			.PCSrc_m(PCSrc_m),
			.PC_jmp_m(PC_jmp_m),
			// Outputs
			.instrMem_stall(instrMem_stall),
			.instrMem_done(instrMem_done),
			.instrMem_err_f(instrMem_err_f),
			.PC_f(PC_f),
			.instruction_f(instruction_f));

fetch_decode_latch iFD (// Inputs
						.clk(clk),
						.rst(rst),
						.PC_f(PC_f),
						.instruction_f(instruction_f),
						.flush(flush),
						.instrMem_err_f(instrMem_err_f),
						.instrMem_done(instrMem_done),
						.dataMem_stall(dataMem_stall),
						// Outputs
						.instrMem_err_d(instrMem_err_d),
						.PC_d(PC_d),
						.instruction_fd(instruction_fd));

// Instantiate decode module
decode decode (// Inputs
   .clk					(clk),            
   .rst					(rst),
   .stall_mem_stg		(dataMem_stall),
   .stall_fetch			(instrMem_stall),
   .instruction_in		(instruction_fd),
   .instruction_f		(instruction_f),
   .RegWrt_in			(regWrite_wb),
   .writeRegSel_in		(writeRegSel_wb),    
   .write_data			(writeData),     
   .read_data1			(read1Data_d),     
   .read_data2			(read2Data_d),
   .MemRd				(~memWrite_e & memEnable_e),  
   .RegisterRs_id_ex	(regRs_e),
   .RegisterRt_id_ex	(regRt_e),   
   .imm5_ext			(imm5Ext_d),       
   .imm8_ext			(imm8Ext_d),       
   .imm11_ext			(imm11Ext_d),      
   .ImmSrc				(immExtSel_d),         
   .BSrc				(B_int_d),           
   .RegSrc				(wbSel_d),         
   .Instr_Funct_out		(extension_d),
   .Instr_BrchCnd_sel	(branchSel_d),
   .ALUOp				(aluOp_d),                    
   .InvA				(invA_d),           
   .InvB				(invB_d),           
   .MemWrt				(memWrite_d),
   .RegWrt_out			(regWrite_d),
   .writeRegSel_out		(writeRegSel_d),
   .RegisterRs			(regRs_d),
   .RegisterRt			(regRt_d),        
   .Branch				(branch_d),         
   .Set					(shift_d),            
   .Sub					(subtract_d),            
   .MemEn				(memEnable_d),          
   .ALUJmp				(aluJmp_d),         
   .SLBI				(slbi_d),
   .halt				(halt_d),
   .btr					(btr_d),
   .jmp					(jmp_d),
   .write_reg_id_ex     (writeRegSel_e),
   .write_reg_ex_mem    (writeRegSel_m),
   .write_reg_mem_wb    (writeRegSel_wb),
   .write_en_id_ex      (regWrite_e),
   .write_en_ex_mem     (regWrite_m),
   .write_en_mem_wb     (regWrite_wb),
   .hazard				(data_hazard),
   .PCSrc_X             (PCSrc_d),
   .flush_out           (flush),
   .instruction_out		(instruction_d)
);

// 2nd pipeline registers (DECODE & EXECUTE)
id_ex id_ex (// Inputs
	.clk					(clk),
	.rst					(rst),
	.pc_out					(PC_d),
	.read_data1				(read1Data_d),
	.read_data2				(read2Data_d),
	.imm5_ext				(imm5Ext_d),
	.imm8_ext				(imm8Ext_d),
	.imm11_ext				(imm11Ext_d),
	.ImmSrc					(immExtSel_d),
	.BSrc					(B_int_d),
	.RegSrc					(wbSel_d),
	.Instr_Funct_out		(extension_d),
	.Instr_BrchCnd_sel		(branchSel_d),
	.ALUOp					(aluOp_d),
	.InvA					(invA_d),
	.InvB					(invB_d),
	.MemWrt					(memWrite_d),
	.RegWrt					(regWrite_d),
	.RegisterRs				(regRs_d),
	.RegisterRt				(regRt_d),
	.writeRegSel			(writeRegSel_d),
	.Branch					(branch_d),
	.Set					(shift_d),
	.Sub					(subtract_d),
	.MemEn					(memEnable_d),
	.ALUJmp					(aluJmp_d),
	.SLBI					(slbi_d),
	.halt					(halt_d),
	.btr					(btr_d),
	.jmp					(jmp_d),
	.stall_mem_stg			(dataMem_stall),
	.halt_fetch				(instrMem_err_d),
	// Outputs
	.halt_fetch_q			(instrMem_err_e),
	.pc_out_q				(PC_e),
	.read_data1_q			(read1Data_e),
	.read_data2_q			(read2Data_e),
	.imm5_ext_q				(imm5Ext_e),
	.imm8_ext_q				(imm8Ext_e),
	.imm11_ext_q			(imm11Ext_e),
	.ImmSrc_q				(immExtSel_e),
	.BSrc_q					(B_int_e),
	.RegSrc_q				(wbSel_e),
	.Instr_Funct_out_q		(extension_e),
	.Instr_BrchCnd_sel_q	(branchSel_e),
	.ALUOp_q				(aluOp_e),
	.InvA_q					(invA_e),
	.InvB_q					(invB_e),
	.MemWrt_q				(memWrite_e),
	.RegWrt_q				(regWrite_e),
	.writeRegSel_q			(writeRegSel_e),
	.RegisterRs_q			(regRs_e),
	.RegisterRt_q			(regRt_e),
	.Branch_q				(branch_e),
	.Set_q					(shift_e),
	.Sub_q					(subtract_e),
	.MemEn_q				(memEnable_e),
	.ALUJmp_q				(aluJmp_e),
	.SLBI_q					(slbi_e),
	.halt_q					(halt_e),
	.btr_q					(btr_e),
	.jmp_q					(jmp_e),
	.flush_in				(flush), //TODO Implement flush
	.instruction            (instruction_d),
	.instruction_q			(instruction_e)
);

// Instantiate execute module
execute execute ( // Inputs
	.exec_out_fmem		((instruction_m[15:11]==5'b11000) ? imm8Ext_m : aluOut_m),
	.instruction		(instruction_e),
    .write_data         (writeData),              
    .pc_in              (PC_e),
	.stall_mem_stg		(dataMem_stall),
	.RegisterRs_id_ex	(regRs_e),
	.RegisterRt_id_ex	(regRt_e),
	.write_reg_ex_mem   (writeRegSel_m),
   	.write_reg_mem_wb   (writeRegSel_wb),
   	.write_en_ex_mem    (regWrite_m),
   	.write_en_mem_wb    (regWrite_wb),              
    .read_data1         (read1Data_e),              
    .read_data2         (read2Data_e),              
    .imm5_ext           (imm5Ext_e),                  
    .imm8_ext           (imm8Ext_e),                  
    .imm11_ext          (imm11Ext_e),                
    .ImmSrc             (immExtSel_e),                      
    .BSrc               (B_int_e),                          
    .Instr_Funct_out    (extension_e),    
    .ALUOp              (aluOp_e),                                                  
    .ALUJump            (aluJmp_e),                     
    .InvB               (invB_e),                          
    .InvA               (invA_e),                          
    .Sub                (subtract_e),                            
    .Set                (shift_e),                            
    .Branch             (branch_e),                      
    .SLBI               (slbi_e),                          
    .BTR                (btr_e),
    .jmp                (jmp_e),
    .Instr_BrchCnd_sel  (branchSel_e),
	.PCSrc				(PCSrc_d),
    .exec_out           (aluOut_e),     
	.mem_addr_out		(read2Data_em),             
    .pc_jmp_out         (PC_jmp_e));

// 3rd pipeline registers (EXECUTE & MEMORY)
ex_mem ex_mem (// Inputs
	.clk			(clk),
	.rst			(rst),
	.halt			(halt_e),
	.PCSrc			(PCSrc_d),
	.exec_out		(aluOut_e),
	.pc_jmp_out		(PC_jmp_e),
	.pc_plus_2		(PC_e),
	.MemEn			(memEnable_e),
	.MemWrt			(memWrite_e),
	.RegWrt			(regWrite_e),
	.writeRegSel	(writeRegSel_e),
	.read_data2		(read2Data_em),
	.imm8_ext		(imm8Ext_e),
	.RegSrc			(wbSel_e),
	.stall_mem_stg	(dataMem_stall),
	.halt_fetch		(instrMem_err_e),
	// Outputs
	.halt_fetch_q	(instrMem_err_m),
	.halt_q			(halt_m),
	.PCSrc_q		(PCSrc_m),
	.exec_out_q		(aluOut_m),
	.pc_jmp_out_q	(PC_jmp_m),
	.pc_plus_2_q	(PC_m),
	.MemEn_q		(memEnable_m),
	.MemWrt_q		(memWrite_m),
	.RegWrt_q		(regWrite_m),
	.writeRegSel_q	(writeRegSel_m),
	.read_data2_q	(read2Data_m),
	.imm8_ext_q		(imm8Ext_m),
	.RegSrc_q		(wbSel_m),
	.flush_in		(flush),
	.instruction    (instruction_e),
	.instruction_q  (instruction_m)
);

// Instantiate memory module
memory memory (// Inputs
    .clk			(clk),                     
    .rst            (rst),
    .mem_en         (memEnable_m),            
    .write_en       (memWrite_m),         
    .addr_in        (aluOut_m),            
    .write_data_in  (read2Data_m),
	// Outputs
    .read_data      (readData_m),
	.halt_mem		(dataMem_err_m),
	.stall_out		(dataMem_stall),
	.done_out		(dataMem_done)         
);

// 4th pipeline registers (MEMORY & WRITE BACK)
mem_wb mem_wb (// Inputs
	.clk			(clk),
	.rst			(rst),
	.RegSrc			(wbSel_m),
	.RegWrt			(regWrite_m),
	.writeRegSel	(writeRegSel_m),
	.read_data		(readData_m),
	.pc_out			(PC_m),
	.exec_out		(aluOut_m),
	.imm8_ext		(imm8Ext_m),
	.halt			(halt_m),
	.halt_fetch		(instrMem_err_m),
	.stall_mem_stg	(dataMem_stall),
	.done_mem		(dataMem_done),
	// Outputs
	.halt_q			(halt_wb),
	.halt_fetch_q	(instrMem_err_wb),
	.RegSrc_q		(wbSel_wb),
	.RegWrt_q		(regWrite_wb),
	.writeRegSel_q	(writeRegSel_wb),
	.read_data_q	(readData_wb),
	.pc_out_q		(PC_wb),
	.exec_out_q		(aluOut_wb),
	.imm8_ext_q		(imm8Ext_wb),
	.instruction	(instruction_m),
	.instruction_q	(instruction_wb));

// Instantiate wb module
wb wb (
    .RegSrc     (wbSel_wb),       
    .addr       (aluOut_wb),           
    .read_data  (readData_wb),
    .pc         (PC_wb),           
    .imm8_ext   (imm8Ext_wb),
    .write_data (writeData)   
);

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
