module hdu (clk, rst, PC_m, PC_f, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard, structural_hazard);

    input wire clk, rst;
    input wire [15:0] PC_m, PC_f;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    output wire data_hazard, control_hazard, structural_hazard;

    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    wire [3:0] ifIdWriteRegister_int;

    wire pre_data_hazard, pre_control_hazard;

    assign structural_hazard = pre_data_hazard | pre_control_hazard;

    //TODO: check for correctness, particularly the !== 3'b000 (there becuase of reset at beginning sets everything to 0, stopgap solution that needs to be changed)
    // maybe use a valid bit [3]?
    assign pre_data_hazard = (rst != 1'b1 & 
                        (((^idExWriteRegister !== 1'bx) & (idExWriteRegister == ifIdReadRegister1 | idExWriteRegister == ifIdReadRegister2))   |
                        ((^exMemWriteRegister !== 1'bx) & (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2)) 	|
                        ((^memWbWriteRegister !== 1'bx) & (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2)))) ? 1'b1 : 1'b0;
    // assign data_hazard = 1'b0;

    register #(.REGISTER_WIDTH(1)) DataHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_data_hazard), .readData(data_hazard));

    assign pre_control_hazard = ((opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) & (PC_m != PC_f) & ~(pre_data_hazard)) ? 1'b1 : 1'b0;

    register #(.REGISTER_WIDTH(1)) CtrlHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_control_hazard), .readData(control_hazard));

    assign ifIdWriteRegister_int = (structural_hazard) ? 4'b1111 : ifIdWriteRegister;
    register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister_int), .readData(idExWriteRegister));
    register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule