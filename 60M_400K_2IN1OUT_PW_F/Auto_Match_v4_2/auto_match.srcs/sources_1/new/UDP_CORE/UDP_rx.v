`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: UDP_rx
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


module UDP_rx#(
    parameter           P_TARGET_PORT   =  16'h8080 ,
                        P_SOURCE_PORT   =  16'h8080
)(
    input               i_clk           ,
    input               i_rst           ,

    /*--------info port-------*/
    input  [15:0]       i_target_port   ,
    input               i_target_valid  ,
    input  [15:0]       i_source_port   ,
    input               i_source_valid  ,

    /*--------data port--------*/
    output [15:0]       o_udp_len       ,
    output [7 :0]       o_udp_data      ,
    output              o_udp_last      ,
    output              o_udp_valid     ,

    /*--------ip port--------*/
    input  [15:0]       i_ip_len        ,
    input  [7 :0]       i_ip_data       ,
    input               i_ip_last       ,
    input               i_ip_valid      
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]             r_target_port   ;
reg  [15:0]             r_source_port   ;
reg  [15:0]             ri_ip_len       ;
reg  [7 :0]             ri_ip_data      ;
reg                     ri_ip_last      ;
reg                     ri_ip_valid     ;
reg  [15:0]             ro_udp_len      ;
reg                     ro_udp_last     ;
reg                     ro_udp_valid    ;
reg  [15:0]             r_udp_cnt       ;

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_udp_len   = ro_udp_len         ;
assign o_udp_data  = ri_ip_data         ;
assign o_udp_last  = ro_udp_last        ;
assign o_udp_valid = ro_udp_valid       ;
/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_port <= 'd0;
    else if(i_target_valid)       
        r_target_port <= i_target_port;
    else 
        r_target_port <= r_target_port;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_port <= 'd0;
    else if(i_source_valid)       
        r_source_port <= i_source_port;
    else 
        r_source_port <= r_source_port;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_ip_len   <= 0;
        ri_ip_data  <= 0;
        ri_ip_last  <= 0;
        ri_ip_valid <= 0;
    end else if(i_ip_valid) begin
        ri_ip_len   <= i_ip_len  ;
        ri_ip_data  <= i_ip_data ;
        ri_ip_last  <= i_ip_last ;
        ri_ip_valid <= i_ip_valid;
    end else begin
        ri_ip_len   <= ri_ip_len  ;
        ri_ip_data  <= 'd0 ;
        ri_ip_last  <= 'd0 ;
        ri_ip_valid <= 'd0;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_udp_cnt <= 'd0;
    else if(ri_ip_valid)
        r_udp_cnt <= r_udp_cnt + 1;
    else 
        r_udp_cnt <= 'd0;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_len <= 'd0;
    else 
        ro_udp_len <= ri_ip_len - 8;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_valid <= 'd0;
    else if(r_udp_cnt == ri_ip_len - 1)
        ro_udp_valid <= 'd0;
    else if(r_udp_cnt == 7)
        ro_udp_valid <= 'd1;
    else 
        ro_udp_valid <= ro_udp_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)   
        ro_udp_last <= 'd0;
    else if(r_udp_cnt == ri_ip_len - 2)
        ro_udp_last <= 'd1;
    else 
        ro_udp_last <= 'd0;
end

endmodule
