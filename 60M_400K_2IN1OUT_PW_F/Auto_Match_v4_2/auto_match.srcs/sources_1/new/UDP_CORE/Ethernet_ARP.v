`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: Ethernet_ARP
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


module Ethernet_ARP#(
    parameter       P_TARGET_IP = {8'd192,8'd168,8'd1,8'd1},
    parameter       P_SOURCE_MAC = {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
    parameter       P_SOURCE_IP  = {8'd192,8'd168,8'd1,8'd2}
)(
    input           i_clk           ,
    input           i_rst           ,

    input   [31:0]  i_source_ip     ,
    input           i_s_ip_valid    ,
    input   [47:0]  i_source_mac    ,
    input           i_s_mac_valid   ,
    input   [31:0]  i_target_ip     ,
    input           i_target_valid  , 

    input  [31:0]   i_seek_ip           ,
    input           i_seek_valid        ,
    output  [47:0]  o_rec_target_mac    ,
    output          o_rec_target_valid  ,

    output  [7 :0]  o_mac_data      ,
    output          o_mac_last      ,
    output          o_mac_valid     ,

    input   [7 :0]  i_mac_data      ,
    input           i_mac_last      ,
    input           i_mac_valid     
);

wire                w_trig_reply    ;
wire [47:0]         w_rec_target_mac    ;   
wire [31:0]         w_target_ip         ;   
wire                w_rec_target_valid  ;
wire [31:0]         w_arp_seek_ip     ;   
wire                w_arp_seek_valid  ;

ARP_tx#(
    .P_TARGET_IP     (P_TARGET_IP                           ),
    .P_SOURCE_MAC    (P_SOURCE_MAC                          ),
    .P_SOURCE_IP     (P_SOURCE_IP                           )
)
ARP_tx_u0
(
    .i_clk           (i_clk                                 ),
    .i_rst           (i_rst                                 ),
    .i_target_ip     (i_target_ip                           ),
    .i_target_valid  (i_target_valid                        ),
    .i_source_mac    (i_source_mac                          ),
    .i_s_mac_valid   (i_s_mac_valid                         ),
    .i_source_ip     (i_source_ip                           ),
    .i_s_ip_valid    (i_s_ip_valid                          ),
    .i_reply_mac     (w_rec_target_mac                      ),
    .i_trig_reply    (w_trig_reply                          ),
    .i_active_send   (0),
    .o_seek_ip       (w_arp_seek_ip   ),
    .o_seek_valid    (w_arp_seek_valid),
    .o_mac_data      (o_mac_data                            ),
    .o_mac_last      (o_mac_last                            ),
    .o_mac_valid     (o_mac_valid                           )
);

ARP_Table ARP_Table_u0(
    .i_clk           (i_clk                                 ),
    .i_rst           (i_rst                                 ),

    .i_seek_ip       (i_seek_ip                             ),
    .i_seek_valid    (i_seek_valid                          ),

    .i_updata_ip     (w_target_ip                           ),
    .i_updata_mac    (w_rec_target_mac                      ),
    .i_updata_valid  (w_rec_target_valid                    ),

    .o_active_mac    (o_rec_target_mac                      ),
    .o_active_valid  (o_rec_target_valid                    )
);  

ARP_rx#(
    .P_TARGET_IP     (P_TARGET_IP                           ),
    .P_SOURCE_MAC    (P_SOURCE_MAC                          ),
    .P_SOURCE_IP     (P_SOURCE_IP                           )
)
ARP_rx_U0
(
    .i_clk           (i_clk                                 ),
    .i_rst           (i_rst                                 ),
    .i_source_ip     (i_source_ip                           ),
    .i_s_ip_valid    (i_s_ip_valid                          ),
    .o_target_mac    (w_rec_target_mac                      ),
    .o_target_ip     (w_target_ip                           ),
    .o_target_valid  (w_rec_target_valid                    ),
    .o_tirg_reply    (w_trig_reply                          ),
    .i_mac_data      (i_mac_data                            ),
    .i_mac_last      (i_mac_last                            ),
    .i_mac_valid     (i_mac_valid                           )
);

endmodule
