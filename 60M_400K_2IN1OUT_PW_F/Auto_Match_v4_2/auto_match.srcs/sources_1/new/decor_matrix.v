`timescale 1ns / 1ps

module Decor_matrix(
    input             i_clk                   ,
    input             i_rst                   ,					  
    // adc original data
    input             i_adc0_lpf_vld          ,
    input   [63:0]    i_adc0_lpf_data         ,
					  
    input             i_adc1_lpf_vld          ,
    input   [63:0]    i_adc1_lpf_data         ,
    
    // adc calib data
    output            o_adc0_calib_vld        ,
    output  [63:0]    o_adc0_calib_data       ,
					  
    output            o_adc1_calib_vld        ,
    output  [63:0]    o_adc1_calib_data       ,
	//SPI DATA
	input [31:0] 	  m1a00					  , //a
	input [31:0] 	  m1a01					  , //b
	input [31:0] 	  m1a10					  , //c
	input [31:0] 	  m1a11					    //d

);                     
//========================================================================

reg                 r_adc0_lpf_vld_d0           ;
reg     [63:0]      r_adc0_lpf_data_d0          ;
reg                 r_adc1_lpf_vld_d0           ;
reg     [63:0]      r_adc1_lpf_data_d0          ;


reg     [63:0]      r1_adc0_lpf_data_d0          ;
reg     [63:0]      r1_adc1_lpf_data_d0          ;


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


reg                 r_adc0_calib_vld        ;
reg     [31:0]      r_adc0_calib_i          ;
reg     [31:0]      r_adc0_calib_q          ;
reg                 r_adc1_calib_vld        ;
reg     [31:0]      r_adc1_calib_i          ;
reg     [31:0]      r_adc1_calib_q          ;


wire    [63:0]      m0a00,m0a10             ;

wire    [97:0]      p0a00_add0,p0a00_add1,p0a10_add0,p0a10_add1;
reg     [49:0]      p0a00_i,p0a00_q,p0a10_i,p0a10_q;

assign o_adc0_calib_vld  = r_adc0_calib_vld ;
assign o_adc0_calib_data = {r_adc0_calib_i,r_adc0_calib_q};

assign o_adc1_calib_vld  = r_adc1_calib_vld ;
assign o_adc1_calib_data = {r_adc1_calib_i,r_adc1_calib_q};
//========================================================================
always@(posedge i_clk)
begin
     if(i_adc0_lpf_vld)
	   r1_adc0_lpf_data_d0 <= i_adc0_lpf_data;
end

always@(posedge i_clk)
begin
     if(i_adc1_lpf_vld)
	   r1_adc1_lpf_data_d0 <= i_adc1_lpf_data;
end



assign m0a00 = r1_adc0_lpf_data_d0;
assign m0a10 = r1_adc1_lpf_data_d0;

                                             //16bit  32bit   
complex_mult#(.DEBUG ("NO "))complex_mult0(i_clk, m1a00, m0a00, p0a00_add0); //a V 
complex_mult#(.DEBUG ("NO "))complex_mult1(i_clk, m1a01, m0a10, p0a00_add1); //b I 
complex_mult#(.DEBUG ("NO "))complex_mult2(i_clk, m1a10, m0a00, p0a10_add0); //c V 
complex_mult#(.DEBUG ("NO "))complex_mult3(i_clk, m1a11, m0a10, p0a10_add1); //d I 49bit +49bit

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
    r_adc0_calib_vld    <= r_adc0_lpf_vld_d5;
    r_adc1_calib_vld    <= r_adc1_lpf_vld_d5;
end

always @(posedge i_clk)begin
if(i_rst)
  begin         
      p0a00_i <= 'd0; //Vt -> i ;49+1 //50bit
      p0a00_q <= 'd0; //Vt -> q ;
				 
      p0a10_i <= 'd0; //It -> i ;
      p0a10_q <= 'd0; //It -> q ;
  end
   
  else
  begin         //vt
      p0a00_i <= {p0a00_add0[97],p0a00_add0[97:49]} + {p0a00_add1[97],p0a00_add1[97:49]}; //Vt -> i ;49+1 //50bit
      p0a00_q <= {p0a00_add0[48],p0a00_add0[48: 0]} + {p0a00_add1[48],p0a00_add1[48: 0]}; //Vt -> q ;
               //It
      p0a10_i <= {p0a10_add0[97],p0a10_add0[97:49]} + {p0a10_add1[97],p0a10_add1[97:49]}; //It -> i ;
      p0a10_q <= {p0a10_add0[48],p0a10_add0[48: 0]} + {p0a10_add1[48],p0a10_add1[48: 0]}; //It -> q ;
  end
end
 
always@(posedge i_clk)
begin
    if(p0a00_i[49]) begin
        if(&p0a00_i[48:40])//3bit           //补码
            r_adc0_calib_i  <= p0a00_i[40:9];
        else
            r_adc0_calib_i  <= 32'h80000001;
    end
    else begin
        if(|p0a00_i[48:40])
            r_adc0_calib_i  <= 32'h0fffffff;
        else
            r_adc0_calib_i  <= p0a00_i[40:9];
    end
end

always@(posedge i_clk)
begin
    if(p0a00_q[49]) begin
        if(&p0a00_q[48:40])
            r_adc0_calib_q  <= p0a00_q[40:9];
        else
            r_adc0_calib_q  <= 32'h80000001;
    end
    else begin
        if(|p0a00_q[48:40])
            r_adc0_calib_q  <= 32'h0fffffff;
        else
            r_adc0_calib_q  <= p0a00_q[40:9];
    end
end

always@(posedge i_clk)
begin
    if(p0a10_i[49]) begin
        if(&p0a10_i[48:40])
            r_adc1_calib_i  <= p0a10_i[40:9];
        else
            r_adc1_calib_i  <= 32'h80000001;
    end
    else begin
        if(|p0a10_i[48:40])
            r_adc1_calib_i  <= 32'h0fffffff;
        else
            r_adc1_calib_i  <= p0a10_i[40:9];
    end
end

always@(posedge i_clk)
begin
    if(p0a10_q[49]) begin
        if(&p0a10_q[48:40])
            r_adc1_calib_q  <= p0a10_q[40:9];
        else
            r_adc1_calib_q  <= 32'h80000001;
    end
    else begin
        if(|p0a10_q[48:40])
            r_adc1_calib_q  <= 32'h0fffffff;
        else
            r_adc1_calib_q  <= p0a10_q[40:9];
    end
end	
	   

endmodule
