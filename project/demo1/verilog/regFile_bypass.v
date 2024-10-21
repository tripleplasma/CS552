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
                       clk, rst, read1RegSel, read2RegSel, writeregsel, writedata, write
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeregsel;
   input [15:0] writedata;
   input        write;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   wire [15:0] reg_out[1:0];

   wire [15:0] read1WithBypass, read2WithBypass;
   
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
                .writeRegSel                  (writeregsel[2:0]),
                .writeData                    (writedata[15:0]),
                .writeEn                      (write));

   assign read1WithBypass = (write & (read1RegSel == writeregsel)) ? writedata : reg_out[0];
   assign read2WithBypass = (write & (read2RegSel == writeregsel)) ? writedata : reg_out[1];

   register iREGISTER_0(.clk(clk), .rst(rst), .writeEn(write), .writeData(read1WithBypass), .readData(read1Data));
   register iREGISTER_1(.clk(clk), .rst(rst), .writeEn(write), .writeData(read2WithBypass), .readData(read2Data));
   

endmodule
