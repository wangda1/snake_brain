`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:30 05/28/2018 
// Design Name: 
// Module Name:    blink_detect 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 重写：把计算模块分离开来放到组合逻辑电路中；控制模块放到时序逻辑模块中，减小规模
//					 重写已完成，测试完成
//					  6/10：算法改进：将睁眼检测模块删掉，仅检测闭眼信号，参数选择改进，计算出错，改进成为定点数运算
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//	input: raw_data,
//	output: blink 输出信号形式为：持续不定周期的高电平
//
module blink_detect(
    clk,rst,raw_data,blink,num_clk_calcu
    );

    input clk;
    input rst;
	 input [15:0]raw_data;									//	 输入数据为最高位为 符号位的有符号数表示形式
    output blink;                               	//  输出为持续一个时钟周期的高电平
	 output [9:0] num_clk_calcu;							//	 clk_calcu的计数


    reg [31:0] mean_value = 32'd0;              	//  均值
    reg [31:0] mean_square_value = 32'd2560000;   	//  均方值
    reg [31:0] s_square = 32'd0;                	//  s的平方值

    reg [63:0] k1 = 64'h0000_0000_0000_00ff;					//	8位小数定点数表示为：0.99609375 B0.11111111
    reg [63:0] k2 = 64'h0000_0000_0000_0001;						//  8位小数定点数表示为：0.00390625 B0.00000001

    parameter [2:0]
        case_Init = 2'd0,                           //  重置事件
        case_A = 2'd1,                              //  睁眼事件
        case_B = 2'd2;                              //  闭眼事件
    
    reg [2:0] state = 3'd0;                         //  当前事件
    reg [7:0] num = 8'd0;                           //  计次数
	 reg [63:0] tmp_1 = 64'd0;						//	加32位寄存器防止数据被截断
	 reg [63:0] tmp_2 = 64'd0;
	 reg [31:0] exten_data = 32'd0;
	 reg [31:0] tmp_exten_data = 32'd0;					//	用于暂时存放上次 raw_data数据用于时序逻辑模块比较

    reg blink = 1'b0;
	
    //  计算模块
    //	24 + 8 的定点数计算模式
	 //  6/11测试：时间约束问题，尝试使计算模块改成时序逻辑模块并降低时钟频率！！
	 //  6/17：raw_data 数据改变成有符号数，引入有符号定点小数计算模块！！
	 //  6/17：验证结果：已验证！！
	reg clk_calcu;
	reg [4:0] num_calcu;									//	计数到19达成20个周期
	parameter [4:0] max_num_calcu = 5'd19;
	//reg calcu_flag;										//	1---代表当前 exten_data为负数 0---代表当前 exten_data 为正数
	always @ (posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			tmp_exten_data <= 32'd0;
			exten_data <= 32'd0;
			clk_calcu <= 1'b0;
			num_calcu <= 5'd0;
		end
		else
		begin
			exten_data <= raw_data[15] ? {32'd0}:{8'b0000_0000,raw_data,8'b0000_0000};
			//	求源码表示
			if(exten_data != tmp_exten_data)
				begin
				tmp_exten_data <= exten_data;
				clk_calcu <= 1'b1;
				num_calcu <= 5'd0;
				end
			else
				num_calcu <= num_calcu + 1;
			if(num_calcu == max_num_calcu)
				begin
					clk_calcu <= 1'b0;
					num_calcu <= 5'd0;
				end
		end	
	end
//	debug: 引出clk_calcu 的次数
	
	reg [9:0] num_clk_calcu;
	always @ (posedge clk_calcu or negedge rst)
	begin
		if(!rst)
			num_clk_calcu <= 10'd0;
		else
			num_clk_calcu <= num_clk_calcu + 1'b1;
	end
	
//	时钟改为 raw_data数据改变时的一个持续 一个周期的上升沿并采用上升沿触发
//	6/11 	已验证！！结果正确！！
//	6/17  引入有符号定点小数计算，验证结果：已验证！！！
//	第一次输入为负数情况的考虑
	always @ (posedge clk_calcu or negedge rst)
	begin
		if(!rst)
		    begin
			    mean_value = 32'd0;
			    mean_square_value = 32'd2560000;
			    s_square = 32'd0;
		    end
		else	
			begin
//===============================计算均值=================================================	 
			mean_value =  (k1 * mean_value + k2 * exten_data) >> 8;	
//===============================计算均方值===============================================		  
			mean_square_value = (k1 * mean_square_value  + ((k2 * exten_data) >> 8 ) * exten_data) >> 8;
//===============================计算s_square=============================================
//====						存在数据截断问题，加1寄存器作为中间输出						  
			if(exten_data  > mean_value)
				begin
					tmp_1 = ((exten_data - mean_value) * (exten_data - mean_value)) >> 8;
					tmp_2 = (mean_value * mean_value) >> 8;
					s_square = (tmp_1 << 8) / (mean_square_value - tmp_2);
			    end
			else
				begin
					tmp_1 =  ((mean_value - exten_data) * (mean_value - exten_data)) >> 8;
					tmp_2 = (mean_value * mean_value) >> 8;
					s_square = (tmp_1 << 8) / (mean_square_value - tmp_2);
				end
			end

    end
//  控制模块
//  时序逻辑模块
//	1.组合逻辑每次改变数据就执行一次，而时序逻辑则会每个时钟沿执行一次
//	 6/11: bug:计数num 必须准确计出 来到的数据个数！！！
//			 修复：利用上面计算时钟，检测其下降沿（持续20个时钟周期），此时数据应当都准备好
//			 
    parameter [31:0]
        value_A = 32'd4096;	//32'd2304;                      //  事件A的s_square 9 * 256
    //    value_B = 8'd4;                        //  事件B的s_square
    parameter [7:0] max_num = 8'd200;            //  最大计次数
    always @(negedge clk_calcu or posedge clk_calcu or negedge rst)    
        begin
        if(!rst)
            begin
                state <= case_Init;
                blink <= 1'b0;
                num <= 8'd0;
            end
        else if(!clk_calcu)
				begin
					blink <= 1'b0;
					$display("Now in negedge !");
//===============================判断是否为事件A即：闭眼====================================	
					if(num < max_num)
						begin
						if(s_square > value_A && exten_data > mean_value && state == case_Init)
							begin
								state <= case_A;
								num <= 8'd0;  
								blink <= 1'b1;
							end
						else
							num <= num + 1;
						end
					else
						begin
							state <= case_Init;
							num <= 8'd0;
						end
				end
			else
				begin
				$display("Now in posedge !");
				blink <= 1'b0;
				end
				
		end

endmodule
