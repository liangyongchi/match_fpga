`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/21 14:43:43
// Design Name: 
// Module Name: demod_code
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module demod_code(
	input 			clk_i,	//
	input			rst_i,
	input [31:0]	freq_data,
	input [15:0]	i,
	
	output [31:0]	dout
	
);

//reg [15:0]	i;
reg  [23:0]	din;
wire [12:0]	calib;

//real = cos(2 * PI * fdc * i / fs);	//把pi归一  fpga = cos(2 * PI * fdc / fs)
// data = 2 * freq_data / 4.294967 /fdc * 2^32 = 125 * i * freq_data;

// always@(posedge clk_i or posedge rst_i)
	// if(rst_i)
		// i <= 0;
	// else if(i==3124)
		// i <= 0;
	// else 
		// i <= i+1;
		
		
wire [31 : 0]   P0;
reg  [31 : 0]	freq_data_r0;
mult_unsigned_16x16 u0 (
  .CLK		(clk_i),  // input wire CLK
  .A		(16'd125),// input wire [15 : 0] A	2^32
  .B		(i),      // input wire [15 : 0] B
  .P		(P0)      // output wire [31 : 0] P
);

always@ (posedge clk_i)
	freq_data_r0 <= freq_data;

wire [63 : 0] P1;
mult_unsigned_32x32 u1 (
  .CLK		(clk_i),  	
  .A		(P0),     	//22bit;
  .B		(freq_data_r0),      	
  .P		(P1)    //32定点数，�?要转�?16定点�?
);

wire [47 : 0] Pout;
assign Pout = P1>>16;

// reg [18:0] Pout;
// always@(posedge clk_i or posedge rst_i)
	// if(rst_i)
		// Pout <= 0;
	// else 
		// Pout <= Pout+1;

//assign calib = P[12:0] - 13'd8191;

// always@(posedge clk_i or posedge rst_i)
	// if(rst_i)
		// din <= 16'd0;
	// else if(Pout[13]==0) //偶数
		// din <= {3'b000,Pout[12:0]};
	// else if(Pout[13]==1) //奇数
		// din <= Pout[12:0] - 13'd8191;

always@(posedge clk_i or posedge rst_i)
	if(rst_i)
		din <= 19'd0;
	else if(Pout[16]==0) //偶数
		din <= {3'b000,Pout[15:0]};
	else if(Pout[16]==1) //奇数
		din <= Pout[15:0] - 16'd65535;

wire [15:0]	sin_out,cos_out;
sin_cos_ctrl	sin_cos_ctrl(
	.clk_i		(clk_i),
	.rst_i		(rst_i),
	.din		(din),	//16位定点数�?65535
	.sin_out	(sin_out),
	.cos_out	(cos_out)
);

assign dout = {cos_out,sin_out};

endmodule
