module prescaler_tb;
	reg clk_in = 0;
	wire clk_out;

	always #1 clk_in = ~clk_in;
	prescaler #(.bits(2)) INST (.clk_in(clk_in), .clk_out(clk_out));

	initial begin
		$dumpfile("prescaler_tb.vcd");
		$dumpvars();
		#50 $finish;
	end
endmodule
