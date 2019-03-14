`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:57:18 06/05/2018 
// Design Name: 
// Module Name:    snake_top 
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
//	测试需要：1.将 clk_1s模块的计数改小 2.
//	6/8测试：bug:1.方向不能正常改变,left_bt向左走，right_bt向右走，且偶尔方向紊乱；可先对该模块进行仿真，
//						注意坐标的改变是否按照正常的逻辑
`include "Definition.h"

 
 module snake_top(
    clk,rst,hs,vs,red,green,blue,left_bt,right_bt,attention_data,meditation_data,signal_data,man_control,brain_left,brain_right
    );
    input clk,rst;
    input left_bt,right_bt;
	 input [7:0] attention_data;
	 input [7:0] meditation_data;
	 input [7:0] signal_data;
	 input brain_left,brain_right;
    output hs,vs;							  //  行，列消隐信号
	 output [3:0] red,green,blue;	          //  输出颜色信号
	 input man_control;						//	人工与脑电控制切换

    wire clk_1s;
    wire clk_25M;
	 wire [2:0] snake_speed;				//	蛇的移动速度等级
	 wire clk_speed;							//	蛇的移动速度时钟

//  1s时钟产生模块：用于蛇的移动速度
    CLK_1S M1(
	.clk(clk),.rst(rst),.clk_1s(clk_1s),.snake_speed(snake_speed),.clk_speed(clk_speed)
    );
//  25MHz时钟产生模块：用于VGA的刷新频率
    CLK_25M M2(
	.clk(clk),.rst(rst),.clk_25M(clk_25M)
    );
//	 蛇的控制参数生成模块
	 game_para M7(
	 .clk_1s(clk_1s),.rst(rst),.attention_data(attention_data),.snake_speed(snake_speed),.apple_size(apple_size)
    );
//  蛇的控制模块
    wire [1:0] game_status;
    wire [6:0] x_pos;
    wire [5:0] y_pos;
    wire [6:0] apple_x_pos;
    wire [5:0] apple_y_pos;
    wire is_apple;
    wire is_crash;
    wire is_snake;
	 wire is_score;
	 wire is_border;
	 wire is_attention;
	 wire is_meditation;
    wire is_suicide;
	 wire is_signal;
    wire [2:0] score;
    wire apple_gen;

    snake_control M3(
    .clk(clk),.clk_1s(clk_speed),.clk_25M(clk_25M),.rst(rst),.left_bt(left_bt),.right_bt(right_bt),.game_status(game_status),
        .x_pos(x_pos),.y_pos(y_pos),.apple_x_pos(apple_x_pos),.apple_y_pos(apple_y_pos),
        .is_snake(is_snake),.is_apple(is_apple),.is_crash(is_crash),.score(score),.apple_gen(apple_gen),.is_suicide(is_suicide),
		  .man_control(man_control),.brain_right(brain_right),.brain_left(brain_left)
    );
//  VGA信号产生模块
//	 加入脑电波信号的强度进度条显示
    vga M4(
	.clk_25M(clk_25M),.rst(rst),.hs(hs),.vs(vs),.red(red),.green(green),.blue(blue),
        .is_snake(is_snake),.is_apple(is_apple),.is_score(is_score),.is_border(is_border),.is_attention(is_attention),.is_meditation(is_meditation),
		  .x_pos(x_pos),.y_pos(y_pos),.game_status(game_status),.is_signal(is_signal)
    );
//  总的游戏控制模块
    game_control M5(
    .clk_1s(clk),.rst(rst),.is_crash(is_crash),.is_suicide(is_suicide),.game_status(game_status)
    );
//	 苹果产生模块
	apple M6(
    .clk_25M(clk_25M),.rst(rst),.apple_x_pos(apple_x_pos),.apple_y_pos(apple_y_pos),.apple_gen(apple_gen)
    );
//	 分数显示模块
   score_border M8(
	.clk_25M(clk_25M),.rst(rst),.score(score),.attention_data(attention_data),.meditation_data(meditation_data),.signal_data(signal_data),
	.is_attention(is_attention),.is_meditation(is_meditation),.is_score(is_score),.is_border(is_border),.is_signal(is_signal),
	.x_pos(x_pos),.y_pos(y_pos)
    );

endmodule
