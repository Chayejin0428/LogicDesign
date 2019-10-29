module	tb_mux04;

	reg				in0		;
	reg				in1		;
	reg				in2		;
	reg				in3		;

	reg 	[1:0]	sel		;

	wire			out1	;

	wire			out2	;

	wire			out3	;

	mux4to1_inst dut_1(		.in0(in0		),
	   						.in1(in1		),
							.in2(in2		),
							.in3(in3		),
		  					.sel(sel		),
							.out(out1		));

	mux4to1_case dut_2(		.in0(in0		),
	   						.in1(in1		),
							.in2(in2		),
							.in3(in3		),
		  					.sel(sel		),
							.out(out2		));

	mux4to1_if dut_3( 		.in0(in0		),
	   						.in1(in1		),
							.in2(in2		),
							.in3(in3		),
		  					.sel(sel		),
							.out(out3		));

	initial begin
	$display("Mux24to1_inst : out1");
	$display("Mux4to1_if: out2");
	$display("Mux4to1_case: out3");
	$display("=============================================================================================");
	$display("in0	in1	in2	in3	sel	out1	out2	out3");
	$display("=============================================================================================");
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0000_00;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0001_01;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0010_10;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0011_11;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0100_00;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0101_01;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0110_10;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	{in0, in1, in2, in3, sel} = 6'b_0111_11;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", in0, in1, in2, in3, sel, out1, out2, out3);
	#(50)	$finish		;

	end

endmodule


