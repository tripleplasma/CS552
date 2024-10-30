module hdu (clk, rst, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard);

    input wire clk, rst;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    output wire data_hazard, control_hazard;

    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;

    assign data_hazard = (idExWriteRegister == ifIdReadRegister1    |
                        idExWriteRegister == ifIdReadRegister2      |
                        exMemWriteRegister == ifIdReadRegister1 	|
                        exMemWriteRegister == ifIdReadRegister2 	|
                        memWbWriteRegister == ifIdReadRegister1 	|
                        memWbWriteRegister == ifIdReadRegister2
                        ) ? 1'b1 : 1'b0;

    assign control_hazard = (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;

    register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule