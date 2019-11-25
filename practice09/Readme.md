# Lab 09

## 실습 내용

### **리모컨 송신**

- 적외선 컨트롤러
  - 적외선(Infrared Rays, IR)
  : 근거리 통신 목적으로 사용하기에 적합 
 
- IR 통신 방법 : 송신부 
  - 적외선 발광 다이오드 (Infrared Rays Emitting Diode, RED) 
    -외형은 LED처럼 생겼지만, 가시광선이 아닌 적외선을 발생
 
  
- IR 통신 방법 : 수신부
  - 포토다이오드 (Photodiode) 
    
    - 빛에너지를 전기에너지로 바꾸어 전류 생성 
    
    - 보통 포토다이오드의 경우 검정색

 - 리모컨 송신 신호 
   - NEC 적외선 통신 규약 (NEC Infrared Transmission Protocol) 
  Leader Code : 프레임의 모드 선택 
   
     - Custom Code : 특정 회사를 나타냄 
   
     - Data Code : 송신 데이터 (데이터 확인 위해 보수 신호도 보냄)

### 코드 일부
```
//		순차적으로 들어오는 Rx Bits
module	ir_rx(	
		o_data,
		i_ir_rxb,
		clk,
		rst_n);

output	[31:0]	o_data		;

input		i_ir_rxb	;
input		clk		;
input		rst_n		;

//		low count, high count로 데이터의 유무 확인

parameter	IDLE		= 2'b00	;
parameter	LEADCODE	= 2'b01	;	// 9ms high 4.5ms low
parameter	DATACODE	= 2'b10	;	// Custom & Data Code
parameter	COMPLETE	= 2'b11	;	// 32-bit data

//		1M Clock = 1 us Reference Time
//		1마이크로세크 단위로 이전값과 새로운 값을 가지고 있음
wire		clk_1M				;
nco		u_nco(
		.o_gen_clk	( clk_1M	),
		.i_nco_num	( 32'd50	),
		.clk		( clk		),
		.rst_n		( rst_n		));

//		Sequential Rx Bits

wire		ir_rx		;
assign		ir_rx = ~i_ir_rxb;

reg	[1:0]	seq_rx				;
always @(posedge clk_1M or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		seq_rx <= 2'b00;
	end else begin
		seq_rx <= {seq_rx[0], ir_rx};
	end
end

//		Count Signal Polarity (High & Low)
//		LEADCODE가 계속 high로 오면 cnt_h 증가, 반대이면 cnt_l 증가
reg	[15:0]	cnt_h		;
reg	[15:0]	cnt_l		;
always @(posedge clk_1M or negedge rst_n) begin	
	if(rst_n == 1'b0) begin
		cnt_h <= 16'd0;
		cnt_l <= 16'd0;
	end else begin
		case(seq_rx)	//		2'b10은 동작하는게 없어 제외
			2'b00	: cnt_l <= cnt_l + 1;
			2'b01	: begin
				cnt_l <= 16'd0;
				cnt_h <= 16'd0;
			end
			2'b11	: cnt_h <= cnt_h + 1;
		endcase
	end
end

//		State Machine - 4개의 state 존재
//		0에서 1로 갈 때, 리셋
//		state 총 4개, 각각 2bit

reg	[1:0]	state		;
reg	[5:0]	cnt32		;
always @(posedge clk_1M or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		state <= IDLE;
		cnt32 <= 6'd0;
	end else begin
		case (state)
			IDLE: begin
				state <= LEADCODE;
				cnt32 <= 6'd0;
			end
			LEADCODE: begin	//		구간에 상관없이 LEADCODE가 올 때 혹은 오지 않을 때의 상태 
				if (cnt_h >= 8500 && cnt_l >= 4000) begin	//		MAX ; 9000, MIN ; 4500일 때 규약이랑 맞는 것인데 일부러 마진을 두고 시간을 줄임
					state <= DATACODE;
				end else begin
					state <= LEADCODE;
				end
			end
			DATACODE: begin
				if (seq_rx == 2'b01) begin	//		2'b01은 LEADCODE가 완전히 끝났다는 의미
					cnt32 <= cnt32 + 1;
				end else begin
					cnt32 <= cnt32;	//		cnt32는 rising edge를 세어 확인(high & low가 하나의 세트)
				end
				if (cnt32 >= 6'd32 && cnt_l >= 1000) begin
					state <= COMPLETE;
				end else begin
					state <= DATACODE;
				end
			end
			COMPLETE: state <= IDLE;	//		low signal의 길이가 1000이 넘으면 complete
		endcase
	end
end

//		32bit Custom & Data Code
//		cnt32는 데이터가 올 때마다 증가
//		Custom Code는 버리고 Data Code 받음
reg	[31:0]	data		;
reg	[31:0]	o_data		;
always @(posedge clk_1M or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		data <= 32'd0;
	end else begin
		case (state)
			DATACODE: begin
				if (cnt_l >= 1000) begin
					data[32-cnt32] <= 1'b1;
				end else begin
					data[32-cnt32] <= 1'b0;
				end
			end
			COMPLETE: o_data <= data;	//		o_data는 COMPLETE가 되어야지만 나오는데, 그 전까지는 wave에서 나타나지 않아야 함 
		endcase
	end
end

endmodule
```
```
`timescale		1ns/1ns
module	tb;


parameter	tCK	= 1000/50	;	// 50MHz Clock

reg		clk			;
reg		rst_n			;
reg		i_ir_rxb		;

initial		clk = 1'b0	;
always	#(tCK/2)
		clk = ~clk	;

wire	[5:0]	o_seg_enb	;
wire		o_seg_dp	;
wire	[6:0]	o_seg		;
top		dut(
		.o_seg_enb	(o_seg_enb	),
		.o_seg_dp	(o_seg_dp	),
		.o_seg		(o_seg		),
		.i_ir_rxb	(i_ir_rxb	),
		.clk		(clk		),
		.rst_n		(rst_n		));

initial begin
	#(0*tCK)	rst_n	= 1'b0;	i_ir_rxb = 1'b0;
	#(1000*tCK)	rst_n	= 1'b1;	i_ir_rxb = 1'b0;
			L_CODE;
			D_CODE0;
			D_CODE1;
			D_CODE0;
			D_CODE1;
			D_CODE0;
			D_CODE0;
			D_CODE1;
			D_CODE1;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE1;
			D_CODE1;
			D_CODE1;
			D_CODE1;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE0;
			D_CODE1;
	#(1000*tCK)	$finish;
end

//		반복성이 있는 것은 task를 쓰면 편리함
task	L_CODE;	//		L_CODE가 올 때		
	begin
				i_ir_rxb	= 1'b0;
		#(9000000)	i_ir_rxb	= 1'b1;
		#(4500000)	;
	end
endtask

task	D_CODE0;	//		0bit가 올 때
	begin
				i_ir_rxb	= 1'b0;
		#(560000)	i_ir_rxb	= 1'b1;
		#(565000)	;
	end
endtask

task	D_CODE1;	//		1bit가 올 때
	begin
				i_ir_rxb	= 1'b0;
		#(560000)	i_ir_rxb	= 1'b1;
		#(1690000)	;
	end
endtask

endmodule
```
## 결과

### **Waveform 검증 **

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice09/figs/wave(1).PNG)

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice09/figs/wave(2).PNG)


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTcwNjY4NTc1NywtNTIwNTE1OTAyXX0=
-->