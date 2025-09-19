`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: ARP_rx
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


module ARP_rx#(
    parameter       P_TARGET_IP = {8'd192,8'd168,8'd1,8'd1},
    parameter       P_SOURCE_MAC = {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
    parameter       P_SOURCE_IP  = {8'd192,8'd168,8'd1,8'd2}
)(
    input           i_clk           ,
    input           i_rst           ,

    input   [31:0]  i_source_ip     ,
    input           i_s_ip_valid    ,

    /*--------info port--------*/
    output  [47:0]  o_target_mac    ,
    output  [31:0]  o_target_ip     ,
    output          o_target_valid  ,

    output          o_tirg_reply    ,

    /*--------MAC port--------*/
    input   [7 :0]  i_mac_data      ,
    input           i_mac_last      ,
    input           i_mac_valid     
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [47:0]         ro_target_mac   ;
reg  [31:0]         ro_target_ip    ;
reg                 ro_target_valid ;
reg  [7 :0]         ri_mac_data     ;
reg  [7 :0]         ri_mac_data_1d  ;
reg                 ri_mac_last     ;
reg                 ri_mac_valid    ;
reg  [15:0]         r_mac_cnt       ;
reg  [15:0]         r_arp_op        ;
reg                 ro_tirg_reply   ;
reg  [31:0]         ri_source_ip    ; 

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_target_mac = ro_target_mac ;
assign o_target_ip  = ro_target_ip  ;
assign o_tirg_reply = ro_tirg_reply ;
assign o_target_valid = ro_target_valid;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_mac_data  <= 'd0;
        ri_mac_last  <= 'd0;
        ri_mac_valid <= 'd0;
        ri_mac_data_1d <= 'd0;
    end else begin   
        ri_mac_data  <= i_mac_data ;
        ri_mac_last  <= i_mac_last ;
        ri_mac_valid <= i_mac_valid;
        ri_mac_data_1d <= ri_mac_data;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_source_ip <= P_SOURCE_IP;
    else if(i_s_ip_valid)
        ri_source_ip <= i_source_ip;
    else 
        ri_source_ip <= ri_source_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_cnt <= 'd0;
    else if(ri_mac_valid)   
        r_mac_cnt <= r_mac_cnt + 1;
    else     
        r_mac_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_arp_op <= 'd0;
    else if(r_mac_cnt >= 6 && r_mac_cnt <= 7)
        r_arp_op <= {r_arp_op[7 :0],ri_mac_data};
    else     
        r_arp_op <= r_arp_op;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_target_mac <= 'd0;
    else if(r_mac_cnt >= 8 && r_mac_cnt <= 13 && (r_arp_op == 1 || r_arp_op == 2))
        ro_target_mac <= {ro_target_mac[39:0],ri_mac_data};
    else        
        ro_target_mac <= ro_target_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_target_ip <= 'd0;
    else if(r_mac_cnt >= 14 && r_mac_cnt <= 17 && (r_arp_op == 1 || r_arp_op == 2))
        ro_target_ip <= {ro_target_ip[23:0],ri_mac_data};
    else     
        ro_target_ip <= ro_target_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)    
        ro_target_valid <= 'd0;
    else if(r_mac_cnt == 17)   
        ro_target_valid <= 'd1;
    else        
        ro_target_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_tirg_reply <= 'd0;
    else if(r_mac_cnt == 18 && r_arp_op == 1)
        ro_tirg_reply <= 'd1;
    else 
        ro_tirg_reply <= 'd0;
end

endmodule
