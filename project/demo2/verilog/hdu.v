<<<<<<< HEAD
module hdu (clk, rst, PC_f, PC_m, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard, structural_hazard);

    input wire clk, rst;
    input wire [15:0] PC_f, PC_m;
=======
module hdu (clk, rst, PC_m, PC_f, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard, structural_hazard);

    input wire clk, rst;
    input wire [15:0] PC_m, PC_f;
>>>>>>> c53aaa87bbb5874a37eb9ad38b80642d808801ef
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    output wire data_hazard, control_hazard, structural_hazard;

    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    wire [3:0] ifIdWriteRegister_int;
<<<<<<< HEAD
=======

    wire pre_data_hazard, pre_control_hazard;

    assign structural_hazard = pre_data_hazard | pre_control_hazard;
>>>>>>> c53aaa87bbb5874a37eb9ad38b80642d808801ef

    wire pre_data_hazard, pre_control_hazard;
    assign structural_hazard = pre_control_hazard | pre_data_hazard;
    
    //TODO: check for correctness, particularly the !== 3'b000 (there becuase of reset at beginning sets everything to 0, stopgap solution that needs to be changed)
    // maybe use a valid bit [3]?
    assign pre_data_hazard = (rst != 1'b1 & 
<<<<<<< HEAD
                        (((^idExWriteRegister !== 1'bx & idExWriteRegister !== 4'h0) & (idExWriteRegister == ifIdReadRegister1 | idExWriteRegister == ifIdReadRegister2))   |
                        ((^exMemWriteRegister !== 1'bx & exMemWriteRegister !== 4'h0) & (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2)) 	|
                        ((^memWbWriteRegister !== 1'bx & memWbWriteRegister !== 4'h0) & (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2)))) ? 1'b1 : 1'b0;
=======
                        (((^idExWriteRegister !== 1'bx) & (idExWriteRegister == ifIdReadRegister1 | idExWriteRegister == ifIdReadRegister2))   |
                        ((^exMemWriteRegister !== 1'bx) & (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2)) 	|
                        ((^memWbWriteRegister !== 1'bx) & (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2)))) ? 1'b1 : 1'b0;
>>>>>>> c53aaa87bbb5874a37eb9ad38b80642d808801ef
    // assign data_hazard = 1'b0;

    register #(.REGISTER_WIDTH(1)) DataHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_data_hazard), .readData(data_hazard));

    assign pre_control_hazard = ((opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) & (PC_m != PC_f) & ~(pre_data_hazard)) ? 1'b1 : 1'b0;

    register #(.REGISTER_WIDTH(1)) CtrlHazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(pre_control_hazard), .readData(control_hazard));

<<<<<<< HEAD
    wire latch_control;
    register #(.REGISTER_WIDTH(1)) NopLatch(.clk(clk), .rst(1'b0), .writeEn(1'b1), .writeData(control_hazard), .readData(latch_control));

    assign ifIdWriteRegister_int = (latch_control | data_hazard) ? 4'h0 : ((ifIdWriteRegister == 4'b0000) ? 4'b1111 : ifIdWriteRegister);
=======
    assign ifIdWriteRegister_int = (structural_hazard) ? 4'b1111 : ifIdWriteRegister;
>>>>>>> c53aaa87bbb5874a37eb9ad38b80642d808801ef
    register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister_int), .readData(idExWriteRegister));
    register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule