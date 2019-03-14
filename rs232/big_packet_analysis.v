`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:32:56 05/22/2018 
// Design Name: 
// Module Name:    big_packet_analysis 
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
module big_packet_analysis(
    clk,rst,rs_ena,byte_data_in,out_data
    );
	 
input clk;
input rst;
input rs_ena;
input [7:0] byte_data_in;
output reg [23:0] out_data;

reg [7:0] data0;
reg [7:0] data1;
reg [7:0] data2;
reg [7:0] data3;

wire byte_int;                  //字节中断表示检测到一个字节接收完成

//===============================检测rs_ena下降沿判断是否一字节数据准备好========================
//表现为持续一个clk周期的高电平
reg byte_int_tmp_0 = 1'b0;
reg byte_int_tmp_1 = 1'b0;
always @(posedge clk or negedge rst)
begin
  if(!rst)
  begin
    byte_int_tmp_0 <= 1'b0;
    byte_int_tmp_1 <= 1'b0;    
  end
  else
  begin
    byte_int_tmp_0 <= rs_ena;
    byte_int_tmp_1 <= byte_int_tmp_0;    
  end
end

assign byte_int = ~byte_int_tmp_0 & byte_int_tmp_1;
//================================采样数据======================================================
reg [7:0] signal_data = 8'h00;
reg [7:0] attention_data = 8'h00;
reg [7:0] meditation_data = 8'h00;
reg frame_int = 1'b0;

always @(posedge clk or negedge rst)
begin
  if(!rst)
    begin   
        data0 <= 8'h00;
        data1 <= 8'h00;
        data2 <= 8'h00;
        data3 <= 8'h00;
    end
  else
    if(byte_int)
    begin
      data0 <= byte_data_in;
      data1 <= data0;
      data2 <= data1;
      data3 <= data2;
    end 
end

reg [4:0] num = 5'd0;
always @(posedge clk or negedge rst)
begin
  if(!rst)
    begin
      signal_data = 8'h00;
      attention_data = 8'h00;
      meditation_data = 8'h00;
    end
  else
    if(frame_int)
    begin
        if(byte_int)
            begin
				if(num == 5'd31)
					num = 2'd1;
				else
					num = num + 1'b1;
            case(num)
                5'd1:  signal_data = byte_data_in;
                5'd29: attention_data = byte_data_in;
                5'd31:
					 begin
					 meditation_data = byte_data_in;
					 out_data = {signal_data,attention_data,meditation_data};
					 end
                default: ;
            endcase
				end
    end
end

//===================================检测帧头部数据===========================================
always @(posedge clk)
begin
  if(data3==8'hAA && data2==8'hAA && data1==8'h20 && data0==8'h02)
    frame_int = 1'b1;
  else
    if(num == 5'd31)
	 begin
        frame_int = 1'b0;
	 end
end

//==================================检测校验和输出数据=========================================

endmodule
