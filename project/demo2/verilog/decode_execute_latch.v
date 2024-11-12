module decode_execute_latch(clk, rst, nop, PC_d, PC_e, instruction_d, instruction_e, read1Data_d, read1Data_e, read2Data_d, read2Data_e, immExt_d, immExt_e, aluSrc_d,
                            aluSrc_e, branch_d, branch_e, memRead_d, memRead_e, memToReg_d, memToReg_e, memWrite_d, memWrite_e, halt_d, halt_e, link_d, link_e, 
                            jumpImm_d, jumpImm_e, jump_d, jump_e, writeRegSel_d, writeRegSel_e, regWrite_d, regWrite_e);

    input wire clk, rst;
    input wire nop;
    input wire [15:0] PC_d, instruction_d, read1Data_d, read2Data_d, immExt_d;
    input wire halt_d, link_d, memRead_d, memToReg_d, memWrite_d, aluSrc_d, jumpImm_d, jump_d, regWrite_d;
    input wire [2:0] branch_d, writeRegSel_d;
    output wire [15:0] PC_e, instruction_e, read1Data_e, read2Data_e, immExt_e;
    output wire halt_e, link_e, memRead_e, memToReg_e, memWrite_e, aluSrc_e, jumpImm_e, jump_e, regWrite_e;
    output wire [2:0] branch_e, writeRegSel_e;

    wire [15:0] instruction_de_int, read1Data_de_int, read2Data_de_int, immExt_de_int;
    wire halt_de_int, link_de_int, memRead_de_int, memToReg_de_int, memWrite_de_int, aluSrc_de_int, jumpImm_de_int, jump_de_int, regWrite_de_int;
    wire [2:0] branch_de_int, writeRegSel_de_int;

    wire [15:0] PC_int;
    register iPC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(~nop), .writeData(PC_d), .readData(PC_int));
    assign PC_e = (nop) ? PC_e : PC_int;
    register iINSTRUCTION_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_d), .readData(instruction_de_int));              // rchanged writeEn from ~nop to 1, unsure about it here due to other signals
    assign instruction_e = (nop) ? 16'b0000_1000_0000_0000 : instruction_de_int;

    register iREAD1DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read1Data_d), .readData(read1Data_e));
    //assign read1Data_e = (nop) ? 16'h0000 : read1Data_de_int;
    register iREAD2DATA_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(read2Data_d), .readData(read2Data_e));
    //assign read2Data_e = (nop) ? 16'h0000 : read2Data_de_int;
    register iIMMEXT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(immExt_d), .readData(immExt_e));
    //assign immExt_e = (nop) ? 16'h0000 : immExt_de_int;

    register #(.REGISTER_WIDTH(1)) iHALT_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(halt_d), .readData(halt_de_int));
    assign halt_e = (nop) ? 1'b0 : halt_de_int;
    register #(.REGISTER_WIDTH(1)) iLINK_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(link_d), .readData(link_de_int));
    assign link_e = (nop) ? 1'b0 : link_de_int;
    register #(.REGISTER_WIDTH(1)) iMEMREAD_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memRead_d), .readData(memRead_de_int));
    assign memRead_e = (nop) ? 1'b0 : memRead_de_int;
    register #(.REGISTER_WIDTH(1)) iMEMTOREG_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memToReg_d), .readData(memToReg_de_int));
    assign memToReg_e = (nop) ? 1'b0 : memToReg_de_int;
    register #(.REGISTER_WIDTH(1)) iMEMWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(memWrite_d), .readData(memWrite_de_int));
    assign memWrite_e = (nop) ? 1'b0 : memWrite_de_int;
    register #(.REGISTER_WIDTH(1)) iALUSRC_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(aluSrc_d), .readData(aluSrc_de_int));
    assign aluSrc_e = (nop) ? 1'b0 : aluSrc_de_int;
    register #(.REGISTER_WIDTH(1)) iJUMPIMM_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jumpImm_d), .readData(jumpImm_de_int));
    assign jumpImm_e = (nop) ? 1'b0 : jumpImm_de_int;
    register #(.REGISTER_WIDTH(1)) iJUMP_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(jump_d), .readData(jump_de_int));
    assign jump_e = (nop) ? 1'b0 : jump_de_int;
    register #(.REGISTER_WIDTH(1)) iREGWRITE_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(regWrite_d), .readData(regWrite_de_int));
    assign regWrite_e = (nop) ? 1'b0 : regWrite_de_int;

    register #(.REGISTER_WIDTH(3)) iBRANCH_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(branch_d), .readData(branch_de_int));
    assign branch_e = (nop) ? 3'b000 : branch_de_int;
    register #(.REGISTER_WIDTH(3)) iWRITEREGSEL_LATCH_DE(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(writeRegSel_d), .readData(writeRegSel_e));
    //assign writeRegSel_e = (nop) ? 3'b000 : writeRegSel_de_int;
    
endmodule