module hdu (clk, rst, PC_e, PC_m, PC_wb, ifIdReadRegister1, ifIdReadRegister2, 
            writeRegSel_e, writeRegSel_m, writeRegSel_wb, instruction_f, instruction_d, instruction_e, instruction_m,
            opcode, data_hazard, control_hazard, structural_hazard, pre_data_hazard);

    input wire clk, rst;
    input wire [15:0] PC_e, PC_m, PC_wb;
    input wire [15:0] instruction_f, instruction_d, instruction_e, instruction_m;
    input wire [2:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [2:0] writeRegSel_e, writeRegSel_m, writeRegSel_wb;
    input wire [4:0] opcode;

    output wire data_hazard, control_hazard, structural_hazard, pre_data_hazard;

    wire pre_control_hazard, jal_hazard, control_hazard_int;

    wire ifIdNop, idExNop, exMemNop, memWbNop;
    wire ignoreReg2;
    wire [4:0] opcode_d;

    // assign structural_hazard = (opcode_d == 5'b0_0001) ? 1'b0 : pre_control_hazard | pre_data_hazard;
    assign structural_hazard = pre_control_hazard | pre_data_hazard;

    assign opcode_d = instruction_d[15:11];
    assign ignoreReg2 = (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011 | opcode_d == 5'b11000) ? 1'b1 : 1'b0;

    wire [15:0] instruction_wb;
    register InstrWBLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_m), .readData(instruction_wb));

    //TODO: check for correctness, particularly the !== 3'b000 (there becuase of reset at beginning sets everything to 0, stopgap solution that needs to be changed)
    // maybe use a valid bit [3]?
    assign pre_data_hazard = (rst != 1'b1 &  
                    (((^writeRegSel_e !== 1'bx) & (idExNop) & (writeRegSel_e == ifIdReadRegister1 | ((writeRegSel_e == ifIdReadRegister2) & ~ignoreReg2)) & |PC_e)   |
                    ((^writeRegSel_m !== 1'bx) & (exMemNop) & (writeRegSel_m == ifIdReadRegister1 | ((writeRegSel_m == ifIdReadRegister2) & ~ignoreReg2)) & |PC_m) 	|
                    ((^writeRegSel_wb !== 1'bx) & (memWbNop) & (writeRegSel_wb == ifIdReadRegister1 | ((writeRegSel_wb == ifIdReadRegister2) & ~ignoreReg2)) & |PC_wb)) & 
                    (((instruction_m != 16'b0000_1000_0000_0000) | (instruction_wb == 16'b0000_1000_0000_0000)) & (instruction_d != 16'b0000_1000_0000_0000))) ? 1'b1 : 1'b0;
    
    // assign data_hazard = 1'b0;

    //assign data_hazard = pre_data_hazard;
    register #(.REGISTER_WIDTH(1)) DataHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_data_hazard), .readData(data_hazard));

    assign pre_control_hazard = ((~ifIdNop) & (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) & ~pre_data_hazard & ~((instruction_m == instruction_f) & (instruction_d == 16'b0000_1000_0000_0000) & (instruction_e == 16'b0000_1000_0000_0000))) ? 1'b1 : 1'b0;
    //  & (instruction_m != instruction_f)
    assign jal_hazard = ((~idExNop) & (opcode[4:1] == 4'b0011) & ~pre_data_hazard & ~((instruction_m == instruction_f) & (instruction_d == 16'b0000_1000_0000_0000) & (instruction_e == 16'b0000_1000_0000_0000) & (instruction_m == 16'b0000_1000_0000_0000))) ? 1'b1 : 1'b0;

    assign control_hazard_int = (opcode[4:1] == 4'b0011) ? jal_hazard : pre_control_hazard;
    register #(.REGISTER_WIDTH(1)) CtrlHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData((control_hazard_int) & ((instruction_d == instruction_f) | instruction_d == 16'b0000_1000_0000_0000)), .readData(control_hazard));

    assign ifIdNop = (opcode == 5'b0_0001) ? 1'b1 : 1'b0;
    register #(.REGISTER_WIDTH(1)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdNop), .readData(idExNop));
    register #(.REGISTER_WIDTH(1)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExNop), .readData(exMemNop));
    register #(.REGISTER_WIDTH(1)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemNop), .readData(memWbNop));

    // wire latch_control;
    // register #(.REGISTER_WIDTH(1)) NopLatch(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(control_hazard), .readData(latch_control));

    // assign ifIdWriteRegister = (control_hazard | pre_data_hazard) ? 4'h0 : (
    //                             (writeRegSel_d == 3'b000) ? 4'b1111 : {1'b0, writeRegSel_d});
    // register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    // register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    // register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule