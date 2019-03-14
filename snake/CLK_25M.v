`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:22:29 06/08/2018 
// Design Name: 
// Module Name:    CLK_25M 
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
module CLK_25M(
	clk,rst,clk_25M
    );
	 input clk,rst;
	 output reg clk_25M;
	 
//	产生行列时序信号
//	640 * 480 需要25MHz时钟频率
//	已验证！！
	 parameter [1:0]
		N1 = 2'd3,
		N2 = 2'd1;
	 reg [1:0] count = 2'd0;
	 
	 always @(posedge clk or negedge rst)
	 begin
		if(!rst)
			count <= 2'd0;
		else
			if(count == N1)
				count <= 2'd0;
			else
				count <= count + 1;
	 end
	 always @(posedge clk or negedge rst)
	 begin
		if(!rst)
			clk_25M <= 1'b0;
		else
			if(count == N1)
				clk_25M <= 1'b0;
			else if(count == N2)
				clk_25M <= 1'b1;
	  end

endmodule
