`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:53:46 05/19/2018 
// Design Name: 
// Module Name:    rs_receive 
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
module rs_receive(  
    input rx_data,//接收到的串口数据  
    input clk,  
    input rst,  
    output [7:0] byte_data_out,//接收完成的一字节数据输出  
    input rs_clk,//输入的数据有效采样时刻时钟  
    output reg rs_ena='b0//有效数据到来标志  
    );  
   
//++++++++++++++++++++++++++++++++++++++++++++++  
  reg rx_data0='b0;  
  reg rx_data1='b0;   
  reg rx_data2='b0;//声明寄存器用于提取有效数据的下降沿；  
  wire neg_rx_data=~rx_data1 & rx_data2;//下降沿时该信号电平为高    
  always @(posedge clk or negedge rst)    
  begin  
    if(!rst)  
      begin  
            rx_data0<='b0;  
            rx_data1<='b0;  
            rx_data2<='b0;  
      end  
     else  
        begin  
            rx_data0<=rx_data;  
            rx_data1<=rx_data0;  
            rx_data2<=rx_data1;  
        end  
  end  
 //+++++++++++++++++++++++++++++++++++++++++++++  
 reg rx_int='b0;//接收中断信号  
 //reg rs_ena;  
  reg [3:0]num='d0;  
 always @(posedge clk or negedge rst)  
 begin  
    if(!rst)  
     begin  
        rx_int<='b0;  
        rs_ena<='bz;  
     end  
     else  
        if(neg_rx_data)  
            begin  
                rx_int<='b1;//下降沿到来时，产生接收中断--此期间即使有下降沿到来也不理会，此时使能模块1，即rs_ena为高电平。  
                rs_ena<='b1;  
             end  
        else  
           if(num=='d10)  
            begin  
                rx_int<='b0;//num==10,即数据接收完成时，中断结束。  
                rs_ena<='b0;  
            end  
 end  
 reg [7:0]rx_data_buf='d0;//接收信号缓存区，由于数据一位一位传输，不能立刻赋值输出，用于缓存数据，到接收完成再赋值给输出  
 reg [7:0]data_byte_r='d0;//寄存器型，用于完成赋值，最后赋给输出。  
 assign byte_data_out=data_byte_r;  
  
 always @(posedge clk or negedge rst)  
 begin  
        if(!rst)  
            num<='d0;  
         else   
         if(rx_int)  
          begin  
              if(rs_clk)//在接收中断的情况下，到来一次采样时钟进行一次如下运算，  
                 begin  
                    num<=num+1'b1;  
                    case(num)  
                     'd1:rx_data_buf[0]<=rx_data;  
                     'd2:rx_data_buf[1]<=rx_data;  
                     'd3:rx_data_buf[2]<=rx_data;  
                     'd4:rx_data_buf[3]<=rx_data;//数据依次加入到缓存区  
                       
                     'd5:rx_data_buf[4]<=rx_data;  
                     'd6:rx_data_buf[5]<=rx_data;  
                     'd7:rx_data_buf[6]<=rx_data;  
                     'd8:rx_data_buf[7]<=rx_data;  
                     default:;  
                    endcase  
                  end  
                else  
                  if(num=='d10)  
                     begin//数据接收完成，将缓存数据交给寄存器，同时计数器清零  
                        num<='d0;  
                        data_byte_r<=rx_data_buf;  
                     end  
            end  
 end  
    
endmodule
