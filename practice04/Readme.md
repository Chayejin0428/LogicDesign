# Lab 04

## 실습 내용

### **3:8 Decoder**

#### **3:8 Decoder**
3 Types of Designs 
- 연속 할당문 (assign)에 shift operator (<<) 사용 
- If 문 활용 
- Case 문 활용 

Test Bench 
- 모든 입력 Case 반드시 포함

### **Latch & Flip-Flop **

#### **Latch & Flip-Flop**
-D Latch 
- Level Sensitive 동작 확인 

-D Flip-Flop (DFF) 
-  w/ Asynchronous Reset (비동기식 리셋) 
- w/ Synchronous Reset (동기식 리셋)

## 퀴즈

### QUIZ 3.2

```verilog
module dec3to8_shift( out , in , en ); 
output [7:0] out ; 
input [2:0] in ; 
input en ; 
assign out = (en==1'b1)? 8’d1<<in : 8'd0;
endmodule 
```
8’d2 << 7 은 이진수로 어떻게 표현될까?

### QUIZ 3.2 답 : 8'b00000000

## 결과

### **Top Module의 DUT/TestBench Code 및 Waveform 검증 & FPGA 동작 사진**

#### **3:8 Decoder**

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice04/figs/practice04_decoder_wave.PNG)

#### **Latch & Flip-Flop**

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice04/figs/practice04_latch%26flip-flop_wave.PNG)

> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTczMDQzODA2Nl19
-->