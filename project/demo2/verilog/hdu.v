module hdu (clk, rst, ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister, opcode, data_hazard, control_hazard);

    input wire clk, rst;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2, ifIdWriteRegister;
    input wire [4:0] opcode;
    output wire data_hazard, control_hazard;

    wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;

    //TODO: check for correctness, particularly the !== 3'b000 (there becuase of reset at beginning sets everything to 0, stopgap solution that needs to be changed)
    assign data_hazard = (rst != 1'b1 & 
                        ((^idExWriteRegister !== 1'bx & idExWriteRegister !== 3'b000) & (idExWriteRegister == ifIdReadRegister1 | idExWriteRegister == ifIdReadRegister2))   |
                        ((^exMemWriteRegister !== 1'bx & exMemWriteRegister !== 3'b000) & (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2)) 	|
                        ((^memWbWriteRegister !== 1'bx & memWbWriteRegister !== 3'b000) & (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2))) ? 1'b1 : 1'b0;
    // assign data_hazard = 1'b0;

    assign control_hazard = (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;

    register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule