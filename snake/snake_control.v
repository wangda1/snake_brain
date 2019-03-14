`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:57:06 06/05/2018 
// Design Name: 
// Module Name:    snake_control 
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
//  蛇身控制模块：
//  蛇身的存储用10个reg 
//  需要验证仿真得几点：1.能否正确产生1s时钟信号 2.按照方向坐标能否顺序复制 3.方向能否正确改变 4.能否正确输出 apple_refresh信号
//                    5.能否正确输出 is_snake,is_appple信号 6. 能否正确输出 is_crash信号
//	 测试：修改：1.1s时钟产生 count_1s
//	 6/20删掉苹果大小改变模块；加入手动与脑电波控制：脑电输入的转向信号是：100MHz的短周期信号，控制切换采用第二个拨码开关！！！

`include "Definition.h"

module snake_control(
    clk,clk_1s,clk_25M,rst,left_bt,right_bt,game_status,x_pos,y_pos,apple_x_pos,apple_y_pos,is_snake,is_apple,is_crash,score,apple_gen,is_suicide,
	 man_control,brain_right,brain_left
    );
    input rst;
    input clk;                                  //  输入100MHz频率，来做按键防抖
    input clk_1s;
    input clk_25M;                              //  输入25MHz时钟频率
    input left_bt,right_bt;                     //  向左，右移动
    input [1:0] game_status;                    //  游戏状态
    input [6:0] x_pos;                          //  此时扫描到的 x,y 坐标
    input [5:0] y_pos;
    input [6:0] apple_x_pos;                    //  此时的苹果的 x,y 坐标
    input [5:0] apple_y_pos;
	 input man_control;									//	 人工控制与脑电控制的切换
	 input brain_right,brain_left;					//	 脑电输出的向左，向右转向
    output reg is_snake,is_apple;               //  输出蛇身与苹果颜色控制信息;信号形式为持续一个 25MHz 一个周期的高电平
    output is_crash;                        		//  输出是否撞到墙壁;信号形式为持续高电平 时钟为 1s
    output reg [2:0] score;                     //  输出当前分数信息，max = 7
    output reg apple_gen;                   		//  输出苹果刷新信号：输出信号形式：持续1或多个25M时钟周期的高电平
    output is_suicide;                      		//  输出是否自尽；输出信号形式为：持续一个 1s 的高电平

    reg [6:0] snake_x_pos [9:0];                //  存储蛇身的x坐标
    reg [5:0] snake_y_pos [9:0];                //  存储蛇身的y坐标
    reg snake_valid [9:0];                      //  存储蛇身的有效位

//  （待定）蛇身移动速度产生模块
//  产生1s时钟信号，计数大约到50M电平发生一次跳变
//	 已验证！！
/*    reg clk_1s;
    reg [25:0] count_1s;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            clk_1s <= 1'b0;
            count_1s <= 26'd0;
        end
        else
            //if(count_1s == 26'd52428800)
				if(count_1s == 26'd5)
            begin
                clk_1s <= ~clk_1s;
                count_1s <= 26'd0;
            end
            else
                count_1s <= count_1s + 1;
    end*/

//  方向控制模块：状态机根据当前方向状态和输入按键来产生当前的方向信息
//	 6/7改：1.通过沿出发来判断方向；否则时钟频率过快，电平判断方向会不断改变
//	  		  2.已验证！！
//	 6/8测：原因可能在于按键的时间过短，上升沿触发后，执行 else 导致方向，修改！！！
//   6/16测：猜想应当是按键抖动导致方向改变的紊乱，加入防抖模块

//  防抖思路：通过检测间隔一段时间的两个电平来判断是否为按下按键；延时时间为20ms
//  输出信号表现为：至少持续 20ms的电平！！！
//  in: left_bt,right_bt
//  out: left_button,right_button
//	 已验证！！！
    reg reg_left_bt_1,reg_left_bt_2;
    reg reg_right_bt_1,reg_right_bt_2;
    wire left_button,right_button;
    reg [10:0] count_button;
    always @ (posedge clk or negedge rst)
    begin
      if(!rst)
		begin
        count_button <= 11'd0;
		  reg_left_bt_1 <= 1'b0;
		  reg_left_bt_2 <= 1'b0;
		  reg_right_bt_1 <= 1'b0;
		  reg_right_bt_2 <= 1'b0;
		end
      else
        begin
          if(count_button == 11'h7ff)
          begin
            reg_left_bt_1 <= left_bt;
            reg_right_bt_1 <= right_bt;
            count_button <= 11'h0;
			reg_left_bt_2 <= reg_left_bt_1;
			reg_right_bt_2 <= reg_right_bt_1;
          end
          else
				count_button <= count_button + 1;
        end
    end

    assign left_button = ~reg_left_bt_2 & reg_left_bt_1;
    assign right_button = ~reg_right_bt_2 & reg_right_bt_1;

//  检测边沿信号，因：组合逻辑产生的 clk 会报 warning！
//	 已验证！！
    reg left_1,left_2;
    reg right_1,right_2;
    reg is_left,is_right;
    always @ (posedge clk)
    begin
        left_1 <= left_button;
        left_2 <= left_1;
        right_1 <= right_button;
        right_2 <= right_1;
    end
//	 加入手动控制与脑电波控制模块切换
//
	 always @ (posedge clk)
	 begin
		if(!man_control)
			begin
				is_right <= right_1 & ~right_2;
				is_left <= left_1 & ~left_2;
			end
		else
			begin
				is_right <= brain_right;
				is_left <= brain_left;
			end
	 end
	 
    parameter [1:0]
        up = 2'd0,
        right = 2'd1,
        down = 2'd2,
        left = 2'd3;
    reg [1:0] direction;
    always @ (posedge clk or negedge rst)
    begin
      if(!rst)
        begin
            direction <= right;
        end
      else
        begin
          case (direction)
            up: begin if(is_left) direction <= left; else if(is_right) direction <= right; end
            right: begin if(is_left) direction <= up; else if(is_right) direction <= down; end
            down: begin if(is_left) direction <= right; else if(is_right) direction <= left; end
            left: begin if(is_left) direction <= down; else if(is_right) direction <= up; end
            default: ;
          endcase
        end
    end

//  坐标移动模块：根据当前方向信息，每隔1s进行操作坐标
//  操作头部，后续直接进行顺着前面的进行复制前面坐标信息，当然只是复制 valid 的坐标
//  蛇身初始化为(40,30),(39,30)
//	 6/7: 测试：snake_x_pos,snake_y_pos的坐标都能顺序推进
//	 6/7：已验证！！
    integer i;
    always @ (posedge clk_1s or negedge rst)
    begin
      if(!rst)
        begin
          snake_x_pos[0] <= 7'd40;
          snake_y_pos[0] <= 6'd30;
          snake_x_pos[1] <= 7'd39;
          snake_y_pos[1] <= 6'd30;
          snake_x_pos[2] <= 7'd0;
          snake_y_pos[2] <= 6'd0;
          snake_x_pos[3] <= 7'd0;
          snake_y_pos[3] <= 6'd0;
          snake_x_pos[4] <= 7'd0;
          snake_y_pos[4] <= 6'd0;
          snake_x_pos[5] <= 7'd0;
          snake_y_pos[5] <= 6'd0;
          snake_x_pos[6] <= 7'd0;
          snake_y_pos[6] <= 6'd0;
          snake_x_pos[7] <= 7'd0;
          snake_y_pos[7] <= 6'd0;
          snake_x_pos[8] <= 7'd0;
          snake_y_pos[8] <= 6'd0;
          snake_x_pos[9] <= 7'd0;
          snake_y_pos[9] <= 6'd0;
        end
        else
            begin
                case(direction)
                up: snake_y_pos[0] <= snake_y_pos[0] - 1;
                right: snake_x_pos[0] <= snake_x_pos[0] + 1;
                left: snake_x_pos[0] <= snake_x_pos[0] - 1;
                down: snake_y_pos[0] <= snake_y_pos[0] + 1;
                default: ;
                endcase
                for(i=1;i<=9;i=i+1)
                begin
                snake_x_pos[i] <= snake_x_pos[i-1];
                snake_y_pos[i] <= snake_y_pos[i-1];
                end    
            end
    end

//	 蛇的自咬判定
//	 循环比较判定是否坐标重合

	 assign is_suicide = (snake_x_pos[0] == snake_x_pos[4] && snake_y_pos[0] == snake_y_pos[4] && snake_valid[4]) || 
								(snake_x_pos[0] == snake_x_pos[5] && snake_y_pos[0] == snake_y_pos[5] && snake_valid[5]) ||
								(snake_x_pos[0] == snake_x_pos[6] && snake_y_pos[0] == snake_y_pos[6] && snake_valid[6]) ||
								(snake_x_pos[0] == snake_x_pos[7] && snake_y_pos[0] == snake_y_pos[7] && snake_valid[7]) ||
								(snake_x_pos[0] == snake_x_pos[8] && snake_y_pos[0] == snake_y_pos[8] && snake_valid[8]) ||
								(snake_x_pos[0] == snake_x_pos[9] && snake_y_pos[0] == snake_y_pos[9] && snake_valid[9]);
//  判断蛇是否碰到墙壁
//  输出 is_crash 高电平信号，持续1s的高电平
//	 6/7测试：1.在snake_x_pos = 80 && direction = right is_crash 信号输出 clk_1s周期高电平
//				 2.snake_x_pos 增加到 123 etc...
//	 6/7：已验证！！
	 
	 assign is_crash = (snake_x_pos[0] == `left_border) ||
								(snake_x_pos[0] == `right_border) ||
								(snake_y_pos[0] == `up_border) ||
								(snake_y_pos[0] == `down_border);
//  判断蛇是否吃到苹果
//  in: apple_x_pos,apple_y_pos,snake_x_pos,snake_y_pos
//  out: snake_valid,score
//	  6/7测试：1.score 增加 2. snake_valid增加
//	  6/7：已验证！！
    always @ (posedge clk_1s or negedge rst)
    begin
      if(!rst)
        begin
            score <= 3'd0;
				snake_valid[0] <= 1'b1;
				snake_valid[1] <= 1'b1;
				snake_valid[2] <= 1'b0;
				snake_valid[3] <= 1'b0;
				snake_valid[4] <= 1'b0;
				snake_valid[5] <= 1'b0;
				snake_valid[6] <= 1'b0;
				snake_valid[7] <= 1'b0;
				snake_valid[8] <= 1'b0;
				snake_valid[9] <= 1'b0;
        end
       else
        if(snake_x_pos[0] == apple_x_pos && snake_x_pos[0] == apple_x_pos && snake_y_pos[0] == apple_y_pos && snake_y_pos[0] == apple_y_pos)
            begin
              score <= score + 1;
              snake_valid[score+2] <= 1'b1;
            end

    end
//  加入苹果大小可变模块，根据专注度调节苹果大小
//  根据 size大小：0,1,2,3,4,分为几个等级，apple_x_pos,apple_y_pos保存apple左上角坐标大小
//  in: size [0,4]
//  out: 








//  输出比较蛇身，苹果的结果 is_snake,is_apple
//  in: snake_x_pos,snake_y_pos,snake_valid,x_pos,y_pos
//  out: is_snake,is_apple
//	 6/7：测试：1.逻辑正确 2.输出为 clk_25M 一个周期的高电平
//	 6/7: 已验证！！
    integer j;
    always @ (posedge clk_25M or negedge rst)
    begin
      if(!rst)
        begin
          is_snake <= 1'b0;
          is_apple <= 1'b0;
        end
      else
        begin
          is_snake <= 1'b0;
          is_apple <= 1'b0;
          for(j=0;j<=9;j=j+1)
            begin
              if(snake_valid[j] == 1'b1)
                if(x_pos == snake_x_pos[j] && y_pos == snake_y_pos[j])
                    is_snake <= 1'b1;
            end
          if(x_pos == apple_x_pos && x_pos == apple_x_pos && y_pos == apple_y_pos && y_pos == apple_y_pos)
            is_apple <= 1'b1;
        end
    end
//  蛇身与苹果比较确认模块：进行循环比较来判断当前是否处于蛇身与苹果交叉部位
//  苹果的产生模块另外见其它，应该保证不出现在墙壁上
//  思路为：利用25MHz来作为判断的比价时钟，这样可以在1s内有多次改变机会
//  为精简电路：采用计数比较的方式，防止 for 循环出现电路面积过大，毕竟前面已经出现多次 for 循环
//    in:x_pos,y_pos,clk_25M
//    out:apple_refresh
//	 6/8测试：当蛇吃到苹果时，产生一个25M时钟周期的高电平 apple_refresh信号
//	 6/8：已验证
    reg [2:0] score_bak;
	reg apple_refresh;
    always @ (posedge clk_25M or negedge rst)
    begin
      if(!rst)
        apple_refresh <= 1'b0;
      else
        begin
          apple_refresh <= 1'b0; 
			 score_bak <= score;
          if(score != score_bak)			//	吃到苹果得分情况下，刷新苹果
            apple_refresh <= 1'b1;		//这里 apple_refresh更新信息可能出问题???????????????????????????????????????????????
        end
    end
//  蛇身与苹果比较确认模块：进行循环比较来判断当前是否处于蛇身与苹果交叉部位
//  苹果的产生模块另外见其它，应该保证不出现在墙壁上
//  思路为：利用25MHz来作为判断的比价时钟，这样可以在1s内有多次改变机会
//  为精简电路：采用计数比较的方式，防止 for 循环出现电路面积过大，毕竟前面已经出现多次 for 循环
//    in:x_pos,y_pos,clk_25M
//    out:apple_superpos
    reg [3:0] pos_num;
    reg apple_superpos;                 //  表示产生苹果坐标与蛇身重合
    parameter [3:0] max_pos_num = 4'd9;
    always @ (posedge clk_25M or negedge rst)
    begin
      if(!rst)
      begin
        apple_superpos <= 1'b0;
        pos_num <= 4'd0;
      end
      else
        begin
            apple_superpos <= 1'b0;
			if(pos_num == max_pos_num)
                pos_num <= 4'd0;
			else
				pos_num <= pos_num + 1;
            if(apple_gen && snake_x_pos[pos_num] == apple_x_pos && snake_y_pos[pos_num] == apple_y_pos && snake_valid[pos_num] == 1'b1)
                apple_superpos <= 1'b1;
        end

    end
//	产生 apple_gen 信号
    always @ (posedge clk_25M or negedge rst)
    begin
      if(!rst)
        apple_gen <= 1'b0;
      else
		begin
        if(apple_refresh)
            apple_gen <= 1'b1;
        if(apple_gen && !apple_superpos)
            apple_gen <= ~apple_gen;
		end
    end    
//  加入判断是否咬到自己
//  in: clk_1s,rst,snake_x_pos,snake_y_pos
//  out: is_suicide



endmodule
