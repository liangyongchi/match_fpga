//////////////////////////////////////////////////////////////////////////////////
// Company: COPYRIGHT 2021-2031, QUANTALUS All Rights Reserved.
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF QUANTALUS.
// The copyright notice above does not evidence any actual or intended
// publication of such source code. 
// All materials not authorized may not be redirected or for other usages.
// 
// Project Name: 
// Module Name: gen_sync_reset
// Description:  
// Dependencies: 
// Engineer: Zhehao Shi
// Create Date: 2022/11/24 14:13:33
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
// Revision:
// V1.0    2022/11/24  Zhehao Shi  first create
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module gen_sync_reset #(
    parameter CLK_FREQ = 200000 , //200Mhz
    parameter DLY_TIME = 1000     //1000ms
)(
    //------system
    input   wire                i_clk              ,
    input   wire                i_rst              ,

    output  wire                o_rst              ,
    output  wire                o_rstn             
);
//-----------------------parameter-------------------
`ifndef SIM
    localparam  DLY_TINE_CNT = (DLY_TIME*1000000)/(1000/(CLK_FREQ/1000));
`else
    localparam  DLY_TINE_CNT = 400;
`endif
//----------------------inner signal-----------------
reg  [31:0]             r_dly_cnt  = DLY_TINE_CNT ;

reg                     r_rst_d1   =  1'b1 ;
reg                     r_rst_d2   =  1'b1 ;
reg                     r_rst_d3   =  1'b1 ;
//----------------------instance---------------------

//----------------------main code-------------------- 
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst == 1'b1) begin
        r_rst_d1 <= 1'b1 ;
        r_rst_d2 <= 1'b1 ;
    end
    else begin
        r_rst_d1 <= 1'b0    ;
        r_rst_d2 <= r_rst_d1;
    end
end

always @(posedge i_clk or posedge r_rst_d2)
begin
    if(r_rst_d2 == 1'b1) begin
        r_dly_cnt <= DLY_TINE_CNT ;
    end
    else if(|r_dly_cnt) begin
        r_dly_cnt <= r_dly_cnt - 32'd1 ;
    end
    else ;
end

always @(posedge i_clk or posedge r_rst_d2)
begin
    if(r_rst_d2 == 1'b1) begin
        r_rst_d3 <= 1'b1 ;
    end
    else if(r_dly_cnt==32'd0) begin
        r_rst_d3 <= 1'b0 ;
    end
end

assign o_rst  =  r_rst_d3;
assign o_rstn = ~r_rst_d3;

endmodule // gen_sync_reset
