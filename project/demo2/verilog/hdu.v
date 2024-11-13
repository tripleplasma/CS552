module hdu (clk, rst, opcode, 
                    ifIdReadRegister1, ifIdReadRegister2,
                    PC_e, PC_m, PC_wb,
                    idExWriteRegister, exMemWriteRegister, memWbWriteRegister,
                    disablePCWrite, disableIFIDWrite, insertNOP);

    input wire clk, rst;
    input wire[15:0] PC_e, PC_m, PC_wb;
    input wire [4:0] opcode;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    output wire disablePCWrite, disableIFIDWrite, insertNOP;


    //TODO: Check if the opcode is a valid R type instruction so that we don't confuse immediate bits for register names


    wire data_hazard = (rst == 1'b0) & ((idExWriteRegister == ifIdReadRegister1  | idExWriteRegister == ifIdReadRegister2 & |PC_e)      |
                                        (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2 & |PC_m)     |
                                        (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2 & |PC_wb));
    // assign data_hazard = 1'b0;

    // register #(.REGISTER_WIDTH(1)) HazardLatch(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(structural_hazard), .readData(data_hazard));
    //This opcode is the opcode from the most latest fetched instruction
    wire control_hazard = (opcode[4:2] == 3'b001 | opcode[4:2] == 3'b011) ? 1'b1 : 1'b0;

    assign disablePCWrite = data_hazard | control_hazard | insertNOP;
    assign disableIFIDWrite = data_hazard | control_hazard | insertNOP;

    // wire insertNOP_int;
    // assign insertNOP = data_hazard & insertNOP_int;
    register #(.REGISTER_WIDTH(1)) insertNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_hazard), .readData(insertNOP));

    // assign ifIdWriteRegister_int = (structural_hazard) ? 4'b1111 : ifIdWriteRegister;
    // register #(.REGISTER_WIDTH(4)) IdExWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(ifIdWriteRegister), .readData(idExWriteRegister));
    // register #(.REGISTER_WIDTH(4)) ExMemWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(idExWriteRegister), .readData(exMemWriteRegister));
    // register #(.REGISTER_WIDTH(4)) MemWbWriteReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(exMemWriteRegister), .readData(memWbWriteRegister));

endmodule