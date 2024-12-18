/* Filename: register.v
 * Description: A variable-width register used by the register file and created using D-Flip Flops.
 * Author: Khiem Vu
 */
module register(clk, rst, writeEn, writeData, readData);
    
    parameter REGISTER_WIDTH = 16;

    input clk, rst, writeEn;
    input [REGISTER_WIDTH-1:0] writeData;
    output [REGISTER_WIDTH-1:0] readData;
    
    // Intermediate wires to determine if we should write data or not
    wire [REGISTER_WIDTH-1:0] newData;
    wire [REGISTER_WIDTH-1:0] currentData;

    // determine whether to write the data or maintain state
    assign newData = (writeEn) ? writeData : currentData;
    
    // Instantiate DFFs for each register bit
    dff iDFF [REGISTER_WIDTH-1:0] (.q(currentData), .d(newData), .clk(clk), .rst(rst));
    
    // determine data to be read
    assign readData = currentData;

endmodule
