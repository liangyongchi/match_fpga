`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: IP_tx
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


module IP_tx#(
    parameter       P_ST_TARGET_IP = {8'd192,8'd168,8'd1,8'd0},
    parameter       P_ST_SOURCE_IP = {8'd192,8'd168,8'd1,8'd1}
)(
    input               i_clk       ,
    input               i_rst       ,

    /*--------info port --------*/
    input  [31:0]   i_target_ip         ,
    input           i_target_valid      ,
    input  [31:0]   i_source_ip         ,
    input           i_source_valid      ,

    /*--------data port--------*/
    input  [7 :0]   i_send_type         ,
    input  [15:0]   i_send_len          ,
    input  [7 :0]   i_send_data         ,
    input           i_send_last         ,
    input           i_send_valid        ,

    output [31:0]   o_arp_seek_ip       ,
    output          o_arp_seek_valid    ,

    /*--------mac port--------*/
    output [15:0]   o_mac_type          ,
    output [15:0]   o_mac_len           ,
    output [7 :0]   o_mac_data          ,
    output          o_mac_last          ,
    output          o_mac_valid         

);

/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [31:0]         r_target_ip         ;
reg  [31:0]         r_source_ip         ;
reg  [7 :0]         ri_send_type        ;
reg  [15:0]         ri_send_len         ;
reg  [7 :0]         ri_send_data        ;
reg                 ri_send_last        ;
reg                 ri_send_valid       ;
reg                 ri_send_valid_1d    ;
reg                 r_fifo_ip_rd_en     ;
reg  [7 :0]         r_ip_data           ;
reg                 r_ip_valid          ;
reg  [15:0]         r_ip_data_cnt       ;
reg  [15:0]         r_ip_message        ;
reg  [31:0]         r_ip_check          ;
reg  [15:0]         ro_mac_type         ;  
reg                 ro_mac_last         ; 
reg  [31:0]         ro_arp_seek_ip      ;
reg                 ro_arp_seek_valid   ;

/***************wire******************/
wire [7:0]         w_fifo_ip_dout      ;
wire                w_fifo_ip_full      ;
wire                w_fifo_ip_empty     ;

/***************component*************/
FIFO_MAC_8X64 FIFO_IP_8X64_INST (
  .clk          (i_clk              ),      // input wire clk
  .din          (ri_send_data       ),      // input wire [7 : 0] din
  .wr_en        (ri_send_valid      ),  // input wire wr_en
  .rd_en        (r_fifo_ip_rd_en    ),  // input wire rd_en
  .dout         (w_fifo_ip_dout     ),    // output wire [7 : 0] dout
  .full         (w_fifo_ip_full     ),    // output wire full
  .empty        (w_fifo_ip_empty    )  // output wire empty
);


/***************assign****************/
assign o_mac_data  = r_ip_data  ;
assign o_mac_valid = r_ip_valid ;
assign o_mac_len   = ri_send_len; 
assign o_mac_type  = ro_mac_type;
assign o_mac_last  = ro_mac_last;
assign o_arp_seek_ip    = ro_arp_seek_ip   ;
assign o_arp_seek_valid = ro_arp_seek_valid;
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
        ri_send_type  <= 'd0;
        ri_send_len   <= 'd0;
        ri_send_data  <= 'd0;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end else if(i_send_valid) begin
        ri_send_type  <= i_send_type    ;
        ri_send_len   <= i_send_len + 20;
        ri_send_data  <= i_send_data    ;
        ri_send_last  <= i_send_last    ;
        ri_send_valid <= i_send_valid   ;
    end else begin
        ri_send_type  <= ri_send_type   ;
        ri_send_len   <= ri_send_len    ;
        ri_send_data  <= ri_send_data   ;
        ri_send_last  <= 'd0;
        ri_send_valid <= 'd0;
    end
end   

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_data_cnt <= 'd0;
    else if(r_ip_data_cnt == ri_send_len - 1)
        r_ip_data_cnt <= 'd0;
    else if(ri_send_valid || r_ip_data_cnt)
        r_ip_data_cnt <= r_ip_data_cnt + 1;
    else 
        r_ip_data_cnt <= r_ip_data_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_message <= 'd0;
    else if(o_mac_last)
        r_ip_message <= r_ip_message + 1;
    else 
        r_ip_message <= r_ip_message;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_check <= 'd0;
    else if(ri_send_valid && r_ip_data_cnt == 0)
        r_ip_check <= 16'h4500 + ri_send_len + r_ip_message + 16'h4000 + {8'd64,ri_send_type} + r_source_ip[31:16] +
                      r_source_ip[15:0] + r_target_ip[31:16] + r_target_ip[15:0];
    else if(r_ip_data_cnt == 1)
        r_ip_check <= r_ip_check[31:16] + r_ip_check[15:0];
    else if(r_ip_data_cnt == 2)
        r_ip_check <= r_ip_check[31:16] + r_ip_check[15:0];
    else if(r_ip_data_cnt == 3)
        r_ip_check <= ~r_ip_check;
    else 
        r_ip_check <= r_ip_check;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_send_valid_1d <= 'd0;
    else    
        ri_send_valid_1d <= ri_send_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_valid <= 'd0;
    else if(ro_mac_last)
        r_ip_valid <= 'd0;
    else if(ri_send_valid && !ri_send_valid_1d)
        r_ip_valid <= 'd1;
    else 
        r_ip_valid <= r_ip_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_data <= 'd0;
    else case(r_ip_data_cnt)
        0           : r_ip_data <= {4'b0100,4'b0101};           //版本+首部长度
        1           : r_ip_data <= 'd0;                         //服务类型
        2           : r_ip_data <= ri_send_len[15:8];           //总长度的高8位
        3           : r_ip_data <= ri_send_len[7 :0];           //总长度的低8位
        4           : r_ip_data <= r_ip_message[15:8];          //报文标识的高8位
        5           : r_ip_data <= r_ip_message[7 :0];          //报文标识的低8位
        6           : r_ip_data <= {3'b010,5'b00000};           //标志+片偏移
        7           : r_ip_data <= 'd0;                         //片偏移
        8           : r_ip_data <= 'd64;                        //生存时间
        9           : r_ip_data <= ri_send_type;                //协议类型
        10          : r_ip_data <= r_ip_check[15:8];
        11          : r_ip_data <= r_ip_check[7 :0];
        12          : r_ip_data <= r_source_ip[31:24];
        13          : r_ip_data <= r_source_ip[23:16];
        14          : r_ip_data <= r_source_ip[15:8];
        15          : r_ip_data <= r_source_ip[7 :0];
        16          : r_ip_data <= r_target_ip[31:24];
        17          : r_ip_data <= r_target_ip[23:16];
        18          : r_ip_data <= r_target_ip[15:8];
        19          : r_ip_data <= r_target_ip[7 :0];
        default     : r_ip_data <= w_fifo_ip_dout;
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_ip_rd_en <= 'd0;
    else if(ro_mac_last)
        r_fifo_ip_rd_en <= 'd0;
    else if(r_ip_data_cnt == 18)
        r_fifo_ip_rd_en <= 'd1;
    else 
        r_fifo_ip_rd_en <= r_fifo_ip_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_mac_last <= 'd0;
    else if(r_ip_data_cnt == ri_send_len - 1)
        ro_mac_last <= 'd1;
    else 
        ro_mac_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_mac_type <= 'd0;
    end else begin
        ro_mac_type <= 16'h0800;
    end
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_arp_seek_ip    <= P_ST_TARGET_IP;
        ro_arp_seek_valid <= 'd0;
    end else if(ri_send_valid && !ri_send_valid_1d) begin
        ro_arp_seek_ip    <= r_target_ip;
        ro_arp_seek_valid <= 'd1;
    end else begin
        ro_arp_seek_ip    <= ro_arp_seek_ip;
        ro_arp_seek_valid <= 'd0;
    end
end 
endmodule