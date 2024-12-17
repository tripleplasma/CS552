/* Filename: left_shift_rot.sv
 * Description: A submodule of the barrel shifter module that handles the left shift and rotate logic.
 * Author: Khiem Vu
 */
module left_shift_rot(In, ShAmt, Rot, Out);

    input [15:0] In;
    input [3:0] ShAmt;
    input Rot;
    output [15:0] Out;
    
    // intermediate wires for each shift
    wire [15:0] stage1, stage2, stage3;
    
    // shift by one bit
    assign stage1 = (ShAmt[0]) ? 
                        (Rot ? 	{In[14:0], In[15]} : // left rotate
                                {In[14:0], 1'b0})  : // left shift
                    In;

    // shift by two bits
    assign stage2 = (ShAmt[1]) ? 
                        (Rot ? 	{stage1[13:0], stage1[15:14]}   : // left rotate
                                {stage1[13:0], 2'b00})          : // left shift
                    stage1;

    // shift by four bits
    assign stage3 = (ShAmt[2]) ? 
                        (Rot ? 	{stage2[11:0], stage2[15:12]}   : // left rotate
                                {stage2[11:0], 4'h0})           : // left shift
                    stage2;
    
    // shift by eight bits
    assign Out =    (ShAmt[3]) ? 
                        (Rot ? 	{stage3[7:0], stage3[15:8]} : // left rotate
                                {stage3[7:0], 8'h00})       : // left shift
                    stage3;
                    
endmodule