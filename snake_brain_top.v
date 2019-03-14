`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:36:15 06/20/2018 
// Design Name: 
// Module Name:    snake_brain_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//	6/20：整机联调：两个模块分别工作正常！！
module snake_brain_top(
	clk,rst,rs232_rx,left_bt,right_bt,man_control,hs,vs,red,green,blue,sm_seg,sm_bit,led_out,blink
    );
	 input clk,rst;
	 input rs232_rx;
	 input man_control;
	 input left_bt,right_bt;
	 output hs,vs;
	 output [7:0] sm_seg;
	 output [7:0] sm_bit;
	 output [15:1] led_out;
	 output blink;
	 output [3:0] red,blue,green;
	 
	 
	 wire brain_left;
	 wire brain_right;
	 wire [23:0] out_data;	//	out_data 数据格式 [23:16]:signal_data,[15:8]:attention_data,[7:0]:meditation_data
	 
	 assign led_out = out_data[15:1];
								

	 rs232_top MT1(  
    .clk(clk),  
    .rst(rst),  
    .rs232_rx(rs232_rx),  
    .sm_seg(sm_seg),  
    .sm_bit(sm_bit),
	 .out_data(out_data),
	 .blink(blink),
	 .brain_left(brain_left),
	 .brain_right(brain_right)    
    ); 
	 
	 
	 snake_top MT2(
    .clk(clk),
	 .rst(rst),
	 .hs(hs),
	 .vs(vs),
	 .red(red),
	 .green(green),
	 .blue(blue),
	 .left_bt(left_bt),
	 .right_bt(right_bt),
	 .attention_data(out_data[15:8]),
	 .meditation_data(out_data[7:0]),
	 .signal_data(out_data[23:16]),
	 .man_control(man_control),
	 .brain_left(brain_left),
	 .brain_right(brain_right)
    );	 


endmodule
