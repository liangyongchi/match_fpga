`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: MAC_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:    消耗5个周期
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MAC_rx#(
    parameter       P_TARTGET_MAC   =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_SOURCE_MAC    =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_CRC_CHECK     =   1
)(
    input           i_clk               ,
    input           i_rst               ,
    /*--------info port--------*/   
    input  [47:0]   i_target_mac        ,
    input           i_target_mac_valid  ,
    input  [47:0]   i_source_mac        ,
    input           i_source_mac_valid  ,
    /*--------data port--------*/
    output [15:0]   o_post_type         ,
    output [7 :0]   o_post_data         ,
    output          o_post_last         ,
    output          o_post_valid        ,

    output [47:0]   o_rec_src_mac       ,
    output          o_rec_src_valid     ,
    output          o_crc_error         ,   
    output          o_crc_valid         ,    
    /*--------GMII port--------*/
    input  [7 :0]   i_GMII_data         ,
    input           i_GMII_valid        
);
/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg                 ro_post_last          ;
reg                 ro_post_valid         ;
reg  [47:0]         ro_rec_src_mac      ;
reg                 ro_rec_src_valid    ;
reg                 ro_crc_error        ;
reg  [7 :0]         ri_GMII_data        ;
reg                 ri_GMII_valid       ;
reg  [7 :0]         ri_GMII_data_1d     ;
reg                 ri_GMII_valid_1d    ;
reg  [7 :0]         ri_GMII_data_2d     ;
reg                 ri_GMII_valid_2d    ;
reg  [7 :0]         ri_GMII_data_3d     ;
reg                 ri_GMII_valid_3d    ;
reg  [7 :0]         ri_GMII_data_4d     ;
reg                 ri_GMII_valid_4d    ;
reg  [7 :0]         ri_GMII_data_5d     ;
reg                 ri_GMII_valid_5d    ;
reg  [47:0]         r_target_mac        ;
reg  [47:0]         r_source_mac        ;
reg  [47:0]         r_rec_mac           ;
reg                 r_rec_mac_access    ;
reg  [15:0]         r_rec_cnt           ;
reg                 r_headr_check       ;
reg                 r_header_access     ;
reg  [15:0]         r_rec_type          ;//0x0800-IP 0X0806-ARP
reg                 r_crc_rst           ;
reg                 r_crc_en            ;
reg                 r_crc_en_1d         ;
reg  [15:0]         r_rec_5d_cnt        ;
reg  [31:0]         r_crc_result        ;
reg                 ro_crc_valid        ;

/***************wire******************/
wire [31:0]         w_crc_result        ;

/***************component*************/
CRC32_D8 CRC32_D8_u0(
  .i_clk            (i_clk              ),
  .i_rst            (r_crc_rst          ),
  .i_en             (r_crc_en           ),
  .i_data           (ri_GMII_data_5d    ),
  .o_crc            (w_crc_result       )   
);
/***************assign****************/
assign o_post_type     = r_rec_type             ;
assign o_post_data     = ri_GMII_data_5d        ;
assign o_post_last     = ro_post_last             ;
assign o_post_valid    = ro_post_valid            ;
assign o_rec_src_mac   = ro_rec_src_mac         ;
assign o_rec_src_valid = ro_rec_src_valid       ;
assign o_crc_error     = ro_crc_error           ;
assign o_crc_valid     = ro_crc_valid           ;
/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_GMII_data        <= 'd0;
        ri_GMII_valid       <= 'd0;
        ri_GMII_data_1d     <= 'd0;
        ri_GMII_valid_1d    <= 'd0;
        ri_GMII_data_2d     <= 'd0;
        ri_GMII_valid_2d    <= 'd0;
        ri_GMII_data_3d     <= 'd0;
        ri_GMII_valid_3d    <= 'd0;
        ri_GMII_data_4d     <= 'd0;
        ri_GMII_valid_4d    <= 'd0;
    end else begin
        ri_GMII_data        <= i_GMII_data ;
        ri_GMII_valid       <= i_GMII_valid;
        ri_GMII_data_1d     <= ri_GMII_data ;
        ri_GMII_valid_1d    <= ri_GMII_valid;
        ri_GMII_data_2d     <= ri_GMII_data_1d ;
        ri_GMII_valid_2d    <= ri_GMII_valid_1d;
        ri_GMII_data_3d     <= ri_GMII_data_2d ;
        ri_GMII_valid_3d    <= ri_GMII_valid_2d;
        ri_GMII_data_4d     <= ri_GMII_data_3d ;
        ri_GMII_valid_4d    <= ri_GMII_valid_3d;
        ri_GMII_data_5d     <= ri_GMII_data_4d ;
        ri_GMII_valid_5d    <= ri_GMII_valid_4d;
    end     
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_target_mac <= P_TARTGET_MAC;
    else if(i_target_mac_valid)
        r_target_mac <= i_target_mac;
    else
        r_target_mac <= r_target_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_source_mac <= P_SOURCE_MAC ;
    else if(i_source_mac_valid)
        r_source_mac <= i_source_mac;
    else
        r_source_mac <= r_source_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_cnt <= 'd0;
    else if(ri_GMII_valid && r_rec_cnt == 6 && ri_GMII_data == 8'h55)
        r_rec_cnt <= r_rec_cnt;
    else if(ri_GMII_valid)
        r_rec_cnt <= r_rec_cnt + 1;
    else 
        r_rec_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_mac <= 'd0;
    else if(ri_GMII_valid && r_rec_cnt >= 7 && r_rec_cnt <= 12)
        r_rec_mac <= {r_rec_mac[39:0],ri_GMII_data};
    else 
        r_rec_mac <= r_rec_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_mac_access <= 'd0;
    else if(r_rec_cnt == 13 && r_rec_mac != r_source_mac)
        r_rec_mac_access <= 'd0;
    else if(r_rec_cnt == 13 && (r_rec_mac == r_source_mac || &r_rec_mac))
        r_rec_mac_access <= 'd1;
    else 
        r_rec_mac_access <= r_rec_mac_access;
end

always@(*)
begin
    case(r_rec_cnt)
        0,1,2,3,4,5 :r_headr_check <= ri_GMII_data == 8'h55 ? 'd1 : 'd0;
        6           :r_headr_check <= ri_GMII_data == 8'hD5 || ri_GMII_data == 8'h55 ? 'd1 : 'd0;
        default     :r_headr_check <= 'd1;
    endcase
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_header_access <= 'd1;
    else if(!ri_GMII_valid)
        r_header_access <= 'd1;
    else if(ri_GMII_valid && r_rec_cnt >= 0 && r_rec_cnt <= 6 && !r_headr_check)
        r_header_access <= 'd0;
    else 
        r_header_access <= r_header_access;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_rec_src_mac <= 'd0;
    else if(ri_GMII_valid && r_rec_cnt >= 13 && r_rec_cnt <= 18)
        ro_rec_src_mac <= {ro_rec_src_mac[39:0],ri_GMII_data};
    else 
        ro_rec_src_mac <= ro_rec_src_mac;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_rec_src_valid <= 'd0;
    else if(r_rec_cnt == 19)
        ro_rec_src_valid <= 'd1;
    else 
        ro_rec_src_valid <= ro_rec_src_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_type <= 'd0;
    else if(ri_GMII_valid && r_rec_cnt >= 19 && r_rec_cnt <= 20)
        r_rec_type <= {r_rec_type[7:0],ri_GMII_data};
    else 
        r_rec_type <= r_rec_type;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rec_5d_cnt <= 'd0; 
    else if(ri_GMII_valid_5d)
        r_rec_5d_cnt <= r_rec_5d_cnt + 1;
    else
        r_rec_5d_cnt <= 'd0; 
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_valid <= 'd0;
    else if(ro_post_last)
        ro_post_valid <= 'd0;
    else if(r_rec_5d_cnt == 21)
        ro_post_valid <= 'd1;
    else 
        ro_post_valid <= ro_post_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_last <= 'd0;
    else if(!i_GMII_valid && ri_GMII_valid)
        ro_post_last <= 'd1;
    else 
        ro_post_last <= 'd0;
end

// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         ro_arp_valid <= 'd0;
//     else if(!ri_GMII_valid && ri_GMII_data_1d)
//         ro_arp_valid <= 'd0;
//     else if(r_rec_type == 16'h0806 && r_rec_5d_cnt == 20)
//         ro_arp_valid <= 'd1;
//     else 
//         ro_arp_valid <= ro_ip_valid;
// end

// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         ro_arp_last <= 'd0;
//     else if(!i_GMII_valid && ri_GMII_valid && r_rec_type == 16'h0806)
//         ro_arp_last <= 'd1;
//     else 
//         ro_arp_last <= 'd0;
// end
           
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_rst <= 'd1;
    else if(r_rec_5d_cnt == 7)
        r_crc_rst <= 'd0;
    else if(!r_crc_en && r_crc_en_1d)
        r_crc_rst <= 'd1;
    else 
        r_crc_rst <= r_crc_rst;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_en <= 'd0;
    else if(!ri_GMII_valid && ri_GMII_valid_1d)
        r_crc_en <= 'd0;
    else if(r_rec_5d_cnt == 7)
        r_crc_en <= 'd1;
    else 
        r_crc_en <= r_crc_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_en_1d <= 'd0;
    else 
        r_crc_en_1d <= r_crc_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_crc_result <= 'd0;
    else if(ri_GMII_valid)
        r_crc_result <= {ri_GMII_data,r_crc_result[31:8]};
    else
        r_crc_result <= r_crc_result;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_crc_valid <= 'd0;
    else if(!r_crc_en && r_crc_en_1d)
        ro_crc_valid <= 'd1;
    else 
        ro_crc_valid <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_crc_error <= 'd0;
    else if(!P_CRC_CHECK)
        ro_crc_error <= 'd0;
    else if(!r_crc_en && r_crc_en_1d && r_crc_result != w_crc_result)
        ro_crc_error <= 'd1;
    else 
        ro_crc_error <= 'd0;
end

endmodule