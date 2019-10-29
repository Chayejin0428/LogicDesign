module	tb_decoder;

	wire	[7:0]	out		;

	reg		[2:0]	in		;
	reg				en		;

//-----------------------------------------------------
// Instances
//-----------------------------------------------------

	dec3to8_shift dut0(	.out(out1		),
						.in	(in			), 
						.en	(en			));
			
	dec3to8_case dut1(	.out(out2		),
						.in	(in			), 
						.en	(en			));

//-----------------------------------------------------
// Stimulus
//-----------------------------------------------------

	initial begin
	$display("dec3to8_shift : out1");
	$display("dec3to8_case : out2");
	$display("=============================================================================================");
	$display("in[0]	in[1]	in[2]	en	out1	out2");
	$display("=============================================================================================");
	#(50)	{in[0], in[1], in[2], en} = 4'b0000;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0001;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0010;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0011;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0100;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0101;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0110;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b0111;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1000;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1001;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1010;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1011;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1100;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1101;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1110;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	{in[0], in[1], in[2], en} = 4'b1111;	#(50)	$display("%b\t%b\t%b\t%b\t%b\t%b", in[0], in[1], in[2], en, out1, out2);
	#(50)	$finish		;

	end

endmodule


