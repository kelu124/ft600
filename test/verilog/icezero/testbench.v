`timescale 1 ns / 1 ps
`define TESTBENCH

module testbench;
	reg clk = 0;
	always #5 clk = ~clk;

	wire sram_a0, sram_a1, sram_a2, sram_a3, sram_a4, sram_a5, sram_a6, sram_a7, sram_a8, sram_a9, sram_a10, sram_a11, sram_a12, sram_a13, sram_a14, sram_a15;
	wire sram_d0, sram_d1, sram_d2, sram_d3, sram_d4, sram_d5, sram_d6, sram_d7, sram_d8, sram_d9, sram_d10, sram_d11, sram_d12, sram_d13, sram_d14, sram_d15;
	wire sram_ce, sram_oe, sram_lb, sram_ub, sram_we;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
		repeat (100000) @(posedge clk);
		$finish;
	end

	top uut (
		.clk_100mhz (clk),

		.sram_a0  (sram_a0 ),
		.sram_a1  (sram_a1 ),
		.sram_a2  (sram_a2 ),
		.sram_a3  (sram_a3 ),
		.sram_a4  (sram_a4 ),
		.sram_a5  (sram_a5 ),
		.sram_a6  (sram_a6 ),
		.sram_a7  (sram_a7 ),
		.sram_a8  (sram_a8 ),
		.sram_a9  (sram_a9 ),
		.sram_a10 (sram_a10),
		.sram_a11 (sram_a11),
		.sram_a12 (sram_a12),
		.sram_a13 (sram_a13),
		.sram_a14 (sram_a14),
		.sram_a15 (sram_a15),
		.sram_d0  (sram_d0 ),
		.sram_d1  (sram_d1 ),
		.sram_d2  (sram_d2 ),
		.sram_d3  (sram_d3 ),
		.sram_d4  (sram_d4 ),
		.sram_d5  (sram_d5 ),
		.sram_d6  (sram_d6 ),
		.sram_d7  (sram_d7 ),
		.sram_d8  (sram_d8 ),
		.sram_d9  (sram_d9 ),
		.sram_d10 (sram_d10),
		.sram_d11 (sram_d11),
		.sram_d12 (sram_d12),
		.sram_d13 (sram_d13),
		.sram_d14 (sram_d14),
		.sram_d15 (sram_d15),
		.sram_ce  (sram_ce ),
		.sram_oe  (sram_oe ),
		.sram_lb  (sram_lb ),
		.sram_ub  (sram_ub ),
		.sram_we  (sram_we )
	);

	sim_sram sram (
		.SRAM_A0  (sram_a0 ),
		.SRAM_A1  (sram_a1 ),
		.SRAM_A2  (sram_a2 ),
		.SRAM_A3  (sram_a3 ),
		.SRAM_A4  (sram_a4 ),
		.SRAM_A5  (sram_a5 ),
		.SRAM_A6  (sram_a6 ),
		.SRAM_A7  (sram_a7 ),
		.SRAM_A8  (sram_a8 ),
		.SRAM_A9  (sram_a9 ),
		.SRAM_A10 (sram_a10),
		.SRAM_A11 (sram_a11),
		.SRAM_A12 (sram_a12),
		.SRAM_A13 (sram_a13),
		.SRAM_A14 (sram_a14),
		.SRAM_A15 (sram_a15),
		.SRAM_D0  (sram_d0 ),
		.SRAM_D1  (sram_d1 ),
		.SRAM_D2  (sram_d2 ),
		.SRAM_D3  (sram_d3 ),
		.SRAM_D4  (sram_d4 ),
		.SRAM_D5  (sram_d5 ),
		.SRAM_D6  (sram_d6 ),
		.SRAM_D7  (sram_d7 ),
		.SRAM_D8  (sram_d8 ),
		.SRAM_D9  (sram_d9 ),
		.SRAM_D10 (sram_d10),
		.SRAM_D11 (sram_d11),
		.SRAM_D12 (sram_d12),
		.SRAM_D13 (sram_d13),
		.SRAM_D14 (sram_d14),
		.SRAM_D15 (sram_d15),
		.SRAM_CE  (sram_ce ),
		.SRAM_OE  (sram_oe ),
		.SRAM_LB  (sram_lb ),
		.SRAM_UB  (sram_ub ),
		.SRAM_WE  (sram_we )
	);
endmodule

