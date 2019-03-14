`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:54:52 05/19/2018 
// Design Name: 
// Module Name:    rs232_top 
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
module rs232_top(  
    input clk,  
    input rst,  
    input rs232_rx,  
    output reg [7:0] sm_seg,  
    output reg [7:0] sm_bit=8'hfe,
	 output [23:0] out_data,
	 output blink,
	 output brain_left,
	 output brain_right
       
    );  
   wire rs_clk,rs_ena; 
	
//==========================================================================================
//	波特率时钟产生模块
// 		  
	 rs_clk_gen M1(  
		 .clk(clk),.rst(rst),.rs_clk(rs_clk),.rs_ena(rs_ena)  
		  );  
		  
//=======================================================================================
//	数据包接收模块
// byte_data_out: 每字节的数据

	wire [7:0] byte_data_out;  
	 rs_receive M2(  
		.rx_data(rs232_rx),  
		.clk(clk),  
		 .rst(rst),  
		 .byte_data_out(byte_data_out),  
		 .rs_clk(rs_clk),  
		.rs_ena(rs_ena)  
		 ); 
	
//=========================================================================================
//	TGAM数据流协议解析
//	小包解析：out 为 16位数据 raw_data

	wire [15:0] out;
	data_analysis3 M3(
		.clk(clk),.rst(rst),.rs_ena(rs_ena),.byte_data_in(byte_data_out),.out_data(out)
		);
		
//=========================================================================================
//大包解析：  out_data 数据格式 [23:16]:signal_data,[15:8]:attention_data,[7:0]:meditation_data

	//wire [23:0] out_data;
	big_packet_analysis M4(
    .clk(clk),.rst(rst),.rs_ena(rs_ena),.byte_data_in(byte_data_out),.out_data(out_data)
    );
	 
	 
//==========================================================================================
//	眨眼检测：out 为输出一个 clk周期的高电平信号

	 //wire blink;
	 wire [9:0] num_clk_calcu;
	 blink_detect M5(
	 .clk(clk),.rst(rst),.raw_data(out),.blink(blink),.num_clk_calcu(num_clk_calcu)
	 );
	 
//===========================================================================================
//	输出脑电波控制转向信号：输出信号形式为持续 一个100MHz的高电平周期
//	这里改变成检测到眨眼仅能向右转！！

	//wire brain_left;
	//wire brain_right;
	
/*	brain_direction M6(
	.clk(clk),.rst(rst),.blink(blink),.brain_right(brain_right),.brain_left(brain_left)
    );*/	
	 
	 assign brain_right = blink;
	 assign brain_left = 1'b0;
	 

//====================数码管显示接收数据部分================================================= 
    parameter N2=210000;  
    reg clk3=1'b0;  
    reg [17:0]count3=18'd0;  
    //assign clk_out=clk3;    
          
    always @(posedge clk or negedge rst)  
    begin  
        if (!rst)  
          begin  
            count3<=18'd0;  
            clk3<=1'b0;  
          end  
        else  
            if(count3<N2-1)  
                begin  
                    count3<=count3+1'b1;  
                    if(count3<(N2/2-1))  
                      clk3<=1'b0;  
                    else  
                      clk3<=1'b1;  
                end   
            else  
            begin  
                count3<=18'd0;  
                clk3<=1'b0;  
            end   
    end  
//==================state select================  
  
	reg[3:0] Num = 4'h0;  
	always @(posedge clk3 or negedge rst)  
	if(!rst)
		sm_bit <= 8'hfe;
	else
	begin  
		 case (sm_bit)  
		 'h7f:  begin  
					Num<=8'h00;  
					sm_bit<='hfe;  
					end  
		 'hfe:  begin  
				   Num<=num_clk_calcu[9:6];  
					sm_bit<='hfd;  
					end
		 'hfd:	begin
					Num <= out_data[19:16];
					sm_bit<='hfb;
					end
		 'hfb:	begin
					Num <= out_data[23:20];
					sm_bit<='hf7;
					end
					
		 'hf7:	begin
					Num <= out[3:0];
					sm_bit<='hef;
					end 
		 'hef:	begin
					Num <= out[7:4];
					sm_bit<='hdf;
					end
		 'hdf:	begin
					Num <= out[11:8];
					sm_bit<='hbf;
					end
		 'hbf:	begin
					Num <= out[15:12];
					sm_bit<='h7f;
					end
		 default: begin 
					 Num<='d0;  
					 sm_bit<='hfe;
					 end
		 endcase  
			
	end  
//=========================共阴管表==============================  
/*
  always @ (Num)//  
    begin  
        case (Num)    
            4'h0 : sm_seg = 8'h3f;   // "0"  
            4'h1 : sm_seg = 8'h06;   // "1"  
            4'h2 : sm_seg = 8'h5b;   // "2"  
            4'h3 : sm_seg = 8'h4f;   // "3"  
            4'h4 : sm_seg = 8'h66;   // "4"  
            4'h5 : sm_seg = 8'h6d;   // "5"//共阴极数码管表  
            4'h6 : sm_seg = 8'h7d;   // "6"  
            4'h7 : sm_seg = 8'h07;   // "7"  
            4'h8 : sm_seg = 8'h7f;   // "8"  
            4'h9 : sm_seg = 8'h6f;   // "9"  
            4'ha : sm_seg = 8'h77;   // "a"  
            4'hb : sm_seg = 8'h7c;   // "b"  
            4'hc : sm_seg = 8'h39;   // "c"  
            4'hd : sm_seg = 8'h5e;   // "d"  
            4'he : sm_seg = 8'h79;   // "e"  
            4'hf : sm_seg = 8'h71;   // "f"  
        endcase   
    end
*/
//==========================共阳管表============================
//{0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90,0x88,0x83,0xc6,0xa1,0x86,0x8e}
	always @ (Num)
		begin
			case (Num)
            4'h0 : sm_seg = 8'hc0;   // "0"  
            4'h1 : sm_seg = 8'hf9;   // "1"  
            4'h2 : sm_seg = 8'ha4;   // "2"  
            4'h3 : sm_seg = 8'hb0;   // "3"  
            4'h4 : sm_seg = 8'h99;   // "4"  
            4'h5 : sm_seg = 8'h92;   // "5"//共阳极数码管表  
            4'h6 : sm_seg = 8'h82;   // "6"  
            4'h7 : sm_seg = 8'hf8;   // "7"  
            4'h8 : sm_seg = 8'h80;   // "8"  
            4'h9 : sm_seg = 8'h90;   // "9"  
            4'ha : sm_seg = 8'h88;   // "a"  
            4'hb : sm_seg = 8'h83;   // "b"  
            4'hc : sm_seg = 8'hc6;   // "c"  
            4'hd : sm_seg = 8'ha1;   // "d"  
            4'he : sm_seg = 8'h86;   // "e"  
            4'hf : sm_seg = 8'h8e;   // "f" 
			endcase
		end
		
//==============================================       
endmodule  
