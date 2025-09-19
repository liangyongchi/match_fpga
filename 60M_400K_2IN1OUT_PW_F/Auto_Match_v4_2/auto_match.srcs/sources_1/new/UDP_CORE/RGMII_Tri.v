`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/24 19:45:00
// Design Name: 
// Module Name: RGMII_Tri
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


module RGMII_Tri(
    /*--------rgmii port--------*/
    input           i_rxc           ,
    input  [3 :0]   i_rxd           ,
    input           i_rx_ctl        ,

    output          o_txc           ,
    output [3 :0]   o_txd           ,
    output          o_tx_ctl        ,

    /*--------data port--------*/
    output          o_user_rxc      ,
    input   [7 :0]  i_send_data     ,
    input           i_send_valid    ,

    output  [7 :0]  o_rec_data      ,
    output          o_rec_valid     ,
    output          o_rec_end       ,

    output  [1:0]   o_speed         ,
    output          o_link          
);


// reg  [7 :0]         ri_send_data =0 ;
// reg                 ri_send_valid=0 ;
reg  [7 :0]         ro_rec_data = 0 ; 
reg                 ro_rec_valid= 0 ; 
reg                 ro_rec_end  = 0 ; 
reg                 r_cnt_10_100= 0 ; 
reg                 ro_speed=0      ;
reg                 ro_link =0      ;

reg                 r_rxc_half = 1  ;


wire                w_rxc_bufr      ;
wire                w_rxc_bufio     ;
wire                w_rxc_idelay    ;
wire [3 :0]         w_rxd_ibuf      ;
wire                w_rx_ctl_ibuf   ;
(* mark_debug = "true" *)wire [7 :0]         w_rec_data      ;
(* mark_debug = "true" *)wire [1 :0]         w_rec_valid     ;
wire [3 :0]         w_send_d1       ;
wire [3 :0]         w_send_d2       ;
wire                w_send_valid    ;
wire                i_speed1000     ;
wire                w_txc           ;  
//oddr _clk;
wire w_oddr_clk;
assign w_oddr_clk = (i_speed1000) ? w_txc : r_rxc_half;


assign w_txc       = ~w_rxc_bufr ;//相位相反；
assign o_user_rxc  = (i_speed1000) ? w_rxc_bufr : r_rxc_half ;
assign o_speed     = ro_speed    ;
assign o_link      = ro_link     ;
assign i_speed1000 = 1;
assign o_rec_data  = ro_rec_data ;
assign o_rec_valid = ro_rec_valid;
assign o_rec_end   = ro_rec_end  ;



OBUF #(
   .DRIVE           (12             ),   // Specify the output drive strength
   .IOSTANDARD      ("DEFAULT"      ), // Specify the output I/O standard
   .SLEW            ("SLOW"         ) // Specify the output slew rate
) OBUF_inst (
   .O               (o_txc          ),     // Buffer output (connect directly to top-level port)
   .I               (w_txc          )      // Buffer input 
);

// ODDR #(
//    .DDR_CLK_EDGE    ("OPPOSITE_EDGE"    ), // "OPPOSITE_EDGE" or "SAME_EDGE" 
//    .INIT            (1'b0               ),    // Initial value of Q: 1'b0 or 1'b1
//    .SRTYPE          ("SYNC"             ) // Set/Reset type: "SYNC" or "ASYNC" 
// ) ODDR_inst (
//    .Q               (o_txc              ),   // 1-bit DDR output
//    .C               (w_rxc_bufr         ),   // 1-bit clock input
//    .CE              (1                  ), // 1-bit clock enable input
//    .D1              (0                  ), // 1-bit data input (positive edge)
//    .D2              (1                  ), // 1-bit data input (negative edge)
//    .R               (0                  ),   // 1-bit reset
//    .S               (0                  )    // 1-bit set
// );


//侧重io时钟网络；
BUFIO BUFIO_inst (
   .O               (w_rxc_bufio   ),
   .I               (i_rxc         ) 
);

BUFR #(
   .BUFR_DIVIDE     ("BYPASS"       ), 
   .SIM_DEVICE      ("7SERIES"      )  
)//侧重把FPGA内部的逻辑网络；
BUFR_inst (
   .O               (w_rxc_bufr     ), 
   .CE              (1              ), 
   .CLR             (0              ), 
   .I               (i_rxc          )  
);

// (* IODELAY_GROUP = "rgmii" *)
// IDELAYCTRL IDELAYCTRL_U0 (
//    .RDY             (RDY),       // 1-bit output: Ready output
//    .REFCLK          (REFCLK), // 1-bit input: Reference clock input
//    .RST             (RST)        // 1-bit input: Active high reset input
// );

// (* IODELAY_GROUP = "rgmii" *)
// IDELAYE2 #(
//    .CINVCTRL_SEL            ("FALSE"        ),          // Enable dynamic clock inversion (FALSE, TRUE)
//    .DELAY_SRC               ("IDATAIN"      ),           // Delay input (IDATAIN, DATAIN)
//    .HIGH_PERFORMANCE_MODE   ("FALSE"        ), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
//    .IDELAY_TYPE             ("FIXED"        ),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
//    .IDELAY_VALUE            (0              ),                // Input delay tap setting (0-31) 0.15625
//    .PIPE_SEL                ("FALSE"        ),              // Select pipelined mode, FALSE, TRUE
//    .REFCLK_FREQUENCY        (200.0          ),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
//    .SIGNAL_PATTERN          ("DATA"         )          // DATA, CLOCK input signal
// )
// IDELAYE2_inst (
//    .CNTVALUEOUT             (), // 5-bit output: Counter value output
//    .DATAOUT                 (w_rxc_idelay   ),         // 1-bit output: Delayed data output
//    .C                       (),                     // 1-bit input: Clock input
//    .CE                      (),                   // 1-bit input: Active high enable increment/decrement input
//    .CINVCTRL                (),       // 1-bit input: Dynamic clock inversion input
//    .CNTVALUEIN              (),   // 5-bit input: Counter value input
//    .DATAIN                  (),           // 1-bit input: Internal delay data input
//    .IDATAIN                 (i_rxc          ),         // 1-bit input: Data input from the I/O
//    .INC                     (),                 // 1-bit input: Increment / Decrement tap delay input
//    .LD                      (),                   // 1-bit input: Load IDELAY_VALUE input
//    .LDPIPEEN                (),       // 1-bit input: Enable PIPELINE register to load data input
//    .REGRST                  ()            // 1-bit input: Active-high reset tap-delay input
// );

genvar rxd_i;
generate for(rxd_i = 0 ;rxd_i < 4 ;rxd_i = rxd_i + 1)
begin
    IBUF #(
        .IBUF_LOW_PWR    ("TRUE"        ),  
        .IOSTANDARD      ("DEFAULT"     )
    ) 
    IBUF_U 
    (
        .O               (w_rxd_ibuf[rxd_i] ),     // Buffer output
        .I               (i_rxd[rxd_i]      )      // Buffer input (connect directly to top-level port)
    );

    IDDR #(
        .DDR_CLK_EDGE   ("SAME_EDGE_PIPELINED"    ),
        .INIT_Q1        (1'b0                     ),
        .INIT_Q2        (1'b0                     ),
        .SRTYPE         ("SYNC"                   ) 
    )   
    IDDR_u0     
    (   
        .Q1             (w_rec_data[rxd_i]          ), // 1-bit output for positive edge of clock 
        .Q2             (w_rec_data[rxd_i +4]       ), // 1-bit output for negative edge of clock
        .C              (w_rxc_bufio                ),  
        .CE             (1                          ),
        .D              (w_rxd_ibuf[rxd_i]          ),  
        .R              (0                          ),   
        .S              (0                          )   
    );
end
endgenerate

IBUF #(
    .IBUF_LOW_PWR    ("TRUE"                    ),  
    .IOSTANDARD      ("DEFAULT"                 )
)           
IBUF_U          
(           
    .O               (w_rx_ctl_ibuf             ),     // Buffer output
    .I               (i_rx_ctl                  )      // Buffer input (connect directly to top-level port)
);

IDDR #(
    .DDR_CLK_EDGE   ("SAME_EDGE_PIPELINED"      ),
    .INIT_Q1        (1'b0                       ),
    .INIT_Q2        (1'b0                       ),
    .SRTYPE         ("SYNC"                     ) 
)   
IDDR_u0     
(   
    .Q1             (w_rec_valid[0]             ), // 1-bit output for positive edge of clock 
    .Q2             (w_rec_valid[1]             ), // 1-bit output for negative edge of clock
    .C              (w_rxc_bufio                ),  
    .CE             (1                          ),
    .D              (w_rx_ctl_ibuf              ),  
    .R              (0                          ),   
    .S              (0                          )   
);
  

// 

always@(posedge w_rxc_bufr)
begin
    if(!i_speed1000 && (&w_rec_valid))
        r_cnt_10_100 <= r_cnt_10_100 + 1;
    else 
        r_cnt_10_100 <= 'd0;
end 

always@(posedge w_rxc_bufr)
begin
    if(&w_rec_valid && i_speed1000)
        ro_rec_valid <= 'd1;
    else 
        ro_rec_valid <= r_cnt_10_100;
end

always@(posedge w_rxc_bufr)
begin
    if(i_speed1000)
        ro_rec_data <= w_rec_data;
    else 
        ro_rec_data <= {ro_rec_data[3:0],w_rec_data[3:0]};
end

always@(posedge w_rxc_bufr)
begin
    if(&w_rec_valid)
        ro_rec_end <= 'd0;
    else 
        ro_rec_end <= 'd1;
end

always@(posedge w_rxc_bufr)
begin
    if(w_rec_valid == 'd0) begin
        ro_speed <= w_rec_data[2:1];
        ro_link  <= w_rec_data[0];
    end else begin
        ro_speed <= ro_speed;
        ro_link  <= ro_link ;
    end
end

always@(posedge w_rxc_bufr)  
begin  
    r_rxc_half <= ~r_rxc_half;  
end  

genvar txd_i;
generate for(txd_i = 0 ;txd_i < 4 ; txd_i = txd_i + 1)
begin
    assign w_send_d1[txd_i] =  i_send_data[txd_i]    ;  
    assign w_send_d2[txd_i] =  i_send_data[txd_i + 4] ; 


    ODDR #(
        .DDR_CLK_EDGE    ("OPPOSITE_EDGE"       ),
        .INIT            (1'b0                  ),
        .SRTYPE          ("SYNC"                ) 
    ) 
    ODDR_u 
    (
        .Q               (o_txd[txd_i]          ),  
        .C               (w_oddr_clk            ),
        .CE              (1                     ),
        .D1              (w_send_d1[txd_i]      ),    
        .D2              (w_send_d2[txd_i]      ),    
        .R               (0                     ),
        .S               (0                     ) 
    );
end
endgenerate

assign w_send_valid =  i_send_valid ;

ODDR#(
    .DDR_CLK_EDGE        ("OPPOSITE_EDGE"       ),
    .INIT                (1'b0                  ),
    .SRTYPE              ("SYNC"                ) 
)                                               
ODDR_uu0                                        
(                                               
    .Q                   (o_tx_ctl              ),  
    .C                   (w_oddr_clk            ),
    .CE                  (1                     ),
    .D1                  (w_send_valid          ),    
    .D2                  (w_send_valid          ),    
    .R                   (0                     ),
    .S                   (0                     ) 
);

endmodule


//ila_top u_ila_top (
	// .clk(i_rxc   ), // input wire clk


	// .probe0( w_rec_data          ), // input wire [3:0]  probe0  
	// .probe1( w_rec_valid       ), // input wire [0:0]  probe1 
	// .probe2( 0          ), // input wire [0:0]  probe2 
	// .probe3( 0          ), // input wire [3:0]  probe3 
	// .probe4(w_oddr_clk        ), // input wire [0:0]  probe4 
	// .probe5 (i_send_data  ), // input wire [7:0]  probe5 
	// .probe6 (i_send_valid ), // input wire [0:0]  probe6 
	// .probe7 (o_rec_valid  ), // input wire [7:0]  probe7 
	// .probe8 (o_rec_end ), // input wire [0:0]  probe8 
	// .probe9 (o_speed         ), // input wire [1:0]  probe9 
	// .probe10(o_link          ), // input wire [0:0]  probe10 
	// .probe11(o_user_rxc  ), // input wire [0:0]  probe11 
	// .probe12(w_send_d1  ), // input wire [0:0]  probe12 
	// .probe13(w_send_d2    ), // input wire [15:0]  probe13 
	// .probe14(w_send_valid   ) // input wire [7:0]  probe14 

// );