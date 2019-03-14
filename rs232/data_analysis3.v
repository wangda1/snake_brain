`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:36:35 05/22/2018 
// Design Name: 
// Module Name:    data_analysis3 
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
//====================================================
//检测raw_data
//非状态机写法
// 6/17：bug：raw_data解析出来存在负数的情况，因此引入有符号数的计算！！！

module data_analysis3(
    clk,rst,rs_ena,byte_data_in,out_data
);

input clk;
input rst;
input rs_ena;
input [7:0] byte_data_in;
output reg [15:0] out_data;

reg [7:0] data0;
reg [7:0] data1;
reg [7:0] data2;
reg [7:0] data3;
reg [7:0] data4;

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
reg [7:0] high_data = 8'h00;
reg [7:0] low_data = 8'h00;
reg [7:0] check_sum = 8'h00;
reg frame_int = 1'b0;

always @(posedge clk or negedge rst)
begin
  if(!rst)
    begin   
        data0 <= 8'h00;
        data1 <= 8'h00;
        data2 <= 8'h00;
        data3 <= 8'h00;
        data4 <= 8'h00;
    end
  else
    if(byte_int)
    begin
      data0 <= byte_data_in;
      data1 <= data0;
      data2 <= data1;
      data3 <= data2;
      data4 <= data3;
    end 
end

reg [1:0] num = 2'h0;
always @(posedge clk or negedge rst)
begin
  if(!rst)
    begin
      high_data = 8'h00;
      low_data = 8'h00;
      check_sum = 8'h00;
    end
  else
    if(frame_int)
    begin
        if(byte_int)
            begin
				if(num == 2'd3)
					num = 2'd1;
				else
					num = num + 1'b1;
            case(num)
                2'h1: high_data = byte_data_in;
                2'h2: low_data = byte_data_in;
                2'h3:
                begin 
                check_sum = byte_data_in;
					 if((((8'h80+8'h02+high_data+low_data)^32'hffffffff) & 8'hff) == check_sum)
					 begin
						//$display("check right!");
						if((high_data << 8 | low_data) > 32768)
							out_data = (high_data << 8 | low_data) - 65536;
						else
							out_data = high_data << 8 | low_data;
					 end
/*					 else
						out_data = 16'h0;*/
                end
                default: {high_data,low_data,check_sum} = 24'h000000;
            endcase
				end
    end
end

//===================================检测帧头部数据===========================================
always @(posedge clk)
begin
  if(data4==8'hAA && data3==8'hAA && data2==8'h04 && data1==8'h80 && data0==8'h02)
    frame_int = 1'b1;
  else
    if(num == 2'd3)
	 begin
        frame_int = 1'b0;
	 end
end

//==================================检测校验和输出数据=========================================

endmodule
