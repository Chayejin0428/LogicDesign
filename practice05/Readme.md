# Lab 06

## 실습 내용

### **Blocking & Non-Blocking**

#### **Blocking & Non-Blocking 차이 파악**
- 주어진 코드 및 Block Diagram을 통한 차이점 파악
- Test Bench 직접 작성
- 코드의 차이점 설명

### **6bit-Counter**

#### **6bit-Counter (① Code-DUT, Test Bench, ② Waveform or Display 제출)**
- 절차형 할당문 (Procedure Assignment) 을 통한 Counter 설계
--timescale에 대한 이해
--50MHz Clock 기준 1초 마다 0~59까지 바뀌는 카운터 설계

## 퀴즈

###  Q1 - FPGA가 100MHz CLK을 제공한다면 어디가 바뀌는가?

```verilog
module tb_top_cnt;

parameter tCK = 1000/50 ; // 50MHz Clock

reg clk			; 
reg rst_n		;

wire [5:0] out  ;

initial clk = 1'b0; 
always #(tCK/2) clk = ~clk;
top_cnt dut( .out ( out 		 ), 
			 .num ( 32'd50000000 ), 
			 .clk ( clk 		 ), 
			 .rst_n ( rst_n 	 )); 

initial begin 
	#(0*tCK) rst_n = 1'b0; 
	#(1*tCK) rst_n = 1'b1; 
	#(100000000*tCK) $finish; 
end

endmodule
```
![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice05/figs/practice05_quiz.PNG)

Q1 답 : parameter tCK = 1000/100 ;

###  Q2 - FPGA가 50MHz CLK을 제공, 2Hz Clock을 만드려면?


```verilog
module tb_top_cnt;

parameter tCK = 1000/50 ; // 50MHz Clock

reg clk				; 
reg rst_n 			;

wire [5:0] out		;

initial clk = 1'b0; 
always #(tCK/2) clk = ~clk;

top_cnt dut( .out ( out 		 ), 
			 .num ( 32'd50000000 ), 
			 .clk ( clk 		 ), 
			 .rst_n ( rst_n 	 ));
			
initial begin 
	#(0*tCK) rst_n = 1'b0; 
	#(1*tCK) rst_n = 1'b1; 
	#(100000000*tCK) $finish; 
end

endmodule
```
![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice05/figs/practice05_quiz.PNG)

Q2 답 : .num ( 32'd100000000 ),

## 결과

### **Waveform 검증 **

Blocking & Non-Blocking
![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice05/figs/practice05_bnb_wave.PNG)

6bit-Counter
![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice05/figs/practice05_6bit_counter_wave.PNG)


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExNjY5NDU0NjVdfQ==
-->