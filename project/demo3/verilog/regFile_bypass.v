/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   wire [15:0] reg_out[1:0];
   
   regFile iRF0(
                // Outputs
                .read1Data                    (reg_out[0]),
                .read2Data                    (reg_out[1]),
                .err                          (err),
                // Inputs
                .clk                          (clk),
                .rst                          (rst),
                .read1RegSel                  (read1RegSel[2:0]),
                .read2RegSel                  (read2RegSel[2:0]),
                .writeRegSel                  (writeRegSel[2:0]),
                .writeData                    (writeData[15:0]),
                .writeEn                      (writeEn));
   
   // Remove bypassing for now
   assign read1Data = (writeEn & (read1RegSel == writeRegSel)) ? writeData : reg_out[0];
   assign read2Data = (writeEn & (read2RegSel == writeRegSel)) ? writeData : reg_out[1];

endmodule
