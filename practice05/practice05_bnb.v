module block(		q,
					d,
					clk);

	output		q	;

	input		d	;
	input		clk	;

	reg			nl	;
	reg			q	;

	always @ (posedge clk) begin
		nl = d; //blocking
		q = nl; //blocking
	end

endmodule

module nonblock(	q,
					d,
					clk);

	output		q	;
	
	input		d	;
	input		clk	;

	reg			nl	;
	reg			q	;

	always @ (posedge clk) begin
		nl <= d; //nonblocking
		q <= nl; //nonblocking end
	end

endmodule
