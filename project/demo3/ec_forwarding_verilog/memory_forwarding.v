module memory_forwarding(
                            //Inputs
                            opcode_m, opcode_wb,
                            memReadReg, read2Data_m,
                            writeRegSel_wb, writeData_wb,
                            //Outputs
                            read2ForwardData_m
                            );
    input wire[4:0] opcode_m, opcode_wb;
    input wire[3:0] memReadReg;
    input wire[15:0] read2Data_m;
    input wire[3:0] writeRegSel_wb;

    input wire[15:0] writeData_wb; 

    output wire[15:0] read2ForwardData_m;

    assign read2ForwardData_m = ((memReadReg == writeRegSel_wb) & ((opcode_m == 5'b10000) & (opcode_wb == 5'b10001))) ? writeData_wb : read2Data_m; 

endmodule