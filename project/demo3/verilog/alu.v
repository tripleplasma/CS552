/*
    CS/ECE 552 FALL '22
    Homework #2, Problem 3

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
module alu (InA, InB, Cin, Oper, invA, invB, Out, Zero, Ofl, Cout);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0
	output						Cout; // Cout for CF flag

	wire [15:0] A, B, shifter_out, sum, out_4_7;
	wire two_comp_overflow, c_out;
	
	// applying inversion to inputs based off inv vars
	assign A = invA ? ~InA : InA;
	assign B = invB ? ~InB : InB;

	shifter iShift (.In(A), .ShAmt(B[3:0]), .Oper(Oper[1:0]), .Out(shifter_out));
	fulladder16 iFA (.A(A), .B(B), .Cin(Cin), .S(sum), .Cout(c_out));

	// mux for operations 4-7
	assign out_4_7 = Oper[1] ? (Oper[0] ? A & B : A ^ B) : (Oper[0] ? A | B : sum);

	// out mux
	assign Out = Oper[2] ? out_4_7 : shifter_out;

	// zero logic
	assign Zero = ~|Out;
	
	// overflow muxes
	assign two_comp_overflow = (A[15] & B[15] & ~sum[15]) | (~A[15] & ~B[15] & sum[15]);
	assign Ofl = (Oper == 3'b100) & two_comp_overflow;	
	assign Cout = (Oper == 3'b100) & c_out;
    
endmodule
