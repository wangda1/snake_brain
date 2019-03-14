`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:52:25 05/19/2018 
// Design Name: 
// Module Name:    rs_clk_gen 
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
module rs_clk_gen(  
    clk,rst,rs_clk,rs_ena  
     );  
 input clk;//系统时钟  
 input rst;//复位信号  
 input rs_ena; //串口通信允许信号  
 output rs_clk; //输出允许的波特率信号时钟  
   
 parameter N1=10417;//10417,9600bps 100M的系统时钟；  
 parameter N2=5207;//5207,这里是0-5207，共计数5208次  
   
 reg rs_clk='b0;  
 reg [13:0] count='d0;//计数器  
   
 always @(posedge clk or negedge rst)  
 begin  
    if(!rst)  
       begin  
        count<='d0;  //复位信号到来时，count计数器清零  
        end  
    else  
       if(count==N1 || !rs_ena) count<='d0;//当count计满或者无串口通信使能时count都不计数  
        else count<=count+'b1;//当且仅当count不为0，通信使能时count计数。  
 end  
 always @(posedge clk or negedge rst)  
 begin    
    if (!rst)  
     rs_clk<='b0;  
     else  
       if(count==N2&&rs_ena)		//当且仅当count计数到一半 5207 且通信使能时允许时钟翻转  
          rs_clk<='b1;           //  
          else   
          rs_clk<='b0;				//使得rs_clk是一个小波峰的时钟信号，在有效信号的数据位为高电平。  
            
 end  
 endmodule  