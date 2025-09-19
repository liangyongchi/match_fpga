`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 15:53:00
// Design Name: 
// Module Name: CW_PW_POWER_DISPLAY
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


module CW_PW_POWER_DISPLAY(
      input              i_clk              ,
	  input              i_rst              ,
      input   [15:0]     i_vf_power_calib   ,
	  input   [15:0]     i_vr_power_calib   ,
      input   [15:0]     i_vf_power2_calib  ,	  
	  input   [15:0]     i_vr_power2_calib  ,	 
										    
	  input              i_pulse0_on        ,
	  input              i_pulse2_on        ,	
										    
	  input              i_pw_mode0         ,
	  input              i_pw_mode2         ,	
										    
	  output reg [15:0]  o_vf_power_calib   ,
	  output reg [15:0]	 o_vr_power_calib   ,
	  output reg [15:0]  o_vf_power2_calib  ,
	  output reg [15:0]	 o_vr_power2_calib  	  
	  
);

always@(posedge i_clk or posedge i_rst)begin
     if(i_rst)begin
	     o_vf_power_calib  <= 16'd0;
	     o_vr_power_calib  <= 16'd0;
	 end   
	 else if(i_pw_mode0) begin
	       if(i_pulse0_on)begin
	          o_vf_power_calib  <= i_vf_power_calib;
	          o_vr_power_calib  <= i_vr_power_calib;
	       end
		   else begin
	             o_vf_power_calib  <= o_vf_power_calib;
	             o_vr_power_calib  <= o_vr_power_calib;		
		   end	
	 end
	 else begin
	     o_vf_power_calib  <= i_vf_power_calib;
	     o_vr_power_calib  <= i_vr_power_calib; 
	 
	 end
end


always@(posedge i_clk or posedge i_rst)begin
     if(i_rst)begin
	     o_vf_power2_calib  <= 16'd0;
	     o_vr_power2_calib  <= 16'd0;
	 end   
	 else if(i_pw_mode2) begin
	       if(i_pulse2_on)begin
	          o_vf_power2_calib  <= i_vf_power2_calib;
	          o_vr_power2_calib  <= i_vr_power2_calib;
	       end
		   else begin
	             o_vf_power2_calib  <= o_vf_power2_calib;
	             o_vr_power2_calib  <= o_vr_power2_calib;		
		   end	
	 end
	 else begin
	     o_vf_power2_calib  <= i_vf_power2_calib;
	     o_vr_power2_calib  <= i_vr_power2_calib; 
										 
	 end
end


	 
endmodule

