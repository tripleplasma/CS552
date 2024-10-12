/* Filename: right_shift_arith_log.sv
 * Description: A submodule of the barrel shifter module that handles the arithmetic and logical shift right logic.
 * Author: Khiem Vu
 */
module right_shift_arith_log(In, ShAmt, Arith, Out);

    input [15:0] In;
    input [3:0] ShAmt;
    input Arith;
    output [15:0] Out;
    
    wire [15:0] stage1, stage2, stage3;
    
    // shift by one bit
    assign stage1 = (ShAmt[0]) ? 
                        (Arith ? {In[15], In[15:1]}     : // right arithmetic
                                    {1'b0, In[15:1]})   : // right logical
                    In;

    // shift by two bits
    assign stage2 = (ShAmt[1]) ? 
                        (Arith ? {{2{stage1[15]}}, stage1[15:2]}    : // right arithmetic
                                    {2'b00, stage1[15:2]})          : // right logical
                    stage1;

    // shift by four bits
    assign stage3 = (ShAmt[2]) ? 
                        (Arith ? {{4{stage2[15]}}, stage2[15:4]}    : // right arithmetic
                                    {4'h0, stage2[15:4]})           : // right logical
                    stage2;
    
    // shift by eight bits
    assign Out =    (ShAmt[3]) ? 
                        (Arith ? {{8{stage3[15]}}, stage3[15:8]}    : // right arithmetic
                                    {8'h00, stage3[15:8]})          : // right logical
                    stage3;
                    
endmodule