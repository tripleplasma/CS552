/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
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

   wire [15:0] reg_in  [7:0];
   wire [15:0] reg_out [7:0];
   parameter DATA_WIDTH = 16;
   
   assign reg_in[0] = (writeEn & writeRegSel == 3'h0) ? writeData : reg_out[0];
   assign reg_in[1] = (writeEn & writeRegSel == 3'h1) ? writeData : reg_out[1];
   assign reg_in[2] = (writeEn & writeRegSel == 3'h2) ? writeData : reg_out[2];
   assign reg_in[3] = (writeEn & writeRegSel == 3'h3) ? writeData : reg_out[3];
   assign reg_in[4] = (writeEn & writeRegSel == 3'h4) ? writeData : reg_out[4];
   assign reg_in[5] = (writeEn & writeRegSel == 3'h5) ? writeData : reg_out[5];
   assign reg_in[6] = (writeEn & writeRegSel == 3'h6) ? writeData : reg_out[6];
   assign reg_in[7] = (writeEn & writeRegSel == 3'h7) ? writeData : reg_out[7];

   reg1 dff0 (.clk(clk), .rst(rst), .d(reg_in[0]), .q(reg_out[0]));
   reg1 dff1 (.clk(clk), .rst(rst), .d(reg_in[1]), .q(reg_out[1]));
   reg1 dff2 (.clk(clk), .rst(rst), .d(reg_in[2]), .q(reg_out[2]));
   reg1 dff3 (.clk(clk), .rst(rst), .d(reg_in[3]), .q(reg_out[3]));
   reg1 dff4 (.clk(clk), .rst(rst), .d(reg_in[4]), .q(reg_out[4]));
   reg1 dff5 (.clk(clk), .rst(rst), .d(reg_in[5]), .q(reg_out[5]));
   reg1 dff6 (.clk(clk), .rst(rst), .d(reg_in[6]), .q(reg_out[6]));
   reg1 dff7 (.clk(clk), .rst(rst), .d(reg_in[7]), .q(reg_out[7]));

   assign read1Data = reg_out[read1RegSel];
   assign read2Data = reg_out[read2RegSel];

   assign err = (^read1RegSel === 1'bx | ^read2RegSel === 1'bx | 
                 ^writeRegSel === 1'bx | ^writeData === 1'bx | 
                  writeEn === 1'bx | writeEn === 1'bz);

endmodule
