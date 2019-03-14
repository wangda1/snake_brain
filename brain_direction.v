`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:31:00 06/20/2018 
// Design Name: 
// Module Name:    brain_direction 
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
//  脑电波方向判断模块
//	 in: blink信号为持续不定时间的高电平
//  out: brain_right,brain_left输出信号形式为100MHz的高电平

module brain_direction(
	clk,rst,blink,brain_right,brain_left
    );
    input clk,rst;
    input blink;
    output brain_left,brain_right;
	 
	 

//  2s的分频模块：计2s时间内的眨眼次数
//  当眨眼次数为1时输出左转信号
//  当眨眼次数为大于等于2时输出右转信号
//	 6/20：已验证！！！
/*	reg [27:0] count_2s;
	reg blink_1;
	reg blink_2;
	reg [2:0] blink_num;
    parameter [27:0]
        s2s_count = 28'd268435456;
//			 s2s_count = 28'd100;
//        s_0_5_count = 27'd687432000;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)									//		!rst 有的信号不能重置！！！
		  begin
            count_2s <= 28'd0;
				brain_left <= 1'b0;
				brain_right <= 1'b0;	
		  end
        else
        begin
				brain_left <= 1'b0;
				brain_right <= 1'b0;
            if(count_2s == s2s_count)
            begin
					 count_2s <= 28'd0;
                if(blink_num == 1)
                    brain_left <= 1'b1;
                else if(blink_num >= 2)
                    brain_right <= 1'b1;
            end
            else
                count_2s <= count_2s + 1;
        end
    end
	 
	 always @ (posedge clk or negedge rst)
	 if(!rst)
		 begin
				blink_num <= 3'd0;
		 end
	 else
		begin
				blink_1 <= blink;
				blink_2 <= blink_1;
				if(blink_1 && !blink_2)
					blink_num <= blink_num + 1'b1;
	 end*/

	 

endmodule
