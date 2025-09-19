`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: Ethernet_MAC
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


module Ethernet_MAC#(
    parameter       P_TARTGET_MAC   =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_SOURCE_MAC    =   {8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
                    P_CRC_CHECK     =   1
)(
    input           i_clk       ,
    input           i_rst       ,

    /*--------info port--------*/   
    input  [47:0]   i_target_mac        ,
    input           i_target_mac_valid  ,
    input  [47:0]   i_source_mac        ,
    input           i_source_mac_valid  ,

    /*--------data port--------*/
    input           i_udp_valid         ,
    output          o_udp_ready         ,

    input  [15:0]   i_send_type         ,
    input  [15:0]   i_send_len          ,
    input  [7 :0]   i_send_data         ,
    input           i_send_last         ,
    input           i_send_valid        ,

    output [7 :0]   o_ip_data           ,
    output          o_ip_last           ,
    output          o_ip_valid          ,
    output [7 :0]   o_arp_data          ,
    output          o_arp_last          ,
    output          o_arp_valid         ,
    output [47:0]   o_rec_src_mac       ,
    output          o_rec_src_valid     ,
    output          o_crc_error         ,   
    output          o_crc_valid         , 

    /*--------GMII port--------*/
    output [7 :0]   o_GMII_data         ,
    output          o_GMII_valid        ,
    input  [7 :0]   i_GMII_data         ,
    input           i_GMII_valid
);


(* mark_debug = "true" *)wire  [15:0]        w_post_type             ;
(* mark_debug = "true" *)wire  [7 :0]        w_post_data             ;
(* mark_debug = "true" *)wire                w_post_last             ;
(* mark_debug = "true" *)wire                w_post_valid            ;
(* mark_debug = "true" *)wire  [15:0]        w_crc_post_type         ;
(* mark_debug = "true" *)wire  [7 :0]        w_crc_post_data         ;
(* mark_debug = "true" *)wire                w_crc_post_last         ;
(* mark_debug = "true" *)wire                w_crc_post_valid        ;
(* mark_debug = "true" *)wire                w_crc_error             ;       
(* mark_debug = "true" *)wire                w_crc_valid             ;       
    
assign o_crc_error = w_crc_error            ;    
assign o_crc_valid = w_crc_valid            ;    

MAC_tx#(
    .P_TARTGET_MAC          (P_TARTGET_MAC),
    .P_SOURCE_MAC           (P_SOURCE_MAC ),
    .P_CRC_CHECK            (P_CRC_CHECK  )  
)
MAC_tx_u0
(
    .i_clk                  (i_clk             ),
    .i_rst                  (i_rst             ),
    .i_target_mac           (i_target_mac      ),
    .i_target_mac_valid     (i_target_mac_valid),
    .i_source_mac           (i_source_mac      ),
    .i_source_mac_valid     (i_source_mac_valid),
    .i_udp_valid            (i_udp_valid       ),
    .o_udp_ready            (o_udp_ready       ),
    .i_send_type            (i_send_type       ),
    .i_send_len             (i_send_len        ),
    .i_send_data            (i_send_data       ),
    .i_send_last            (i_send_last       ),
    .i_send_valid           (i_send_valid      ),
    .o_GMII_data            (o_GMII_data       ),
    .o_GMII_valid           (o_GMII_valid      )
);

mac_arp_ip_mux mac_arp_ip_mux_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_type                 (w_crc_post_type    ),
    .i_data                 (w_crc_post_data    ),
    .i_last                 (w_crc_post_last    ),
    .i_valid                (w_crc_post_valid   ),
    .o_ip_data              (o_ip_data          ),
    .o_ip_last              (o_ip_last          ),
    .o_ip_valid             (o_ip_valid         ),
    .o_arp_data             (o_arp_data         ),
    .o_arp_last             (o_arp_last         ),
    .o_arp_valid            (o_arp_valid        )
);

CRC_Data_Pro CRC_Data_Pro_u0(
    .i_clk                  (i_clk              ),
    .i_rst                  (i_rst              ),
    .i_per_type             (w_post_type        ),
    .i_per_data             (w_post_data        ),
    .i_per_last             (w_post_last        ),
    .i_per_valid            (w_post_valid       ),
    .i_per_crc_error        (w_crc_error        ),
    .i_per_crc_valid        (w_crc_valid        ),
    .o_post_type            (w_crc_post_type    ),
    .o_post_data            (w_crc_post_data    ),
    .o_post_last            (w_crc_post_last    ),
    .o_post_valid           (w_crc_post_valid   )   
);

MAC_rx#(
    .P_TARTGET_MAC          (P_TARTGET_MAC      ),
    .P_SOURCE_MAC           (P_SOURCE_MAC       ),
    .P_CRC_CHECK            (P_CRC_CHECK        )  
)
MAC_rx_u0
(
    .i_clk                  (i_clk             ),
    .i_rst                  (i_rst             ),
    .i_target_mac           (i_target_mac      ),
    .i_target_mac_valid     (i_target_mac_valid),
    .i_source_mac           (i_source_mac      ),
    .i_source_mac_valid     (i_source_mac_valid),
    .o_post_type            (w_post_type        ),
    .o_post_data            (w_post_data        ),
    .o_post_last            (w_post_last        ),
    .o_post_valid           (w_post_valid       ),
    .o_rec_src_mac          (o_rec_src_mac     ),
    .o_rec_src_valid        (o_rec_src_valid   ),
    .o_crc_error            (w_crc_error       ),   
    .o_crc_valid            (w_crc_valid       ),    
    .i_GMII_data            (i_GMII_data       ),
    .i_GMII_valid           (i_GMII_valid      )
);

endmodule
