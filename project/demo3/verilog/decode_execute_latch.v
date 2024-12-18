module decode_execute_latch(clk, rst, nop, disableIDEXWrite, PC_d, PC_e, instruction_d, instruction_e, read1Data_d, read1Data_e, read2Data_d, read2Data_e, immExt_d, immExt_e, aluSrc_d,
                            aluSrc_e, branch_d, branch_e, memRead_d, memRead_e, memToReg_d, memToReg_e, memWrite_d, memWrite_e, halt_d, halt_e, link_d, link_e, 
                            jumpImm_d, jumpImm_e, jump_d, jump_e, writeRegSel_d, writeRegSel_e, regWrite_d, regWrite_e, instr_mem_align_err_d, instr_mem_align_err_e);

    input wire clk, rst;
    input wire disableIDEXWrite, nop;
    input wire [15:0] PC_d, instruction_d, read1Data_d, read2Data_d, immExt_d;
    input wire halt_d, link_d, memRead_d, memToReg_d, memWrite_d, aluSrc_d, jumpImm_d, jump_d, regWrite_d, instr_mem_align_err_d;
    input wire [2:0] branch_d;
    input wire [3:0] writeRegSel_d;
    output wire [15:0] PC_e, instruction_e, read1Data_e, read2Data_e, immExt_e;
    output wire halt_e, link_e, memRead_e, memToReg_e, memWrite_e, aluSrc_e, jumpImm_e, jump_e, regWrite_e, instr_mem_align_err_e;
    output wire [2:0] branch_e;
    output wire [3:0] writeRegSel_e;

    wire [15:0] instruction_de_int, read1Data_de_int, read2Data_de_int, immExt_de_int;
    wire halt_de_int, link_de_int, memRead_de_int, memToReg_de_int, memWrite_de_int, aluSrc_de_int, jumpImm_de_int, jump_de_int, regWrite_de_int, instr_mem_align_err_de_int;
    wire [2:0] branch_de_int; 
    wire [3:0] writeRegSel_de_int;

    //NOTE: With a Hazard you either overiding a value that shoul persist or you're holding a value too long and thinks its constantly hazarding. You should make sure the bubble is being adding in the right place
    wire [15:0] PC_de_int;

    //NOTE: We move the combinational logic to before we set the value to the latch because it doesn't make sense to latch a bad value then on NOP, we force it to be the right value

    //NOTE: Assumes PC at decode isn't overwritten/ doesnt disappear
    assign PC_de_int = (nop) ? 16'hffff : PC_d; //This is set to fffff simply for debugging purposes like seeing the bubble propagate through the pipeline
    register iPC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(PC_de_int), .readData(PC_e));

    
    assign instruction_de_int = (nop) ? 16'b0000_1000_0000_0000 : instruction_d;
    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(instruction_de_int), .readData(instruction_e));

    assign read1Data_de_int = (nop) ? 16'h0000 : read1Data_d;
    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(read1Data_de_int), .readData(read1Data_e));

    //NOTE: We're doing a check if instruction_d is a NOP because of setFetchNOP propagating through the pipeline
    assign read2Data_de_int = (nop | (instruction_d == 16'b0000_1000_0000_0000)) ? 16'h0000 : read2Data_d;
    register iREAD2DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(read2Data_de_int), .readData(read2Data_e));

    assign immExt_de_int = (nop) ? 16'h0000 : immExt_d;
    register iIMMEXT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(immExt_de_int), .readData(immExt_e));
    
    assign halt_de_int = (nop) ? 1'b0 : halt_d;
    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(halt_de_int), .readData(halt_e));

    assign link_de_int = (nop) ? 1'b0 : link_d;
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(link_de_int), .readData(link_e));

    assign memRead_de_int = (nop) ? 1'b0 : memRead_d;
    register #(.REGISTER_WIDTH(1)) iMEMREAD_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(memRead_de_int), .readData(memRead_e));

    assign memToReg_de_int = (nop) ? 1'b0 : memToReg_d;
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(memToReg_de_int), .readData(memToReg_e));

    assign memWrite_de_int = (nop) ? 1'b0 : memWrite_d;
    register #(.REGISTER_WIDTH(1)) iMEMWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(memWrite_de_int), .readData(memWrite_e));
    
    assign aluSrc_de_int = (nop) ? 1'b0 : aluSrc_d;
    register #(.REGISTER_WIDTH(1)) iALUSRC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(aluSrc_de_int), .readData(aluSrc_e));

    assign jumpImm_de_int = (nop) ? 1'b0 : jumpImm_d;
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(jumpImm_de_int), .readData(jumpImm_e));
    
    assign jump_de_int = (nop) ? 1'b0 : jump_d;
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(jump_de_int), .readData(jump_e));
    
    assign regWrite_de_int = (nop) ? 1'b0 : regWrite_d;
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(regWrite_de_int), .readData(regWrite_e));

    assign instr_mem_align_err_de_int = (nop) ? 1'b0 : instr_mem_align_err_d;
    register #(.REGISTER_WIDTH(1)) iINSTR_MEM_ALIGN_ERR_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(instr_mem_align_err_de_int), .readData(instr_mem_align_err_e));

    register #(.REGISTER_WIDTH(3)) iBRANCH_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(branch_de_int), .readData(branch_e));
    assign branch_de_int = (nop) ? 3'b000 : branch_d;

    //Even though we need 3 bits for registers, we need a fourth bit to indicate invalid because we don't wanna set writeRegSel_e to 3'b000 because our system will think that R0 is being used and thus give false positive data hazards
    assign writeRegSel_de_int = (nop | (instruction_d == 16'b0000_1000_0000_0000)) ? 4'b1111 : writeRegSel_d; 
    register #(.REGISTER_WIDTH(4)) iWRITEREGSEL_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~disableIDEXWrite), .writeData(writeRegSel_de_int), .readData(writeRegSel_e));
    
endmodule