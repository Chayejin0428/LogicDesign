//	--------------------------------------------------
//	Clock Controller (nco, debounce, controller)
//	--------------------------------------------------
module	nco(	
		o_gen_clk,
		i_nco_num,
		clk,
		rst_n);

output		o_gen_clk	;				// generate 1Hz CLK

input	[31:0]	i_nco_num	;				// (like cnt) 1~50M switching
input		clk		;				// 50Mhz CLK
input		rst_n		;

reg	[31:0]	cnt		;				// (like i_nco_num) 1~25M twice switching
reg		o_gen_clk	;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin					// start all 0
			cnt	  <= 32'd0		;
			o_gen_clk <= 1'd0		;
	end else begin
		if(cnt >= i_nco_num/2-1) begin			
			cnt 	  <= 32'd0		;
			o_gen_clk <= ~o_gen_clk		;	// each 25M cnt, clk_1hz = ~clk_1hz
		end else begin
			cnt <= cnt + 1'b1;
		end
	end
end

endmodule

module  debounce(
		o_sw,
		i_sw,
		clk);
output		o_sw			;

input		i_sw			;
input		clk			;

reg		dly1_sw			;
always @(posedge clk) begin
	dly1_sw <= i_sw;
end

reg		dly2_sw			;
always @(posedge clk) begin
	dly2_sw <= dly1_sw;
end

assign		o_sw = dly1_sw | ~dly2_sw;

endmodule


module	controller(
		o_mode,
		o_position,

		o_sec_clk,
		o_min_clk,
		o_hour_clk,		// hour clk o
		
		o_sw_ssec_clk,         // stop watch clk
      		o_sw_sec_clk,      
      		o_sw_min_clk,      

		i_max_hit_sec,
		i_max_hit_min,
		i_max_hit_hour,		// hit hour o ( max: 24)

		i_sw_hit_sec,         // sw hit
      		i_sw_hit_ssec,
      		i_sw_hit_min,         

		o_alarm_sec_clk,
		o_alarm_min_clk,
		o_alarm_hour_clk,	// alarm hour clk

		o_alarm_en1,
		o_alarm_en2,

		o_stopwatch_en,
		o_am_pm_en,		

		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		
		i_sw6,
		i_sw7,

		clk,
		rst_n,
		dis_hour,
		dis_min,
		dis_sec);

output	[2:0]	o_mode			;  	// clock=0, move=1, alarm=2
output	[1:0]	o_position		; 	// hour, min, sec position 

output		o_sec_clk		;
output		o_min_clk		;
output		o_hour_clk		;  	// hour clk o => for only clock

output		o_alarm_en1		;
output		o_alarm_en2		;

output	[1:0]	o_stopwatch_en		;	// stop_watch state
output		o_am_pm_en		;

output		o_alarm_sec_clk 	;
output		o_alarm_min_clk 	;
output		o_alarm_hour_clk	;	// alarm hour clk

output      	o_sw_ssec_clk      	;
output      	o_sw_sec_clk      	;
output     	o_sw_min_clk      	;   	// sw clk

output		dis_hour		;
output		dis_min			;
output		dis_sec			;

input		i_max_hit_sec		;
input		i_max_hit_min		;
input		i_max_hit_hour		;  	// hit hour nessary o (max:24)

input      	i_sw_hit_sec      	;
input      	i_sw_hit_ssec      	;
input      	i_sw_hit_min      	;   

input		i_sw0			;
input 		i_sw1			;
input 		i_sw2			; 
input		i_sw3			;  	// alarm button , when 0, no alarm, when 1, alarm ring
input		i_sw4			;	// at stopwatch, stop button

input		i_sw6			;
input		i_sw7			;

input		clk			;
input		rst_n			;

parameter	MODE_CLOCK	= 3'd0	;
parameter	MODE_SETUP	= 3'd1	;
parameter	MODE_ALARM	= 3'd2	;  	// alarm mode
parameter	MODE_STOPWATCH= 3'd3	;
parameter	MODE_SYDNEY_CLOCK = 3'd4;	// world clock ( sydney  )
parameter	MODE_LONDON_CLOCK = 3'd5;	// world clock ( london )

parameter 
		POS_SEC	 = 2'd0		,
		POS_MIN	 = 2'd1		,
		POS_HOUR = 2'd2		;

wire		clk_100hz		;
nco		u0_nco(
		.o_gen_clk	( clk_100hz	),
		.i_nco_num	( 32'd500000	),
		.clk		( clk		),
		.rst_n		( rst_n		));



wire		sw0			;
debounce	u0_debounce(
		.o_sw		( sw0		),
		.i_sw		( i_sw0		),
		.clk		( clk_100hz	));

wire		sw1			;
debounce	u1_debounce(
		.o_sw		( sw1		),
		.i_sw		( i_sw1		),
		.clk		( clk_100hz	));

wire		sw2			;
debounce	u2_debounce(
		.o_sw		( sw2		),
		.i_sw		( i_sw2		),
		.clk		( clk_100hz	));

wire		sw3			;
debounce	u3_debounce(
		.o_sw		( sw3		),
		.i_sw		( i_sw3		),
		.clk		( clk_100hz	));

wire		sw4			;
debounce	u4_debounce(
		.o_sw		( sw4		),
		.i_sw		( i_sw4		),
		.clk		( clk_100hz	));

wire		sw6			;
debounce	u6_debounce(
		.o_sw		( sw6		),
		.i_sw		( i_sw6		),
		.clk		( clk_100hz	));

wire		sw7			;
debounce	u7_debounce(
		.o_sw		( sw7		),
		.i_sw		( i_sw7		),
		.clk		( clk_100hz	));

/// at blink using

wire		dis_hour		;

nco		u_nco0(					
		.o_gen_clk	( dis_hour	),
		.i_nco_num	( 32'd50000000	),	// 1 sec , clk change
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		dis_min			;

nco		u_nco1(					
		.o_gen_clk	( dis_min	),
		.i_nco_num	( 32'd50000000	),	// 1 sec , clk change
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		dis_sec			;

nco		u_nco2(					
		.o_gen_clk	( dis_sec	),
		.i_nco_num	( 32'd50000000	),	// 1 sec , clk change
		.clk		( clk		),
		.rst_n		( rst_n		));



reg  [2:0]	o_mode			;	// clock, move, alarm

always @(posedge sw0 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_mode <= MODE_CLOCK;
	end else begin
		if(o_mode >= MODE_LONDON_CLOCK) begin
			o_mode <= MODE_CLOCK;
		end else begin
			o_mode <= o_mode + 1'b1;
		end
	end
end

reg [1:0]	o_position		;  	//  hour = 2 , min = 1 , sec = 0

always @(posedge sw1 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_position <= POS_SEC;		// pos_sec =0 start! add 1
	end else begin
		if(o_position >= POS_HOUR) begin
			o_position <= POS_SEC;
		end else begin
			o_position <= o_position + 1'd1;
		end
	end
end

reg 		o_alarm_en1		;

always @(posedge sw3 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_alarm_en1 <= 2'd0;
	end else begin
		o_alarm_en1 <= o_alarm_en1 + 1'b1;
	end
end

reg 		o_alarm_en2		;

always @(posedge sw7 or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_alarm_en2 <= 2'd0;
	end else begin
		o_alarm_en2 <= o_alarm_en2 + 1'b1;
	end
end

///// o_stopwatch_en's mode

parameter   MODE_RESET  = 2'd0   ; 
parameter   MODE_GO   	= 2'd1   ;
parameter   MODE_STOP   = 2'd2   ;

reg   [1:0]   o_stopwatch_en      ;    // reset,  go, stop 

always @(posedge sw4 or negedge rst_n) begin
   	if(rst_n == 1'b0) begin
      		o_stopwatch_en <= MODE_RESET;      
   	end else begin
      		if(o_stopwatch_en >= MODE_STOP) begin
         		o_stopwatch_en <= MODE_RESET;
      		end else begin
        		o_stopwatch_en <= o_stopwatch_en + 1'b1;
      		end
   	end
end

reg		o_am_pm_en		;

always @(posedge sw6 or negedge rst_n) begin			// when o_am_pm_en =1, am_pm mode
	if(rst_n == 1'b0) begin
		o_am_pm_en <= 1'b0;
	end else begin
		o_am_pm_en <= o_am_pm_en + 1'b1;
	end
end


wire		clk_1hz			;

nco		u1_nco(
		.o_gen_clk	( clk_1hz	),
		.i_nco_num	( 32'd50000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		o_sec_clk		;
reg		o_min_clk		;
reg		o_hour_clk		;  // hour clk making

reg		o_alarm_sec_clk		;
reg		o_alarm_min_clk		;
reg		o_alarm_hour_clk	;

reg      	o_sw_ssec_clk      	;
reg      	o_sw_sec_clk      	;
reg      	o_sw_min_clk      	;


always @(*) begin
	case(o_mode)
		MODE_CLOCK : begin
			o_sec_clk  = clk_1hz;
			o_min_clk  = i_max_hit_sec;
			o_hour_clk = i_max_hit_min; // when max-min, hour+1
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_sw_ssec_clk = 1'b0;
        		o_sw_sec_clk = 1'b0;
         		o_sw_min_clk = 1'b0;
		end
		MODE_SETUP : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk  = ~sw2;	
					o_min_clk  = 1'd0;	 
					o_hour_clk = 1'd0;	// when sec select, min and hour = 0	
 					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk  = 1'd0;
					o_min_clk  = ~sw2;
					o_hour_clk = 1'd0;	// when min select, sec and hour = 0
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
				POS_HOUR : begin
					o_sec_clk  = 1'd0;
					o_min_clk  = 1'd0;
					o_hour_clk = ~sw2;	// when hour select, sec and min = 0
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
			endcase
		end
		MODE_ALARM : begin
			case(o_position)
				POS_SEC : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = ~sw2;
					o_alarm_min_clk= 1'b0;
					o_alarm_hour_clk = 1'b0;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
				POS_MIN : begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = ~sw2;
					o_alarm_hour_clk = 1'b0;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
				POS_HOUR: begin
					o_sec_clk = clk_1hz;
					o_min_clk = i_max_hit_sec;
					o_hour_clk = i_max_hit_min;
					o_alarm_sec_clk = 1'b0;
					o_alarm_min_clk = 1'b0;
					o_alarm_hour_clk = ~sw2;
					o_sw_ssec_clk = 1'b0;
         				o_sw_sec_clk = 1'b0;
         				o_sw_min_clk = 1'b0;
				end
			endcase
		end
		 MODE_STOPWATCH : begin
            		case(o_stopwatch_en)       
         			MODE_RESET: begin //reset
                  			o_sec_clk  =clk_1hz ;
                 			o_min_clk  = i_max_hit_sec;
                 			o_hour_clk = i_max_hit_min; 
                   			o_alarm_sec_clk = 1'b0;
                 			o_alarm_min_clk = 1'b0;
                  			o_alarm_hour_clk = 1'b0;
                  			o_sw_ssec_clk = clk_1hz ;
                 			o_sw_sec_clk =clk_1hz ;
                  			o_sw_min_clk = clk_1hz ;
                     		end
       				MODE_GO: begin //go
                  			o_sec_clk  = clk_1hz ;
                 			o_min_clk  = i_max_hit_sec;
                 			o_hour_clk = i_max_hit_min; 
                   			o_alarm_sec_clk = 1'b0;
                 			o_alarm_min_clk = 1'b0;
                  			o_alarm_hour_clk = 1'b0;
                  			o_sw_ssec_clk = clk_100hz;
                  			o_sw_sec_clk = i_sw_hit_ssec;
                  			o_sw_min_clk = i_sw_hit_sec;
                     		end
         			MODE_STOP:begin //stop
                  			o_sec_clk  = clk_1hz ;
                  			o_min_clk  = i_max_hit_sec;
                  			o_hour_clk = i_max_hit_min; 
                  			o_alarm_sec_clk = 1'b0 ;
                  			o_alarm_min_clk = 1'b0 ;
                  			o_alarm_hour_clk = 1'b0;
                  			o_sw_ssec_clk = clk_1hz ;
                			o_sw_sec_clk = clk_1hz ;
                  			o_sw_min_clk = clk_1hz ;
            			end
            			endcase
      		end

		MODE_SYDNEY_CLOCK : begin
			o_sec_clk  = clk_1hz;
			o_min_clk  = i_max_hit_sec;
			o_hour_clk = i_max_hit_min; // when max-min, hour+1
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_sw_ssec_clk = 1'b0;
        		o_sw_sec_clk = 1'b0;
         		o_sw_min_clk = 1'b0;
		end
		MODE_LONDON_CLOCK : begin
			o_sec_clk  = clk_1hz;
			o_min_clk  = i_max_hit_sec;
			o_hour_clk = i_max_hit_min; // when max-min, hour+1
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_sw_ssec_clk = 1'b0;
        		o_sw_sec_clk = 1'b0;
         		o_sw_min_clk = 1'b0;
		end

		default: begin
			o_sec_clk = 1'b0;
			o_min_clk = 1'b0;
			o_hour_clk = 1'b0;
			o_alarm_sec_clk = 1'b0;
			o_alarm_min_clk = 1'b0;
			o_alarm_hour_clk = 1'b0;
			o_sw_ssec_clk = 1'b0;
         		o_sw_sec_clk = 1'b0;
         		o_sw_min_clk = 1'b0;
		end
	endcase
end

endmodule




// 	RESET MODULE
module   hms_cnt_cntstop( 
      			 o_hms_cnt,
      			 o_max_hit,
      			 i_max_cnt,
      			 find_cnt, //[1:0] i_stopwatch_en -> [1:0] find_cnt 
      			 clk,
      			 rst_n
			);

output  [6:0]   o_hms_cnt      	;
output          o_max_hit      	;

input   [6:0]   i_max_cnt      	;     
input   [1:0]   find_cnt    	; 

input      	clk         	;
input      	rst_n         	;

reg   [6:0]   	o_hms_cnt      	;
reg      	o_max_hit      	;

always @(posedge clk or negedge rst_n) begin
   if(rst_n == 1'b0) begin
      o_hms_cnt <= 7'd0;
      o_max_hit <= 1'b0;
   end else begin
    	case(find_cnt)
   		2'd0 : begin   //reset
         		o_hms_cnt <= 7'd0 ;   
         		o_max_hit <= 1'b0;
   		end
   		2'd1 : begin   //go
       			if(o_hms_cnt >= i_max_cnt) begin  
         			o_hms_cnt <= 7'd0;
         			o_max_hit <= 1'b1;
      			end else begin
         			o_hms_cnt <= o_hms_cnt + 1'b1;   
         			o_max_hit <= 1'b0;
      			end
   		end
  		2'd2 : begin   //stop
         		o_hms_cnt <= o_hms_cnt ;   
         		o_max_hit <= 1'b0;
   		end
	
	endcase
    end
end

endmodule

//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------
module	hms_cnt(
		o_hms_cnt,
		o_max_hit,
		i_max_cnt,
		clk,
		rst_n,
		i_en
		);

output	[6:0]	o_hms_cnt		;
output		o_max_hit		;

input	[6:0]	i_max_cnt		;		// max_count value , hour(0-23), min(0-59), sec(0-59)
input		clk			;
input		rst_n			;

input		i_en			;		// for stop watch, 1= stop, 0 = going

reg	[6:0]	o_hms_cnt		;
reg		o_max_hit		;

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		o_hms_cnt <= 7'd0;
		o_max_hit <= 1'b0;
	end else begin	
		if( i_en == 1'b0) begin
			if(o_hms_cnt >= i_max_cnt) begin	// large than i_max_cnt => o_max_hit +1
				o_hms_cnt <= 7'd0;
				o_max_hit <= 1'b1;
				end else begin
				o_hms_cnt <= o_hms_cnt + 1'b1;	// less than i_max_cnt => o_hms_cnt + 1
				o_max_hit <= 1'b0;
				end
		end else begin	
			o_hms_cnt <= o_hms_cnt;
			o_max_hit <= o_max_hit;
		end
	end
end

endmodule


//	--------------------------------------------------
//	HMS(Hour:Min:Sec) Counter
//	--------------------------------------------------

module	hourminsec(	
			o_sec,
			o_min,
			o_hour,				// output-hour

			o_max_hit_sec,
			o_max_hit_min,
			o_max_hit_hour,			// max-hit-hour
			
			o_sw_hit_ssec,			
			o_sw_hit_sec,	
			o_sw_hit_min,			// sw- hit	

			o_alarm1,
			o_alarm2,

			i_mode,
			i_position,

			i_sec_clk,
			i_min_clk,
			i_hour_clk,			// hour-clk

			i_alarm_en1,
			i_alarm_en2,

			i_stopwatch_en,
			i_am_pm_en,

			i_alarm_sec_clk,
			i_alarm_min_clk,
			i_alarm_hour_clk,

			i_sw_ssec_clk,			// sw clk	<= controller
			i_sw_sec_clk,
			i_sw_min_clk,

			clk,
			rst_n
			);

output	[6:0]	o_sec		;
output	[6:0]	o_min		;
output	[6:0]	o_hour		;			// hour(hour : 0-24, but o_hms_cnt is 6-bit, so o_hour need 6-bit)

output		o_alarm1	;
output		o_alarm2	;

output		o_max_hit_sec	;
output		o_max_hit_min	;
output		o_max_hit_hour	;			// max_hit_hour

output		o_sw_hit_ssec	;			
output		o_sw_hit_sec	;
output		o_sw_hit_min	;			// sw_hit

input	[2:0]	i_mode		;
input	[1:0]	i_position	;


input		i_sec_clk	;
input		i_min_clk	;
input		i_hour_clk	;			// hour_clk

input		i_sw_ssec_clk	;		
input 		i_sw_sec_clk	;
input		i_sw_min_clk	;			// sw clk

input		i_alarm_sec_clk	;
input		i_alarm_min_clk	;
input		i_alarm_hour_clk;			// i_alarm_hour_clk

input		i_alarm_en1	;
input		i_alarm_en2	;

input 	[1:0]	i_stopwatch_en	;			// sw-en

input		i_am_pm_en	;

input		clk		;
input		rst_n		;

parameter	MODE_CLOCK	= 3'd0	;
parameter	MODE_SETUP	= 3'd1	;
parameter	MODE_ALARM	= 3'd2	;
parameter	MODE_STOPWATCH	= 3'd3	;
parameter	MODE_SYDNEY_CLOCK = 3'd4;	// world clock ( sydney  )
parameter	MODE_LONDON_CLOCK = 3'd5;	// world clock ( london )


parameter	POS_SEC		= 2'd0	;
parameter	POS_MIN		= 2'd1	;
parameter	POS_HOUR	= 2'd2	;


//	MODE_CLOCK

wire	[6:0]	sec		;
wire		o_max_hit_sec	;

hms_cnt		u0_hms_cnt(				// u0 : sec
		.o_hms_cnt	( sec		),
		.o_max_hit	( o_max_hit_sec	),
		.i_max_cnt	( 7'd59		),	// sec(0-59)
		.clk		( i_sec_clk	),
		.rst_n		( rst_n		),
		.i_en		(		)
		);

wire	[6:0]	min		;
wire		o_max_hit_min	;

hms_cnt		u1_hms_cnt(				// u1 : min
		.o_hms_cnt	( min		),
		.o_max_hit	( o_max_hit_min	),
		.i_max_cnt	( 7'd59		),	// min(0-59)
		.clk		( i_min_clk	),
		.rst_n		( rst_n		),
		.i_en		(		)
		);

wire	[6:0]	hour		;
wire		o_max_hit_hour	; 		

hms_cnt		u2_hms_cnt(				// u2 : hour
		.o_hms_cnt	( hour		),
		.o_max_hit	( o_max_hit_hour),
		.i_max_cnt	( 7'd23		),	// hour(0-23)
		.clk		( i_hour_clk	),	
		.rst_n		( rst_n		),
		.i_en		(		)
		);

reg	[6:0]	apm_sec		;
reg	[6:0]	apm_min		;
reg	[6:0]	apm_hour	;

always @ (*) begin
  if( i_am_pm_en == 1'b0) begin
		apm_sec <= sec	;
		apm_min	<= min	;
		apm_hour<= hour ;
  end else begin
	if( hour >= 7'd12) begin
 		apm_sec <= sec	;
		apm_min	<= min	;
		apm_hour<= hour - 7'd12 ;
	end else begin
		apm_sec <= sec	;
		apm_min	<= min	;
		apm_hour<= hour ;
	end
  end
end



//	MODE_ALARM

wire	[6:0]	alarm_sec	;

hms_cnt		u_hms_cnt_alarm_sec(
		.o_hms_cnt	( alarm_sec		),
		.o_max_hit	( 			),
		.i_max_cnt	( 7'd59			),
		.clk		( i_alarm_sec_clk	),
		.rst_n		( rst_n			),
		.i_en		(			)
		);

wire	[6:0]	alarm_min	;

hms_cnt		u_hms_cnt_alarm_min(
		.o_hms_cnt	( alarm_min		),
		.o_max_hit	( 			),
		.i_max_cnt	( 7'd59			),
		.clk		( i_alarm_min_clk	),
		.rst_n		( rst_n			),
		.i_en		(			)
		);

wire	[6:0]	alarm_hour	;

hms_cnt		u_hms_cnt_alarm_hour(				// hour alarm
		.o_hms_cnt	( alarm_hour		),
		.o_max_hit	( 			),
		.i_max_cnt	( 7'd23			),
		.clk		( i_alarm_hour_clk	),
		.rst_n		( rst_n			),
		.i_en		(			)	
		);


//   MODE_STOPWATCH

wire   [6:0]   sw_mmsec   ;
wire       o_sw_hit_ssec   ;

hms_cnt_cntstop      u0_hms_cnt_stopwatch(            // u0 : ssec
      .o_hms_cnt   ( sw_mmsec      ),
      .o_max_hit   ( o_sw_hit_ssec      ),
      .i_max_cnt   ( 7'd99         ),   // sec(0-59)
      .clk      ( i_sw_ssec_clk      ),
      .find_cnt (  i_stopwatch_en ),
      .rst_n      ( rst_n         ));


wire   [6:0]   sw_sec      ;
wire      o_sw_hit_sec   ;

hms_cnt_cntstop      u1_hms_cnt_stopwatch(            // u1 :sec
      .o_hms_cnt   ( sw_sec      ),
      .o_max_hit   (  o_sw_hit_sec   ),
      .i_max_cnt   ( 7'd59         ),   
      .clk         ( i_sw_sec_clk      ),
      .find_cnt    (  i_stopwatch_en ),
      .rst_n       ( rst_n         ));

wire   [6:0]   sw_min      ;
wire      o_sw_hit_min   ;

hms_cnt_cntstop      u2_hms_cnt_stopwatch(            // u2 : min
      .o_hms_cnt   ( sw_min      ),
      .o_max_hit   (  o_sw_hit_min      ),
      .i_max_cnt   ( 7'd59         ),   
      .clk      ( i_sw_min_clk      ),  
      .find_cnt (  i_stopwatch_en ), 
      .rst_n      ( rst_n         ));


//	MODE_SYDNEY_CLOCK

reg	[6:0]	S_sec		;
reg	[6:0]	S_min		;
reg	[6:0]	S_hour		;

always @ (*) begin
if( hour >= 7'd22) begin
 		S_sec <= sec	;
		S_min <= min	;
		S_hour <= hour -7'd22;
end else begin
		S_sec <= sec	;
		S_min <= min	;
		S_hour <= hour +7'd2;
end
end

//	MODE_LONDON_CLOCK

reg	[6:0]	L_sec		;
reg	[6:0]	L_min		;
reg	[6:0]	L_hour		;

always @ (*) begin
if( hour >= 9) begin
 		L_sec <= sec	;
		L_min <= min	;
		L_hour <= hour -7'd9;
end else begin
		L_sec <= sec	;
		L_min <= min	;
		L_hour <= hour +7'd15;
end
end

reg	[6:0]	o_sec		;
reg	[6:0]	o_min		;
reg	[6:0]	o_hour		;


always @ (*) begin
	case(i_mode)
		MODE_CLOCK: 	begin
			o_sec	= apm_sec;
			o_min	= apm_min;
			o_hour	= apm_hour;
		end
		MODE_SETUP:	begin
			o_sec	= sec;
			o_min	= min;
			o_hour	= hour;
		end
		MODE_ALARM:	begin
			o_sec	= alarm_sec;
			o_min	= alarm_min;
			o_hour	= alarm_hour;
		end
		MODE_STOPWATCH: begin
			o_sec	= sw_mmsec;
			o_min	= sw_sec;
			o_hour	= sw_min;
		end
		MODE_SYDNEY_CLOCK : begin
			o_sec	= S_sec;
			o_min	= S_min;
			o_hour	= S_hour;
		end
		MODE_LONDON_CLOCK : begin
			o_sec	= L_sec;
			o_min	= L_min;
			o_hour	= L_hour;
		end
		default : begin
			o_sec	= 7'd0;
			o_min	= 7'd0;
			o_hour	= 7'd0;
		end
	endcase
end

reg		o_alarm1	;
reg		o_alarm2	;


always @ (posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		o_alarm1 <= 1'b0;
		o_alarm2 <= 1'b0;
	end else begin
		if( (sec == 7'd0) && (min == 7'd0) && (hour != 7'd0) ) begin				// n'o clock ringing
			o_alarm1 <= 1'b1 & i_alarm_en1;
		end else begin
			o_alarm1 <= o_alarm1 & i_alarm_en1;
		end

		if( (sec == alarm_sec) && (min == alarm_min) && (hour == alarm_hour)) begin
			o_alarm2 <= 1'b1 & i_alarm_en2;
		end else begin
			o_alarm2 <= o_alarm2 & i_alarm_en2;
		end			
	end
end

endmodule

//	BUZZ

module	buzz(
		o_buzz,
		i_buzz_en1,
		i_buzz_en2,
		clk,
		rst_n);

output		o_buzz		;

input		i_buzz_en1	;
input		i_buzz_en2	;

input		clk		;
input		rst_n		;

parameter	HIGH_DO = 23889	;
parameter   	HIGH_RE = 21285 ;
parameter	HIGH_RE_SHARP = 20088 ;
parameter   	HIGH_MI = 18960 ;
parameter   	SI = 25316 ;
parameter   	RA = 28409 ;
parameter   	DO = 47801 ;
parameter   	MI = 37936 ;
parameter	REST = 250 ;

wire		clk_bit		;
nco	u_nco_bit(	
		.o_gen_clk	( clk_bit	),
		.i_nco_num	( 25000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg	[4:0]	cnt		;
always @ (posedge clk_bit or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt <= 5'd0;
	end else begin
		if(cnt >= 5'd24) begin
			cnt <= 5'd0;
		end else begin
			cnt <= i_buzz_en2 ;
			cnt <= cnt + 1'd1;

		end
	end
end

reg	[4:0]	h_cnt		;				// when n'o clock, ringing 
always @ (posedge clk_bit or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		h_cnt <= 5'd0;
	end else begin
		if(h_cnt >= 5'd24) begin
			h_cnt <= 5'd0;
		end else begin
			h_cnt <= i_buzz_en1 ;
			h_cnt <= h_cnt + 1'd1;

		end
	end
end

reg   [31:0]   h_nco_num      ;

always @ (*) begin
   	case(h_cnt)
     		5'd00: h_nco_num = MI;
      		5'd01: h_nco_num = REST;
      		5'd02: h_nco_num = MI;
      		5'd03: h_nco_num = REST;
      		5'd04: h_nco_num = MI;
      		5'd05: h_nco_num = REST;
      		5'd06: h_nco_num = MI;
      		5'd07: h_nco_num = REST;
      		5'd08: h_nco_num = MI;
      		5'd09: h_nco_num = REST;
      		5'd10: h_nco_num = MI;
      		5'd11: h_nco_num = REST;
      		5'd12: h_nco_num = MI;
      		5'd13: h_nco_num = REST;
      		5'd14: h_nco_num = MI;
      		5'd15: h_nco_num = REST;
      		5'd16: h_nco_num = MI;
      		5'd17: h_nco_num = REST;
      		5'd18: h_nco_num = MI;
      		5'd19: h_nco_num = REST;
      		5'd20: h_nco_num = MI;
      		5'd21: h_nco_num = REST;
      		5'd22: h_nco_num = MI;
      		5'd23: h_nco_num = REST;
      		5'd24: h_nco_num = MI;
      		5'd25: h_nco_num = REST;
      		5'd26: h_nco_num = MI;
      		5'd27: h_nco_num = REST;
   	endcase
end

reg   [31:0]   nco_num      ;

always @ (*) begin
   	case(cnt)
     		5'd00: nco_num = HIGH_MI;
      		5'd01: nco_num = HIGH_RE_SHARP;
      		5'd02: nco_num = HIGH_MI;
      		5'd03: nco_num = HIGH_RE_SHARP;
      		5'd04: nco_num = HIGH_MI;
      		5'd05: nco_num = SI;
      		5'd06: nco_num = HIGH_RE;
      		5'd07: nco_num = HIGH_DO;
      		5'd08: nco_num = RA;
      		5'd09: nco_num = REST;		
      		5'd10: nco_num = DO;
      		5'd11: nco_num = MI;
      		5'd12: nco_num = RA;
      		5'd13: nco_num = SI;
      		5'd14: nco_num = MI;
      		5'd15: nco_num = HIGH_DO;
      		5'd16: nco_num = SI;
      		5'd17: nco_num = RA;
      		5'd18: nco_num = REST;
   	endcase
end

wire		buzz1		;				// n'o clock ringing

nco	u_nco_buzz1(	
		.o_gen_clk	( buzz1		),
		.i_nco_num	( h_nco_num	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire		buzz2		;

nco	u_nco_buzz2(	
		.o_gen_clk	( buzz2		),
		.i_nco_num	( nco_num	),
		.clk		( clk		),
		.rst_n		( rst_n		));

wire [1:0]	i_buzz_en	;
assign		i_buzz_en = { i_buzz_en1, i_buzz_en2  };

reg		o_buzz		;

always @ (*) begin
	case(i_buzz_en)
	2'b00 : o_buzz = 1'b0 ;
	2'b01 : o_buzz = buzz2 & i_buzz_en2;
	2'b10 : o_buzz = buzz1 & i_buzz_en1;
	2'b11 : o_buzz = buzz2 & i_buzz_en2;			// alarm >>>>>>> n'o clock
	default : ;
	endcase
end
endmodule

module dot(
		mode,
		position,
		o_six_dp,
		blink_clk,
		rst_n,
		alarm_en1,
		alarm_en2,
		ampm_en
			);

input [2:0]	mode		;
input [1:0]	position	;

input		blink_clk	;
input		rst_n		;

input		alarm_en1	;
input		alarm_en2	;

input		ampm_en		;

output [5:0]	o_six_dp	;

reg [5:0]	o_six_dp	;

wire [1:0]	alarm_en	;
assign		alarm_en = { alarm_en1, alarm_en2 } ;

always @(posedge blink_clk or negedge rst_n) begin
if(rst_n == 1'b0) begin
		o_six_dp <= 6'b00_00_00 ;
	end else begin
	case(mode)
		3'd0 : begin
			if(ampm_en == 1'b0) begin
				case(alarm_en)
				2'b00 : o_six_dp = 6'b01_01_00 ;
				2'b01 : o_six_dp = 6'b01_01_01 ;
				2'b10 : o_six_dp = 6'b01_01_10 ;
				2'b11 : o_six_dp = 6'b01_01_11 ;
				endcase
			end else begin
				o_six_dp = 6'b11_11_11 ;
			end
		end
		3'd1 : begin						//setting_mode
			case(position)
				2'b00 : o_six_dp = 6'b00_00_01 ;
				2'b01 : o_six_dp = 6'b00_01_00 ;
				2'b10 : o_six_dp = 6'b01_00_00 ;
				default : o_six_dp = 6'b00_00_00 ;
			endcase
		end
		3'd2: begin						// alarm mode
			if(alarm_en == 1'b0) begin
			case(position)
				2'b00 : o_six_dp = 6'b00_00_01 ;
				2'b01 : o_six_dp = 6'b00_01_00 ;
				2'b10 : o_six_dp = 6'b01_00_00 ;
				default : o_six_dp = 6'b00_00_00 ;
			endcase
			end else begin
			case(position)					// when alarm_en =1, alarm ringing dp[5]=on
				2'b00 : o_six_dp = 6'b10_00_01 ;
				2'b01 : o_six_dp = 6'b10_01_00 ;
				2'b10 : o_six_dp = 6'b11_00_00 ;
				default : o_six_dp = 6'b00_00_00 ;
			endcase
			end
		end
		3'd3 : o_six_dp = 6'b00_01_00;
		3'd4 : o_six_dp = 6'b01_01_00 ;
		3'd5 : o_six_dp = 6'b01_01_00 ;
		default :  o_six_dp <= 6'b00_00_00 ;	
	endcase
	end
end	

endmodule


//	--------------------------------------------------
//	Flexible Numerical Display Decoder
//	--------------------------------------------------
`timescale 	1ns/1ns

module	fnd_dec(
		clk,
		hour10,
		hour0,
		min10,
		min0,
		sec10,
		sec0,
		blink,
		blink_clk,
		dis_hour,
		dis_min,
		dis_sec,
		i_six_digit_seg
		);

output[41:0]	i_six_digit_seg	;		

input		clk		;

input [3:0]	hour10		;
input [3:0]	hour0		;
input [3:0]	min10		;
input [3:0]	min0		;
input [3:0]	sec10		;
input [3:0]	sec0		;

input		dis_hour	;
input		dis_min		;
input		dis_sec		;

input		blink		;
input		blink_clk	;

reg [41:0] 	i_six_digit_seg	;

parameter  tck = 1000/50	;

initial begin
#(0*tck)	i_six_digit_seg[41:0]  = 42'd0		;
#(10*tck) begin
		i_six_digit_seg[41:35] = 7'b000_0000	; 		// 
		i_six_digit_seg[34:28] = 7'b011_0111	; 		// H
		i_six_digit_seg[27:21] = 7'b100_1111	; 		// E
		i_six_digit_seg[20:14] = 7'b000_1110	; 		// L
		i_six_digit_seg[13:7]  = 7'b000_1110	; 		// L
		i_six_digit_seg[6:0]   = 7'b111_1110	; 		// O
end
end

always @ (posedge blink_clk) begin
	if(dis_hour == 1'b1) begin
		case(hour10)
		4'd0 : i_six_digit_seg[41:35] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[41:35] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[41:35] <= 7'b110_1101	; 
		4'd3 : i_six_digit_seg[41:35] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[41:35] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[41:35] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[41:35] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[41:35] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[41:35] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[41:35] <= 7'b111_0011	; 
		default : ;
		endcase
	
		case(hour0)
		4'd0 : i_six_digit_seg[34:28] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[34:28] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[34:28] <= 7'b110_1101	; 
 		4'd3 : i_six_digit_seg[34:28] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[34:28] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[34:28] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[34:28] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[34:28] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[34:28] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[34:28] <= 7'b111_0011	; 
		default : ;
		endcase
	end else begin
		i_six_digit_seg[41:35] <= 7'b000_0000		;
		i_six_digit_seg[34:28] <= 7'b000_0000		;
		
	end
	
	if(dis_min == 1'b1) begin
		case(min10)
		4'd0 : i_six_digit_seg[27:21] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[27:21] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[27:21] <= 7'b110_1101	; 
 		4'd3 : i_six_digit_seg[27:21] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[27:21] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[27:21] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[27:21] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[27:21] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[27:21] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[27:21] <= 7'b111_0011	; 
		default : ;
		endcase
	
		case(min0)
		4'd0 : i_six_digit_seg[20:14] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[20:14] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[20:14] <= 7'b110_1101	; 
 		4'd3 : i_six_digit_seg[20:14] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[20:14] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[20:14] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[20:14] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[20:14] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[20:14] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[20:14] <= 7'b111_0011	; 
		default : ;
		endcase
	end else begin
		i_six_digit_seg[27:21] <= 7'b000_0000		;
		i_six_digit_seg[20:14] <= 7'b000_0000		;
	end
	
	if(dis_sec == 1'b1) begin
		case(sec10)
		4'd0 : i_six_digit_seg[13:7] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[13:7] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[13:7] <= 7'b110_1101	; 
 		4'd3 : i_six_digit_seg[13:7] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[13:7] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[13:7] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[13:7] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[13:7] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[13:7] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[13:7] <= 7'b111_0011	; 
		default : ;
		endcase

		case(sec0)
		4'd0 : i_six_digit_seg[6:0] <= 7'b111_1110	; 
 		4'd1 : i_six_digit_seg[6:0] <= 7'b011_0000	; 
 		4'd2 : i_six_digit_seg[6:0] <= 7'b110_1101	; 
 		4'd3 : i_six_digit_seg[6:0] <= 7'b111_1001	; 
 		4'd4 : i_six_digit_seg[6:0] <= 7'b011_0011	; 
 		4'd5 : i_six_digit_seg[6:0] <= 7'b101_1011	; 
 		4'd6 : i_six_digit_seg[6:0] <= 7'b101_1111	; 
 		4'd7 : i_six_digit_seg[6:0] <= 7'b111_0000	; 
 		4'd8 : i_six_digit_seg[6:0] <= 7'b111_1111	; 
 		4'd9 : i_six_digit_seg[6:0] <= 7'b111_0011	; 
		default : ;
		endcase
	end else begin
		i_six_digit_seg[13:7] <= 7'b000_0000		;
		i_six_digit_seg[6:0] <= 7'b000_0000		;
	end

end


endmodule


//	--------------------------------------------------
//	0~59 --> 2 Separated Segments
//	left = 10 's place	, right = 1 's place
//	--------------------------------------------------
module	double_fig_sep(						
		o_left,
		o_right,
		i_double_fig);

output	[3:0]	o_left		;
output	[3:0]	o_right		;

input	[6:0]	i_double_fig	;

assign		o_left	= i_double_fig / 10	;
assign		o_right	= i_double_fig % 10	;

endmodule


module 		blink( 
		clk,
		rst_n,
		blink, 
		blink_clk,
		setting_mode,
		setting_position,
		i_dis_hour,
		i_dis_min,
		i_dis_sec,
		o_dis_hour,
		o_dis_min,
		o_dis_sec
		);

input		clk			;	
input		rst_n			;

input		i_dis_hour		;
input		i_dis_min		;
input		i_dis_sec		;

output		o_dis_hour;
output		o_dis_min;
output		o_dis_sec ;


output		blink			;		// blink=1  ON, blink=0 OFF
output		blink_clk		;

input [2:0]	setting_mode		;
input [1:0]	setting_position	;

wire		blink_clk		;

nco		blink_clk_u1(			
		.o_gen_clk	( blink_clk	),
		.i_nco_num	( 32'd25000000	),
		.clk		( clk		),
		.rst_n		( rst_n		));

reg		blink		;



always @(posedge blink_clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin					// start 0
			blink	  <= 1'b0		;
	end else begin
		if((setting_mode == 3'd1)||(setting_mode == 3'd2)) begin
			blink <= 1'b1;
		end else begin
			blink <= 1'b0;
		end
	end
end	

reg		o_dis_hour;
reg		o_dis_min;
reg		o_dis_sec ;

always @ ( posedge clk) begin
	if( (setting_mode == 3'd1)||(setting_mode == 3'd2)) begin
		if(blink == 1'b1) begin
			case(setting_position)
				2'b00 :begin				// sec
					o_dis_hour<= 1'b1;
					o_dis_min <= 1'b1;
					o_dis_sec <= ~i_dis_sec;
				end
				2'b01 :begin				// min
					o_dis_hour<= 1'b1;
					o_dis_min <= ~i_dis_min;
					o_dis_sec <= 1'b1;
				end
				2'b10 :begin				// hour
					o_dis_hour<= ~i_dis_hour;
					o_dis_min <= 1'b1;
					o_dis_sec <= 1'b1;
				end
				default : ;
			endcase
		 end else begin
			o_dis_hour<= 1'b1;
			o_dis_min <= 1'b1;
			o_dis_sec <= 1'b1;
		end
	end else begin
		o_dis_hour<= 1'b1;
		o_dis_min <= 1'b1;
		o_dis_sec <= 1'b1;
	end
end

endmodule


module	led_disp(
		o_seg_dp,
		o_seg_enb,
		o_seg,
		i_six_digit_seg,
		i_six_dp,
		clk,
		rst_n
		);

output	[5:0]	o_seg_enb		;		// light place
output		o_seg_dp		;
output	[6:0]	o_seg			;

input	[41:0]	i_six_digit_seg		; 		// 7-segment *6 = 42-bit
input	[5:0]	i_six_dp		;
input		clk			;
input		rst_n			;

wire		gen_clk		;

nco		u_nco(					
		.o_gen_clk	( gen_clk	),
		.i_nco_num	( 32'd5000	),	// i don't know why 32'd5000 ( display = slow ?)
		.clk		( clk		),
		.rst_n		( rst_n		));


reg	[3:0]	cnt_common_node	;			// common_node  = lighting led 

always @(posedge gen_clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		cnt_common_node <= 4'd0;
	end else begin
		if(cnt_common_node >= 4'd5) begin
			cnt_common_node <= 4'd0;
		end else begin
			cnt_common_node <= cnt_common_node + 1'b1;
		end
	end
end

reg	[5:0]	o_seg_enb		;

always @(cnt_common_node) begin				// bling bling twincle
	case (cnt_common_node)				// 0 place => display
		4'd0 : o_seg_enb = 6'b111110;		// first place display
		4'd1 : o_seg_enb = 6'b111101;		// second place display 
		4'd2 : o_seg_enb = 6'b111011;
		4'd3 : o_seg_enb = 6'b110111;
		4'd4 : o_seg_enb = 6'b101111;
		4'd5 : o_seg_enb = 6'b011111;
	endcase
end

reg		o_seg_dp		;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0 : o_seg_dp = i_six_dp[0];
		4'd1 : o_seg_dp = i_six_dp[1];
		4'd2 : o_seg_dp = i_six_dp[2];
		4'd3 : o_seg_dp = i_six_dp[3];
		4'd4 : o_seg_dp = i_six_dp[4];
		4'd5 : o_seg_dp = i_six_dp[5];
	endcase
end

reg	[6:0]	o_seg			;

always @(cnt_common_node) begin
	case (cnt_common_node)
		4'd0 : o_seg = i_six_digit_seg[6:0];	// sec-right
		4'd1 : o_seg = i_six_digit_seg[13:7];	// sec-left
		4'd2 : o_seg = i_six_digit_seg[20:14];	// min-right
		4'd3 : o_seg = i_six_digit_seg[27:21];	// min-left
		4'd4 : o_seg = i_six_digit_seg[34:28];	// hour-right
		4'd5 : o_seg = i_six_digit_seg[41:35];	// hour-left
		default:o_seg = 7'b111_1110; 		// 0 display
	endcase
end



endmodule


module	top_total_clock(
		o_seg_enb,
		o_seg_dp,
		o_seg,
		o_alarm,
		i_sw0,
		i_sw1,
		i_sw2,
		i_sw3,
		i_sw4,
		i_sw6,
		i_sw7,
		clk,
		rst_n);

output	[5:0]	o_seg_enb	;
output		o_seg_dp	;
output	[6:0]	o_seg		;
output		o_alarm		;

input		i_sw0		;
input		i_sw1		;
input		i_sw2		;
input		i_sw3		;
input		i_sw4		;
input		i_sw6		;

input		i_sw7		;

input		clk		;
input		rst_n		;

wire		max_hit_hour	;			// max_hit_hour
wire		max_hit_min	;
wire		max_hit_sec	;

wire		out_max_hit_hour;			// out_max_hit_hour
wire 		out_max_hit_min	;
wire		out_max_hit_sec	;

wire		out_sw_max_hit_ssec;
wire		out_sw_max_hit_sec;
wire		out_sw_max_hit_min;			// out_sw_hit

wire		out_hour_clk	;			// out_hour_clk
wire		out_min_clk	;
wire		out_sec_clk	;

wire 		out_alarm_en1	;
wire		out_alarm_en2	;

wire		out_alarm1	;
wire		out_alarm2	;

wire		out_alarm_hour_clk;
wire		out_alarm_min_clk;
wire		out_alarm_sec_clk;

wire [1:0]	out_position	;
wire [2:0]	out_mode	;

wire [6:0]	out_hour	;			// out_hour add
wire [6:0]	out_min		;
wire [6:0]	out_sec		;

wire [1:0]	stop_en		;
wire		am_pm_en	;

wire 		ssec_clk	;
wire 		sec_clk		;
wire 		min_clk		;

wire		dis_hour_clk	;
wire		dis_min_clk	;
wire		dis_sec_clk	;

wire		blink			;
wire		blink_clk		;

wire		dis_hour		;
wire		dis_min			;
wire		dis_sec			;

controller	controller_ctrl(
		.o_mode(out_mode),
		.o_position(out_position),

		.o_alarm_en1(out_alarm_en1),
		.o_alarm_en2(out_alarm_en2),

		.o_stopwatch_en(stop_en),
		.o_am_pm_en(am_pm_en),		

		.o_sec_clk(out_sec_clk),
		.o_min_clk(out_min_clk),
		.o_hour_clk(out_hour_clk),

		.o_alarm_sec_clk(out_alarm_sec_clk),
		.o_alarm_min_clk(out_alarm_min_clk),
		.o_alarm_hour_clk(out_alarm_hour_clk),	//alarm_hour_clk add

		.o_sw_ssec_clk(ssec_clk),         // stop watch clk
      		.o_sw_sec_clk(sec_clk),      
      		.o_sw_min_clk(min_clk),      
		
		.i_max_hit_sec(out_max_hit_sec),
		.i_max_hit_min(out_max_hit_min),
		.i_max_hit_hour(out_max_hit_hour),

		.i_sw_hit_ssec(out_sw_max_hit_ssec),
		.i_sw_hit_sec(out_sw_max_hit_sec),         // sw hit
      		.i_sw_hit_min(out_sw_max_hit_min),         

		.i_sw0(i_sw0),
		.i_sw1(i_sw1),
		.i_sw2(i_sw2),
		.i_sw3(i_sw3),				// sw3 add
		.i_sw4(i_sw4),				// sw4 add
		.i_sw6(i_sw6),
		.i_sw7(i_sw7),
	
		.clk(clk),
		.rst_n(rst_n),

		.dis_hour(dis_hour_clk),
		.dis_min(dis_min_clk),
		.dis_sec(dis_sec_clk)
		);

blink		blink_blink( 
		.clk(clk),
		.rst_n(rst_n),
		.blink(blink), 
		.blink_clk(blink_clk),
		.setting_mode(out_mode),
		.setting_position(out_position),
		.i_dis_hour(dis_hour_clk),
		.i_dis_min(dis_min_clk),
		.i_dis_sec(dis_sec_clk),
		.o_dis_hour(dis_hour),
		.o_dis_min(dis_min),
		.o_dis_sec(dis_sec)
		);


hourminsec	hourminsec_hourminsec(
		.o_sec(out_sec),
		.o_min(out_min),
		.o_hour(out_hour),

		.o_max_hit_sec(out_max_hit_sec),
		.o_max_hit_min(out_max_hit_min),
		.o_max_hit_hour(out_max_hit_hour),

		.o_alarm1(out_alarm1),
		.o_alarm2(out_alarm2),

		.i_mode(out_mode),
		.i_position(out_position),

		.i_sec_clk(out_sec_clk),
		.i_min_clk(out_min_clk),
		.i_hour_clk(out_hour_clk),

		.o_sw_hit_ssec(out_sw_max_hit_ssec),			
		.o_sw_hit_sec(out_sw_max_hit_sec),	
		.o_sw_hit_min(out_sw_max_hit_min),	// sw- hit	

		.i_alarm_sec_clk(out_alarm_sec_clk),
		.i_alarm_min_clk(out_alarm_min_clk),
		.i_alarm_hour_clk(out_alarm_hour_clk),

		.i_sw_ssec_clk(ssec_clk),			// sw clk	<= controller
		.i_sw_sec_clk(sec_clk),
		.i_sw_min_clk(min_clk),

		.i_alarm_en1(out_alarm_en1),
		.i_alarm_en2(out_alarm_en2),

		.i_stopwatch_en(stop_en),
		.i_am_pm_en(am_pm_en),

		.clk(clk),
		.rst_n(rst_n)
		);

wire [3:0]	out_left_hour	;
wire [3:0]	out_right_hour	;

wire [3:0]	out_left_min	;
wire [3:0]	out_right_min	;

wire [3:0]	out_left_sec	;	
wire [3:0]	out_right_sec	;

double_fig_sep	double_fig_sep_u0_dfs(			// u0 : hour
		.o_left(out_left_hour),
		.o_right(out_right_hour),
		.i_double_fig(out_hour));

double_fig_sep	double_fig_sep_u1_dfs(			// u1 : min
		.o_left(out_left_min),
		.o_right(out_right_min),
		.i_double_fig(out_min));

double_fig_sep	double_fig_sep_u2_dfs(			// u2 : sec
		.o_left(out_left_sec),
		.o_right(out_right_sec),
		.i_double_fig(out_sec));

wire [41:0]	i_six_digit_seg	;

fnd_dec		find_dec_find_dec(
		.clk(clk),
		.hour10(out_left_hour),
		.hour0(out_right_hour),
		.min10(out_left_min),
		.min0(out_right_min),
		.sec10(out_left_sec),
		.sec0(out_right_sec),
		.blink(blink),
		.blink_clk(blink_clk),
		.dis_hour(dis_hour),
		.dis_min(dis_min),
		.dis_sec(dis_sec),
		.i_six_digit_seg(i_six_digit_seg)
		);

wire [5:0]	o_six_dp	;

dot		dot_dot(
		.mode(out_mode),
		.position(out_position),
		.o_six_dp(o_six_dp),
		.blink_clk(blink_clk),
		.rst_n(rst_n),
		.alarm_en1(out_alarm_en1),
		.alarm_en2(out_alarm_en2),
		.ampm_en(am_pm_en)
		);

led_disp	led_disp_u0_led_disp(
		.o_seg_dp(o_seg_dp),
		.o_seg(o_seg),
		.o_seg_enb(o_seg_enb),
		.i_six_digit_seg(i_six_digit_seg),
		.i_six_dp(o_six_dp),
		.clk(clk),
		.rst_n(rst_n)
		);


buzz		buzz_u0(
		.o_buzz(o_alarm),
		.i_buzz_en1(out_alarm1),
		.i_buzz_en2(out_alarm2),
		.clk(clk),
		.rst_n(rst_n)
		);



endmodule




