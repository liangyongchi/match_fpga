`timescale 1ns / 1ps

`include "param_def.vh"
	   
module UDP_TABLE#(
       parameter   P_DATA_WIDTH  =   'd64        ,
	               P_DATA_LEN    =   'd10        ,
				   P_IFG_WORD    =   'd100000000
)
(

	   input                                        i_user_clk       , //100M
	   input                                        i_user_rst       ,
	   input                                        i_eth_start      , 
	   input  [P_DATA_WIDTH*P_DATA_LEN-1 : 0]       i_row_din        ,
   

	   
       input                                        i_rxc            ,
       input      [3 :0]                            i_rxd            ,
       input                                        i_rx_ctl         ,	
	
       output                                       o_txc            ,
       output     [3 :0]                            o_txd            ,
       output                                       o_tx_ctl         	 
   
);
reg     [P_DATA_LEN*P_DATA_WIDTH-1 : 0]             r_row_buff       ;
reg     [31:0]                                      data_frame_num   ;
reg                                                 r0_wr_fifo_en,r1_wr_fifo_en;

wire    [P_DATA_WIDTH-1 : 0]                        w_udp_data  	 ;

wire                                                w_wr_fifo_ready  ;
wire                                                r_wr_fifo_neg    ; 

assign  w_udp_data    = r_row_buff[ P_DATA_WIDTH-1 : 0] ; 
assign  r_wr_fifo_neg = (!r0_wr_fifo_en) & r1_wr_fifo_en;

// wire   i_user_clk;
// wire   i_user_rst;
// wire   locked;
// assign i_user_rst =~locked;
// pll_sys_clk_100M pll_sys_clk_100M_inst
 // (
  // // Clock out ports  
  // .clk_out1(i_user_clk),
  // // Status and control signals               
  // .locked(locked),
 // // Clock in ports
  // .clk_in1(i_user_clk)
 // );

UDP_CORE  #(
            .P_DATA_WIDTH       (P_DATA_WIDTH),
            .P_DATA_LEN         (P_DATA_LEN  ),
			.P_IFG_WORD         (P_IFG_WORD  )
)UDP_CORE_inst
(	
/*input            */   .i_user_clk                (i_user_clk       ), 
/*input  [31 :0]   */   .i_user_data               (w_udp_data       ),
/*input            */   .i_cmd_start               (i_eth_start      ),//if  start :1 else :0;
/*input            */   .i_rxc                     (i_rxc            ),
/*input  [3 :0]    */   .i_rxd                     (i_rxd            ),
/*input            */   .i_rx_ctl                  (i_rx_ctl         ),								    
/*output           */   .o_wr_fifo_ready           (w_wr_fifo_ready  ),								   									    
/*output           */   .o_txc                     (o_txc            ),
/*output [3 :0]    */   .o_txd                     (o_txd            ),
/*output           */   .o_tx_ctl                  (o_tx_ctl         )
);	
/*******************user test 64m spi user*************************/

always@(posedge i_user_clk or posedge i_user_rst)begin
    if(i_user_rst)
	   r_row_buff <= 'd0;
    else if(w_wr_fifo_ready)begin
	   if(P_DATA_LEN == 1)
           r_row_buff <= r_row_buff;
       else
	       r_row_buff <= {r_row_buff[P_DATA_WIDTH*P_DATA_LEN-P_DATA_WIDTH -2: 0],r_row_buff[(P_DATA_WIDTH*P_DATA_LEN-1) -:P_DATA_WIDTH]};
	       //r_row_buff <= {r_row_buff[P_DATA_WIDTH-1:0],r_row_buff[P_DATA_WIDTH*P_DATA_LEN-1:P_DATA_WIDTH]};
	end
	else 
	   //r_row_buff <= {64'd11,64'd22,64'd33,64'd44,64'd55,64'd66,64'd77,64'd88,64'd99,64'd100};
	   r_row_buff <= i_row_din;
end

//data_frame num:
always@(posedge i_user_clk or posedge i_user_rst)begin
    if(i_user_rst)begin
	   r0_wr_fifo_en <= 1'd0;
	   r1_wr_fifo_en <= 1'd0;
	end
	else  begin
	   r0_wr_fifo_en <= w_wr_fifo_ready;
	   r1_wr_fifo_en <= r0_wr_fifo_en;	   
	end
end

always@(posedge i_user_clk or posedge i_user_rst)begin
    if(i_user_rst)
	   data_frame_num <= 32'd0;
	else if(r_wr_fifo_neg)
	   data_frame_num <= data_frame_num + 'd1;
end


/********************tb_code******************************/

//reg  [P_DATA_WIDTH*P_DATA_LEN-1 : 0]       r_row_din;
// always@(posedge i_user_clk )begin
    // if(&r_row_din)
	   // r_row_din <= r_row_din;
	// else
	   // r_row_din <= r_row_din + 'd1;
// end


// always@(posedge i_user_clk or posedge i_user_rst)begin
    // if(i_user_rst)
	   // r_row_buff <= 'd0;
    // else if(w_wr_fifo_ready)begin
	   // if(P_DATA_LEN ==1)
           // r_row_buff <= r_row_buff;
	   // else
	       // r_row_buff <= {r_row_buff[P_DATA_WIDTH*P_DATA_LEN-P_DATA_WIDTH -2: 0],r_row_buff[(P_DATA_WIDTH*P_DATA_LEN-1) -:P_DATA_WIDTH]};
	// end
	// else 
	   // r_row_buff <= i_row_din;
// end


// ila_udp_table ila_udp_table_inst (
	// .clk(i_user_clk), // input wire clk


	// .probe0 (r_row_buff   ), // input wire [382:0]  probe0  
	// .probe1 (w_wr_fifo_ready ), // input wire [0:0]  probe1
    // .probe2 (r_row_din   ),
	// .probe3 (i_user_rst   )
// );

/*******************user test 64m spi user*************************/
endmodule