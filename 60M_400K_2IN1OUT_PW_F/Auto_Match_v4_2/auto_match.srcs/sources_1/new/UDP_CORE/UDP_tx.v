`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: UDP_tx
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


module UDP_tx#(
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
    input  [15:0]       i_send_len      ,
    input  [7 :0]       i_send_data     ,
    input               i_send_last     ,
    input               i_send_valid    ,

    /*--------ip port--------*/
    output [15:0]       o_ip_len        ,
    output [7 :0]       o_ip_data       ,
    output              o_ip_last       ,
    output              o_ip_valid      
);

/***************function**************/

/***************parameter*************/
localparam              P_ST_MIN_LEN = 18 + 8;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]             r_target_port   ;
reg  [15:0]             r_source_port   ;
reg  [15:0]             ri_send_len     ;
reg  [7 :0]             ri_send_data    ;
reg                     ri_send_last    ;
reg                     ri_send_valid   ;
reg  [15:0]             ro_ip_len       ;
reg  [7 :0]             ro_ip_data      ;
reg                     ro_ip_last      ;
reg                     ro_ip_valid     ;
reg                     r_fifo_udp_rd_en; 
reg  [15:0]             r_udp_cnt       ;
reg                     r_fifo_udp_empty;

/***************wire******************/
wire [7:0]              w_fifo_udp_dout ;   
wire                    w_fifo_udp_full ;   
wire                    w_fifo_udp_empty;   

/***************component*************/
FIFO_MAC_8X64 FIFO_UDP_8X64_U0 (
  .clk          (i_clk              ),      // input wire clk
  .din          (ri_send_data       ),      // input wire [7 : 0] din
  .wr_en        (ri_send_valid      ),  // input wire wr_en
  .rd_en        (r_fifo_udp_rd_en   ),  // input wire rd_en
  .dout         (w_fifo_udp_dout    ),    // output wire [7 : 0] dout
  .full         (w_fifo_udp_full    ),    // output wire full
  .empty        (w_fifo_udp_empty   )  // output wire empty
);

/***************assign****************/
assign o_ip_len   = ro_ip_len           ;
assign o_ip_data  = ro_ip_data          ;
assign o_ip_last  = ro_ip_last          ;
assign o_ip_valid = ro_ip_valid         ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_port <= P_TARGET_PORT;
    else if(i_target_valid)       
        r_target_port <= i_target_port;
    else 
        r_target_port <= r_target_port;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_port <= P_SOURCE_PORT;
    else if(i_source_valid)       
        r_source_port <= i_source_port;
    else 
        r_source_port <= r_source_port;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_send_data  <= 'd0;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end else begin
        ri_send_data  <= i_send_data ;
        ri_send_last  <= i_send_last ;
        ri_send_valid <= i_send_valid;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_send_len     <= 'd0;
    else if(i_send_valid)   
        ri_send_len     <= i_send_len  ;
    else 
        ri_send_len     <= ri_send_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)    
        r_udp_cnt <= 'd0;
    else if(ri_send_len < 18 && r_udp_cnt == P_ST_MIN_LEN - 1)
        r_udp_cnt <= 'd0;
    else if(ri_send_len >= 18 && r_udp_cnt == (ri_send_len + 8) - 1)
        r_udp_cnt <= 'd0;
    else if(ri_send_valid || r_udp_cnt)
        r_udp_cnt <= r_udp_cnt + 1;
    else 
        r_udp_cnt <= r_udp_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ip_len <= 'd0;
    else if(ri_send_len < 18)
        ro_ip_len <= P_ST_MIN_LEN;
    else 
        ro_ip_len <= ri_send_len + 8;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ip_valid <= 'd0;
    else if(ro_ip_last)
        ro_ip_valid <= 'd0;
    else if(ri_send_valid)
        ro_ip_valid <= 'd1;
    else 
        ro_ip_valid <= ro_ip_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ip_last <= 'd0;
    else if(ri_send_len < 18 && r_udp_cnt == P_ST_MIN_LEN - 1)
        ro_ip_last <= 'd1;
    else if(ri_send_len >= 18 && r_udp_cnt == (ri_send_len + 8) - 1)
        ro_ip_last <= 'd1;
    else 
        ro_ip_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_udp_rd_en <= 'd0;
    else if(r_udp_cnt == (ri_send_len + 8) - 1)
        r_fifo_udp_rd_en <= 'd0;
    else if(r_udp_cnt == 6)
        r_fifo_udp_rd_en <= 'd1;
    else 
        r_fifo_udp_rd_en <= r_fifo_udp_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_udp_empty <= 'd0;
    else 
        r_fifo_udp_empty <= w_fifo_udp_empty;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_ip_data <= 'd0;
    else case(r_udp_cnt)
        0           : ro_ip_data <= r_source_port[15:8];
        1           : ro_ip_data <= r_source_port[7 :0];
        2           : ro_ip_data <= r_target_port[15:8];
        3           : ro_ip_data <= r_target_port[7 :0];
        4           : ro_ip_data <= ro_ip_len[15:8];
        5           : ro_ip_data <= ro_ip_len[7 :0];
        6           : ro_ip_data <= 'd0;
        7           : ro_ip_data <= 'd0;
        default     : ro_ip_data <= !r_fifo_udp_empty ? w_fifo_udp_dout : 'd0;
    endcase         
end

endmodule
