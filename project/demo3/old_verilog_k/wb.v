/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (
   input  wire [1:0]    RegSrc,
   input  wire [15:0]   addr,
   input  wire [15:0]   read_data,
   input  wire [15:0]   pc,
   input  wire [15:0]   imm8_ext,
   output wire [15:0]   write_data
);

reg [15:0] write_data_d;

always @(*) begin
   case(RegSrc)
      2'b00 : write_data_d = pc;
      2'b01 : write_data_d = read_data;
      2'b10 : write_data_d = addr;
      2'b11 : write_data_d = imm8_ext;
      default : write_data_d = 16'h0000;
   endcase
end

assign write_data = write_data_d;
   
endmodule
`default_nettype wire
