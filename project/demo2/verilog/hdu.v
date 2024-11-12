module hdu (clk, rst, PC_f, PC_m, ifIdReadRegister1, ifIdReadRegister2, 
            writeRegSel_e, writeRegSel_m, writeRegSel_wb, instruction_e, instruction_m, instruction_d, instruction_f,
            opcode, data_hazard, control_hazard, structural_hazard, pre_data_hazard);

    input wire clk, rst;
    input wire [15:0] PC_f, PC_m;
    input wire [15:0] instruction_f, instruction_m, instruction_e, instruction_d;
    input wire [2:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [2:0] writeRegSel_e, writeRegSel_m, writeRegSel_wb;
    input wire [4:0] opcode;

    output wire data_hazard, control_hazard, structural_hazard, pre_data_hazard;

    wire pre_control_hazard;
    assign structural_hazard = pre_control_hazard | pre_data_hazard;

    // Set to true after first instruciton so don't have false hazard before any instruction runs
    wire not_first;
    assign not_first = |instruction_e & ~rst;

    wire ignoreReg2;
    wire [4:0]opcode_d;
    assign opcode_d = instruction_d[15:11];
    assign ignoreReg2 = (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011 | opcode_d == 5'b11000) ? 1'b1 : 1'b0;

    wire [15:0] instruction_wb;
    register InstrWBLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(instruction_m), .readData(instruction_wb));

    //TODO: check for correctness, particularly the !== 3'b000 (there becuase of reset at beginning sets everything to 0, stopgap solution that needs to be changed)
    // maybe use a valid bit [3]?
    assign pre_data_hazard = (rst != 1'b1 & 
                        (((^writeRegSel_e !== 1'bx) & (writeRegSel_e == ifIdReadRegister1 | ((writeRegSel_e == ifIdReadRegister2) & ~ignoreReg2)))   |
                        ((^writeRegSel_m !== 1'bx) & (writeRegSel_m == ifIdReadRegister1 | ((writeRegSel_m == ifIdReadRegister2) & ~ignoreReg2))) 	|
                        ((^writeRegSel_wb !== 1'bx) & (writeRegSel_wb == ifIdReadRegister1 | ((writeRegSel_wb == ifIdReadRegister2) & ~ignoreReg2)))) & 
                        (not_first & ((instruction_m != 16'b0000_1000_0000_0000) | (instruction_wb == 16'b0000_1000_0000_0000)) & (instruction_d != 16'b0000_1000_0000_0000))) ? 1'b1 : 1'b0;
    // assign data_hazard = 1'b0;

    //assign data_hazard = pre_data_hazard;
    register #(.REGISTER_WIDTH(1)) DataHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_data_hazard), .readData(data_hazard));

    assign pre_control_hazard = ((opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) & ~pre_data_hazard & (instruction_m != instruction_f)) ? 1'b1 : 1'b0;
    //  & (instruction_m != instruction_f)

    register #(.REGISTER_WIDTH(1)) CtrlHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_control_hazard & ((instruction_d == instruction_f) | instruction_d == 16'b0000_1000_0000_0000)), .readData(control_hazard));

endmodule