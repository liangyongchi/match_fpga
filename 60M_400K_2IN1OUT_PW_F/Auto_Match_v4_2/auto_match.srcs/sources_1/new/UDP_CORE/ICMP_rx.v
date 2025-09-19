`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: ICMP_rx
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


module ICMP_rx(
    input           i_clk       ,
    input           i_rst       ,

    /*--------rec port--------*/
    input  [15:0]   i_icmp_len          ,
    input  [7 :0]   i_icmp_data         ,
    input           i_icmp_last         ,
    input           i_icmp_valid        ,           

    /*--------send port--------*/
    output          o_trig_reply        ,
    output  [15:0]  o_trig_seq          
);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]         ri_icmp_len         ;
reg  [7 :0]         ri_icmp_data        ;
reg                 ri_icmp_last        ;
reg                 ri_icmp_valid       ;
reg                 ro_trig_reply       ;
reg  [15:0]         r_icmp_cnt          ;
reg  [7 :0]         r_type              ;
reg  [15:0]         ro_trig_seq         ;

/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_trig_reply = ro_trig_reply     ;
assign o_trig_seq   = ro_trig_seq       ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_icmp_len   <= 'd0;
        ri_icmp_data  <= 'd0;
        ri_icmp_last  <= 'd0;
        ri_icmp_valid <= 'd0;
    end else begin
        ri_icmp_len   <= i_icmp_len  ;
        ri_icmp_data  <= i_icmp_data ;
        ri_icmp_last  <= i_icmp_last ;
        ri_icmp_valid <= i_icmp_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_icmp_cnt <= 'd0;
    else if(ri_icmp_valid)
        r_icmp_cnt <= r_icmp_cnt + 1;
    else 
        r_icmp_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_type <= 'd0;
    else if(ri_icmp_valid && r_icmp_cnt == 0)
        r_type <= ri_icmp_data;
    else 
        r_type <= r_type;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_trig_seq <= 'd0;
    else if(r_icmp_cnt >=6 && r_icmp_cnt <= 7)
        ro_trig_seq <= {ro_trig_seq[7 :0],ri_icmp_data};
    else 
        ro_trig_seq <= ro_trig_seq;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_trig_reply <= 'd0;
    else if(r_icmp_cnt == 7 && r_type == 8)
        ro_trig_reply <= 'd1;
    else 
        ro_trig_reply <= 'd0;
end



endmodule
