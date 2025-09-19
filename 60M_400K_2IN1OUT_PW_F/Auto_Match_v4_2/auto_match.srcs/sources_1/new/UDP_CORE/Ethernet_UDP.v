`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: Ethernet_UDP
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


module Ethernet_UDP#(
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

    output [15:0]       o_udp_len       ,
    output [7 :0]       o_udp_data      ,
    output              o_udp_last      ,
    output              o_udp_valid     ,

    /*--------ip port--------*/
    output [15:0]       o_ip_len        ,
    output [7 :0]       o_ip_data       ,
    output              o_ip_last       ,
    output              o_ip_valid      ,
    
    input  [15:0]       i_ip_len        ,
    input  [7 :0]       i_ip_data       ,
    input               i_ip_last       ,
    input               i_ip_valid      
);

UDP_tx#(
    .P_TARGET_PORT      (P_TARGET_PORT),
    .P_SOURCE_PORT      (P_SOURCE_PORT)
)
UDP_tx_u0
(
    .i_clk              (i_clk          ),
    .i_rst              (i_rst          ),
    .i_target_port      (i_target_port  ),
    .i_target_valid     (i_target_valid ),
    .i_source_port      (i_source_port  ),
    .i_source_valid     (i_source_valid ),
    .i_send_len         (i_send_len     ),
    .i_send_data        (i_send_data    ),
    .i_send_last        (i_send_last    ),
    .i_send_valid       (i_send_valid   ),
    .o_ip_len           (o_ip_len       ),
    .o_ip_data          (o_ip_data      ),
    .o_ip_last          (o_ip_last      ),
    .o_ip_valid         (o_ip_valid     )
);

UDP_rx#(
    .P_TARGET_PORT      (P_TARGET_PORT),
    .P_SOURCE_PORT      (P_SOURCE_PORT)
)
UDP_rx_u0
(
    .i_clk              (i_clk          ),
    .i_rst              (i_rst          ),
    .i_target_port      (i_target_port  ),
    .i_target_valid     (i_target_valid ),
    .i_source_port      (i_source_port  ),
    .i_source_valid     (i_source_valid ),
    .o_udp_len          (o_udp_len      ),
    .o_udp_data         (o_udp_data     ),
    .o_udp_last         (o_udp_last     ),
    .o_udp_valid        (o_udp_valid    ),
    .i_ip_len           (i_ip_len       ),
    .i_ip_data          (i_ip_data      ),
    .i_ip_last          (i_ip_last      ),
    .i_ip_valid         (i_ip_valid     )
);
endmodule
