`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:06:55 06/20/2018 
// Design Name: 
// Module Name:    score_border 
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
//	attention_data,meditation_data
//	========		========
//	= seg_1=		=seg_0 =
//	========		========
//	=	   =		=      =
//	========		========
//	  seg_3			  seg_2
//	  seg_5			  seg_4
module score_border(
	clk_25M,rst,score,attention_data,meditation_data,signal_data,is_score,is_border,is_attention,is_meditation,is_signal,x_pos,y_pos
    );

	input clk_25M;
	input rst;
	input [6:0] x_pos;
	input [5:0] y_pos;
	input [2:0] score;
	input [7:0] attention_data;
	input [7:0] meditation_data;
	input [7:0] signal_data;
	output is_score;
	output is_border;
	output is_attention;
	output is_meditation;
	output is_signal;
	
	reg [6:0] seg_0,seg_1,seg_2,seg_3,seg_4,seg_5;
	always @ (posedge clk_25M or negedge rst)
	begin
		if(!rst)
			begin
				seg_0 <= 7'b0111111;
				seg_1 <= 7'b0111111;
				seg_2 <= 7'b0111111;
				seg_3 <= 7'b0111111;
				seg_4 <= 7'b0111111;
				seg_5 <= 7'b0111111;
			end
		else
		begin
			case(score)
					0: seg_0 <= 7'b0111111;
					1:	seg_0 <= 7'b0000110;
					2:	seg_0 <= 7'b1011011;
					3:	seg_0 <= 7'b1001111;
					4:	seg_0 <= 7'b1100110;
					5:	seg_0 <= 7'b1101101;
					6:	seg_0 <= 7'b1111101;
					7:	seg_0 <= 7'b0000111;
	/*				8:	seg_0 <= 7'b1111111;
					9:	seg_0 <= 7'b1101111;
					a:	seg_0 <= 7'b1110111;
					b:	seg_0 <= 7'b1111100;
					c:	seg_0 <= 7'b0111001;
					d:	seg_0 <= 7'b1011110;
					e:	seg_0 <= 7'b1111011;
					f: 	seg_0 <= 7'b1110001;*/
			endcase
			seg_1 <= 7'b0111111;
			
			case(attention_data[7:4])
					4'h0: seg_3 <= 7'b0111111;
					4'h1:	seg_3 <= 7'b0000110;
					4'h2:	seg_3 <= 7'b1011011;
					4'h3:	seg_3 <= 7'b1001111;
					4'h4:	seg_3 <= 7'b1100110;
					4'h5:	seg_3 <= 7'b1101101;
					4'h6:	seg_3 <= 7'b1111101;
					4'h7:	seg_3 <= 7'b0000111;
					4'h8:	seg_3 <= 7'b1111111;
					4'h9:	seg_3 <= 7'b1101111;
					4'hA:	seg_3 <= 7'b1110111;
					4'hB:	seg_3 <= 7'b1111100;
					4'hC:	seg_3 <= 7'b0111001;
					4'hD:	seg_3 <= 7'b1011110;
					4'hE:	seg_3 <= 7'b1111011;
					4'hF: seg_3 <= 7'b1110001;
			endcase
			
			case(attention_data[3:0])
					4'h0: seg_2 <= 7'b0111111;
					4'h1:	seg_2 <= 7'b0000110;
					4'h2:	seg_2 <= 7'b1011011;
					4'h3:	seg_2 <= 7'b1001111;
					4'h4:	seg_2 <= 7'b1100110;
					4'h5:	seg_2 <= 7'b1101101;
					4'h6:	seg_2 <= 7'b1111101;
					4'h7:	seg_2 <= 7'b0000111;
					4'h8:	seg_2 <= 7'b1111111;
					4'h9:	seg_2 <= 7'b1101111;
					4'hA: seg_2 <= 7'b1110111;
					4'hB: seg_2 <= 7'b1111100;
					4'hC:	seg_2 <= 7'b0111001;
					4'hD:	seg_2 <= 7'b1011110;
					4'hE:	seg_2 <= 7'b1111011;
					4'hF: seg_2 <= 7'b1110001;	
			endcase
			
			case(meditation_data[7:4])
					4'h0: seg_5 <= 7'b0111111;
					4'h1:	seg_5 <= 7'b0000110;
					4'h2:	seg_5 <= 7'b1011011;
					4'h3:	seg_5 <= 7'b1001111;
					4'h4:	seg_5 <= 7'b1100110;
					4'h5:	seg_5 <= 7'b1101101;
					4'h6:	seg_5 <= 7'b1111101;
					4'h7:	seg_5 <= 7'b0000111;
					4'h8:	seg_5 <= 7'b1111111;
					4'h9:	seg_5 <= 7'b1101111;
					4'hA:	seg_5 <= 7'b1110111;
					4'hB:	seg_5 <= 7'b1111100;
					4'hC:	seg_5 <= 7'b0111001;
					4'hD:	seg_5 <= 7'b1011110;
					4'hE:	seg_5 <= 7'b1111011;
					4'hF: seg_5 <= 7'b1110001;		
			endcase
			
			case(meditation_data[3:0])
					4'h0: seg_4 <= 7'b0111111;
					4'h1:	seg_4 <= 7'b0000110;
					4'h2:	seg_4 <= 7'b1011011;
					4'h3:	seg_4 <= 7'b1001111;
					4'h4:	seg_4 <= 7'b1100110;
					4'h5:	seg_4 <= 7'b1101101;
					4'h6:	seg_4 <= 7'b1111101;
					4'h7:	seg_4 <= 7'b0000111;
					4'h8:	seg_4 <= 7'b1111111;
					4'h9:	seg_4 <= 7'b1101111;
					4'hA:	seg_4 <= 7'b1110111;
					4'hB:	seg_4 <= 7'b1111100;
					4'hC:	seg_4 <= 7'b0111001;
					4'hD:	seg_4 <= 7'b1011110;
					4'hE:	seg_4 <= 7'b1111011;
					4'hF: seg_4 <= 7'b1110001;		
			endcase
		end
	end
	
	assign is_score = (x_pos>4 && x_pos<9 && y_pos==5 && seg_1[0]) ||
							(x_pos>4 && x_pos<9 && y_pos==10 && seg_1[6]) ||
							(x_pos>4 && x_pos<9 && y_pos==15 && seg_1[3]) ||
							(y_pos>5 && y_pos<10 && x_pos==4 && seg_1[5]) ||
							(y_pos>5 && y_pos<10 && x_pos==9 && seg_1[1]) ||
							(y_pos>10 && y_pos<15 && x_pos==4 && seg_1[4]) ||
							(y_pos>10 && y_pos<15 && x_pos==9 && seg_1[2]) ||
							
							(x_pos>12 && x_pos<17 && y_pos==5 && seg_0[0]) ||
							(x_pos>12 && x_pos<17 && y_pos==10 && seg_0[6]) ||
							(x_pos>12 && x_pos<17 && y_pos==15 && seg_0[3]) ||
							(y_pos>5 && y_pos<10 && x_pos==12 && seg_0[5]) ||
							(y_pos>5 && y_pos<10 && x_pos==17 && seg_0[1]) ||
							(y_pos>10 && y_pos<15 && x_pos==12 && seg_0[4]) ||
							(y_pos>10 && y_pos<15 && x_pos==17 && seg_0[2]);
							
							
assign is_attention = (x_pos>4 && x_pos<9 && y_pos==25 && seg_2[0]) ||
							(x_pos>4 && x_pos<9 && y_pos==30 && seg_2[6]) ||
							(x_pos>4 && x_pos<9 && y_pos==35 && seg_2[3]) ||
							(y_pos>25 && y_pos<30 && x_pos==4 && seg_2[5]) ||
							(y_pos>25 && y_pos<30 && x_pos==9 && seg_2[1]) ||
							(y_pos>30 && y_pos<35 && x_pos==4 && seg_2[4]) ||
							(y_pos>30 && y_pos<35 && x_pos==9 && seg_2[2]) ||

							(x_pos>12 && x_pos<17 && y_pos==25 && seg_3[0]) ||
							(x_pos>12 && x_pos<17 && y_pos==30 && seg_3[6]) ||
							(x_pos>12 && x_pos<17 && y_pos==35 && seg_3[3]) ||
							(y_pos>25 && y_pos<30 && x_pos==12 && seg_3[5]) ||
							(y_pos>25 && y_pos<30 && x_pos==17 && seg_3[1]) ||
							(y_pos>30 && y_pos<35 && x_pos==12 && seg_3[4]) ||
							(y_pos>30 && y_pos<35 && x_pos==17 && seg_3[2]);

assign is_meditation = (x_pos>12 && x_pos<17 && y_pos==45 && seg_4[0]) ||
							(x_pos>12 && x_pos<17 && y_pos==50 && seg_4[6]) ||
							(x_pos>12 && x_pos<17 && y_pos==55 && seg_4[3]) ||
							(y_pos>45 && y_pos<50 && x_pos==12 && seg_4[5]) ||
							(y_pos>45 && y_pos<50 && x_pos==17 && seg_4[1]) ||
							(y_pos>50 && y_pos<55 && x_pos==12 && seg_4[4]) ||
							(y_pos>50 && y_pos<55 && x_pos==17 && seg_4[2]) ||

							(x_pos>4 && x_pos<9 && y_pos==45 && seg_5[0]) ||
							(x_pos>4 && x_pos<9 && y_pos==50 && seg_5[6]) ||
							(x_pos>4 && x_pos<9 && y_pos==55 && seg_5[3]) ||
							(y_pos>45 && y_pos<50 && x_pos==4 && seg_5[5]) ||
							(y_pos>45 && y_pos<50 && x_pos==9 && seg_5[1]) ||
							(y_pos>50 && y_pos<55 && x_pos==4 && seg_5[4]) ||
							(y_pos>50 && y_pos<55 && x_pos==9 && seg_5[2]);
							
assign is_signal = x_pos>=42 && x_pos<43+signal_data[7:4] && y_pos>1 && y_pos<5;//	画出进度条	
	
assign is_border = 	 (x_pos == 0) ||
							 (x_pos == 20) || 
							 (x_pos == 79) ||
							 (y_pos == 0) ||
							 (y_pos == 59) ||
							 (x_pos>=0 && x_pos<20 && y_pos==20) ||
							 (x_pos>=0 && x_pos<20 && y_pos==40) ||
							 (x_pos>20 && x_pos<80 && y_pos==6) || 		//	画出进度条区域边界
							 (x_pos == 58 && y_pos>1 && y_pos<5);			//	画出进度条边界
		

endmodule
