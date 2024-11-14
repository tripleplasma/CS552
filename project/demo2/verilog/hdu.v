module hdu (clk, rst, 
                    opcode_f, opcode_d, opcode_e, opcode_m,
                    ifIdReadRegister1, ifIdReadRegister2,
                    PC_e, PC_m, PC_wb,
                    idExWriteRegister, exMemWriteRegister, memWbWriteRegister,
                    disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP);

    input wire clk, rst;
    input wire[15:0] PC_e, PC_m, PC_wb;
    input wire [4:0] opcode_f, opcode_d, opcode_e, opcode_m;
    input wire [3:0] ifIdReadRegister1, ifIdReadRegister2;
    input wire [3:0] idExWriteRegister, exMemWriteRegister, memWbWriteRegister;
    output wire disablePCWrite, disableIFIDWrite, setExNOP, setFetchNOP;


    //TODO: Check if the opcode_f is a valid R type instruction so that we don't confuse immediate bits for register names
    //TODO: make a check to make sure that the instructions at those stages aren't NOPs otherwise it'll think R0 is being used
    wire data_hazard = (rst == 1'b0) & ((idExWriteRegister == ifIdReadRegister1  | idExWriteRegister == ifIdReadRegister2 & |PC_e)      |
                                        (exMemWriteRegister == ifIdReadRegister1 | exMemWriteRegister == ifIdReadRegister2 & |PC_m)     |
                                        (memWbWriteRegister == ifIdReadRegister1 | memWbWriteRegister == ifIdReadRegister2 & |PC_wb));


    wire control_hazard =   (opcode_f[4:2] == 3'b001 | opcode_f[4:2] == 3'b011) | 
                            (opcode_d[4:2] == 3'b001 | opcode_d[4:2] == 3'b011) |
                            (opcode_e[4:2] == 3'b001 | opcode_e[4:2] == 3'b011) | 
                            (opcode_m[4:2] == 3'b001 | opcode_m[4:2] == 3'b011) ;

    assign disablePCWrite = data_hazard | control_hazard | setExNOP;
    assign disableIFIDWrite = (data_hazard | setExNOP);

    //These signals require a register because they need to be delayed a cycle to properly tell the pipeline to input a NOP during the E or F phase
    // wire l = data_hazard & opcode_f == 5'b00001;
    wire setFetchNOP_int = (control_hazard & ~data_hazard) | (control_hazard & data_hazard & opcode_f == 5'b00001) ;
    register #(.REGISTER_WIDTH(1)) setFetchNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(setFetchNOP_int), .readData(setFetchNOP));

    register #(.REGISTER_WIDTH(1)) setExNOPReg(.clk(clk), .rst(rst), .writeEn(1'b1), .writeData(data_hazard), .readData(setExNOP));
endmodule