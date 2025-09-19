`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/20 19:40:18
// Design Name: 
// Module Name: sin_cos_ctrl
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


module sin_cos_ctrl(
	input 			clk_i,
	input			rst_i,
	input [23:0]	din,
	
	output reg [15:0]	sin_out,
	output reg [15:0]	cos_out
);

wire 	m_axis_dout_tvalid;
wire [31 : 0] m_axis_dout_tdata;	


//转换为16定点数
always @(posedge clk_i)
if(m_axis_dout_tvalid)
begin 
	if(m_axis_dout_tdata[15]==0) //正数
	begin 
		if(m_axis_dout_tdata[14] == 1)
			sin_out <= 32767;
		else 
			sin_out <= {1'b0,m_axis_dout_tdata[13:0],1'b0};
	end 
	else if(m_axis_dout_tdata[15]==1) //负数
	begin 
		if(m_axis_dout_tdata[14] == 0)
			sin_out <= -32767;
		else 
			sin_out <= {1'b1,m_axis_dout_tdata[13:0],1'b1};
	end 
end 
		
always @(posedge clk_i)
if(m_axis_dout_tvalid) 
begin 
	if(m_axis_dout_tdata[31]==0) //正数
	begin 
		if(m_axis_dout_tdata[30] == 1)
			cos_out <= 32767;
		else 
			cos_out <= {1'b0,m_axis_dout_tdata[29:16],1'b0};
	end 
	else if(m_axis_dout_tdata[31]==1) //负数
	begin 
		if(m_axis_dout_tdata[30] == 0)
			cos_out <= -32767;
		else 
			cos_out <= {1'b1,m_axis_dout_tdata[29:16],1'b1};
	end
end 	


// always @(posedge clk_i)
// if(m_axis_dout_tvalid) begin 
	// cos_out <= m_axis_dout_tdata[15:0];
	// sin_out <= m_axis_dout_tdata[31:16];
// end 

sin_cos sin_cos (
  .aclk	(clk_i),                                // input wire aclk
  .s_axis_phase_tvalid	(1'b1),  // input wire s_axis_phase_tvalid
  .s_axis_phase_tdata	(din),    // input wire [31 : 0] s_axis_phase_tdata
  .m_axis_dout_tvalid	(m_axis_dout_tvalid),    // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata	(m_axis_dout_tdata)      // output wire [31 : 0] m_axis_dout_tdata,低位cos,高位sin
);
	
	
	
	
endmodule
