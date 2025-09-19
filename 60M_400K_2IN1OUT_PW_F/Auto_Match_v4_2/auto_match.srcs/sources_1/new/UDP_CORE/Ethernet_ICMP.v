`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: Ethernet_ICMP
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


module Ethernet_ICMP(
    input           i_clk           ,
    input           i_rst           ,

    input  [15:0]   i_icmp_len      ,
    input  [7 :0]   i_icmp_data     ,
    input           i_icmp_last     ,
    input           i_icmp_valid    , 
    output [15:0]   o_icmp_len      ,
    output [7 :0]   o_icmp_data     ,
    output          o_icmp_last     ,
    output          o_icmp_valid    
);

wire        w_trig_reply    ;   
wire [31:0] w_trig_seq      ;   

ICMP_tx ICMP_tx_u0(
    .i_clk              (i_clk          ),
    .i_rst              (i_rst          ),
    .i_trig_reply       (w_trig_reply   ),
    .i_trig_seq         (w_trig_seq     ),
    .o_icmp_len         (o_icmp_len     ),
    .o_icmp_data        (o_icmp_data    ),
    .o_icmp_last        (o_icmp_last    ),
    .o_icmp_valid       (o_icmp_valid   )
);

ICMP_rx ICMP_rx_u0(
    .i_clk              (i_clk          ),
    .i_rst              (i_rst          ),
    .i_icmp_len         (i_icmp_len     ),
    .i_icmp_data        (i_icmp_data    ),
    .i_icmp_last        (i_icmp_last    ),
    .i_icmp_valid       (i_icmp_valid   ),           
    .o_trig_reply       (w_trig_reply   ),
    .o_trig_seq         (w_trig_seq     )         
);


endmodule
