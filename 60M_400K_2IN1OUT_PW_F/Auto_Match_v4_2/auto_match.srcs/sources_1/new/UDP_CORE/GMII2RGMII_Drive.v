`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/24 19:45:00
// Design Name: 
// Module Name: GMII2RGMII_Drive
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


module GMII2RGMII_Drive(
    input               i_udp_stack_clk ,
    input  [7 :0]       i_GMII_data     ,
    input               i_GMII_valid    ,
    output [7 :0]       o_GMII_data     ,
    output              o_GMII_valid    ,

    input               i_rxc           ,
    input  [3 :0]       i_rxd           ,
    input               i_rx_ctl        ,
    output              o_txc           ,
    output [3 :0]       o_txd           ,
    output              o_tx_ctl        ,
    output  [1:0]       o_speed         ,
    output              o_link          ,
    output              o_user_clk      
);

(* mark_debug = "true" *)wire [7 :0]  w_send_data ;
(* mark_debug = "true" *)wire         w_send_valid;
wire [7 :0]  w_rec_data  ;
wire         w_rec_valid ;
wire         w_rec_end   ;
wire         w_user_rxc       ;
wire         w_speed1000 ;

assign w_speed1000 = 1;
assign o_user_clk  = w_user_rxc;

// RGMII_RAM RGMII_RAM_u0(
//     .i_udp_stack_clk    (i_udp_stack_clk    ),
//     .i_GMII_data        (i_GMII_data        ),
//     .i_GMII_valid       (i_GMII_valid       ),
//     .o_GMII_data        (o_GMII_data        ),
//     .o_GMII_valid       (o_GMII_valid       ),

//     .i_rxc              (w_user_rxc         ),
//     .i_speed1000        (w_speed1000        ),
//     .o_send_data        (w_send_data        ),
//     .o_send_valid       (w_send_valid       ),
//     .i_rec_data         (w_rec_data         ),
//     .i_rec_valid        (w_rec_valid        ),
//     .i_rec_end          (w_rec_end          )
// );

RGMII_Tri RGMII_Tri_inst(
    .i_rxc              (i_rxc              ),
    .i_rxd              (i_rxd              ),
    .i_rx_ctl           (i_rx_ctl           ),
    .o_txc              (o_txc              ),
    .o_txd              (o_txd              ),
    .o_tx_ctl           (o_tx_ctl           ),


    .o_user_rxc         (w_user_rxc         ),
    .i_send_data        (i_GMII_data        ),
    .i_send_valid       (i_GMII_valid       ),
    .o_rec_data         (o_GMII_data        ),
    .o_rec_valid        (o_GMII_valid       ),
    .o_rec_end          (                   ),
    .o_speed            (o_speed            ),
    .o_link             (o_link             )
);

endmodule