/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (/* TODO: Add appropriate inputs/outputs for your decode stage here*/
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn, imm_5, imm_8, imm_11, immExtSel,
                // Outputs
                read1Data, read2Data, err, immExt
                );
                
    // TODO: Your code here
    input        clk, rst;
    input [2:0]  read1RegSel;
    input [2:0]  read2RegSel;
    input [2:0]  writeRegSel;
    input [15:0] writeData;
    input        writeEn;
    input [4:0]  imm_5;
    input [7:0]  imm_8;
    input [10:0] imm_11;
    input [2:0]  immExtSel;

    output [15:0] read1Data;
    output [15:0] read2Data;
    output        err;
    output [15:0] immExt;
    
    
    // bypass register file
    regFile_bypass rf_b_0(
                         // Outputs
                         .read1Data                    (read1Data[15:0]),
                         .read2Data                    (read2Data[15:0]),
                         .err                          (err),
                         // Inputs
                         .clk                          (clk),
                         .rst                          (rst),
                         .read1RegSel                  (read1RegSel[2:0]),
                         .read2RegSel                  (read2RegSel[2:0]),
                         .writeRegSel                  (writeRegSel[2:0]),
                         .writeData                    (writeData[15:0]),
                         .writeEn                      (writeEn));
    
    // register file with no bypass, not sure if we're using it or not.
    // regFile iRF0(
                // // Outputs
                // .read1Data                    (read1Data[15:0]),
                // .read2Data                    (reg_out[1]),
                // .err                          (err),
                // // Inputs
                // .clk                          (clk),
                // .rst                          (rst),
                // .read1RegSel                  (read1RegSel[2:0]),
                // .read2RegSel                  (read2RegSel[2:0]),
                // .writeRegSel                  (writeRegSel[2:0]),
                // .writeData                    (writeData[15:0]),
                // .writeEn                      (writeEn));
                
    // zero/sign-extension module
    extension iEXTENSION0(.imm_5(imm_5), .imm_8(imm_8), .imm_11(imm_11), .immExtSel(immExtSel), . immExt(immExt));
   
endmodule
`default_nettype wire
