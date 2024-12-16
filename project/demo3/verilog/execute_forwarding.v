module execute_forwarding(
                            //Inputs
                            read1RegSel_e, read2RegSel_e,
                            writeRegSel_m, aluOut_m, 
                            writeRegSel_wb, writeData_wb,
                            read1Data_e, read2Data_e, //This is the read1Data value that was in the ID/EX latch
                            //Outputs
                            read1ForwardData_e,
                            read2ForwardData_e
                            );
    //Need to know which registers execute needs
    input wire[2:0] read1RegSel_e, read2RegSel_e;
    input wire[15:0] read1Data_e, read2Data_e;
    input wire[3:0] writeRegSel_m, writeRegSel_wb;

    //   For EX-EX forwarding, For MEM-EX forwarding
    input wire[15:0] aluOut_m, writeData_wb; 

    output wire[15:0] read1ForwardData_e, read2ForwardData_e;

    wire canExExForward1 = (read1RegSel_e == writeRegSel_m);
    wire canExExForward2 = (read2RegSel_e == writeRegSel_m);
    wire canMemExForward1 = (read1RegSel_e == writeRegSel_wb);
    wire canMemExForward2 = (read2RegSel_e == writeRegSel_wb);

    //NOTE: We will always be using the Ex-Ex forwarding in the case where both are available since it has the latest value
    //NOTE: We assume the HDU will handle hazards correctly for these 2 lines to work correctly
    assign read1ForwardData_e = canExExForward1 ? (aluOut_m) : (canMemExForward1 ? (writeData_wb) : read1Data_e);
    assign read2ForwardData_e = canExExForward2 ? (aluOut_m) : (canMemExForward2 ? (writeData_wb) : read2Data_e);

endmodule