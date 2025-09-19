`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/28 10:51:49
// Design Name: 
// Module Name: Decor_Calib
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


module Decor_Calib(
    input           i_clk                   ,
    input           i_rst                   ,
    
    input           i_sys_start             ,
    output          o_sys_start             ,
    
    input           i_calib_en              ,
    
    //output  [31:0]  o_adc0_mean             ,	//从SPI发来
    //output  [31:0]  o_adc1_mean             ,
    
    // adc original data
    input           i_adc0_lpf_vld          ,
    input   [63:0]  i_adc0_lpf_data         ,
    
    input           i_adc1_lpf_vld          ,
    input   [63:0]  i_adc1_lpf_data         ,
    
    // adc calib data
    output          o_adc0_calib_vld        ,
    output  [63:0]  o_adc0_calib_data       ,
    
    output          o_adc1_calib_vld        ,
    output  [63:0]  o_adc1_calib_data       ,
	//SPI DATA
	input [31:0] 	m1a00					, //a
	input [31:0] 	m1a01					, //b
	input [31:0] 	m1a10					, //c
	input [31:0] 	m1a11					, //d
	
	
    //stream data uart rx
    input           i_uart_rx_en            ,
    input   [7 :0]  i_uart_rx_addr          ,
    input   [15:0]  i_uart_rx_frame_num     ,
    input   [15:0]  i_uart_rx_data_length   ,
    output          o_calib_coef_req        ,
    input           i_calib_coef_data_vld   ,
    input   [15:0]  i_calib_coef_data       
);
//========================================================================
reg                 r_uart_rx_en            ;
reg     [7 :0]      r_uart_rx_addr          ;
reg     [15:0]      r_uart_rx_frame_num     ;
reg     [15:0]      r_uart_rx_data_length   ;
reg                 r_calib_coef_data_vld   ;
reg     [15:0]      r_calib_coef_data       ;

reg                 r_uart_rx_en_d0         ;

reg     [15:0]      r_calib_coef_frame_num  ;
reg     [15:0]      r_calib_coef_data_len   ;
reg                 r_calib_coef_en         ;
reg                 r_calib_coef_wreq       ;

reg                 r_calib_coef_en_d0      ;
reg     [15:0]      r_calib_coef_req_cnt    ;
reg     [ 3:0]      r_calib_wr_addr         ;

reg                 r_calib_en              ;

reg                 r_adc0_lpf_vld_d0           ;
reg     [63:0]      r_adc0_lpf_data_d0          ;
reg                 r_adc1_lpf_vld_d0           ;
reg     [63:0]      r_adc1_lpf_data_d0          ;

reg                 r_adc0_lpf_vld_d1           ;
reg                 r_adc1_lpf_vld_d1           ;
reg                 r_adc0_lpf_vld_d2           ;
reg                 r_adc1_lpf_vld_d2           ;
reg                 r_adc0_lpf_vld_d3           ;
reg                 r_adc1_lpf_vld_d3           ;
reg                 r_adc0_lpf_vld_d4           ;
reg                 r_adc1_lpf_vld_d4           ;
reg                 r_adc0_lpf_vld_d5           ;
reg                 r_adc1_lpf_vld_d5           ;

reg                 r_sys_start_d0          ;
reg                 r_sys_start_d1          ;
reg                 r_sys_start_d2          ;
reg                 r_sys_start_d3          ;
reg                 r_sys_start_d4          ;
reg                 r_sys_start_d5          ;
reg                 r_sys_start_d6          ;

reg     [15:0]      r_decor_00_i            ;
reg     [15:0]      r_decor_00_q            ;
reg     [15:0]      r_decor_01_i            ;
reg     [15:0]      r_decor_01_q            ;
reg     [15:0]      r_decor_10_i            ;
reg     [15:0]      r_decor_10_q            ;
reg     [15:0]      r_decor_11_i            ;
reg     [15:0]      r_decor_11_q            ;

reg     [31:0]      r_adc0_mean             ;
reg     [31:0]      r_adc1_mean             ;

reg                 r_adc0_calib_vld        ;
reg     [31:0]      r_adc0_calib_i          ;
reg     [31:0]      r_adc0_calib_q          ;
reg                 r_adc1_calib_vld        ;
reg     [31:0]      r_adc1_calib_i          ;
reg     [31:0]      r_adc1_calib_q          ;

wire    [63:0]      m0a00,m0a10             ;

wire    [97:0]      p0a00_add0,p0a00_add1,p0a10_add0,p0a10_add1;
reg     [49:0]      p0a00_i,p0a00_q,p0a10_i,p0a10_q;
//========================================================================
always@(posedge i_clk)
begin
    r_calib_en  <= i_calib_en;
end

always@(posedge i_clk)
begin
    if(r_calib_en == 1'b0) begin
        r_decor_00_i  <= 16'd32767;
        r_decor_00_q  <= 16'd0; 
        r_decor_01_i  <= 16'd0; 
        r_decor_01_q  <= 16'd0; 
        r_decor_10_i  <= 16'd0;
        r_decor_10_q  <= 16'd0; 
        r_decor_11_i  <= 16'd32767;
        r_decor_11_q  <= 16'd0;
        
        r_adc0_mean   <= 32'd0;
        r_adc1_mean   <= 32'd0;
    end
    else if(r_calib_coef_data_vld) begin
        case(r_calib_wr_addr[3:0])
            4'd0: r_decor_00_i  <=  r_calib_coef_data;
            4'd1: r_decor_00_q  <=  r_calib_coef_data;
            4'd2: r_decor_01_i  <=  r_calib_coef_data;
            4'd3: r_decor_01_q  <=  r_calib_coef_data;
            4'd4: r_decor_10_i  <=  r_calib_coef_data;
            4'd5: r_decor_10_q  <=  r_calib_coef_data;
            4'd6: r_decor_11_i  <=  r_calib_coef_data;
            4'd7: r_decor_11_q  <=  r_calib_coef_data;
            
            4'd8: r_adc0_mean[15:0]   <=  r_calib_coef_data;
            4'd9: r_adc0_mean[31:16]   <=  r_calib_coef_data;
            4'd10: r_adc1_mean[15:0]   <=  r_calib_coef_data;
            4'd11: r_adc1_mean[31:16]  <=  r_calib_coef_data;
            default:;
        endcase
    end
    else begin
        r_decor_00_i  <=  r_decor_00_i;
        r_decor_00_q  <=  r_decor_00_q;
        r_decor_01_i  <=  r_decor_01_i;
        r_decor_01_q  <=  r_decor_01_q;
        r_decor_10_i  <=  r_decor_10_i;
        r_decor_10_q  <=  r_decor_10_q;
        r_decor_11_i  <=  r_decor_11_i;
        r_decor_11_q  <=  r_decor_11_q;
        
        r_adc0_mean   <=  r_adc0_mean ;
        r_adc1_mean   <=  r_adc1_mean ;
    end
end

assign m0a00 = r_adc0_lpf_data_d0;
assign m0a10 = r_adc1_lpf_data_d0;

//assign m1a00 = {r_decor_00_i,r_decor_00_q};
//assign m1a01 = {r_decor_01_i,r_decor_01_q};
//assign m1a10 = {r_decor_10_i,r_decor_10_q};
//assign m1a11 = {r_decor_11_i,r_decor_11_q};

complex_mult#(.DEBUG ("NO "))complex_mult0(i_clk, m1a00, m0a00, p0a00_add0); //a, V (Vi ,Vq)  ADC0_V
complex_mult#(.DEBUG ("NO "))complex_mult1(i_clk, m1a01, m0a10, p0a00_add1); //b  I (Ii ,Iq)  ADC1_I
complex_mult#(.DEBUG ("NO "))complex_mult2(i_clk, m1a10, m0a00, p0a10_add0); //c  V (Vi ,Vq)  ADC0_V
complex_mult#(.DEBUG ("NO "))complex_mult3(i_clk, m1a11, m0a10, p0a10_add1); //d  I (Ii ,Iq)  ADC1_I

always @(posedge i_clk)
begin            // a Vmi   +                              b Imi
    p0a00_i <= {p0a00_add0[97],p0a00_add0[97:49]} + {p0a00_add1[97],p0a00_add1[97:49]}; //Vti
    p0a00_q <= {p0a00_add0[48],p0a00_add0[48: 0]} + {p0a00_add1[48],p0a00_add1[48: 0]}; //Vtq
                 // a Vmq      +                           b Imq
				 // c Vmi     +                            d Imi
    p0a10_i <= {p0a10_add0[97],p0a10_add0[97:49]} + {p0a10_add1[97],p0a10_add1[97:49]}; //Iti
    p0a10_q <= {p0a10_add0[48],p0a10_add0[48: 0]} + {p0a10_add1[48],p0a10_add1[48: 0]}; //It
end
                 //  cVmq              +                   d Imq

always@(posedge i_clk)
begin
    if(p0a00_i[49]) begin
        if(&p0a00_i[48:46])//3bit           //补码
            r_adc0_calib_i  <= p0a00_i[46:15];
        else
            r_adc0_calib_i  <= 32'h80000001;
    end
    else begin
        if(|p0a00_i[48:46])
            r_adc0_calib_i  <= 32'h0fffffff;
        else
            r_adc0_calib_i  <= p0a00_i[46:15];
    end
end

always@(posedge i_clk)
begin
    if(p0a00_q[49]) begin
        if(&p0a00_q[48:46])
            r_adc0_calib_q  <= p0a00_q[46:15];
        else
            r_adc0_calib_q  <= 32'h80000001;
    end
    else begin
        if(|p0a00_q[48:46])
            r_adc0_calib_q  <= 32'h0fffffff;
        else
            r_adc0_calib_q  <= p0a00_q[46:15];
    end
end

always@(posedge i_clk)
begin
    if(p0a10_i[49]) begin
        if(&p0a10_i[48:46])
            r_adc1_calib_i  <= p0a10_i[46:15];
        else
            r_adc1_calib_i  <= 32'h80000001;
    end
    else begin
        if(|p0a10_i[48:46])
            r_adc1_calib_i  <= 32'h0fffffff;
        else
            r_adc1_calib_i  <= p0a10_i[46:15];
    end
end

always@(posedge i_clk)
begin
    if(p0a10_q[49]) begin
        if(&p0a10_q[48:46])
            r_adc1_calib_q  <= p0a10_q[46:15];
        else
            r_adc1_calib_q  <= 32'h80000001;
    end
    else begin
        if(|p0a10_q[48:46])
            r_adc1_calib_q  <= 32'h0fffffff;
        else
            r_adc1_calib_q  <= p0a10_q[46:15];
    end
end
//========================================================================

always@(posedge i_clk)
begin
    r_adc0_lpf_vld_d0   <= i_adc0_lpf_vld     ;
    r_adc0_lpf_data_d0  <= i_adc0_lpf_data    ;
    r_adc1_lpf_vld_d0   <= i_adc1_lpf_vld     ;
    r_adc1_lpf_data_d0  <= i_adc1_lpf_data    ;
    
    r_adc0_lpf_vld_d1   <= r_adc0_lpf_vld_d0  ;
    r_adc1_lpf_vld_d1   <= r_adc1_lpf_vld_d0  ;
    r_adc0_lpf_vld_d2   <= r_adc0_lpf_vld_d1  ;
    r_adc1_lpf_vld_d2   <= r_adc1_lpf_vld_d1  ;
    r_adc0_lpf_vld_d3   <= r_adc0_lpf_vld_d2  ;
    r_adc1_lpf_vld_d3   <= r_adc1_lpf_vld_d2  ;
    r_adc0_lpf_vld_d4   <= r_adc0_lpf_vld_d3  ;
    r_adc1_lpf_vld_d4   <= r_adc1_lpf_vld_d3  ;
    r_adc0_lpf_vld_d5   <= r_adc0_lpf_vld_d4  ;
    r_adc1_lpf_vld_d5   <= r_adc1_lpf_vld_d4  ;
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
end

always@(posedge i_clk)
begin
    r_adc0_calib_vld    <= r_adc0_lpf_vld_d5;
    r_adc1_calib_vld    <= r_adc1_lpf_vld_d5;
end


//========================================================================
assign o_calib_coef_req  = r_calib_coef_wreq ;

assign o_adc0_calib_vld  = r_adc0_calib_vld ;
assign o_adc0_calib_data = {r_adc0_calib_i,r_adc0_calib_q};
assign o_adc1_calib_vld  = r_adc1_calib_vld ;
assign o_adc1_calib_data = {r_adc1_calib_i,r_adc1_calib_q};

assign o_sys_start       = r_sys_start_d6;

assign o_adc0_mean = r_adc0_mean;
assign o_adc1_mean = r_adc1_mean;

//========================================================================
always @(posedge i_clk)
begin
    r_uart_rx_en            <= i_uart_rx_en         ;
    r_uart_rx_addr          <= i_uart_rx_addr       ;
    r_uart_rx_frame_num     <= i_uart_rx_frame_num  ;
    r_uart_rx_data_length   <= i_uart_rx_data_length;
    r_calib_coef_data_vld   <= i_calib_coef_data_vld & r_calib_coef_en;
    r_calib_coef_data       <= i_calib_coef_data    ;
end

always @(posedge i_clk)
begin
    r_uart_rx_en_d0 <= r_uart_rx_en;
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_calib_coef_frame_num    <= 'd0;
        r_calib_coef_data_len     <= 'd0;
        
        r_calib_coef_en           <= 'd0;
        
    end
    else if((!r_uart_rx_en_d0 & r_uart_rx_en) && (r_uart_rx_addr == 8'h02)) begin
        r_calib_coef_frame_num    <= r_uart_rx_frame_num;
        r_calib_coef_data_len     <= r_uart_rx_data_length;
        
        r_calib_coef_en           <= 1'b1;
    end
    else if(r_calib_coef_req_cnt >= r_calib_coef_data_len) begin
        r_calib_coef_en           <= 1'b0;
    end
    else begin
        r_calib_coef_frame_num    <= r_calib_coef_frame_num ;
        r_calib_coef_data_len     <= r_calib_coef_data_len  ;

        r_calib_coef_en           <= r_calib_coef_en        ;
    end
end

always @(posedge i_clk)
begin
    r_calib_coef_en_d0    <= r_calib_coef_en;
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_calib_coef_wreq <= 1'b0;
    end
    else if(!r_calib_coef_wreq & r_calib_coef_en) begin
        r_calib_coef_wreq <= 1'b1;
    end
    else begin
        r_calib_coef_wreq <= 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_calib_coef_req_cnt  <= 'd0;
    end
    else if(!r_uart_rx_en_d0 & r_uart_rx_en) begin
        r_calib_coef_req_cnt  <= 'd0;
    end
    else if(r_calib_coef_data_vld)begin
        r_calib_coef_req_cnt  <= r_calib_coef_req_cnt + 'd1;
    end
    else begin
        r_calib_coef_req_cnt  <= r_calib_coef_req_cnt;
    end
end
//========================================================================
always @(posedge i_clk or posedge i_rst)
begin
    if(i_rst) begin
        r_calib_wr_addr   <= 'd0;
    end
    else if((!r_calib_coef_en_d0 & r_calib_coef_en) && (r_calib_coef_frame_num == 8'h00)) begin
        r_calib_wr_addr   <= 'd0;
    end
    else if(r_calib_coef_data_vld) begin
        r_calib_wr_addr   <= r_calib_wr_addr + 'd1;
    end
    else begin
        r_calib_wr_addr   <= r_calib_wr_addr;
    end
end

// ila_1 ila_calib (
    // .clk    (i_clk),
    // .probe0 ({
                 // r_sys_start_d0
                // ,r_calib_en
                // ,r_adc0_lpf_vld_d0 
                // ,o_sys_start  
                // ,o_adc0_calib_vld
                // ,r_adc0_lpf_data_d0
                // ,r_adc1_lpf_data_d0
                // ,p0a00_add0[97:49] 
                // ,p0a00_add1[97:49]         
                // ,p0a00_add0[48:0]       
                // ,p0a00_add1[48:0]     
                // ,p0a00_i
                // ,p0a00_q
                // ,p0a10_add0[97:49] 
                // ,p0a10_add1[97:49]         
                // ,p0a10_add0[48:0] 
                // ,p0a10_add1[48:0]       
                // ,r_adc0_calib_i
                // ,r_adc0_calib_q
                
                // ,r_calib_coef_data_vld
                // ,r_calib_coef_data   
                // ,r_calib_wr_addr  
            // })
// );
/*
ila_1 ila_calib (
    .clk    (i_clk),
    .probe0 ({
			i_adc0_lpf_data[63:32],
			i_adc0_lpf_vld,
			i_adc0_lpf_data[31:0],
			i_sys_start,
			
			o_adc0_calib_data[63:32],
			o_adc0_calib_vld,
			o_adc0_calib_data[31:0]
			})
);
*/

endmodule
