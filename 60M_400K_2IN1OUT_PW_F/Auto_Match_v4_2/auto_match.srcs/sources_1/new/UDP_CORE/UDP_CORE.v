`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/14 10:58:04
// Design Name: 
// Module Name: XC7Z035_TOP
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


module UDP_CORE#(
       parameter      P_DATA_WIDTH   = 'd64        ,
                      P_DATA_LEN     = 'd4         ,
                      P_IFG_WORD	 = 'd1000				  
)(	   
       input                           i_user_clk      , 
	   input  [P_DATA_WIDTH-1 :0]      i_user_data     ,
	   input                           i_cmd_start     ,//if  start :1 else :0;
       input                           i_rxc           ,
       input  [3 :0]                   i_rxd           ,
       input                           i_rx_ctl        ,
	   					            			    
	   output                          o_wr_fifo_ready ,								    
	   					            			    
       output                          o_txc           ,
       output [3 :0]                   o_txd           ,
       output                          o_tx_ctl        
);

(* mark_debug = "true" *)wire [7 :0]             w_GMII_tx_data  ;
(* mark_debug = "true" *)wire                    w_GMII_tx_valid ;
(* mark_debug = "true" *)wire [7 :0]             w_GMII_rx_data  ;
(* mark_debug = "true" *)wire                    w_GMII_rx_valid ;
(* mark_debug = "true" *)wire [1 :0]             w_speed         ;
(* mark_debug = "true" *)wire                    w_link          ;
                         wire                    w_stack_clk     ;
                         wire                    w_stack_rst     ;
(* mark_debug = "true" *)wire [15:0]             w_rec_len       ;
(* mark_debug = "true" *)wire [7 :0]             w_rec_data      ;
(* mark_debug = "true" *)wire                    w_rec_last      ;
(* mark_debug = "true" *)wire                    w_rec_valid     ;

(* mark_debug = "true" *)wire [15:0]             w_send_len      ;
(* mark_debug = "true" *)wire [7 :0]             w_send_data     ;
(* mark_debug = "true" *)wire                    w_send_last     ;
(* mark_debug = "true" *)wire                    w_send_valid    ;
                         wire                    w_send_ready    ;

  // hardware reset；
rst_gen_module#(                                   
    .P_RST_CYCLE            (1000                   )   
)                               
rst_stack_gen_inst                               
(                               
    .i_clk                  (w_stack_clk            ),
    .o_rst                  (w_stack_rst            )
);

udp_flow_ctrl #(
    .P_SEND_LEN             ( P_DATA_LEN            ),
	.P_DATA_WIDTH           ( P_DATA_WIDTH          ),
    .P_IFG_WORD	            ( P_IFG_WORD            )
)u_udp_flow_ctrl
(   
  //user_clk domain;
    .i_user_clk             (i_user_clk             ),  
    .i_cmd_start            (i_cmd_start            ),
    .i_user_data            (i_user_data            ),  	
  	.o_wr_fifo_ready		(o_wr_fifo_ready        ),
 //stack_clk domain;
  //*input  [63:0]  */   
    .i_stack_clk            (w_stack_clk            ), 
    .i_stack_rst            (w_stack_rst            ),
							
    .i_send_ready           (w_send_ready           ),    //*input          */  
    .o_send_len             (w_send_len             ),    //*output  [15:0] */  
    .o_send_data            (w_send_data            ),    //*output  [7 :0] */  
    .o_send_last            (w_send_last            ),    //*output         */  
    .o_send_valid           (w_send_valid           )     //*output         */  
);


UDP_Stack_Module#(
    .P_TARGET_PORT          (16'h8080                              ),
    .P_SOURCE_PORT          (16'h8080                              ),
    .P_TARGET_IP            ({8'd192,8'd168,8'd100,8'd99}          ),
    .P_SOURCE_IP            ({8'd192,8'd168,8'd100,8'd100}         ),
    .P_TARTGET_MAC          ({8'hff,8'hff,8'hff,8'hff,8'hff,8'hff} ),
    .P_SOURCE_MAC           ({8'h01,8'h02,8'h03,8'h04,8'h05,8'h06} ),
    .P_CRC_CHEKC            ( 1                                    )     
)
UDP_Stack_Module_inst
(
    .i_clk                  (w_stack_clk            ),
    .i_rst                  (w_stack_rst            ),
    /*--------info port-------*/    
    .i_target_port          (0                      ),
    .i_target_port_valid    (0                      ),
    .i_source_port          (0                      ),
    .i_source_port_valid    (0                      ),
    .i_target_ip            (0                      ),
    .i_target_ip_valid      (0                      ),
    .i_source_ip            (0                      ),
    .i_source_ip_valid      (0                      ),
    .i_target_mac           (0                      ),
    .i_target_mac_valid     (0                      ),
    .i_source_mac           (0                      ),
    .i_source_mac_valid     (0                      ),
    /*--------data port--------*/
    .i_send_len             (w_send_len             ),
    .i_send_data            (w_send_data            ),
    .i_send_last            (w_send_last            ),
    .i_send_valid           (w_send_valid           ),
	
    .o_send_ready           (w_send_ready           ),//判断ready为高，下丿个周期拉高valid	                                                     
    .o_rec_len              (w_rec_len              ),
    .o_rec_data             (w_rec_data             ),
    .o_rec_last             (w_rec_last             ),
    .o_rec_valid            (w_rec_valid            ),

    .o_source_ip            (),
    .o_source_ip_valid      (),
    .o_rec_src_mac          (),
    .o_rec_src_valid        (),
    .o_crc_error            (),   
    .o_crc_valid            (), 
    /*--------GMII port--------*/
    .o_GMII_data            (w_GMII_tx_data         ),
    .o_GMII_valid           (w_GMII_tx_valid        ),
    .i_GMII_data            (w_GMII_rx_data         ),
    .i_GMII_valid           (w_GMII_rx_valid        )   
);


GMII2RGMII_Drive GMII2RGMII_Drive_inst(
    .i_udp_stack_clk        (w_stack_clk            ),
    .i_GMII_data            (w_GMII_tx_data         ),
    .i_GMII_valid           (w_GMII_tx_valid        ),
    .o_GMII_data            (w_GMII_rx_data         ),
    .o_GMII_valid           (w_GMII_rx_valid        ),
													
    .i_rxc                  (i_rxc                  ),
    .i_rxd                  (i_rxd                  ),
    .i_rx_ctl               (i_rx_ctl               ),
    .o_txc                  (o_txc                  ),
    .o_txd                  (o_txd                  ),
    .o_tx_ctl               (o_tx_ctl               ),
    .o_speed                (w_speed                ),
    .o_link                 (w_link                 ),
    .o_user_clk             (w_stack_clk            )
);


endmodule