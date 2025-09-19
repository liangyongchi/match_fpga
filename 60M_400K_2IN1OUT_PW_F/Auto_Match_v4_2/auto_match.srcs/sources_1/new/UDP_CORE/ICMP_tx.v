`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: ICMP_tx
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


module ICMP_tx(
    input           i_clk           ,
    input           i_rst           ,

    input           i_trig_reply    ,
    input  [15:0]   i_trig_seq      ,

    output [15:0]   o_icmp_len      ,
    output [7 :0]   o_icmp_data     ,
    output          o_icmp_last     ,
    output          o_icmp_valid    
);

/***************function**************/

/***************parameter*************/
localparam          P_LEN  = 40     ;
/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg                 ri_trig_reply   ;
reg  [15:0]         ri_trig_seq     ;
reg  [15:0]         ro_icmp_len     ;
reg  [7 :0]         ro_icmp_data    ;
reg                 ro_icmp_last    ;
reg                 ro_icmp_valid   ;
reg  [15:0]         r_icmp_cnt      ;
reg  [31:0]         r_icmp_check    ;
reg  [7 :0]         r_check_cnt     ;


/***************wire******************/

/***************component*************/

/***************assign****************/
assign o_icmp_len   = ro_icmp_len  ;
assign o_icmp_data  = ro_icmp_data ;
assign o_icmp_last  = ro_icmp_last ;
assign o_icmp_valid = ro_icmp_valid;
/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_trig_reply <= 'd0;
        ri_trig_seq   <= 'd0;
    end else begin
        ri_trig_reply <= i_trig_reply;
        ri_trig_seq   <= i_trig_seq;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_check_cnt <= 'd0;
    else if(r_icmp_cnt == P_LEN - 1)
        r_check_cnt <= 'd0;
    else if(r_check_cnt == 3)
        r_check_cnt <= r_check_cnt + 1;
    else if(ri_trig_reply | r_check_cnt)
        r_check_cnt <= r_check_cnt + 1;
    else 
        r_check_cnt <= r_check_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_icmp_check <= 'd0;
    else if(r_check_cnt == 0)
        r_icmp_check <= 16'h0001 + ri_trig_seq;
    else if(r_check_cnt == 1)
        r_icmp_check <= r_icmp_check[31:16] + r_icmp_check[15:0];
    else if(r_check_cnt == 2)
        r_icmp_check <= r_icmp_check[31:16] + r_icmp_check[15:0];
    else if(r_check_cnt == 3)
        r_icmp_check <= ~r_icmp_check;
    else 
        r_icmp_check <= r_icmp_check;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_icmp_cnt <= 'd0;
    else if(r_icmp_cnt == P_LEN - 1)
        r_icmp_cnt <= 'd0;
    else if(r_check_cnt == 3 || r_icmp_cnt)
        r_icmp_cnt <= r_icmp_cnt + 1;
    else 
        r_icmp_cnt <= r_icmp_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin   
    if(i_rst)
        ro_icmp_len <= 'd0;
    else 
        ro_icmp_len <= P_LEN;
end

always@(posedge i_clk,posedge i_rst)
begin   
    if(i_rst)
        ro_icmp_valid <= 'd0;
    else if(r_icmp_cnt == P_LEN - 1)
        ro_icmp_valid <= 'd0;
    else if(r_check_cnt == 3)
        ro_icmp_valid <= 'd1;
    else 
        ro_icmp_valid <= ro_icmp_valid;
end

always@(posedge i_clk,posedge i_rst)
begin   
    if(i_rst)
        ro_icmp_last <= 'd0;
    else if(r_icmp_cnt == P_LEN - 2)
        ro_icmp_last <= 'd1;
    else 
        ro_icmp_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin   
    if(i_rst)
        ro_icmp_data <= 'd0;
    else case(r_icmp_cnt)
        0           :ro_icmp_data <= 'd0;
        1           :ro_icmp_data <= 'd0;
        2           :ro_icmp_data <= r_icmp_check[15:8];
        3           :ro_icmp_data <= r_icmp_check[7 :0];
        4           :ro_icmp_data <= 8'h00;
        5           :ro_icmp_data <= 8'h01;
        6           :ro_icmp_data <= ri_trig_seq[15:8];
        7           :ro_icmp_data <= ri_trig_seq[7 :0];
        default     :ro_icmp_data <= 'd0;
    endcase
end

endmodule
