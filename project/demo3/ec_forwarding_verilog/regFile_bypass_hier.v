/*
 CS/ECE 552, Fall '22
 Homework #3, Problem #2
 
 Wrapper module around 8x16b register file with bypassing.

 YOU SHALL NOT EDIT THIS FILE. ANY CHANGES TO THIS FILE WILL
 RESULT IN ZERO FOR THIS PROBLEM.
 */
module regFile_bypass_hier (
                            // Outputs
                            read1Data, read2Data, 
                            // Inputs
                            read1RegSel, read2RegSel, writeregsel, writedata, write
                            );

   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeregsel;
   input [15:0] writedata;
   input        write;

   output [15:0] read1Data;
   output [15:0] read2Data;

   wire          clk, rst;
   wire          err;

   // Ignore err for now
   clkrst clk_generator(.clk(clk), .rst(rst), .err(err) );
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
                         .writeregsel                  (writeregsel[2:0]),
                         .writedata                    (writedata[15:0]),
                         .write                      (write));

endmodule
