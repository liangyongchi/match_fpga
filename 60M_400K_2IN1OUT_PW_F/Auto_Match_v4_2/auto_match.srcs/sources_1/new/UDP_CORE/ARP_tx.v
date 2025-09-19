`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: ARP_tx
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


module ARP_tx#(
    parameter       P_TARGET_IP = {8'd192,8'd168,8'd1,8'd1},
    parameter       P_SOURCE_MAC = {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
    parameter       P_SOURCE_IP  = {8'd192,8'd168,8'd1,8'd2}
)(
    input           i_clk           ,
    input           i_rst           ,

    input   [31:0]  i_target_ip     ,
    input           i_target_valid  ,
    input   [47:0]  i_source_mac    ,
    input           i_s_mac_valid   ,
    input   [31:0]  i_source_ip     ,
    input           i_s_ip_valid    ,

    input   [47:0]  i_reply_mac     ,

    output  [31:0]  o_seek_ip       ,
    output          o_seek_valid    ,

    input           i_trig_reply    ,
    input           i_active_send   ,

    output  [7 :0]  o_mac_data      ,
    output          o_mac_last      ,
    output          o_mac_valid     
);

/***************function**************/

/***************parameter*************/
localparam          P_LEN    = 46   ;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [31:0]         r_target_ip     ;
reg                 ri_trig_reply   ;
reg                 ri_active_send  ;
reg  [7 :0]         ro_mac_data     ;
reg                 ro_mac_last     ;
reg                 ro_mac_valid    ;
reg  [15:0]         r_mac_cnt       ;
reg  [15:0]         r_arp_op        ;
reg  [47:0]         ri_source_mac   ; 
reg  [31:0]         ri_source_ip    ; 
reg  [31:0]         ro_seek_ip      ;
reg                 ro_seek_valid   ;
reg  [47:0]         ri_reply_mac    ;
reg  [15:0]         r_arp_cnt       ;

/***************wire******************/
wire                w_act           ;

/***************component*************/

/***************assign****************/
assign o_mac_data  = ro_mac_data    ;
assign o_mac_last  = ro_mac_last    ;
assign o_mac_valid = ro_mac_valid   ;
assign o_seek_ip    = ro_seek_ip    ;
assign o_seek_valid = ro_seek_valid ;
assign w_act       = r_arp_cnt == 10;

/***************always****************/
   

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        ro_seek_valid <= 'd0;
    else if(i_trig_reply | i_active_send)
        ro_seek_valid <= 'd1;
    else            
        ro_seek_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_seek_ip <= 'd0;
    else 
        ro_seek_ip <= ri_source_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_ip <= P_TARGET_IP;
    else if(i_target_valid)
        r_target_ip <= i_target_ip;
    else 
        r_target_ip <= r_target_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_source_mac <= P_SOURCE_MAC;
    else if(i_s_mac_valid)
        ri_source_mac <= i_source_mac;
    else 
        ri_source_mac <= ri_source_mac;
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
    if(i_rst) begin
        ri_trig_reply  <= 'd0;
        ri_active_send <= 'd0;
    end else begin
        ri_trig_reply  <= i_trig_reply ;
        ri_active_send <= i_active_send | w_act;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_arp_cnt <= 'd0;
    else if(r_arp_cnt < 11)
        r_arp_cnt <= r_arp_cnt + 1;
    else 
        r_arp_cnt <= r_arp_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_mac_cnt <= 'd0;
    else if(r_mac_cnt == P_LEN - 1)
        r_mac_cnt <= 'd0;
    else if(ri_trig_reply || ri_active_send  || r_mac_cnt)   
        r_mac_cnt <= r_mac_cnt + 1;
    else 
        r_mac_cnt <= r_mac_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_arp_op <= 'd0;
    else if(ri_trig_reply)
        r_arp_op <= 'd2;
    else if(ri_active_send)
        r_arp_op <= 'd1;
    else 
        r_arp_op <= r_arp_op;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_reply_mac <= 'd0;
    else 
        ri_reply_mac <= i_reply_mac;
end     

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_data <= 'd0;
    else case(r_mac_cnt)
        0           :ro_mac_data <= 'd0;
        1           :ro_mac_data <= 'd1;
        2           :ro_mac_data <= 8'h08;
        3           :ro_mac_data <= 8'h00;
        4           :ro_mac_data <= 'd6;
        5           :ro_mac_data <= 'd4;
        6           :ro_mac_data <= r_arp_op[15:8];
        7           :ro_mac_data <= r_arp_op[7 :0];
        8           :ro_mac_data <= ri_source_mac[47:40];
        9           :ro_mac_data <= ri_source_mac[39:32];
        10          :ro_mac_data <= ri_source_mac[31:24];
        11          :ro_mac_data <= ri_source_mac[23:16];
        12          :ro_mac_data <= ri_source_mac[15: 8];
        13          :ro_mac_data <= ri_source_mac[7 : 0];
        14          :ro_mac_data <= ri_source_ip[31:24];
        15          :ro_mac_data <= ri_source_ip[23:16];
        16          :ro_mac_data <= ri_source_ip[15: 8];
        17          :ro_mac_data <= ri_source_ip[7 : 0];
        18          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[47:40] : 8'h00;
        19          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[39:32] : 8'h00;
        20          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[31:24] : 8'h00; 
        21          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[23:16] : 8'h00;
        22          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[15: 8] : 8'h00;
        23          :ro_mac_data <= r_arp_op == 2 ? ri_reply_mac[7 : 0] : 8'h00;
        24          :ro_mac_data <= r_target_ip[31:24];
        25          :ro_mac_data <= r_target_ip[23:16];
        26          :ro_mac_data <= r_target_ip[15: 8];
        27          :ro_mac_data <= r_target_ip[7 : 0];
        default     :ro_mac_data <= 'd0;
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_valid <= 'd0;
    else if(r_mac_cnt == P_LEN - 1)
        ro_mac_valid <= 'd0;
    else if(ri_trig_reply || ri_active_send )
        ro_mac_valid <= 'd1;
    else 
        ro_mac_valid <= ro_mac_valid;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_last <= 'd0;
    else if(r_mac_cnt == P_LEN - 2)
        ro_mac_last <= 'd1;
    else 
        ro_mac_last <= 'd0;
end

endmodule
