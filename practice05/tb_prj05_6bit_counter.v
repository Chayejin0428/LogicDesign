`timescale 1ns/1ns
module tb_cnt;

	parameter tCK = 1000/50			; //50MHz clock

	reg					clk			;
	reg					rst_n		;	

	wire 	[5:0] 		out			;

	initial 			clk = 1'b0	;
	always	# (tCK/2)	clk = ~clk	;

	cnt6	dut(	.out	(out),
					.clk	(clk),
					.rst_n	(rst_n));

	initial begin
	# (0*tCK) rst_n = 1'b0			;
	# (1*tCK) rst_n = 1'b1			;
	# (100*tCK)	$finish				;

	end

endmodule

module top_cnt(out,	num,	clk,	rst_n)	;
	
	output	[5:0]		out			;

	input	[31:0]		num			;
	input				clk			;
	input				rst_n		;

	wire				clk_1hz		;

	nco		u_nco(	.clk_1hz(clk_1hz),
					.num	(num),
					.clk	(clk),
					.rst_n	(rst_n));

	cnt6	u_cnt6(	.out	(out),
					.clk	(clk_1hz),
					.rst_n	(rst_n));

endmodule
