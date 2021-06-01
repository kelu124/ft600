`define TESTBENCH

module blinky_tb;
	reg clk_in = 0;
	wire led;

	always #1 clk_in = ~clk_in;
	top INST(.clk_100mhz(clk_in), .led1(led));

	initial begin
		$dumpfile("blinky_tb.vcd");
		$dumpvars();
		#5000 $finish;
	end
endmodule
