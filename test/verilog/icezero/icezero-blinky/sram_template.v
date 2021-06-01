
module top (
	output led1,
	output reg sram_ce, sram_we, sram_oe, sram_lb, sram_ub,
	output sram_a0, sram_a1, sram_a2, sram_a3, sram_a4, sram_a5, sram_a6, sram_a7,
	output sram_a8, sram_a9, sram_a10, sram_a11, sram_a12, sram_a13, sram_a14, sram_a15, sram_a16, sram_a17, sram_a18,
	inout sram_d0, sram_d1, sram_d2, sram_d3, sram_d4, sram_d5, sram_d6, sram_d7,
	inout sram_d8, sram_d9, sram_d10, sram_d11, sram_d12, sram_d13, sram_d14, sram_d15,
	input clk_100mhz
);
	// Memory Interface (not used, but here if you need it)
	reg [18:0] sram_addr;
	reg [15:0] sram_dout;
	wire [15:0] sram_din;

	assign {sram_a18, sram_a17, sram_a16, sram_a15, sram_a14, sram_a13, sram_a12, sram_a11, sram_a10,
			sram_a9, sram_a8, sram_a7, sram_a6, sram_a5, sram_a4, sram_a3, sram_a2, sram_a1, sram_a0 } = sram_addr;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) sram_dio [15:0] (
		.PACKAGE_PIN({sram_d15, sram_d14, sram_d13, sram_d12, sram_d11, sram_d10, sram_d9, sram_d8,
				sram_d7, sram_d6, sram_d5, sram_d4, sram_d3, sram_d2, sram_d1, sram_d0}),
		.OUTPUT_ENABLE(sram_oe),
		.D_OUT_0(sram_dout),
		.D_IN_0(sram_din)
	);

	// Clock Generator
	wire clk, pll_locked;

`ifdef TESTBENCH
	assign clk = clk_100mhz, pll_locked = 1;
`else
	wire clk_16mhz;
	reg clk_8mhz = 0, clk_4mhz = 0, clk_2mhz = 0;

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

	// always @(posedge clk_16mhz) clk_8mhz <= !clk_8mhz;
	// always @(posedge clk_8mhz) clk_4mhz <= !clk_4mhz;
	// always @(posedge clk_4mhz) clk_2mhz <= !clk_2mhz;
	assign clk = clk_16mhz;
`endif

	// Reset Generator
	reg [7:0] resetstate = 0;
	reg resetn = 0;

	always @(posedge clk) begin
		resetstate <= pll_locked ? resetstate + !(&resetstate) : 0;
		resetn <= &resetstate;
	end

	// Blink LED with ~2 Hz
	reg[21:0] ledCounter = 0;
	always @(posedge clk) begin
		ledCounter <= ledCounter + 1;
	end
	assign led1 = ledCounter[21];
endmodule
