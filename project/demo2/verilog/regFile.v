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

    /* YOUR CODE HERE */
    parameter REGISTER_WIDTH = 16;
    
    // Register storage
    wire [REGISTER_WIDTH-1:0] reg_out[7:0];  // 8 registers, each 16 bits wide
    
    // select register to write
    assign writeReg0 = (writeRegSel == 3'b000) ? 1'b1 : 1'b0;
    assign writeReg1 = (writeRegSel == 3'b001) ? 1'b1 : 1'b0;
    assign writeReg2 = (writeRegSel == 3'b010) ? 1'b1 : 1'b0;
    assign writeReg3 = (writeRegSel == 3'b011) ? 1'b1 : 1'b0;
    assign writeReg4 = (writeRegSel == 3'b100) ? 1'b1 : 1'b0;
    assign writeReg5 = (writeRegSel == 3'b101) ? 1'b1 : 1'b0;
    assign writeReg6 = (writeRegSel == 3'b110) ? 1'b1 : 1'b0;
    assign writeReg7 = (writeRegSel == 3'b111) ? 1'b1 : 1'b0;
   
    // instantiate registers
    register iREGISTER_0(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg0), .writeData(writeData), .readData(reg_out[0]));
    register iREGISTER_1(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg1), .writeData(writeData), .readData(reg_out[1]));
    register iREGISTER_2(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg2), .writeData(writeData), .readData(reg_out[2]));
    register iREGISTER_3(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg3), .writeData(writeData), .readData(reg_out[3]));
    register iREGISTER_4(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg4), .writeData(writeData), .readData(reg_out[4]));
    register iREGISTER_5(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg5), .writeData(writeData), .readData(reg_out[5]));
    register iREGISTER_6(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg6), .writeData(writeData), .readData(reg_out[6]));
    register iREGISTER_7(.clk(clk), .rst(rst), .writeEn(writeEn & writeReg7), .writeData(writeData), .readData(reg_out[7]));

    // set readData
    assign read1Data = reg_out[read1RegSel];
    assign read2Data = reg_out[read2RegSel];

    // set err if any of the inputs are unknown
    assign err = (^read1RegSel === 1'bx) | (^read2RegSel === 1'bx) | (^writeRegSel === 1'bx) | (^writeData === 1'bx) | (writeEn === 1'bx);

endmodule
