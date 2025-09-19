`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: Ethernet_IP
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


module Ethernet_IP#(
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

    /*--------arp port--------*/
    output [31:0]   o_arp_seek_ip       ,
    output          o_arp_seek_valid    ,
    /*--------mac port--------*/
    output [15:0]   o_mac_type          ,
    output [15:0]   o_mac_len           ,
    output [7 :0]   o_mac_data          ,
    output          o_mac_last          ,
    output          o_mac_valid         ,

    input  [7 :0]   i_mac_data          ,
    input           i_mac_last          ,
    input           i_mac_valid 

);

IP_tx#(
    .P_ST_TARGET_IP         (P_ST_TARGET_IP         ),
    .P_ST_SOURCE_IP         (P_ST_SOURCE_IP         )
)
IP_tx_u0
(
    .i_clk                  (i_clk                  ),
    .i_rst                  (i_rst                  ),
    .i_target_ip            (i_target_ip            ),
    .i_target_valid         (i_target_valid         ),
    .i_source_ip            (i_source_ip            ),
    .i_source_valid         (i_source_valid         ),
    .i_send_type            (i_send_type            ),
    .i_send_len             (i_send_len             ),
    .i_send_data            (i_send_data            ),
    .i_send_last            (i_send_last            ),
    .i_send_valid           (i_send_valid           ),
    .o_arp_seek_ip          (o_arp_seek_ip          ),
    .o_arp_seek_valid       (o_arp_seek_valid       ),
    .o_mac_type             (o_mac_type             ),
    .o_mac_len              (o_mac_len              ),
    .o_mac_data             (o_mac_data             ),
    .o_mac_last             (o_mac_last             ),
    .o_mac_valid            (o_mac_valid            )  
);

IP_rx#(
    .P_ST_TARGET_IP         (P_ST_TARGET_IP         ),   
    .P_ST_SOURCE_IP         (P_ST_SOURCE_IP         )
)
IP_rx_u0
(
    .i_clk                  (i_clk                  ),
    .i_rst                  (i_rst                  ),
    .i_target_ip            (i_target_ip            ),
    .i_target_valid         (i_target_valid         ),
    .i_source_ip            (i_source_ip            ),
    .i_source_valid         (i_source_valid         ),
    .o_udp_len              (o_udp_len              ),
    .o_udp_data             (o_udp_data             ),
    .o_udp_last             (o_udp_last             ),
    .o_udp_valid            (o_udp_valid            ),
    .o_icmp_len             (o_icmp_len             ),
    .o_icmp_data            (o_icmp_data            ),
    .o_icmp_last            (o_icmp_last            ),
    .o_icmp_valid           (o_icmp_valid           ),
    .o_source_ip            (o_source_ip            ),
    .o_source_ip_valid      (o_source_ip_valid      ),
    .i_mac_data             (i_mac_data             ),
    .i_mac_last             (i_mac_last             ),
    .i_mac_valid            (i_mac_valid            )   

);

endmodule
