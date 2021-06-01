`include "prescaler.v"

module top (
	input clk_100mhz,
	output led1
);
	// Clock Generator
	wire clk_16mhz, pll_locked;
`ifdef TESTBENCH
	assign clk_16mhz = clk_100mhz, pll_locked = 1;
`else

	SB_PLL40_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.PLLOUT_SELECT("GENCLK"),
		.FDA_FEEDBACK(4'b1111),
		.FDA_RELATIVE(4'b1111),
		.DIVR(4'b0011),		// DIVR =  3
		.DIVF(7'b0101000),	// DIVF = 40
		.DIVQ(3'b110),		// DIVQ =  6
		.FILTER_RANGE(3'b010)	// FILTER_RANGE = 2
	) pll (
		.PACKAGEPIN   (clk_100mhz),
		.PLLOUTGLOBAL (clk_16mhz ),
		.LOCK         (pll_locked),
		.BYPASS       (1'b0      ),
		.RESETB       (1'b1      )
	);
`endif

	// Blink LED with ~2 Hz
	wire clk_2hz;
	prescaler #(.bits(23)) ps1(.clk_in(clk_16mhz), .clk_out(clk_2hz));
	assign led1 = clk_2hz;
endmodule
