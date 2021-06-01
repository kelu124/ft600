// Prescaler that slows down the incoming clock by a specified value
module prescaler (input clk_in, output clk_out);
  	// Specifies how much this prescaler is slowing down the incoming 
	// clock. A "bBits" of 1 will half the incoming clock
  	parameter bits  = 1;

	reg[bits-1:0] counter  = 0;
	always @(posedge clk_in) counter <= counter + 1;
	assign clk_out = counter[bits-1];
endmodule
