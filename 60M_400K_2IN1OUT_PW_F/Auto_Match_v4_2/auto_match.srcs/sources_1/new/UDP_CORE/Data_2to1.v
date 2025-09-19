`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/19 10:12:23
// Design Name: 
// Module Name: Data_2to1
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


module Data_2to1(
    input               i_clk               ,
    input               i_rst               ,

    input  [15:0]       i_type_A            ,
    input  [15:0]       i_len_A             ,
    input  [7 :0]       i_data_A            ,
    input               i_last_A            ,
    input               i_valid_A           ,
    output              o_next_frame_stop   ,

    input  [15:0]       i_type_B            ,
    input  [15:0]       i_len_B             ,
    input  [7 :0]       i_data_B            ,
    input               i_last_B            ,
    input               i_valid_B           ,

    output [15:0]       o_type              ,
    output [15:0]       o_len               ,
    output [7 :0]       o_data              ,
    output              o_last              ,
    output              o_valid         
);

/***************function**************/

/***************parameter*************/
localparam  P_LEN= 12;
/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg [15:0]              ri_type_A       ;
reg [15:0]              ri_len_A        ;
reg [7 :0]              ri_data_A       ;
reg                     ri_last_A       ;
reg                     ri_valid_A      ;
reg                     ri_valid_A_1d   ;
reg [15:0]              ri_type_B       ;
reg [15:0]              ri_len_B        ;
reg [7 :0]              ri_data_B       ;
reg                     ri_last_B       ;
reg                     ri_valid_B      ;
reg                     ri_valid_B_1d   ;
reg  [7 :0]             ro_data         ;
reg                     ro_last         ;
reg                     ro_valid        ;
reg                     r_fifo_A_rden   ;
reg                     r_fifo_B_rden   ;
reg                     r_fifo_A_rden_1d;
reg                     r_fifo_B_rden_1d;
reg  [1 :0]             r_fifo_rd       ;
reg  [1:0]              r_arbiter       ;
reg  [15:0]             r_rd_cnt        ; 
reg                     r_rd_en         ;
reg                     ro_next_frame_stop  ;
reg  [15:0]             ro_type         ;
reg  [15:0]             ro_len          ;
reg                     r_rden_A_pos    ;
reg                     r_rden_B_pos    ;
reg  [7 :0]             r_cnt           ;

/***************wire******************/
wire [7 :0]             w_fifo_A_dout   ;
wire                    w_fifo_A_full   ;
wire                    w_fifo_A_empty  ;
wire [7 :0]             w_fifo_B_dout   ;
wire                    w_fifo_B_full   ;
wire                    w_fifo_B_empty  ;
wire                    w_rd_en         ;
wire                    w_valid_A_pos   ;
wire                    w_valid_B_pos   ;
wire                    w_rden_A_pos    ;
wire                    w_rden_B_pos    ;
wire [31:0]             w_A_type_len    ;
wire [31:0]             w_B_type_len    ;

/***************component*************/
FIFO_8X256 FIFO_8X256_U0_A (
  .clk              (i_clk          ),   
  .din              (ri_data_A      ),   
  .wr_en            (ri_valid_A     ), 
  .rd_en            (r_fifo_A_rden  ), 
  .dout             (w_fifo_A_dout  ),  
  .full             (w_fifo_A_full  ),  
  .empty            (w_fifo_A_empty )  
);

FIFO_32X16 FIFO_32X16_A (
  .clk              (i_clk                  ),  
  .din              ({ri_type_A,ri_len_A}   ),  
  .wr_en            (w_valid_A_pos          ),  
  .rd_en            (w_rden_A_pos           ),  
  .dout             (w_A_type_len           ),  
  .full             (),
  .empty            () 
);

FIFO_8X256 FIFO_8X256_U0_B (
  .clk              (i_clk          ),   
  .din              (ri_data_B      ),   
  .wr_en            (ri_valid_B     ), 
  .rd_en            (r_fifo_B_rden  ), 
  .dout             (w_fifo_B_dout  ),  
  .full             (w_fifo_B_full  ),  
  .empty            (w_fifo_B_empty )  
);

FIFO_32X16 FIFO_32X16_B (
  .clk              (i_clk                  ),
  .din              ({ri_type_B,ri_len_B}   ),
  .wr_en            (w_valid_B_pos          ),
  .rd_en            (w_rden_B_pos           ),
  .dout             (w_B_type_len           ),
  .full             (), 
  .empty            ()  
);

/***************assign****************/
assign o_data  = ro_data    ;
assign o_last  = ro_last    ;
assign o_valid = ro_valid   ;
assign w_rd_en = r_fifo_A_rden | r_fifo_B_rden;
assign o_next_frame_stop = ro_next_frame_stop;
assign w_valid_A_pos = ri_valid_A & !ri_valid_A_1d;
assign w_valid_B_pos = ri_valid_B & !ri_valid_B_1d;
assign w_rden_A_pos = r_fifo_A_rden & !r_fifo_A_rden_1d;
assign w_rden_B_pos = r_fifo_B_rden & !r_fifo_B_rden_1d;
assign o_type       = ro_type;
assign o_len        = ro_len ;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_type_A  <= 'd0;
        ri_len_A   <= 'd0;
        ri_data_A  <= 'd0;
        ri_last_A  <= 'd0;
        ri_valid_A <= 'd0;
        ri_type_B  <= 'd0;
        ri_len_B   <= 'd0;
        ri_data_B  <= 'd0;
        ri_last_B  <= 'd0;
        ri_valid_B <= 'd0;
        ri_valid_A_1d <= 'd0;
        ri_valid_B_1d <= 'd0;
    end else begin
        ri_type_A  <= i_type_A  ;
        ri_len_A   <= i_len_A   ;
        ri_data_A  <= i_data_A  ;
        ri_last_A  <= i_last_A  ;
        ri_valid_A <= i_valid_A ;
        ri_type_B  <= i_type_B  ;
        ri_len_B   <= i_len_B   ;
        ri_data_B  <= i_data_B  ;
        ri_last_B  <= i_last_B  ;
        ri_valid_B <= i_valid_B ;
        ri_valid_A_1d <= ri_valid_A;
        ri_valid_B_1d <= ri_valid_B;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_fifo_A_rden_1d <= 'd0 ;
        r_fifo_B_rden_1d <= 'd0 ;
    end else begin
        r_fifo_A_rden_1d <= r_fifo_A_rden;
        r_fifo_B_rden_1d <= r_fifo_B_rden;
    end
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt <= 'd0;
    else if(r_arbiter)
        r_cnt <= 'd0;
    else if(r_cnt == P_LEN)
        r_cnt <= r_cnt;
    else if(r_arbiter == 0)
        r_cnt <= r_cnt + 1;
    else 
        r_cnt <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_arbiter <= 'd0;
    else if(ro_last)
        r_arbiter <= 'd0;
    else if(!w_fifo_A_empty && r_arbiter == 0 && r_cnt == P_LEN)
        r_arbiter <= 'd1;
    else if(!w_fifo_B_empty && r_arbiter == 0 && r_cnt == P_LEN)
        r_arbiter <= 'd2;
    else 
        r_arbiter <= r_arbiter;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) 
        ro_data  <= 'd0;
    else if(r_arbiter == 1)  
        ro_data  <= w_fifo_A_dout;
    else if(r_arbiter == 2)   
        ro_data  <= w_fifo_B_dout;
    else  
        ro_data  <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_valid <= 'd0;
    else 
        ro_valid <= r_fifo_rd[0];
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_last <= 'd0;
    else if(!w_rd_en & r_rd_en)
        ro_last <= 'd1;
    else 
        ro_last <= 'd0;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_A_rden <= 'd0;
    else if(r_arbiter == 1 && r_rd_cnt == ri_len_A - 1)
        r_fifo_A_rden <= 'd0;
    else if(r_arbiter == 1 && !w_fifo_A_empty && !ro_valid)
        r_fifo_A_rden <= 'd1;
    else 
        r_fifo_A_rden <= r_fifo_A_rden;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_B_rden <= 'd0;
    else if(r_arbiter == 2 && r_rd_cnt == ri_len_B - 1)
        r_fifo_B_rden <= 'd0;
    else if(r_arbiter == 2 && !w_fifo_B_empty && !ro_valid)
        r_fifo_B_rden <= 'd1;
    else 
        r_fifo_B_rden <= r_fifo_B_rden;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rd_cnt <= 'd0;
    else if(r_arbiter == 1 && r_rd_cnt == ri_len_A - 1)
        r_rd_cnt <= 'd0;
    else if(r_arbiter == 2 && r_rd_cnt == ri_len_B - 1)
        r_rd_cnt <= 'd0;
    else if(r_fifo_A_rden | r_fifo_B_rden)
        r_rd_cnt <= r_rd_cnt + 1;
    else 
        r_rd_cnt <= r_rd_cnt;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_rd <= 'd0;
    else 
        r_fifo_rd <= {r_fifo_rd[0],(r_fifo_A_rden | r_fifo_B_rden)};
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rd_en <= 'd0;
    else 
        r_rd_en <= w_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_next_frame_stop <= 'd0;
    else if(ro_next_frame_stop && r_arbiter == 2 && w_fifo_B_empty)
        ro_next_frame_stop <= 'd0;
    else if(r_arbiter == 1 && !w_fifo_B_empty)
        ro_next_frame_stop <= 'd1;
    else 
        ro_next_frame_stop <= ro_next_frame_stop;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_rden_A_pos <= 'd0;
        r_rden_B_pos <= 'd0;
    end else begin
        r_rden_A_pos <= w_rden_A_pos ;
        r_rden_B_pos <= w_rden_B_pos ;
    end 
end
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_type <= 'd0;
        ro_len  <= 'd0;
    end else if(r_arbiter == 1 && r_rden_A_pos) begin
        ro_type <= w_A_type_len[31:16];
        ro_len  <= w_A_type_len[15:0];
    end else if(r_arbiter == 2 && r_rden_B_pos) begin
        ro_type <= w_B_type_len[31:16];
        ro_len  <= w_B_type_len[15:0];
    end else begin
        ro_type <= ro_type;
        ro_len  <= ro_len ;
    end
end

endmodule
