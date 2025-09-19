`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/18 20:35:43
// Design Name: 
// Module Name: adc_lpf
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

module adc_lpf_400k(
    input           i_clk_250               ,
    input           i_rst                   ,
    
    input           i_sys_start             ,
    output          o_sys_start             ,
    
    // adc demod data
    input           i_adc0_demod_vld        ,
    input   [63:0]  i_adc0_demod_data       ,
    
    input           i_adc1_demod_vld        ,
    input   [63:0]  i_adc1_demod_data       ,
    
    // adc lpf data
    output          o_adc0_lpf_vld          ,
    output  [63:0]  o_adc0_lpf_data         ,
    
    output          o_adc1_lpf_vld          ,
    output  [63:0]  o_adc1_lpf_data         ,
    //stream data uart rx
    input           i_uart_rx_en            ,
    input   [7 :0]  i_uart_rx_addr          ,
    input   [15:0]  i_uart_rx_frame_num     ,
    input   [15:0]  i_uart_rx_data_length   ,
    output          o_lpf_coef_req          ,
    input           i_lpf_coef_data_vld     ,
    input   [15:0]  i_lpf_coef_data         
);
//========================================================================
reg                 r_uart_rx_en            ;
reg     [7 :0]      r_uart_rx_addr          ;
reg     [15:0]      r_uart_rx_frame_num     ;
reg     [15:0]      r_uart_rx_data_length   ;

reg                 r_uart_rx_en_d0         ;

reg     [15:0]      r_lpf_coef_frame_num    ;
reg     [15:0]      r_lpf_coef_data_len     ;
reg                 r_lpf_coef_en           ;
reg                 r_lpf_coef_wreq         ;
reg                 r_lpf_coef_wreq_d1      ;

reg                 r_lpf_coef_wreq_pulse   ;

reg     [15:0]      r_lpf_coef_req_cnt      ;

reg     [15:0]      r_lpf_coef_data_len_d0  ;
reg     [15:0]      r_lpf_coef_data_len_d1  ;
reg     [15:0]      r_lpf_coef_data_len_d2  ;

reg                 r_lpf_coef_data_vld_d0  ;
reg                 r_lpf_coef_data_vld_d1  ;
reg                 r_lpf_coef_data_vld_d2  ;
reg                 r_lpf_coef_data_vld_d3  ;
reg     [15:0]      r_lpf_coef_data_d0      ;
reg     [15:0]      r_lpf_coef_data_d1      ;
reg     [15:0]      r_lpf_coef_data_d2      ;

reg                 r_lpf_coef_data_last    ;
reg                 r_lpf_coef_data_vld     ;
reg     [15:0]      r_lpf_coef_data         ;
reg     [15:0]      r_lpf_coef_data_cnt     ; 

reg                 r_lpf_coef_data_last_d0 ;
reg                 r_lpf_coef_data_last_d1 ;

reg                 r_lpf_coef_data_sync    ;

reg                 r_adc0_demod_vld_d0     ;
reg     [63:0]      r_adc0_demod_data_d0    ;

reg                 r_adc1_demod_vld_d0     ;
reg     [63:0]      r_adc1_demod_data_d0    ;
reg                 r_adc1_demod_vld_d1     ;
reg     [63:0]      r_adc1_demod_data_d1    ;

reg                 r_sys_start_d0          ;

reg                 r_adc_ch_id           =0;

wire                s_adc0_lpf_vld          ;
wire    [39:0]      s_adc0_lpf_i_data       ;
wire    [39:0]      s_adc0_lpf_q_data       ;
wire                s_adc1_lpf_vld          ;
wire    [39:0]      s_adc1_lpf_i_data       ;
wire    [39:0]      s_adc1_lpf_q_data       ;

wire                s_sys_start             ;

reg                 r_adc0_lpf_vld          ;
reg     [31:0]      r_adc0_lpf_i_data       ;
reg     [31:0]      r_adc0_lpf_q_data       ;

reg                 r_adc1_lpf_vld          ;
reg     [31:0]      r_adc1_lpf_i_data       ;
reg     [31:0]      r_adc1_lpf_q_data       ;

reg                 r_sys_start             ;

reg                 r_adc0_lpf_vld_o        ;
reg     [31:0]      r_adc0_lpf_i_data_o     ;
reg     [31:0]      r_adc0_lpf_q_data_o     ;

reg                 r_sys_start_o           ;
//========================================================================

reg                 s_axis_data_tvalid      ;
wire                s_axis_data_tready      ;
reg  [1:0]          s_axis_data_tuser       ;
reg  [63:0]         s_axis_data_tdata       ;
wire                m_axis_data_tvalid      ;
wire [1:0]          m_axis_data_tuser       ;
wire [79:0]         m_axis_data_tdata       ;
wire                s_axis_config_tvalid    ;
wire                s_axis_config_tready    ;
wire [7:0]          s_axis_config_tdata     ;
wire                s_axis_reload_tvalid    ;
wire                s_axis_reload_tready    ;
wire                s_axis_reload_tlast     ;
wire [15:0]         s_axis_reload_tdata     ;

//========================================================================
fir_compiler_lpf_400k adc_lpf_400k_inst(
    .aclk                   ( i_clk_250               ),//input         
    .s_axis_data_tvalid     ( s_axis_data_tvalid      ),//input         
    .s_axis_data_tready     ( s_axis_data_tready      ),//output       
    .s_axis_data_tuser      ( s_axis_data_tuser       ),//input [0:0]  
    .s_axis_data_tdata      ( s_axis_data_tdata       ),//input [63:0]  
    .m_axis_data_tvalid     ( m_axis_data_tvalid      ),//output     
    .m_axis_data_tuser      ( m_axis_data_tuser       ),//output [0:0] 
    .m_axis_data_tdata      ( m_axis_data_tdata       ),//output [159:0] 
    .s_axis_config_tvalid   ( s_axis_config_tvalid    ),//input         
    .s_axis_config_tready   ( s_axis_config_tready    ),//output        
    .s_axis_config_tdata    ( s_axis_config_tdata     ),//input [7:0]   
    .s_axis_reload_tvalid   ( s_axis_reload_tvalid    ),//input         
    .s_axis_reload_tready   ( s_axis_reload_tready    ),//output        
    .s_axis_reload_tlast    ( s_axis_reload_tlast     ),//input         
    .s_axis_reload_tdata    ( s_axis_reload_tdata     ) //input [15:0]  
);

//========================================================================

always@(posedge i_clk_250 or posedge i_rst) if(i_rst) s_axis_data_tvalid   <= 'd0; else s_axis_data_tvalid   <= r_adc0_demod_vld_d0 | r_adc1_demod_vld_d1;
always@(posedge i_clk_250 or posedge i_rst) if(i_rst) s_axis_data_tuser    <= 'd0; else s_axis_data_tuser    <= {r_sys_start_d0,r_adc_ch_id};
always@(posedge i_clk_250 or posedge i_rst) if(i_rst) s_axis_data_tdata    <= 'd0; else s_axis_data_tdata    <= r_adc_ch_id ? r_adc1_demod_data_d1 : r_adc0_demod_data_d0;

assign s_axis_config_tvalid = r_lpf_coef_data_sync;
assign s_axis_config_tdata  = 8'd0;
assign s_axis_reload_tvalid = r_lpf_coef_data_vld;
assign s_axis_reload_tlast  = r_lpf_coef_data_last;
assign s_axis_reload_tdata  = r_lpf_coef_data;

assign s_adc0_lpf_vld       = !m_axis_data_tuser[0] & m_axis_data_tvalid;
assign s_adc0_lpf_i_data    = !m_axis_data_tuser[0] ? m_axis_data_tdata[79:40] : s_adc0_lpf_i_data;
assign s_adc0_lpf_q_data    = !m_axis_data_tuser[0] ? m_axis_data_tdata[39: 0] : s_adc0_lpf_q_data;

assign s_adc1_lpf_vld       =  m_axis_data_tuser[0] & m_axis_data_tvalid;
assign s_adc1_lpf_i_data    =  m_axis_data_tuser[0] ? m_axis_data_tdata[79:40] : s_adc1_lpf_i_data;
assign s_adc1_lpf_q_data    =  m_axis_data_tuser[0] ? m_axis_data_tdata[39: 0] : s_adc1_lpf_q_data;

assign s_sys_start          = m_axis_data_tuser[1] & m_axis_data_tvalid;
//==================================================================
always @(posedge i_clk_250)
begin
    r_adc0_demod_vld_d0     <= i_adc0_demod_vld    ;
    r_adc0_demod_data_d0    <= i_adc0_demod_data   ;
    
    r_adc1_demod_vld_d0     <= i_adc1_demod_vld    ;
    r_adc1_demod_data_d0    <= i_adc1_demod_data   ;
    r_adc1_demod_vld_d1     <= r_adc1_demod_vld_d0 ;
    r_adc1_demod_data_d1    <= r_adc1_demod_data_d0;
end

always @(posedge i_clk_250)
begin
    r_sys_start_d0  <= i_sys_start;
end

always @(posedge i_clk_250)
begin
    if(i_sys_start)
        r_adc_ch_id <= 1'b0;
    else if(r_adc0_demod_vld_d0 | r_adc1_demod_vld_d1)
        r_adc_ch_id <= ~r_adc_ch_id;
    else
        r_adc_ch_id <= r_adc_ch_id;
end
//==================================================================
assign o_adc0_lpf_vld       = r_adc0_lpf_vld_o    ;
assign o_adc0_lpf_data      = {r_adc0_lpf_i_data_o,r_adc0_lpf_q_data_o} ;

assign o_adc1_lpf_vld       = r_adc1_lpf_vld    ;
assign o_adc1_lpf_data      = {r_adc1_lpf_i_data,r_adc1_lpf_q_data} ;

assign o_sys_start          = r_sys_start_o       ;

assign o_lpf_coef_req       = r_lpf_coef_wreq_pulse;
//==================================================================
// 截位保护
//==================================================================
always @(posedge i_clk_250)
begin
    r_sys_start     <= s_sys_start;
    r_adc0_lpf_vld  <= s_adc0_lpf_vld;
    r_adc1_lpf_vld  <= s_adc1_lpf_vld;
end

always @(posedge i_clk_250)
begin
    r_adc0_lpf_vld_o     <= r_adc0_lpf_vld   ;
    r_adc0_lpf_i_data_o  <= r_adc0_lpf_i_data;
    r_adc0_lpf_q_data_o  <= r_adc0_lpf_q_data;
    r_sys_start_o        <= r_sys_start      ;
end

always@(posedge i_clk_250)
begin
    if(s_adc0_lpf_i_data[39]) begin
        if(&s_adc0_lpf_i_data[38:31])
            r_adc0_lpf_i_data  <= s_adc0_lpf_i_data[31:0];
        else
            r_adc0_lpf_i_data  <= 32'h80000001;
    end
    else begin
        if(|s_adc0_lpf_i_data[39:31])
            r_adc0_lpf_i_data  <= 32'h7fffffff;
        else
            r_adc0_lpf_i_data  <= s_adc0_lpf_i_data[31:0];
    end
end

always@(posedge i_clk_250)
begin
    if(s_adc0_lpf_q_data[39]) begin
        if(&s_adc0_lpf_q_data[38:31])
            r_adc0_lpf_q_data  <= s_adc0_lpf_q_data[31:0];
        else
            r_adc0_lpf_q_data  <= 32'h80000001;
    end
    else begin
        if(|s_adc0_lpf_q_data[39:31])
            r_adc0_lpf_q_data  <= 32'h7fffffff;
        else
            r_adc0_lpf_q_data  <= s_adc0_lpf_q_data[31:0];
    end
end

always@(posedge i_clk_250)
begin
    if(s_adc1_lpf_i_data[39]) begin
        if(&s_adc1_lpf_i_data[38:31])
            r_adc1_lpf_i_data  <= s_adc1_lpf_i_data[31:0];
        else
            r_adc1_lpf_i_data  <= 32'h80000001;
    end
    else begin
        if(|s_adc1_lpf_i_data[39:31])
            r_adc1_lpf_i_data  <= 32'h7fffffff;
        else
            r_adc1_lpf_i_data  <= s_adc1_lpf_i_data[31:0];
    end
end

always@(posedge i_clk_250)
begin
    if(s_adc1_lpf_q_data[39]) begin
        if(&s_adc1_lpf_q_data[38:31])
            r_adc1_lpf_q_data  <= s_adc1_lpf_q_data[31:0];
        else
            r_adc1_lpf_q_data  <= 32'h80000001;
    end
    else begin
        if(|s_adc1_lpf_q_data[39:31])
            r_adc1_lpf_q_data  <= 32'h7fffffff;
        else
            r_adc1_lpf_q_data  <= s_adc1_lpf_q_data[31:0];
    end
end

//==================================================================
always @(posedge i_clk_250)
begin
    r_uart_rx_en            <= i_uart_rx_en         ;
    r_uart_rx_addr          <= i_uart_rx_addr       ;
    r_uart_rx_frame_num     <= i_uart_rx_frame_num  ;
    r_uart_rx_data_length   <= i_uart_rx_data_length;
end

always @(posedge i_clk_250)
begin
    r_uart_rx_en_d0 <= r_uart_rx_en;
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_frame_num    <= 'd0;
        r_lpf_coef_data_len     <= 'd0;
        
        r_lpf_coef_en           <= 'd0;
        
    end
    else if((!r_uart_rx_en_d0 & r_uart_rx_en) && (r_uart_rx_addr == 8'h05)) begin
        r_lpf_coef_frame_num    <= r_uart_rx_frame_num;
        r_lpf_coef_data_len     <= r_uart_rx_data_length;
        
        r_lpf_coef_en           <= 1'b1;
    end
    else if(r_lpf_coef_req_cnt >= r_lpf_coef_data_len) begin
        r_lpf_coef_en           <= 1'b0;
    end
    else begin
        r_lpf_coef_frame_num    <= r_lpf_coef_frame_num ;
        r_lpf_coef_data_len     <= r_lpf_coef_data_len  ;

        r_lpf_coef_en           <= r_lpf_coef_en        ;
    end
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_wreq <= 1'b0;
    end
    else if(!r_lpf_coef_en)
        r_lpf_coef_wreq <= 1'b0;
    else if(!r_lpf_coef_wreq) begin
        r_lpf_coef_wreq <= 1'b1;
    end
    else if(s_axis_reload_tready)begin
        r_lpf_coef_wreq <= 1'b0;
    end
    else begin
        r_lpf_coef_wreq <= r_lpf_coef_wreq;
    end
    //===========
    r_lpf_coef_wreq_d1  <= r_lpf_coef_wreq;
end

always @(posedge i_clk_250)
begin
    if(!r_lpf_coef_wreq_d1 & r_lpf_coef_wreq)
        r_lpf_coef_wreq_pulse   <= 1'b1;
    else
        r_lpf_coef_wreq_pulse   <= 1'b0;
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_req_cnt  <= 'd0;
    end
    else if(!r_uart_rx_en_d0 & r_uart_rx_en) begin
        r_lpf_coef_req_cnt  <= 'd0;
    end
    else if(r_lpf_coef_data_vld_d0)begin
        r_lpf_coef_req_cnt  <= r_lpf_coef_req_cnt + 'd1;
    end
    else begin
        r_lpf_coef_req_cnt  <= r_lpf_coef_req_cnt;
    end
end

always @(posedge i_clk_250)
begin
    r_lpf_coef_data_vld_d0  <= i_lpf_coef_data_vld & r_lpf_coef_en  ;
end
//===============================================================
// Processing across clock domains
//===============================================================
always @(posedge i_clk_250)
begin
    r_lpf_coef_data_len_d0  <= r_lpf_coef_data_len   ;
    r_lpf_coef_data_len_d1  <= r_lpf_coef_data_len_d0;
    r_lpf_coef_data_len_d2  <= r_lpf_coef_data_len_d1;
end

always @(posedge i_clk_250)
begin
    r_lpf_coef_data_vld_d1  <= r_lpf_coef_data_vld_d0 ;
    r_lpf_coef_data_vld_d2  <= r_lpf_coef_data_vld_d1 ;
    r_lpf_coef_data_vld_d3  <= r_lpf_coef_data_vld_d2 ;
    
    r_lpf_coef_data_d0      <= i_lpf_coef_data    ;
    r_lpf_coef_data_d1      <= r_lpf_coef_data_d0 ;
    r_lpf_coef_data_d2      <= r_lpf_coef_data_d1 ;
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_data_vld     <= 'd0;
        r_lpf_coef_data         <= 'd0;
    end else if(!r_lpf_coef_data_vld_d3 & r_lpf_coef_data_vld_d2) begin
        r_lpf_coef_data_vld     <= 1'b1;
        r_lpf_coef_data         <= r_lpf_coef_data_d2;
    end
    else if(s_axis_reload_tready==1'b1) begin
        r_lpf_coef_data_vld     <= 1'b0;
    end
    else begin
        r_lpf_coef_data_vld     <= r_lpf_coef_data_vld ;
        r_lpf_coef_data         <= r_lpf_coef_data     ;
    end
end

always @(posedge i_clk_250)
begin
    if(!r_lpf_coef_en) begin
        r_lpf_coef_data_cnt <= 'd0;
    end
    else if(!r_lpf_coef_data_vld_d3 & r_lpf_coef_data_vld_d2) begin
        if(r_lpf_coef_data_cnt >= r_lpf_coef_data_len_d2)
            r_lpf_coef_data_cnt <= 'd0;
        else
            r_lpf_coef_data_cnt <= r_lpf_coef_data_cnt + 'd1;
    end
    else begin
        r_lpf_coef_data_cnt     <= r_lpf_coef_data_cnt     ;
    end
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_data_last     <= 1'b0;
    end else if((!r_lpf_coef_data_vld_d3 & r_lpf_coef_data_vld_d2) && (r_lpf_coef_data_cnt == (r_lpf_coef_data_len_d2-1))) begin
        r_lpf_coef_data_last     <= 1'b1;
    end
    else if(s_axis_reload_tready==1'b1) begin
        r_lpf_coef_data_last     <= 1'b0;
    end
    else begin
        r_lpf_coef_data_last     <= r_lpf_coef_data_last ;
    end
end

always @(posedge i_clk_250)
begin
    r_lpf_coef_data_last_d0 <= r_lpf_coef_data_last;
    r_lpf_coef_data_last_d1 <= r_lpf_coef_data_last_d0;
end

always @(posedge i_clk_250 or posedge i_rst)
begin
    if(i_rst) begin
        r_lpf_coef_data_sync     <= 1'b0;
    end else if(!r_lpf_coef_data_last_d0 & r_lpf_coef_data_last_d1) begin
        r_lpf_coef_data_sync     <= 1'b1;
    end
    else if(s_axis_config_tready==1'b1) begin
        r_lpf_coef_data_sync     <= 1'b0;
    end
    else begin
        r_lpf_coef_data_sync     <= r_lpf_coef_data_sync ;
    end
end
//===============================================================
/*
ila_1 ila_lpf (
    .clk    (i_clk_250),
    .probe0 ({
                 r_uart_rx_en         
                ,r_uart_rx_addr       
                ,r_uart_rx_data_length[7:0]
                ,r_bpf_coef_en
                ,i_bpf_coef_data_vld
                ,s_axis_reload_tready
                ,s_axis_reload_tvalid
                ,s_axis_reload_tlast 
                ,s_axis_reload_tdata 
                ,s_axis_data_tvalid
                ,s_axis_data_tdata[63:32] 
                ,s_axis_data_tuser 
                ,s_axis_data_tdata[31:0]
                ,m_axis_data_tvalid
                ,m_axis_data_tdata[79:40]
                ,m_axis_data_tuser
                ,m_axis_data_tdata[39:0]
            })
);
*/
/* ila_1 ila_lpf (
    .clk    (i_clk_250),
    .probe0 ({
			i_adc0_demod_data[63:32],
			i_adc0_demod_vld,
			i_adc0_demod_data[31:0],
			i_sys_start,
			
			o_adc0_lpf_data[63:32],
			o_adc0_lpf_vld,
			o_adc0_lpf_data[31:0]
			})
);			
 */

endmodule
