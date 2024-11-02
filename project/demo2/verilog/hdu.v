module hdu (clk, rst, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, memRead_d, memRead_e, memRead_m, data_hazard, control_hazard, exExForward1, exExForward2, memExForward1, memExForward2, memMemForward);

    input wire clk, rst;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    input wire memRead_d, memRead_e, memRead_m; // used to determine if lw
    output wire data_hazard, control_hazard, exExForward1, exExForward2, memExForward1, memExForward2, memMemForward;

    wire [3:0] idExReadRegister1, idExReadRegister2, exMemReadRegister1; // exMemReadRegister2
    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;

    // only stall on load?
    assign data_hazard = (idExWriteRegister == ifIdReadRegister1 & (memRead_d)    |   // not sure how to stall if we're forwarding, currently it's going to stall before it forwards
                        idExWriteRegister == ifIdReadRegister2 & (memRead_d)      |   // maybe add conditionals based on certain opcodes (e.g. if lw, stall?)
                        exMemWriteRegister == ifIdReadRegister1  & (memRead_e)	|   // need to discuss
                        exMemWriteRegister == ifIdReadRegister2 & (memRead_e) 	// |
//                      memWbWriteRegister == ifIdReadRegister1 	|
//                      memWbWriteRegister == ifIdReadRegister2
                        ) ? 1'b1 : 1'b0;

    assign exExForward1 = ((exMemWriteRegister == idExReadRegister1) & (~control_hazard) & (~memRead_m)) ? 1'b1 : 1'b0;
    assign exExForward2 = ((exMemWriteRegister == idExReadRegister2) & (~control_hazard) & (~nemRead_m)) ? 1'b1 : 1'b0;
    assign memExForward1 = ((memWbWriteRegister == idExReadRegister1) & (~control_hazard)) ? 1'b1 : 1'b0;
    assign memExForward2 = ((memWbWriteRegister == idExReadRegister2) & (~control_hazard)) ? 1'b1 : 1'b0;
    assign memMemForward = ((memWbWriteRegister == exMemReadRegister1) & (~control_hazard)) ? 1'b1 : 1'b0; // I think it's register1 for load/store, but correct if wrong

    assign control_hazard = (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;

    register #(.REGISTER_WIDTH(4)) IdExReadReg1(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdReadRegister1), .readData(idExReadRegister1));
    register #(.REGISTER_WIDTH(4)) IdExReadReg2(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdReadRegister2), .readData(idExReadRegister2));
    register #(.REGISTER_WIDTH(4)) ExMemReadReg1(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExReadRegister1), .readData(exMemReadRegister1));
    // register #(.REGISTER_WIDTH(4)) ExMemReadReg2(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExReadRegister2), .readData(exMemReadRegister2));

    register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule