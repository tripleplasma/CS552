/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (/* TODO: Add appropriate input wires/output wires for your decode stage here*/
                // input wires
                clk, rst, read1RegSel, read2RegSel, writeregsel, writedata, write, imm_5, imm_8, imm_11, immExtSel,
                // output wires
                read1Data, read2Data, err, immExt
                );
                
    // TODO: Your code here
    input wire        clk, rst;
    input wire [2:0]  read1RegSel;
    input wire [2:0]  read2RegSel;
    input wire [2:0]  writeregsel;
    input wire [15:0] writedata;
    input wire        write;
    input wire [4:0]  imm_5;
    input wire [7:0]  imm_8;
    input wire [10:0] imm_11;
    input wire [2:0]  immExtSel;

    output wire [15:0] read1Data;
    output wire [15:0] read2Data;
    output wire        err;
    output wire [15:0] immExt;
    
    
    // bypass register file
    regFile_bypass regFile0(
                         // output wires
                         .read1Data                    (read1Data[15:0]),
                         .read2Data                    (read2Data[15:0]),
                         .err                          (err),
                         // input wires
                         .clk                          (clk),
                         .rst                          (rst),
                         .read1RegSel                  (read1RegSel[2:0]),
                         .read2RegSel                  (read2RegSel[2:0]),
                         .writeregsel                  (writeregsel[2:0]),
                         .writedata                    (writedata[15:0]),
                         .write                        (write));
    
    // register file with no bypass, not sure if we're using it or not.
    // regFile iRF0(
                // // output wires
                // .read1Data                    (read1Data[15:0]),
                // .read2Data                    (reg_out[1]),
                // .err                          (err),
                // // input wires
                // .clk                          (clk),
                // .rst                          (rst),
                // .read1RegSel                  (read1RegSel[2:0]),
                // .read2RegSel                  (read2RegSel[2:0]),
                // .writeregsel                  (writeregsel[2:0]),
                // .writeData                    (writeData[15:0]),
                // .writeEn                      (writeEn));
                
    // zero/sign-extension module
    extension iEXTENSION0(.imm_5(imm_5), .imm_8(imm_8), .imm_11(imm_11), .immExtSel(immExtSel), . immExt(immExt));
   
endmodule
`default_nettype wire
