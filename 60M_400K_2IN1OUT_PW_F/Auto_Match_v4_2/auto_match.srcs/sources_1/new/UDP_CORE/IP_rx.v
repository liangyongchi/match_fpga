`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: IP_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 消耗2个周期
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


 module IP_rx#(
    parameter       P_ST_TARGET_IP = {8'd192,8'd168,8'd1,8'd0},
    parameter       P_ST_SOURCE_IP = {8'd192,8'd168,8'd1,8'd1}
)(
    input           i_clk               ,
    input           i_rst               ,

    /*--------info port --------*/
    input  [31:0]   i_target_ip         ,
    input           i_target_valid      ,
    input  [31:0]   i_source_ip         ,
    input           i_source_valid      ,

    /*--------data port--------*/
    output [15:0]   o_udp_len           ,
    output [7 :0]   o_udp_data          ,
    output          o_udp_last          ,
    output          o_udp_valid         ,
    output [15:0]   o_icmp_len          ,
    output [7 :0]   o_icmp_data         ,
    output          o_icmp_last         ,
    output          o_icmp_valid        ,

    output [31:0]   o_source_ip         ,
    output          o_source_ip_valid   ,

    /*--------mac port--------*/
    input  [7 :0]   i_mac_data          ,
    input           i_mac_last          ,
    input           i_mac_valid

);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [31:0]         r_target_ip         ;
reg  [31:0]         r_source_ip         ;
reg  [7 :0]         ri_mac_data         ;
reg  [7 :0]         ri_mac_data_1d      ;
reg                 ri_mac_last         ;
reg                 ri_mac_valid        ;
reg                 ri_mac_valid_1d     ;
reg  [15:0]         ro_udp_len          ;
reg                 ro_udp_last         ;
reg                 ro_udp_valid        ;
reg  [15:0]         ro_icmp_len         ;
reg                 ro_icmp_last        ;
reg                 ro_icmp_valid       ;
reg  [15:0]         r_ip_len            ;
reg  [7 :0]         r_ip_type           ;
reg  [31:0]         r_ip_source         ;
reg  [31:0]         r_ip_target         ;
reg  [15:0]         r_ip_cnt            ;
reg                 ro_source_ip_valid  ;

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_udp_data   = ri_mac_data_1d    ;
assign o_icmp_data  = ri_mac_data_1d    ;
assign o_udp_len    = ro_udp_len        ;
assign o_udp_last   = ro_udp_last       ;
assign o_udp_valid  = ro_udp_valid      ;
assign o_icmp_len   = ro_icmp_len       ;
assign o_icmp_last  = ro_icmp_last      ;
assign o_icmp_valid = ro_icmp_valid     ;
assign o_source_ip       = r_ip_source  ;
assign o_source_ip_valid = ro_source_ip_valid;
/***************always****************/

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_ip <= P_ST_TARGET_IP;
    else if(i_target_valid)
        r_target_ip <= i_target_ip;
    else 
        r_target_ip <= r_target_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_ip <= P_ST_SOURCE_IP;
    else if(i_source_valid)
        r_source_ip <= i_source_ip;
    else 
        r_source_ip <= r_source_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_mac_data  <= 'd0;
        ri_mac_last  <= 'd0;
        ri_mac_valid <= 'd0;
        ri_mac_data_1d <= 'd0;
        ri_mac_valid_1d <= 'd0;
    end else begin
        ri_mac_data  <= i_mac_data ;
        ri_mac_last  <= i_mac_last ;
        ri_mac_valid <= i_mac_valid;
        ri_mac_data_1d <= ri_mac_data;
        ri_mac_valid_1d <= ri_mac_valid;
    end
end
   
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_cnt <= 'd0;
    else if(ri_mac_valid)
        r_ip_cnt <= r_ip_cnt + 1;
    else 
        r_ip_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_len <= 'd0;
    else if(r_ip_cnt >= 2 && r_ip_cnt <= 3)
        r_ip_len <= {r_ip_len[7:0],ri_mac_data};
    else 
        r_ip_len <= r_ip_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_type <= 'd0;
    else if(r_ip_cnt == 9)
        r_ip_type <= ri_mac_data;
    else 
        r_ip_type <= r_ip_type;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_source <= 'd0;
    else if(r_ip_cnt >= 12 && r_ip_cnt <= 15)
        r_ip_source <= {r_ip_source[23:0],ri_mac_data};
    else    
        r_ip_source <= r_ip_source;
end     

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_source_ip_valid <= 'd0;
    else if(r_ip_cnt == 15)
        ro_source_ip_valid <= 'd1;
    else 
        ro_source_ip_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_target <= 'd0;
    else if(r_ip_cnt >= 16 && r_ip_cnt <= 19)
        r_ip_target <= {r_ip_target[23:0],ri_mac_data};
    else 
        r_ip_target <= r_ip_target;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_udp_len  <= 'd0;
        ro_icmp_len <= 'd0;
    end else begin
        ro_udp_len  <= r_ip_len - 20;
        ro_icmp_len <= r_ip_len - 20;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_valid <= 'd0;
    else if(!ri_mac_valid && ri_mac_valid_1d)
        ro_udp_valid <= 'd0;
    else if(r_ip_cnt == 20 && r_ip_target == r_source_ip && r_ip_type == 17)
        ro_udp_valid <= 'd1;
    else 
        ro_udp_valid <= ro_udp_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_icmp_valid <= 'd0;
    else if(!ri_mac_valid && ri_mac_valid_1d)
        ro_icmp_valid <= 'd0;
    else if(r_ip_cnt == 20 && r_ip_target == r_source_ip && r_ip_type == 1)
        ro_icmp_valid <= 'd1;
    else 
        ro_icmp_valid <= ro_icmp_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_udp_last <= 'd0;
    else if(!i_mac_valid && ri_mac_valid && r_ip_type == 17)
        ro_udp_last <= 'd1;
    else 
        ro_udp_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_icmp_last <= 'd0;
    else if(!i_mac_valid && ri_mac_valid && r_ip_type == 1)
        ro_icmp_last <= 'd1;
    else 
        ro_icmp_last <= 'd0;
end

endmodule
