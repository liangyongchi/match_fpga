`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/22 15:00:25
// Design Name: 
// Module Name: udp_flow_ctrl
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


module udp_flow_ctrl#(
    parameter                       P_SEND_LEN   = 'd100,
	                                P_DATA_WIDTH = 'd64 ,
                                    P_IFG_WORD   = 'd1_000									
)
(

	input                           i_cmd_start     ,												    
    input                           i_user_clk      ,
	input   [P_DATA_WIDTH-1:0]      i_user_data     ,
												    
	input                           i_stack_clk     ,
    input                           i_stack_rst     ,
	input                           i_send_ready    ,

    output                          o_wr_fifo_ready ,	
    output  [15:0]                  o_send_len      ,
    output  [7 :0]                  o_send_data     ,
    output                          o_send_last     ,
    output                          o_send_valid    
);

localparam   LP_FIFO__LEN = P_SEND_LEN <<3; //64/8=8; 2^3=8
								    													    
reg  [15:0]             r_send_len =0  ;
reg  [7 :0]             r_send_data=0  ;
reg                     r_send_last=0  ;
reg                     r_send_valid=0 ;
reg  [31:0]             ifg_cnt=0      ; 
reg  [7:0]              r_start_cnt=0  ;
reg                     wr_en   =0     ;
reg                     rd_en   =0     ;
								       
reg  [15:0]             wr_cnt  =16'd0 ;
reg  [15:0]             rd_cnt  =16'd0 ;

wire  [7:0]             dout           ;
wire                    empty          ;
wire                    o_reset_ok     ;
wire                    wr_fifo_ready  ;
assign  o_reset_ok      = (&r_start_cnt);
assign  wr_fifo_ready   = (&r_start_cnt) && i_cmd_start && (ifg_cnt <= P_SEND_LEN-1);    
assign  o_wr_fifo_ready = wr_fifo_ready;
assign  o_send_len      = r_send_len   ;
assign  o_send_data     = r_send_valid?dout:0;
assign  o_send_last     = r_send_last  ;
assign  o_send_valid    = r_send_valid ;

//-----------64bit to 8bit fifo for send data timing  -------// 
fifo_asyn_64_8 u_fifo_asyn_64_8 (
  .wr_clk              (i_user_clk    ),  // input wire wr_clk
  .rd_clk              (i_stack_clk   ),  // input wire rd_clk
  .din                 (i_user_data   ),        // input wire [31 : 0] din
  .wr_en               (wr_en         ),    // input wire wr_en
  .rd_en               (rd_en         ),    // input wire rd_en
  .dout                (dout          ),      // output wire [7 : 0] dout
  .full                (full          ),      // output wire full
  .empty               (empty         )    // output wire empty
);

/*-------------------user_data 's timing domain------------------------*/

always@(posedge i_user_clk)
begin
    if(o_reset_ok && i_cmd_start && (ifg_cnt <= P_SEND_LEN-1) )
        wr_en <= 1'd1;
    else
	    wr_en <= 1'd0;
end

always@(posedge i_user_clk)
begin
    if(o_reset_ok && (ifg_cnt >= P_IFG_WORD-1) )
	    ifg_cnt <= 'd0;
    else 
	    ifg_cnt <= ifg_cnt + 1 ;
end



always@(posedge i_stack_clk)
begin
    if(!empty && (rd_cnt <= LP_FIFO__LEN -1))
	   rd_en <= 1'd1;
    else
       rd_en <= 1'd0;
end

always@(posedge i_stack_clk)
begin
    if(!empty && (rd_cnt <= LP_FIFO__LEN -1))
	    rd_cnt <= rd_cnt + 16'd1;
    else 
        rd_cnt <= 16'd0;
end

//hardware rst start delay;
always@(posedge i_stack_clk or posedge i_stack_rst)
begin
    if(i_stack_rst)
	    r_start_cnt <= 'd0;
    else if(&r_start_cnt) begin
        r_start_cnt <= r_start_cnt;
    end else begin
        r_start_cnt <= r_start_cnt + 1;
    end
end

//fifo data sync;
always@(posedge i_stack_clk)
begin
       r_send_valid <= rd_en;
end

always@(posedge i_stack_clk)
begin
    if(rd_cnt == (P_DATA_WIDTH>>3)*P_SEND_LEN  )
        r_send_last <= 'd1;
    else 
        r_send_last <= 'd0;
end

always@(posedge i_stack_clk)
begin
    r_send_len <= (P_DATA_WIDTH>>3)*P_SEND_LEN ;
end

// ila_udp_test ila_udp_test_inst(
	// .clk(i_user_clk), // input wire clk
	
	// .probe0(0), // input wire [0:0]  probe0  
	// .probe1(i_send_ready), // input wire [0:0]  probe1 
	// .probe2(wr_en), // input wire [0:0]  probe2 
	// .probe3(ifg_cnt), // input wire [31:0]  probe3 
	
	// .probe4(i_cmd_start), // input wire [0:0]  probe1 
	// .probe5(i_user_data)
// );


// /*-------------------udp_stack 's timing domain------------------------*/
// ila_udp_test_stack ila_udp_test_stack_inst (
	// .clk(i_stack_clk), // input wire clk
	
	// .probe0(rd_en             ), // input wire [0:0]  probe0  
	// .probe1(rd_cnt            ), // input wire [0:0]  probe1 
	// .probe2(r_start_cnt       ), // input wire [0:0]  probe2 
	// .probe3(r_send_valid      ), // input wire [63:0]  probe3 
	// .probe4(dout              ), // input wire [0:0]  probe1 
	// .probe5(r_send_last       ),//  input wire [0:0]  probe2 
    // .probe6(r_send_len        )//  input wire [0:0]  probe2 
// );

endmodule