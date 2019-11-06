# Lab 03

## 실습 내용

### **4:1 MUX**

#### **2:1 MUX**
- (cond_expr ? true_expr : false_expr) 사용 
- If 문 사용

#### **4:1 MUX**
: 2:1 MUX 사용한 계층적 설계 (Instantiation) 
i) If 문
ii) Case 문

## 퀴즈

### 아래 코드 일부를 수정하여 다음을 구하시오

```verilog
module mux2to1_cond( out, in0, in1, sel); 
output out ; 
input in0 ; 
input in1 ; 
input sel ; 
assign out = (sel==1’b0)? answer;
endmodule 
```

### >Q3.1

```verilog
module mux2to1_cond( out, in0, in1, sel); 
output out ; 
input in0 ; 
input in1 ; 
input sel ; 
assign out = (sel==1’b0)? in0 : in1;
endmodule 
```

## 결과

### **Top Module의 DUT/TestBench Code 및 Waveform 검증 & FPGA 동작 사진**

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice03/figs/practice03(mux02-wave).PNG)

![](https://github.com/Chayejin0428/LogicDesign/blob/master/practice03/figs/practice03(mux04-wave).PNG)


> Written with [StackEdit](https://stackedit.io/).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTEyMDA4MDEyMF19
-->
