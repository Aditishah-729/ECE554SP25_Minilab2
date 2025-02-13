////////////////////////////////////////////////////////
// Module: abs.v     				      //
// Authors: Aditi SHah, Cullen Krasselt		      //
////////////////////////////////////////////////////////

module Abs(input signed [11:0] in, output signed [11:0] out);
	assign out = in > 0 ? in : -in;

endmodule
