`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/19 10:20:19
// Design Name: 
// Module Name: adc_demod
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

module adc_demod(
    input           i_clk                   ,
    input           i_rst                   ,
    
    input   [15:0]  i_coef_len              ,
    
    input           i_sys_start             ,
    output          o_sys_start             ,
    input   [3:0]	RF_FREQ				    ,
	input   [31:0]	freq_data			    ,
    // adc bpf data
    input           i_adc0_vld              ,
    input   [63:0]  i_adc0_data             ,
    
    input           i_adc1_vld              ,
    input   [63:0]  i_adc1_data             ,
    
    // adc demod data
    output          o_adc0_demod_vld        ,
    output  [63:0]  o_adc0_demod_data       ,
    
    output          o_adc1_demod_vld        ,
    output  [63:0]  o_adc1_demod_data       ,
	output reg	[13:0]	r_demod_rd_addr	    ,
	//data SPI                              
	input 			i_demod_wr_en		    ,
	input   [14:0]	i_demod_wr_addr  	    ,    
	input   [31:0]	i_demod_wr_data 	    ,   
	
    //stream data uart rx
    input           i_uart_rx_en            ,
    input   [7 :0]  i_uart_rx_addr          ,
    input   [15:0]  i_uart_rx_frame_num     ,
    input   [15:0]  i_uart_rx_data_length   ,
    output          o_demod_coef_req        ,
    input           i_demod_coef_data_vld   ,
    input   [15:0]  i_demod_coef_data       ,
	input   [31:0]  i_demod_freq_coef        //spi设置电源功率频率解调计算�?
);
//========================================================================

reg                 r_uart_rx_en            ;
reg     [7 :0]      r_uart_rx_addr          ;
reg     [15:0]      r_uart_rx_frame_num     ;
reg     [15:0]      r_uart_rx_data_length   ;
reg                 r_demod_coef_data_vld   ;
reg     [15:0]      r_demod_coef_data       ;

reg                 r_uart_rx_en_d0         ;

reg     [15:0]      r_demod_coef_frame_num  ;
reg     [15:0]      r_demod_coef_data_len   ;
reg                 r_demod_coef_en         ;
reg                 r_demod_coef_wreq       ;

reg                 r_demod_coef_en_d0      ;

reg     [15:0]      r_demod_coef_req_cnt    ;

reg     [14:0]      r_demod_wr_addr         ;
//reg     [13:0]      r_demod_rd_addr = 14'd0 ;
wire     [31:0]      s_demod_rd_dout         ;

reg     [15:0]      r_coef_len_d0           ;

reg                 r_adc0_vld_d0           ;
reg     [63:0]      r_adc0_data_d0          ;
reg                 r_adc1_vld_d0           ;
reg     [63:0]      r_adc1_data_d0          ;

reg                 r_adc0_vld_d1           ;
reg     [63:0]      r_adc0_data_d1          ;
reg                 r_adc1_vld_d1           ;
reg     [63:0]      r_adc1_data_d1          ;

reg                 r_adc0_vld_d2           ;
reg     [63:0]      r_adc0_data_d2          ;
reg                 r_adc1_vld_d2           ;
reg     [63:0]      r_adc1_data_d2          ;

reg                 r_adc0_vld_d3           ;
reg     [63:0]      r_adc0_data_d3          ;
reg                 r_adc1_vld_d3           ;
reg     [63:0]      r_adc1_data_d3          ;

reg                 r_adc0_vld_d4           ;
reg                 r_adc1_vld_d4           ;
reg                 r_adc0_vld_d5           ;
reg                 r_adc1_vld_d5           ;
reg                 r_adc0_vld_d6           ;
reg                 r_adc1_vld_d6           ;
reg                 r_adc0_vld_d7           ;
reg                 r_adc1_vld_d7           ;

reg                 r_sys_start_d0          ;
reg                 r_sys_start_d1          ;
reg                 r_sys_start_d2          ;
reg                 r_sys_start_d3          ;
reg                 r_sys_start_d4          ;
reg                 r_sys_start_d5          ;
reg                 r_sys_start_d6          ;
reg                 r_sys_start_d7          ;
reg                 r_sys_start_d8          ;

reg     [15:0]      r_demod_coef_0_i        ;
reg     [15:0]      r_demod_coef_0_q        ;
reg     [15:0]      r_demod_coef_1_i        ;
reg     [15:0]      r_demod_coef_1_q        ;

wire    [97:0]      s_mult_demod0           ;
wire    [97:0]      s_mult_demod1           ;

wire    [48:0]      s_mult_demod0_i_p       ;
wire    [48:0]      s_mult_demod0_q_p       ;

wire    [48:0]      s_mult_demod1_i_p       ;
wire    [48:0]      s_mult_demod1_q_p       ;

reg                 r_adc0_demod_vld        ;
reg     [31:0]      r_adc0_demod_i          ;
reg     [31:0]      r_adc0_demod_q          ;
reg                 r_adc1_demod_vld        ;
reg     [31:0]      r_adc1_demod_i          ;
reg     [31:0]      r_adc1_demod_q          ;
wire 	[31 : 0] 	douta_2M				;
wire 	[31 : 0] 	douta_13p56M			;
wire 	[31 : 0] 	douta_60M				;

wire    [31:0]      power_freq_coef         ;

assign  power_freq_coef = i_demod_freq_coef ;
// adc_demod_coef_rom adc_demod_coef_rom (	//改成rom，固定校准序�?
  // .clka		(i_clk),    // input wire clka
  // .ena		(1'b1),      // input wire ena
  // .addra	(r_demod_rd_addr),  // input wire [11 : 0] addra
  // .douta	(douta_2M)  // output wire [31 : 0] douta
// );

// demod_rom_13p56M demod_rom_13p56M (
  // .clka		(i_clk),    // input wire clka
  // .ena		(1'b1),      // input wire ena
  // .addra	(r_demod_rd_addr),  // input wire [11 : 0] addra
  // .douta	(douta_13p56M)  // output wire [31 : 0] douta
// );

// demod_rom_60M demod_rom_60M (
  // .clka		(i_clk),    // input wire clka
  // .ena		(1'b1),      // input wire ena
  // .addra	(r_demod_rd_addr),  // input wire [11 : 0] addra
  // .douta	(douta_60M)  // output wire [31 : 0] douta
// );

demod_code	demod_code(
	.clk_i		(i_clk),
	.rst_i		(i_rst),
	//.freq_data	(58239757),	//(freq_data),	//固定13.56M  4.2949 * 13560000=58,238,844
    .freq_data	(power_freq_coef),	//(freq_data),	//固定13.56M
	.i			(r_demod_rd_addr),  //0-3124
	.dout		(s_demod_rd_dout)   //不同频率的正弦波
);

always@(posedge i_clk)
begin
    r_demod_coef_0_i    <= s_demod_rd_dout[31:16];//cos
    r_demod_coef_0_q    <= s_demod_rd_dout[15: 0];//sin 

    r_demod_coef_1_i    <= s_demod_rd_dout[31:16];//cos
    r_demod_coef_1_q    <= s_demod_rd_dout[15: 0];//sin 
end

always@(posedge i_clk)
begin
    r_coef_len_d0   <= i_coef_len ; //d3125
end

// always @(posedge i_clk or posedge i_rst)
    // if(i_rst)
		// s_demod_rd_dout <= douta_2M;
	// else case(RF_FREQ)
	// 0:	s_demod_rd_dout <= douta_2M;
	// 1:	s_demod_rd_dout <= douta_13p56M;
	
	// 4:	s_demod_rd_dout <= douta_60M;
	
	// default : s_demod_rd_dout <= douta_2M;
	// endcase 

complex_mult#(.DEBUG ("NO "))complex_mult0(i_clk, {r_demod_coef_0_i,r_demod_coef_0_q}, r_adc0_data_d3, s_mult_demod0); //s(t)=I(t)cos(2πfct)−Q(t)sin(2πfct)
complex_mult#(.DEBUG ("NO "))complex_mult1(i_clk, {r_demod_coef_1_i,r_demod_coef_1_q}, r_adc1_data_d3, s_mult_demod1);

assign s_mult_demod0_i_p = s_mult_demod0[97:49];
assign s_mult_demod0_q_p = s_mult_demod0[48: 0];

assign s_mult_demod1_i_p = s_mult_demod1[97:49];
assign s_mult_demod1_q_p = s_mult_demod1[48: 0];

//========================================================================
always @(posedge i_clk)
begin
    r_uart_rx_en            <= i_uart_rx_en         ;
    r_uart_rx_addr          <= i_uart_rx_addr       ;
    r_uart_rx_frame_num     <= i_uart_rx_frame_num  ;
    r_uart_rx_data_length   <= i_uart_rx_data_length;
    r_demod_coef_data_vld   <= i_demod_coef_data_vld & r_demod_coef_en;
    r_demod_coef_data       <= i_demod_coef_data    ;
end

always @(posedge i_clk)
begin
    r_uart_rx_en_d0 <= r_uart_rx_en;
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_demod_coef_frame_num    <= 'd0;
        r_demod_coef_data_len     <= 'd0;
        
        r_demod_coef_en           <= 'd0;
        
    end
    else if((!r_uart_rx_en_d0 & r_uart_rx_en) && (r_uart_rx_addr == 8'h04)) begin
        r_demod_coef_frame_num    <= r_uart_rx_frame_num;
        r_demod_coef_data_len     <= r_uart_rx_data_length;
        
        r_demod_coef_en           <= 1'b1;
    end
    else if(r_demod_coef_req_cnt >= r_demod_coef_data_len) begin
        r_demod_coef_en           <= 1'b0;
    end
    else begin
        r_demod_coef_frame_num    <= r_demod_coef_frame_num ;
        r_demod_coef_data_len     <= r_demod_coef_data_len  ;

        r_demod_coef_en           <= r_demod_coef_en        ;
    end
end

always @(posedge i_clk)
begin
    r_demod_coef_en_d0    <= r_demod_coef_en;
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_demod_coef_wreq <= 1'b0;
    end
    else if(!r_demod_coef_wreq & r_demod_coef_en) begin
        r_demod_coef_wreq <= 1'b1;
    end
    else begin
        r_demod_coef_wreq <= 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_demod_coef_req_cnt  <= 'd0;
    end
    else if(!r_uart_rx_en_d0 & r_uart_rx_en) begin
        r_demod_coef_req_cnt  <= 'd0;
    end
    else if(r_demod_coef_data_vld)begin
        r_demod_coef_req_cnt  <= r_demod_coef_req_cnt + 'd1;
    end
    else begin
        r_demod_coef_req_cnt  <= r_demod_coef_req_cnt;
    end
end
//========================================================================
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_demod_wr_addr   <= 'd0;
    end
    else if((!r_demod_coef_en_d0 & r_demod_coef_en) && (r_demod_coef_frame_num == 8'h00)) begin
        r_demod_wr_addr   <= 'd0;
    end
    else if(r_demod_coef_data_vld) begin
        r_demod_wr_addr   <= r_demod_wr_addr + 'd1;
    end
    else begin
        r_demod_wr_addr   <= r_demod_wr_addr;
    end
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst)
        r_demod_rd_addr <= 'd0;
    else if(i_sys_start) begin
        r_demod_rd_addr <= 'd0;
    end
    else if(i_adc0_vld | i_adc1_vld) begin
        if(r_demod_rd_addr >= (r_coef_len_d0-1'd1)) begin //d3125
            r_demod_rd_addr <= 'd0;
        end
        else begin
            r_demod_rd_addr <= r_demod_rd_addr + 1'b1;
        end
    end
    else begin
        r_demod_rd_addr <= r_demod_rd_addr;
    end
end
//========================================================================

always@(posedge i_clk)
begin
    r_adc0_vld_d0   <= i_adc0_vld     ;
    r_adc0_data_d0  <= i_adc0_data    ;
    r_adc1_vld_d0   <= i_adc1_vld     ;
    r_adc1_data_d0  <= i_adc1_data    ;
    
    r_adc0_vld_d1   <= r_adc0_vld_d0  ;
    r_adc0_data_d1  <= r_adc0_data_d0 ;
    r_adc1_vld_d1   <= r_adc1_vld_d0  ;
    r_adc1_data_d1  <= r_adc1_data_d0 ;
    
    r_adc0_vld_d2   <= r_adc0_vld_d1  ;
    r_adc0_data_d2  <= r_adc0_data_d1 ;
    r_adc1_vld_d2   <= r_adc1_vld_d1  ;
    r_adc1_data_d2  <= r_adc1_data_d1 ;
    
    r_adc0_vld_d3   <= r_adc0_vld_d2  ;
    r_adc0_data_d3  <= r_adc0_data_d2 ;
    r_adc1_vld_d3   <= r_adc1_vld_d2  ;
    r_adc1_data_d3  <= r_adc1_data_d2 ;
    
    r_adc0_vld_d4   <= r_adc0_vld_d3  ;
    r_adc1_vld_d4   <= r_adc1_vld_d3  ;
    r_adc0_vld_d5   <= r_adc0_vld_d4  ;
    r_adc1_vld_d5   <= r_adc1_vld_d4  ;
    r_adc0_vld_d6   <= r_adc0_vld_d5  ;
    r_adc1_vld_d6   <= r_adc1_vld_d5  ;
    r_adc0_vld_d7   <= r_adc0_vld_d6  ;
    r_adc1_vld_d7   <= r_adc1_vld_d6  ;
end

always@(posedge i_clk)
begin
    r_sys_start_d0  <= i_sys_start    ;
    r_sys_start_d1  <= r_sys_start_d0 ;
    r_sys_start_d2  <= r_sys_start_d1 ;
    r_sys_start_d3  <= r_sys_start_d2 ;
    r_sys_start_d4  <= r_sys_start_d3 ;
    r_sys_start_d5  <= r_sys_start_d4 ;
    r_sys_start_d6  <= r_sys_start_d5 ;
    r_sys_start_d7  <= r_sys_start_d6 ;
    r_sys_start_d8  <= r_sys_start_d7 ;
end

always@(posedge i_clk)
begin
    r_adc0_demod_vld    <= r_adc0_vld_d7;
    r_adc1_demod_vld    <= r_adc1_vld_d7;
end

always@(posedge i_clk)
begin
    if(s_mult_demod0_i_p[48]) begin
        if(&s_mult_demod0_i_p[47:46])
            r_adc0_demod_i  <= s_mult_demod0_i_p[46:15];
        else
            r_adc0_demod_i  <= 32'h80000001;
    end
    else begin
        if(|s_mult_demod0_i_p[47:46])
            r_adc0_demod_i  <= 32'h0fffffff;
        else
            r_adc0_demod_i  <= s_mult_demod0_i_p[46:15];
    end
end

always@(posedge i_clk)
begin
    if(s_mult_demod0_q_p[48]) begin
        if(&s_mult_demod0_q_p[47:46])
            r_adc0_demod_q  <= s_mult_demod0_q_p[46:15];
        else
            r_adc0_demod_q  <= 32'h80000001;
    end
    else begin
        if(|s_mult_demod0_q_p[47:46])
            r_adc0_demod_q  <= 32'h0fffffff;
        else
            r_adc0_demod_q  <= s_mult_demod0_q_p[46:15];
    end
end

always@(posedge i_clk)
begin
    if(s_mult_demod1_i_p[48]) begin
        if(&s_mult_demod1_i_p[47:46])
            r_adc1_demod_i  <= s_mult_demod1_i_p[46:15];
        else
            r_adc1_demod_i  <= 32'h80000001;
    end
    else begin
        if(|s_mult_demod1_i_p[47:46])
            r_adc1_demod_i  <= 32'h0fffffff;
        else
            r_adc1_demod_i  <= s_mult_demod1_i_p[46:15];
    end
end

always@(posedge i_clk)
begin
    if(s_mult_demod1_q_p[48]) begin
        if(&s_mult_demod1_q_p[47:46])
            r_adc1_demod_q  <= s_mult_demod1_q_p[46:15];
        else
            r_adc1_demod_q  <= 32'h80000001;
    end
    else begin
        if(|s_mult_demod1_q_p[47:46])
            r_adc1_demod_q  <= 32'h0fffffff;
        else
            r_adc1_demod_q  <= s_mult_demod1_q_p[46:15];
    end
end

//=====================================================================================================================
assign o_demod_coef_req  = r_demod_coef_wreq ;

assign o_adc0_demod_vld  = r_adc0_demod_vld ;
assign o_adc0_demod_data = {r_adc0_demod_i,r_adc0_demod_q};
assign o_adc1_demod_vld  = r_adc1_demod_vld ;
assign o_adc1_demod_data = {r_adc1_demod_i,r_adc1_demod_q};

assign o_sys_start       = r_sys_start_d8;
//======================================================================================================================
/*
    wire    [63:0]      cordic_dat0_in          ;
    wire                cordic_q0_val           ;
    wire    [63:0]      cordic_q0               ;

    wire    [63:0]      cordic_dat1_in          ;
    wire                cordic_q1_val           ;
    wire    [63:0]      cordic_q1               ;

    reg                 r_mod_dat0_vld          ;
    reg                 r_mod_dat0_vld_d0       ;
    reg     [15:0]      r_mod_dat0              ;
    reg     [15:0]      r_mod_dat0_d0           ;

    reg                 r_mod_dat1_vld          ;
    reg                 r_mod_dat1_vld_d0       ;
    reg     [15:0]      r_mod_dat1              ;
    reg     [15:0]      r_mod_dat1_d0           ;

    wire                s_sys_start_sync        ;
    reg                 r_sys_start_sync_d0     ;
    reg                 r_sys_start_sync_d1     ;
    //===================================================================

    assign cordic_dat0_in = {r_adc0_demod_i,r_adc0_demod_q};
    assign cordic_dat1_in = {r_adc1_demod_i,r_adc1_demod_q};

    adc_demod_cordic adc_demod_cordic_inst0 (      // latency: 40 clock
    .aclk                     ( i_clk               ),    // input wire aclk
    .s_axis_cartesian_tvalid  ( r_adc0_demod_vld    ),    // input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata   ( cordic_dat0_in      ),    // input wire [63 : 0] s_axis_cartesian_tdata
    .s_axis_cartesian_tuser   ( r_sys_start_d4      ),    // input [0:0]s_axis_cartesian_tuser
    .m_axis_dout_tvalid       ( cordic_q0_val       ),    // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata        ( cordic_q0           ),    // output wire [63 : 0] m_axis_dout_tdata
    .m_axis_dout_tuser        ( s_sys_start_sync    )     // output [0:0]m_axis_dout_tuser
    );
    
    adc_demod_cordic adc_demod_cordic_inst1 (      // latency: 40 clock
    .aclk                     ( i_clk               ),    // input wire aclk
    .s_axis_cartesian_tvalid  ( r_adc1_demod_vld    ),    // input wire s_axis_cartesian_tvalid
    .s_axis_cartesian_tdata   ( cordic_dat1_in      ),    // input wire [63 : 0] s_axis_cartesian_tdata
    .s_axis_cartesian_tuser   ( r_sys_start_d4      ),    // input [0:0]s_axis_cartesian_tuser
    .m_axis_dout_tvalid       ( cordic_q1_val       ),    // output wire m_axis_dout_tvalid
    .m_axis_dout_tdata        ( cordic_q1           ),    // output wire [63 : 0] m_axis_dout_tdata
    .m_axis_dout_tuser        (                     )     // output [0:0]m_axis_dout_tuser
    );

    //-----------------------------------------------------------------------------
    //                      calculate the mod data : 18bit now
    //-----------------------------------------------------------------------------
    always @ (posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_mod_dat0 <= 32'h1;
    else if(cordic_q0[31] == 1'b1)
        r_mod_dat0 <= 16'h7fff;
    else 
        r_mod_dat0 <= cordic_q0[30:15];
    end

    always @ (posedge i_clk or posedge i_rst) begin
    if(i_rst)
        r_mod_dat1 <= 32'h1;
    else if(cordic_q1[31] == 1'b1)
        r_mod_dat1 <= 16'h7fff;
    else 
        r_mod_dat1 <= cordic_q1[30:15];
    end

    always @ (posedge i_clk ) begin
        r_mod_dat0_d0 <= r_mod_dat0;
        r_mod_dat1_d0 <= r_mod_dat1;
    end

    always @ (posedge i_clk ) begin
        r_mod_dat0_vld  <= cordic_q0_val ;
        r_mod_dat1_vld  <= cordic_q1_val ;
    end

    always @ (posedge i_clk ) begin
        r_mod_dat0_vld_d0  <= r_mod_dat0_vld ;
        r_mod_dat1_vld_d0  <= r_mod_dat1_vld ;
    end

    always @ (posedge i_clk ) begin
        r_sys_start_sync_d0 <= s_sys_start_sync    ;
        r_sys_start_sync_d1 <= r_sys_start_sync_d0 ;
    end
    */

    //===========================================================================
    /*
    ila_1 ila_demod (
        .clk    (i_clk),
        .probe0 ({
                i_adc0_data[63:32],
                i_adc0_vld,
                i_adc0_data[31:0],
                i_sys_start,
                
                o_adc0_demod_data[63:32],
                o_adc0_demod_vld,
                o_adc0_demod_data[31:0]
                })
    );	
*/

endmodule
