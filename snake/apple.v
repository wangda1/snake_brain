`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:56:23 06/05/2018 
// Design Name: 
// Module Name:    apple 
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
//  苹果产生模块
//  1.产生的苹果坐标位于 [up_border,down_border] [left_border,right_border]
//  2.产生的苹果坐标进行判断：1.不能与 snake_x_pos snake_y_pos 重合 
`include "Definition.h"
module apple(
    clk_25M,rst,apple_x_pos,apple_y_pos,apple_gen
    );
    input rst;
	 input clk_25M;
	 input apple_gen;
    output reg [6:0] apple_x_pos;                 //  此时的苹果的 x,y 坐标
    output reg [5:0] apple_y_pos;

//  苹果坐标的产生：这里使用一个简单的产生伪随机数的方法
//  默认重置后苹果产生坐标为：(75,30)
//  in: clk_25M,rst,apple_refresh
//  out:apple_x_pos, 
//	 6/8：测试：当 apple_gen 为高电平，每经过 clk_25M 一个周期产生一个伪随机数
//	 6/8：已验证！！
    always @ (posedge clk_25M or negedge rst)
    begin
      if(!rst)
        begin
          apple_x_pos <= 7'd75;
          apple_y_pos <= 7'd30;
        end
      else
        if(apple_gen)         //  当请求产生信号与重合信号出现时刷新苹果坐标
            begin
              apple_x_pos <= apple_x_pos[4:0] + apple_y_pos[4:1] + 25;           // 范围：5 -- 67
              apple_y_pos <= apple_x_pos[6:2] + apple_y_pos[5:2] + 7;           //  范围：7 -- 53
            end
    end



endmodule
