`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/18 16:12:39
// Design Name: 
// Module Name: CRC_Data_Pro
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


module CRC_Data_Pro(
    input               i_clk           ,
    input               i_rst           ,

    input  [15:0]       i_per_type      ,
    input  [7 :0]       i_per_data      ,
    input               i_per_last      ,
    input               i_per_valid     ,
    input               i_per_crc_error ,
    input               i_per_crc_valid ,

    output [15:0]       o_post_type     ,
    output [7 :0]       o_post_data     ,
    output              o_post_last     ,
    output              o_post_valid 
);

/***************function**************/

/***************parameter*************/
localparam              P_FRAME_GAP =   12  ;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
reg  [15:0]             ri_per_type         ;
reg  [7 :0]             ri_per_data         ;
reg                     ri_per_last         ;
reg                     ri_per_valid        ;
reg                     ri_per_valid_1d     ;
reg                     ri_per_crc_error    ;
reg                     ri_per_crc_valid    ;
reg  [7 :0]             ro_post_data        ;
reg                     ro_post_last        ;
reg                     ro_post_valid       ;
reg                     r_ram_en_A          ;
reg                     r_ram_we_A          ;
reg  [11:0]             r_ram_addr_A        ;
reg  [7 :0]             r_ram_din_A         ;
reg                     r_ram_en_B          ;
reg                     r_ram_en_B_1d       ;
reg                     r_ram_we_B          ;
reg  [11:0]             r_ram_addr_B        ;
reg  [10:0]             r_data_len          ;
reg  [10:0]             r_data_len_o        ;
reg                     r_fifo_rd_en        ;
reg                     r_fifo_rd_en_1d     ;
reg                     r_fifo_wr_en        ;
reg                     r_out_run           ;
reg                     r_out_run_1d        ;
reg  [10:0]             r_fifo_dout         ;
reg  [15:0]             r_gap_cnt           ;
reg  [15:0]             ro_post_type        ;
reg                     ri_per_last_1d      ;

/***************wire******************/
wire [7 :0]             w_ram_dout_B        ;
wire [10:0]             w_fifo_dout         ;
wire                    w_fifo_empty        ;
wire                    w_fifo_full         ;
wire [15:0]             w_fifo_type         ;

/***************component*************/
RAM_8x1500_TrueDual RAM_8x1500_TrueDual_u0 (//修改为8X3000 
  .clka                 (i_clk          ),
  .ena                  (r_ram_en_A     ),
  .wea                  (r_ram_we_A     ),
  .addra                (r_ram_addr_A   ),
  .dina                 (r_ram_din_A    ),
  .douta                (),

  .clkb                 (i_clk          ),
  .enb                  (r_ram_en_B     ),
  .web                  (r_ram_we_B     ),
  .addrb                (r_ram_addr_B   ),
  .dinb                 (0              ),
  .doutb                (w_ram_dout_B   ) 
);

FIFO_11X64 FIFO_11X64_U0 (
  .clk                  (i_clk          ),
  .din                  (r_data_len     ),
  .wr_en                (r_fifo_wr_en   ),
  .rd_en                (r_fifo_rd_en   ),
  .dout                 (w_fifo_dout    ),
  .full                 (w_fifo_full    ),
  .empty                (w_fifo_empty   ) 
);

FIFO_16X64 FIFO_16X64_U1 (
  .clk                  (i_clk          ),
  .din                  (ri_per_type     ),
  .wr_en                (r_fifo_wr_en   ),
  .rd_en                (r_fifo_rd_en   ),
  .dout                 (w_fifo_type    ),
  .full                 (),
  .empty                () 
);

/***************assign****************/
assign o_post_data  = ro_post_data ;
assign o_post_last  = ro_post_last ;
assign o_post_valid = ro_post_valid;
assign o_post_type  = ro_post_type;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_per_data      <= 'd0;
        ri_per_last      <= 'd0;
        ri_per_valid     <= 'd0;
        ri_per_type      <= 'd0;
        ri_per_crc_error <= 'd0;
        ri_per_crc_valid <= 'd0;
    end else begin
        ri_per_data      <= i_per_data     ;
        ri_per_last      <= i_per_last     ;
        ri_per_valid     <= i_per_valid    ;
        ri_per_type      <= i_per_type     ;
        ri_per_crc_error <= i_per_crc_error;
        ri_per_crc_valid <= i_per_crc_valid;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_ram_en_A   <= 'd0;   
        r_ram_we_A   <= 'd0;   
        r_ram_din_A  <= 'd0;
    end else if(ri_per_valid) begin
        r_ram_en_A   <= 'd1;
        r_ram_we_A   <= 'd1;
        r_ram_din_A  <= ri_per_data;
    end else begin
        r_ram_en_A   <= 'd0;
        r_ram_we_A   <= 'd0;
        r_ram_din_A  <= 'd0;
    end
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_per_valid_1d <= 'd0;
    else
        ri_per_valid_1d <= ri_per_valid;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_addr_A <= 'd0;
    else if(ri_per_crc_valid && ri_per_crc_error)
        r_ram_addr_A <= r_ram_addr_A - r_data_len;
    else if(r_ram_addr_A == 2999)
        r_ram_addr_A <= 'd0;
    else if(ri_per_valid && !ri_per_valid_1d)
        r_ram_addr_A <= r_ram_addr_A;
    else if(ri_per_valid | ri_per_valid_1d)
        r_ram_addr_A <= r_ram_addr_A + 1;
    else 
        r_ram_addr_A <= r_ram_addr_A;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_per_last_1d <= 'd0;
    else 
        ri_per_last_1d <= ri_per_last;
end

// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst)
//         r_data_len <= 'd0;
//     else if(ri_per_last_1d)
//         r_data_len <= r_ram_addr_A;
//     else 
//         r_data_len <= r_data_len;
// end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_data_len <= 'd0;
    else if(r_fifo_wr_en)
        r_data_len <= 'd0;
    else if(ri_per_valid)
        r_data_len <= r_data_len + 1;
    else
        r_data_len <= r_data_len;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_wr_en <= 'd0;
    else if(ri_per_crc_valid && !ri_per_crc_error && !r_fifo_wr_en)
        r_fifo_wr_en <= 'd1;
    else 
        r_fifo_wr_en <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_rd_en <= 'd0;
    else if(!w_fifo_empty && !r_out_run && !r_fifo_rd_en && r_gap_cnt == P_FRAME_GAP - 4)
        r_fifo_rd_en <= 'd1;
    else
        r_fifo_rd_en <= 'd0; 
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_rd_en_1d <= 'd0;
    else 
        r_fifo_rd_en_1d <= r_fifo_rd_en;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_dout <= 'd0;
    else if(r_fifo_rd_en_1d)   
        r_fifo_dout <= w_fifo_dout;
    else 
        r_fifo_dout <= r_fifo_dout;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_out_run <= 'd0;
    else if(r_data_len_o == r_fifo_dout - 1)
        r_out_run <= 'd0;
    else if(!r_fifo_rd_en && r_fifo_rd_en_1d)
        r_out_run <= 'd1;
    else 
        r_out_run <= r_out_run;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_data_len_o <= 'd0;
    else if(r_data_len_o == r_fifo_dout - 1)
        r_data_len_o <= 'd0;
    else  if(r_out_run)
        r_data_len_o <= r_data_len_o + 1;
    else  
        r_data_len_o <= r_data_len_o;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_out_run_1d <= 'd0;
    else
        r_out_run_1d <= r_out_run;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_ram_en_B   <= 'd0;   
        r_ram_we_B   <= 'd0;   
    end else if(r_out_run && !r_out_run_1d) begin
        r_ram_en_B   <= 'd1;   
        r_ram_we_B   <= 'd0;   
        
    end else if(r_out_run) begin
        r_ram_en_B   <= 'd1;   
        r_ram_we_B   <= 'd0;   
        
    end else begin
        r_ram_en_B   <= 'd0;   
        r_ram_we_B   <= 'd0;   
    end 
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_addr_B <= 'd0;
    else if(r_ram_addr_B == 2999)   
        r_ram_addr_B <= 'd0;
    else if(r_out_run && !r_out_run_1d)
        r_ram_addr_B <= r_ram_addr_B;
    else if(r_out_run | r_out_run_1d)
        r_ram_addr_B <= r_ram_addr_B + 1;
    else 
        r_ram_addr_B <= r_ram_addr_B;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_data <= 'd0;
    else if(r_ram_en_B_1d)
        ro_post_data <= w_ram_dout_B;
    else 
        ro_post_data <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_type <= 'd0;
    else if(r_fifo_rd_en_1d)
        ro_post_type <= w_fifo_type;
    else 
        ro_post_type <= ro_post_type;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_en_B_1d <= 'd0;
    else 
        r_ram_en_B_1d <= r_ram_en_B;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_valid <= 'd0;
    else 
        ro_post_valid <= r_ram_en_B_1d;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_post_last <= 'd0;
    else if(!r_ram_en_B && r_ram_en_B_1d)
        ro_post_last <= 'd1;
    else    
        ro_post_last <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_gap_cnt <= 'd1;
    else if(r_fifo_rd_en)
        r_gap_cnt <= 'd0;
    else if(r_gap_cnt == P_FRAME_GAP - 4)
        r_gap_cnt <= r_gap_cnt;
    else if(ro_post_last | r_gap_cnt)
        r_gap_cnt <= r_gap_cnt + 1;
    else 
        r_gap_cnt <= r_gap_cnt;
end

endmodule
