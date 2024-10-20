/* Filename: right_shift_rot_log.sv
 * Description: A submodule of the barrel shifter module that handles the rotate and logical shift right logic.
 * Author: Khiem Vu
 */
module right_shift_rot_log(In, ShAmt, Rotate, Out);

    input [15:0] In;
    input [3:0] ShAmt;
    input Rotate;
    output [15:0] Out;
    
    wire [15:0] stage1, stage2, stage3;
    
    // shift by one bit
    assign stage1 = (ShAmt[0]) ? 
                        (Rotate ? {In[0], In[15:1]}     : // right rotate
                                    {1'b0, In[15:1]})   : // right logical
                    In;

    // shift by two bits
    assign stage2 = (ShAmt[1]) ? 
                        (Rotate ? {{stage1[1:0]}, stage1[15:2]}      : // right rotate
                                    {2'b00, stage1[15:2]})          : // right logical
                    stage1;

    // shift by four bits
    assign stage3 = (ShAmt[2]) ? 
                        (Rotate ? {{stage2[3:0]}, stage2[15:4]}   : // right rotate
                                    {4'h0, stage2[15:4]})           : // right logical
                    stage2;
    
    // shift by eight bits
    assign Out =    (ShAmt[3]) ? 
                        (Rotate ? {{stage3[7:0]}, stage3[15:8]}    : // right rotate
                                    {8'h00, stage3[15:8]})          : // right logical
                    stage3;
                    
endmodule