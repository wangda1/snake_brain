`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:55:56 06/05/2018 
// Design Name: 
// Module Name:    game_control 
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
`include "Definition.h"

module game_control(
    clk_1s,rst,is_crash,is_suicide,game_status
    );
    input clk_1s;
    input rst;
    input is_crash;
    input is_suicide;
    output reg game_status;               //  输出运行或结束：信号形式为 reg

//  游戏状态转换模块：
//    in: clk_1s,is_crash,is_suicide,game_status
//    out: game_status

    always @ (posedge clk_1s or negedge rst)
    begin
      if(!rst)
        game_status <= `Start;
      else
        if(is_crash || is_suicide)
            game_status <= `Over;
    end


endmodule
