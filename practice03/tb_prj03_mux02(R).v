module	tb_mux02;


	reg		in0			;
	reg		in1			;
	reg		sel			;

	wire	out1		;

	wire	out2		;

	wire	out3		;
		
	mux2to1_cond dut_1(		.in0(in0		),
	   						.in1(in1		),
		  					.sel(sel		),
							.out(out1		));

	mux2to1_if dut_2(		.in0(in0		),
	   						.in1(in1		),
		  					.sel(sel		),
							.out(out2		));

	mux2to1_case dut_3( 	.in0(in0		),
	   						.in1(in1		),
		  					.sel(sel		),
							.out(out3		));

	initial begin
	$display("Mux2to1_cond : out1");
	$display("Mux2to1_if: out2");
	$display("Mux2to1_case: out3");
	$display("=============================================================================================");
	$display("in0	in1	sel	out1	out2	out3");
	$display("=============================================================================================");
	#(50)	{in0, in1, sel} = 3'b_000;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_001;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_010;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_011;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_100;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_101;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_110;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	{in0, in1, sel} = 3'b_111;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in0, in1, sel, out1, out2, out3);
	#(50)	$finish		;

	end

endmodule

