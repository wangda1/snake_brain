`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:22:09 06/08/2018 
// Design Name: 
// Module Name:    CLK_1S 
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
//  根据 snake_speed 来调节蛇的移动速度，speed的值越大，速度越快，
//  注意：输入的 值应该稳定一些，可分2s采集并改变一次
module CLK_1S(
	clk,rst,clk_1s,clk_speed,snake_speed
    );
	 input clk,rst;
    input [2:0] snake_speed;
	 output reg clk_1s;
	 output reg clk_speed;

//  蛇身移动的计数产生模块
//  in: snake_speed
//  out: max_count
//	 6/20：已验证！！
    parameter  [25:0]
        s1s_count = 26'd52428800,
        s0_9s_count = 26'd47185920,
        s0_8s_count = 26'd41943040,
        s0_7s_count = 26'd36700160,
        s0_6s_count = 26'd31457280,
        s0_5s_count = 26'd26214400,
        s0_4s_count = 26'd20971520,
        s0_3s_count = 26'd15728640;
    reg [25:0] max_count;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
            max_count <= s1s_count;
        else
        begin
          case (snake_speed)
            3'd0: max_count <= s1s_count;
            3'd1: max_count <= s0_9s_count;
            3'd2: max_count <= s0_8s_count;
            3'd3: max_count <= s0_7s_count;
            3'd4: max_count <= s0_6s_count;
            3'd5: max_count <= s0_5s_count;
            3'd6: max_count <= s0_4s_count;
            3'd7: max_count <= s0_3s_count;
          endcase
        end
    end

//  （待定）蛇身移动速度产生模块
//  产生1s时钟信号，计数大约到50M电平发生一次跳变
//	 已验证！！
    reg [25:0] count_speed;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            clk_speed <= 1'b0;
            count_speed <= 26'd0;
        end
        else
            if(count_speed >= max_count)
            begin
                clk_speed <= ~clk_speed;
                count_speed <= 26'd0;
            end
            else
                count_speed <= count_speed + 1;
    end
//	1s时钟的产生模块
	 reg [25:0] count_1s;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
        begin
            clk_1s <= 1'b0;
            count_1s <= 26'd0;
        end
        else
            if(count_1s == s1s_count)
            begin
                clk_1s <= ~clk_1s;
                count_1s <= 26'd0;
            end
            else
                count_1s <= count_1s + 1;
    end	

endmodule
