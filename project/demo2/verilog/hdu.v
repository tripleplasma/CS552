module hdu (clk, rst, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard);

    input wire clk, rst;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    output wire data_hazard, control_hazard;

    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;

    assign data_hazard = (idExWriteRegister == ifIdRegister1    |
                        idExWriteRegister == ifIdRegister2      |
                        exMemWriteRegister == ifIdRegister1 	|
                        exMemWriteRegister == ifIdRegister2 	|
                        memWbWriteRegister == ifIdRegister1 	|
                        memWbWriteRegister == ifIdRegister2
                        ) ? 1'b1 : 1'b0;

    assign control_hazard = (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;

    register IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    register ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule