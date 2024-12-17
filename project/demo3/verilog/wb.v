/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (
   input  wire [1:0]    RegSrcSel,
   input  wire [15:0]   Addr,
   input  wire [15:0]   Read_Data,
   input  wire [15:0]   PC,
   input  wire [15:0]   Imm8_Ext,
   output wire [15:0]   Write_Data
);

assign Write_Data =  RegSrcSel == 2'b00 ? PC : 
                     (RegSrcSel == 2'b01 ? Read_Data : 
                     (RegSrcSel == 2'b10 ? Addr : 
                     (RegSrcSel == 2'b11 ? Imm8_Ext : 16'b0)));
endmodule
`default_nettype wire
