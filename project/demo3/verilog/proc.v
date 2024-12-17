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
wire [15:0] pc_in_f, pc_out_f, pc_out_fd, pc_out_de, pc_out_em, pc_out_mw, pc_jmp_out, instruction, instruction_fd;

wire [15:0] write_data, read_data1, read_data2, imm5_ext, imm8_ext, imm11_ext;
wire [15:0] read_data1_de, read_data2_de, imm5_ext_de, imm8_ext_de, imm11_ext_de;
wire [15:0] read_data2_em, imm8_ext_em, mem_addr_out_ex;
wire [15:0] imm8_ext_mw;

wire [15:0] exec_out, exec_out_em, exec_out_mw, instruction_out_d, instruction_q_x, instruction_q_m, instruction_q_w;
wire [15:0] read_data, read_data_mw;

wire [1:0] RegSrc, Instr_Funct_out, Instr_BrchCnd_sel, BSrc, RegSrc_de, Instr_Funct_out_de, Instr_BrchCnd_sel_de, BSrc_de, RegSrc_em, RegSrc_mw;
wire [3:0] ALUOp, ALUOp_de;
wire PCSrc, PCSrc_em;

wire InvA, InvB, MemWrt, Branch, Set, Sub, MemEn, ALUJmp, SLBI, ImmSrc, btr, jmp;
wire InvA_de, InvB_de, MemWrt_de, Branch_de, Set_de, Sub_de, MemEn_de, ALUJmp_de, SLBI_de, ImmSrc_de, btr_de, jmp_de;
wire MemWrt_em, MemEn_em;
wire RegWrt, RegWrt_de, RegWrt_em, RegWrt_mw;
wire [2:0] writeRegSel, writeRegSel_de, writeRegSel_em, writeRegSel_mw;
wire [2:0] RegisterRs, RegisterRt, RegisterRs_de, RegisterRt_de;
wire halt, halt_de, halt_em, halt_mw, hazard, flush;

wire halt_out_f, halt_out_fd, halt_out_de, halt_out_em, halt_out_mw, halt_mem;
wire stall_mem_stg, stall_fetch, done_fetch, done_mem;

// Instantiate fetch module
fetch fetch (
   .clk         	(clk),       
   .rst         	(rst),       
   .halt        	(halt_em),
   .stall_mem_stg	(stall_mem_stg),
   .hazard 			(hazard),
   .flush			(flush),
   .PCSrc			(PCSrc_em),
   .pc_in       	(pc_in_f),
   .stall_out		(stall_fetch),
   .done_out		(done_fetch),
   .halt_out		(halt_out_f),
   .pc_out      	(pc_out_f),
   .instruction_out	(instruction)
);

// 1st pipeline registers (FETCH & DECODE)
if_id if_id (
	.clk			(clk),
	.rst			(rst),
	.pc_out			(pc_out_f),
	.instruction	(instruction),
	.halt_fetch		(halt_out_f),
	.done_fetch		(done_fetch),
	.stall_fetch	(stall_fetch),
	.stall_mem_stg	(stall_mem_stg),
	.halt_fetch_q	(halt_out_fd),
	.pc_out_q		(pc_out_fd),
	.instruction_q	(instruction_fd),
	.flush_in		(flush) //TODO Implement flush
);

// Instantiate decode module
decode decode (
   .clk					(clk),            
   .rst					(rst),
   .stall_mem_stg		(stall_mem_stg),
   .stall_fetch			(stall_fetch),
   .instruction_in		(instruction_fd),
   .instruction_f		(instruction),
   .RegWrt_in			(RegWrt_mw),
   .writeRegSel_in		(writeRegSel_mw),    
   .write_data			(write_data),     
   .read_data1			(read_data1),     
   .read_data2			(read_data2),
   .MemRd				(~MemWrt_de & MemEn_de),  
   .RegisterRs_id_ex	(RegisterRs_de),
   .RegisterRt_id_ex	(RegisterRt_de),   
   .imm5_ext			(imm5_ext),       
   .imm8_ext			(imm8_ext),       
   .imm11_ext			(imm11_ext),      
   .ImmSrc				(ImmSrc),         
   .BSrc				(BSrc),           
   .RegSrc				(RegSrc),         
   .Instr_Funct_out		(Instr_Funct_out),
   .Instr_BrchCnd_sel	(Instr_BrchCnd_sel),
   .ALUOp				(ALUOp),                    
   .InvA				(InvA),           
   .InvB				(InvB),           
   .MemWrt				(MemWrt),
   .RegWrt_out			(RegWrt),
   .writeRegSel_out		(writeRegSel),
   .RegisterRs			(RegisterRs),
   .RegisterRt			(RegisterRt),        
   .Branch				(Branch),         
   .Set					(Set),            
   .Sub					(Sub),            
   .MemEn				(MemEn),          
   .ALUJmp				(ALUJmp),         
   .SLBI				(SLBI),
   .halt				(halt),
   .btr					(btr),
   .jmp					(jmp),
   .write_reg_id_ex     (writeRegSel_de),
   .write_reg_ex_mem    (writeRegSel_em),
   .write_reg_mem_wb    (writeRegSel_mw),
   .write_en_id_ex      (RegWrt_de),
   .write_en_ex_mem     (RegWrt_em),
   .write_en_mem_wb     (RegWrt_mw),
   .hazard				(hazard),
   .PCSrc_X             (PCSrc),
   .flush_out           (flush),
   .instruction_out		(instruction_out_d)
);

// 2nd pipeline registers (DECODE & EXECUTE)
id_ex id_ex (
	.clk					(clk),
	.rst					(rst),
	.pc_out					(pc_out_fd),
	.read_data1				(read_data1),
	.read_data2				(read_data2),
	.imm5_ext				(imm5_ext),
	.imm8_ext				(imm8_ext),
	.imm11_ext				(imm11_ext),
	.ImmSrc					(ImmSrc),
	.BSrc					(BSrc),
	.RegSrc					(RegSrc),
	.Instr_Funct_out		(Instr_Funct_out),
	.Instr_BrchCnd_sel		(Instr_BrchCnd_sel),
	.ALUOp					(ALUOp),
	.InvA					(InvA),
	.InvB					(InvB),
	.MemWrt					(MemWrt),
	.RegWrt					(RegWrt),
	.RegisterRs				(RegisterRs),
	.RegisterRt				(RegisterRt),
	.writeRegSel			(writeRegSel),
	.Branch					(Branch),
	.Set					(Set),
	.Sub					(Sub),
	.MemEn					(MemEn),
	.ALUJmp					(ALUJmp),
	.SLBI					(SLBI),
	.halt					(halt),
	.btr					(btr),
	.jmp					(jmp),
	.stall_mem_stg			(stall_mem_stg),
	.halt_fetch				(halt_out_fd),
	.halt_fetch_q			(halt_out_de),
	.pc_out_q				(pc_out_de),
	.read_data1_q			(read_data1_de),
	.read_data2_q			(read_data2_de),
	.imm5_ext_q				(imm5_ext_de),
	.imm8_ext_q				(imm8_ext_de),
	.imm11_ext_q			(imm11_ext_de),
	.ImmSrc_q				(ImmSrc_de),
	.BSrc_q					(BSrc_de),
	.RegSrc_q				(RegSrc_de),
	.Instr_Funct_out_q		(Instr_Funct_out_de),
	.Instr_BrchCnd_sel_q	(Instr_BrchCnd_sel_de),
	.ALUOp_q				(ALUOp_de),
	.InvA_q					(InvA_de),
	.InvB_q					(InvB_de),
	.MemWrt_q				(MemWrt_de),
	.RegWrt_q				(RegWrt_de),
	.writeRegSel_q			(writeRegSel_de),
	.RegisterRs_q			(RegisterRs_de),
	.RegisterRt_q			(RegisterRt_de),
	.Branch_q				(Branch_de),
	.Set_q					(Set_de),
	.Sub_q					(Sub_de),
	.MemEn_q				(MemEn_de),
	.ALUJmp_q				(ALUJmp_de),
	.SLBI_q					(SLBI_de),
	.halt_q					(halt_de),
	.btr_q					(btr_de),
	.jmp_q					(jmp_de),
	.flush_in				(flush), //TODO Implement flush
	.instruction            (instruction_out_d),
	.instruction_q			(instruction_q_x)
);

// Instantiate execute module
execute execute (
	.exec_out_fmem		((instruction_q_m[15:11]==5'b11000) ? imm8_ext_em : exec_out_em),
	.instruction		(instruction_q_x),
    .write_data         (write_data),              
    .pc_in              (pc_out_de),
	.stall_mem_stg		(stall_mem_stg),
	.RegisterRs_id_ex	(RegisterRs_de),
	.RegisterRt_id_ex	(RegisterRt_de),
	.write_reg_ex_mem   (writeRegSel_em),
   	.write_reg_mem_wb   (writeRegSel_mw),
   	.write_en_ex_mem    (RegWrt_em),
   	.write_en_mem_wb    (RegWrt_mw),              
    .read_data1         (read_data1_de),              
    .read_data2         (read_data2_de),              
    .imm5_ext           (imm5_ext_de),                  
    .imm8_ext           (imm8_ext_de),                  
    .imm11_ext          (imm11_ext_de),                
    .ImmSrc             (ImmSrc_de),                      
    .BSrc               (BSrc_de),                          
    .Instr_Funct_out    (Instr_Funct_out_de),    
    .ALUOp              (ALUOp_de),                                                  
    .ALUJump            (ALUJmp_de),                     
    .InvB               (InvB_de),                          
    .InvA               (InvA_de),                          
    .Sub                (Sub_de),                            
    .Set                (Set_de),                            
    .Branch             (Branch_de),                      
    .SLBI               (SLBI_de),                          
    .BTR                (btr_de),
    .jmp                (jmp_de),
    .Instr_BrchCnd_sel  (Instr_BrchCnd_sel_de),
	.PCSrc				(PCSrc),
    .exec_out           (exec_out),     
	.mem_addr_out		(mem_addr_out_ex),             
    .pc_jmp_out         (pc_jmp_out)
);

// 3rd pipeline registers (EXECUTE & MEMORY)
ex_mem ex_mem (
	.clk			(clk),
	.rst			(rst),
	.halt			(halt_de),
	.PCSrc			(PCSrc),
	.exec_out		(exec_out),
	.pc_jmp_out		(pc_jmp_out),
	.pc_plus_2		(pc_out_de),
	.MemEn			(MemEn_de),
	.MemWrt			(MemWrt_de),
	.RegWrt			(RegWrt_de),
	.writeRegSel	(writeRegSel_de),
	.read_data2		(mem_addr_out_ex),
	.imm8_ext		(imm8_ext_de),
	.RegSrc			(RegSrc_de),
	.stall_mem_stg	(stall_mem_stg),
	.halt_fetch		(halt_out_de),
	.halt_fetch_q	(halt_out_em),
	.halt_q			(halt_em),
	.PCSrc_q		(PCSrc_em),
	.exec_out_q		(exec_out_em),
	.pc_jmp_out_q	(pc_in_f),
	.pc_plus_2_q	(pc_out_em),
	.MemEn_q		(MemEn_em),
	.MemWrt_q		(MemWrt_em),
	.RegWrt_q		(RegWrt_em),
	.writeRegSel_q	(writeRegSel_em),
	.read_data2_q	(read_data2_em),
	.imm8_ext_q		(imm8_ext_em),
	.RegSrc_q		(RegSrc_em),
	.flush_in		(flush),
	.instruction    (instruction_q_x),
	.instruction_q  (instruction_q_m)
);

// Instantiate memory module
memory memory (
    .clk			(clk),                     
    .rst            (rst),
    .mem_en         (MemEn_em),            
    .write_en       (MemWrt_em),         
    .addr_in        (exec_out_em),            
    .write_data_in  (read_data2_em),
    .read_data      (read_data),
	.halt_mem		(halt_mem),
	.stall_out		(stall_mem_stg),
	.done_out		(done_mem)         
);

// 4th pipeline registers (MEMORY & WRITE BACK)
mem_wb mem_wb (
	.clk			(clk),
	.rst			(rst),
	.RegSrc			(RegSrc_em),
	.RegWrt			(RegWrt_em),
	.writeRegSel	(writeRegSel_em),
	.read_data		(read_data),
	.pc_out			(pc_out_em),
	.exec_out		(exec_out_em),
	.imm8_ext		(imm8_ext_em),
	.halt			(halt_em),
	.halt_fetch		(halt_out_em),
	.stall_mem_stg	(stall_mem_stg),
	.done_mem		(done_mem),
	.halt_q			(halt_mw),
	.halt_fetch_q	(halt_out_mw),
	.RegSrc_q		(RegSrc_mw),
	.RegWrt_q		(RegWrt_mw),
	.writeRegSel_q	(writeRegSel_mw),
	.read_data_q	(read_data_mw),
	.pc_out_q		(pc_out_mw),
	.exec_out_q		(exec_out_mw),
	.imm8_ext_q		(imm8_ext_mw),
	.instruction	(instruction_q_m),
	.instruction_q	(instruction_q_w)
);

// Instantiate wb module
wb wb (
    .RegSrc     (RegSrc_mw),       
    .addr       (exec_out_mw),           
    .read_data  (read_data_mw),
    .pc         (pc_out_mw),           
    .imm8_ext   (imm8_ext_mw),
    .write_data (write_data)   
);

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
