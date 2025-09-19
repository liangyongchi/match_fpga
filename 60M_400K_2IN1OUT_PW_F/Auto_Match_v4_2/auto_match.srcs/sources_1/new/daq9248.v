`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/12 14:35:08
// Design Name: 
// Module Name: daq9248_test
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

module daq9248(
    input  wire        i_clk_62p5       ,
    input  wire        i_clk_250        ,
    input  wire        i_rst_62p5       ,
    
    //input  wire        i_test_mode_en   ,
    input  wire [31:0] i_adc0_mean      ,
    input  wire [31:0] i_adc1_mean      ,
    
    output reg         o_sys_start      ,
    //input  wire [13:0] i_dac_din_a      ,
    //input  wire [13:0] i_dac_din_b      ,
    
    //output wire        o_card_power_en  ,
    
    //output wire        o_ad9248_clka    ,
    //input  wire        i_ad9248_ora     ,
	input 			   vld				,
    input  wire [13:0] i_ad9248_da      ,	//AD9643数据
    input  wire [13:0] i_ad9248_db      ,	//AD9643数据
	
	output             m_axis_i_tvalid  ,
	output [31:0]      m_axis_i_tdata   ,
    
    output reg         o_ad9248_da_vld  ,
    output reg  [31:0] o_ad9248_da      ,
    output reg         o_ad9248_db_vld  ,
    output reg  [31:0] o_ad9248_db  
);
//==================================================================================
reg 				vld_d0,vld_d1;
reg  [13:0]         r_ad9248_da_d0          ;
reg  [13:0]         r_ad9248_da_d1          ;

reg  [13:0]         r_ad9248_db_d0          ;
reg  [13:0]         r_ad9248_db_d1          ;

reg                 r_sys_start_d0          ;
reg                 r_sys_start_d1          ;

reg                 r_test_mode_en_d0       ;
reg                 r_test_mode_en_d1       ;

reg                 r_ad9248_da_vld         ;
reg  [15:0]         r_ad9248_da             ;
reg                 r_ad9248_db_vld         ;
reg  [15:0]         r_ad9248_db             ;
reg                 r_sys_start             ;

reg                 O_sys_start_adc         ;
reg                 adc_valid               ;
//reg                 adc_valid_d0            ;


wire                s_axis_i_tvalid         ;
wire                s_axis_i_tready         ;
wire [31:0]         s_axis_i_tdata          ;
wire [0:0]          s_axis_i_tuser          ;
wire                m_axis_i_tready         ;
//wire                m_axis_i_tvalid         ;
//wire [31:0]         m_axis_i_tdata          ;
wire [0:0]          m_axis_i_tuser          ;

reg [31:0] 	i_adc0_mean_r0,i_adc0_mean_r1      ;
reg [31:0] 	i_adc1_mean_r0,i_adc1_mean_r1      ;


//==================================================================================
adc_sync_fifo sync_fifo_in_inst(
    .s_aclk                 ( i_clk_62p5              ),
    .s_aresetn              ( ~i_rst_62p5             ), 
    .s_axis_tvalid          ( s_axis_i_tvalid         ),
    .s_axis_tready          ( s_axis_i_tready         ),
    .s_axis_tdata           ( s_axis_i_tdata          ),
    .s_axis_tuser           ( s_axis_i_tuser          ),
    .m_aclk                 ( i_clk_250               ),
    .m_axis_tvalid          ( m_axis_i_tvalid         ),
    .m_axis_tready          ( m_axis_i_tready         ),
    .m_axis_tdata           ( m_axis_i_tdata          ),
    .m_axis_tuser           ( m_axis_i_tuser          )
);

assign s_axis_i_tvalid      = s_axis_i_tready & vld_d1;	
assign s_axis_i_tdata       = {{{2{r_ad9248_da_d1[13]}},r_ad9248_da_d1},{{2{r_ad9248_db_d1[13]}},r_ad9248_db_d1}};
assign s_axis_i_tuser       = O_sys_start_adc;
assign m_axis_i_tready      = 1'b1;

assign s_axis_data_tvalid   = m_axis_i_tvalid;
assign s_axis_data_tuser    = m_axis_i_tuser;
assign s_axis_data_tdata    = m_axis_i_tdata;

//==================================================================================
//assign o_card_power_en = 1'b1;
assign o_ad9248_clka   = i_clk_62p5;
assign o_ad9248_clkb   = i_clk_62p5;

reg [11:0]	start_cnt;
always @(posedge i_clk_62p5 or posedge i_rst_62p5)
	if(i_rst_62p5)
		start_cnt <= 0;
	else if(start_cnt == 'd3124)
		start_cnt <= 0;
	else 
		start_cnt <= start_cnt+1;

always @(posedge i_clk_62p5 or posedge i_rst_62p5)
	if(i_rst_62p5)		
		O_sys_start_adc <= 0;
	else if(start_cnt == 'd3124)
		O_sys_start_adc <= 1;
	else 
		O_sys_start_adc <= 0;

always@(posedge i_clk_62p5)
begin
    r_sys_start_d0  <= O_sys_start_adc  ;
    r_sys_start_d1  <= r_sys_start_d0   ;
	
	i_adc0_mean_r0 <= i_adc0_mean;
	i_adc1_mean_r0 <= i_adc1_mean;
	i_adc0_mean_r1 <= i_adc0_mean_r0;
	i_adc1_mean_r1 <= i_adc1_mean_r0;
end

//always@(posedge i_clk_62p5)
//begin
//    r_test_mode_en_d0  <= i_test_mode_en    ;
//    r_test_mode_en_d1  <= r_test_mode_en_d0 ;
//end

always@(posedge i_clk_62p5)
begin
    //r_ad9248_da_d0 <= r_test_mode_en_d1 ? i_dac_din_a : i_ad9248_da;
    //r_ad9248_db_d0 <= r_test_mode_en_d1 ? i_dac_din_b : i_ad9248_db;
    //直接接到AD9643的数据
	vld_d1 <= vld;
    r_ad9248_da_d1 <= i_ad9248_da;	//r_ad9248_da_d0 - 14'd8192;
    r_ad9248_db_d1 <= i_ad9248_db;	//r_ad9248_db_d0 - 14'd8192;
end

always@(posedge i_clk_250)
begin
    r_ad9248_da_vld <= m_axis_i_tvalid;
    r_ad9248_da     <= m_axis_i_tdata[31:16];
    r_ad9248_db_vld <= m_axis_i_tvalid;
    r_ad9248_db     <= m_axis_i_tdata[15:0];
    r_sys_start     <= m_axis_i_tuser[0] & m_axis_i_tvalid;
end

always@(posedge i_clk_250)
begin
    o_ad9248_da_vld <= r_ad9248_da_vld;
    o_ad9248_da     <= {r_ad9248_da,16'd0} - i_adc0_mean_r1   ;
    o_ad9248_db_vld <= r_ad9248_db_vld;
    o_ad9248_db     <= {r_ad9248_db,16'd0} - i_adc1_mean_r1   ;
    o_sys_start     <= r_sys_start    ;
end

//=========================================================================================

endmodule
