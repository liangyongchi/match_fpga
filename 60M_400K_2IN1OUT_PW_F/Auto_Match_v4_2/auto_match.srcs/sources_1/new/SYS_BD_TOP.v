
`timescale 1 ns / 1 ps

module SYS_BD_TOP #
(
	// Users to add parameters here
    parameter integer C_UDP_DATA_WIDTH ='d64        , 
	parameter integer C_UDP_DATA_LEN   ='d10        , 
	parameter integer C_UDP_IFG_WORD   ='d100000000 , 
	// User parameters ends 
	
     
	// Parameters of Axi Slave Bus Interface S00_AXI 
	parameter integer C_S00_AXI_DATA_LEN    = 256,
	parameter integer C_S00_AXI_DATA_WIDTH	= 32 ,
	parameter integer C_S00_AXI_ADDR_WIDTH	= 11
)
(
	// PL Users to add ports here;
    input                       i_sys_clk_p      ,   //sys_clk = 100M (D9);    	
    input                       i_sys_clk_n      , 
											     
	input  [11:0]               i_adc0_data0     , //HF    PCB_CH1
	input  [11:0]               i_adc0_data1     ,
	
	input  [11:0]               i_adc1_data0     , //OS0   PCB_CH3  
	input  [11:0]               i_adc1_data1     ,	
	
	// input  [11:0]               i_adc2_data0     ,
	// input  [11:0]               i_adc2_data1     ,
	
	input  [11:0]               i_adc3_data0     ,// OS1     PCB_CH4
	input  [11:0]               i_adc3_data1     ,	
	
	input  [11:0]               i_adc4_data0     ,
	input  [11:0]               i_adc4_data1     , //OS2		 PCB_CH2	(1IN 3OUT)  ;LF  PCB_CH3  (2IN_2OUT)					     
											     
 	output                      o_adc0_clka      , 
  	output                      o_adc0_clkb      ,  	
 	output                      o_adc1_clka      , 
  	output                      o_adc1_clkb      ,  	
 	// output                      o_adc2_clka      , 
  	// output                      o_adc2_clkb      , 
 	output                      o_adc3_clka      , 
  	output                      o_adc3_clkb      ,  	
 	output                      o_adc4_clka      , 
  	output                      o_adc4_clkb      ,  
 	
	//other about power system : feeddog &&on-off fpga with mcu;
	// input 				        INTLOCK_IN       ,
	// output 				        INTLOCK_OUT      ,
	// output 				        bias_on          ,	//0接S1，1接S2，0开1关
    // output 				        RF_ON_FPGA_DLY   ,	//0开1关 
	// output  			        RF_ON_MCU        ,	//开关信号给MCU，需要取反,1开0关
	// output 				        FPGA_DOG_WAVE    ,	//输出100 kHz
	output [5:0]		           debug_led        ,
    output                         FPGA_T25          ,  // pin：B17；
    output                         FPGA_T24          ,
		
	// //moto ctrl ;
    input   [7:0]               MOTO_ALM         , 
	output  [7:0]               MOTO_PWM         ,           
    output  [7:0]               MOTO_DIR         , 
    output  [7:0]               MOTO_EN          ,

	
    // input                       i_rxc            ,
    // input  [3 :0]               i_rxd            ,
    // input                       i_rx_ctl         ,	
										         
    // output                      o_txc            ,
    // output [3 :0]               o_txd            ,
    // output                      o_tx_ctl         ,
										         
	// MCU --FPGA Tspi bus                       
	input				        SPI_CS	         ,
	input				        SPI_SDI	         ,
	input				        SPI_SCLK         ,
	output  			        SPI_SDO	         
	
	
	// User ports ends
    // inout [14:0]DDR_addr    ,
    // inout [2:0]DDR_ba       ,
    // inout DDR_cas_n         ,
    // inout DDR_ck_n          ,
    // inout DDR_ck_p          ,
    // inout DDR_cke           ,
    // inout DDR_cs_n          ,
    // inout [3:0]DDR_dm       ,
    // inout [31:0]DDR_dq      ,
    // inout [3:0]DDR_dqs_n    ,
    // inout [3:0]DDR_dqs_p    ,
    // inout DDR_odt           ,
    // inout DDR_ras_n         ,
    // inout DDR_reset_n       ,
    // inout DDR_we_n          ,
    // inout FIXED_IO_ddr_vrn  ,
    // inout FIXED_IO_ddr_vrp  ,
    // inout [53:0]FIXED_IO_mio,
    // inout FIXED_IO_ps_clk   ,
    // inout FIXED_IO_ps_porb  ,
    // inout FIXED_IO_ps_srstb 


);
//local param define and wire assign here;
assign o_adc0_clka = clk_64m ;
assign o_adc0_clkb = clk_64m ;

assign o_adc1_clka = clk_64m ;
assign o_adc1_clkb = clk_64m ;

// assign o_adc2_clka = clk_64m ;
// assign o_adc2_clkb = clk_64m ;

assign o_adc3_clka = clk_64m ;
assign o_adc3_clkb = clk_64m ;

assign o_adc4_clka = clk_64m ;
assign o_adc4_clkb = clk_64m ;

 /*************************************************************************/
 /*----------------------------PL logic area------------------------------*/
 /*************************************************************************/
 


//internal wire assign; 

wire sysclk_bufg;
wire pll_locked;
wire pll1_locked;
wire clk_64m ;
wire clk_128m;
wire clk_50m ;	
wire sys_reset;

assign sys_reset = ~pll_locked;


   IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst (
      .O(i_sys_clk),  // Buffer output
      .I(i_sys_clk_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(i_sys_clk_n) // Diff_n buffer input (connect directly to top-level port)
   );


// clock design；
BUFG BUFG_inst (
      .O(sysclk_bufg), // 1-bit output: Clock output
      .I(i_sys_clk)  // 1-bit input: Clock input
);
   
clk_wiz_0 clk_wiz_0(
    .clk_128m                        ( clk_128m            ),	//128M
    .clk_64m                         ( clk_64m             ),	//64M	   
	.clk_50m 					     ( clk_50m             ),	//50M
 	
    .locked                          ( pll_locked          ),
    .clk_in1                         ( sysclk_bufg         )
); 


// Add user logic here

DiCoupler_top DiCoupler_top(
    .i_sys_reset                     (sys_reset            ), 
    .i_clk_64m                       (clk_64m              ),	
    .i_clk_128m                      (clk_128m             ),	
    .i_clk_50m                       (clk_50m              ),	//100M	 
													       
    .i_adc_clk                       (clk_64m              ),   //ADC 参考时钟，三路都用 同一个16M参考；					
													       
    .i_adc0_data0                    (i_adc0_data0         ),   //HF
    .i_adc0_data1                    (i_adc0_data1         ),		
	
    // .i_adc1_data0                    (i_adc1_data0         ),   //OS0
    // .i_adc1_data1                    (i_adc1_data1         ),
	
    .i_adc2_data0                    (i_adc1_data0         ),  //LF 
    .i_adc2_data1                    (i_adc1_data1         ),
	
    .i_adc3_data0                    (i_adc3_data0         ),   //OS1
    .i_adc3_data1                    (i_adc3_data1         ),
	
    .i_adc4_data0                    (i_adc4_data0         ),   //OS2
    .i_adc4_data1                    (i_adc4_data1         ),



    .INTLOCK_IN                      (INTLOCK_IN           ),
    .INTLOCK_OUT                     (INTLOCK_OUT          ),
    .bias_on                         (bias_on              ),	//0接S1，1接S2，0开1关
    .RF_ON_FPGA_DLY                  (RF_ON_FPGA_DLY       ),	//0开1关 
    .RF_ON_MCU                       (RF_ON_MCU            ),	//开关信号给MCU，需要取反,1开0关
    .FPGA_DOG_WAVE                   (FPGA_DOG_WAVE        ),	//输出100 kHz
    .debug_led                       (debug_led            ),
    .FPGA_T25                        (FPGA_T25             ),  // pin：B17；
    .FPGA_T24                        (FPGA_T24             ),
					            
    .MOTO_ALM                        (MOTO_ALM             ), 
    .MOTO_PWM                        (MOTO_PWM             ),           
    .MOTO_DIR                        (MOTO_DIR             ), 
    .MOTO_EN                         (MOTO_EN              ),

					                       
    .SPI_CS	                         (SPI_CS	           ),
    .SPI_SDI	                     (SPI_SDI	           ),
    .SPI_SCLK                        (SPI_SCLK             ),
    .SPI_SDO	                     (SPI_SDO	           )


);


// pl_sys_bd pl_sys_bd_inst (
    // // .S_AXI_ACLK                     (s00_axi_aclk           ), //output 
    // // .S_AXI_RSTN_0                   (s00_axi_aresetn        ), //output
	

    // // /*axi_rtlmm*/	
    // // .M03_AXI_0_araddr               (s00_axi_araddr         ),
    // // .M03_AXI_0_arprot               (s00_axi_arprot         ),
    // // .M03_AXI_0_arready              (s00_axi_arready        ),
    // // .M03_AXI_0_arvalid              (s00_axi_arvalid        ),
    // // .M03_AXI_0_awaddr               (s00_axi_awaddr         ),
    // // .M03_AXI_0_awprot               (s00_axi_awprot         ),
    // // .M03_AXI_0_awready              (s00_axi_awready        ),
    // // .M03_AXI_0_awvalid              (s00_axi_awvalid        ),
    // // .M03_AXI_0_bready               (s00_axi_bready         ),
    // // .M03_AXI_0_bresp                (s00_axi_bresp          ),
    // // .M03_AXI_0_bvalid               (s00_axi_bvalid         ),
    // // .M03_AXI_0_rdata                (s00_axi_rdata          ),
    // // .M03_AXI_0_rready               (s00_axi_rready         ),
    // // .M03_AXI_0_rresp                (s00_axi_rresp          ),
    // // .M03_AXI_0_rvalid               (s00_axi_rvalid         ),
    // // .M03_AXI_0_wdata                (s00_axi_wdata          ),
    // // .M03_AXI_0_wready               (s00_axi_wready         ),
    // // .M03_AXI_0_wstrb                (s00_axi_wstrb          ),
    // // .M03_AXI_0_wvalid               (s00_axi_wvalid         )
// );
 
pl_sys_wrapper  pl_sys_wrapper_inst
(
   // .DDR_addr(DDR_addr),
   // .DDR_ba(DDR_ba),
   // .DDR_cas_n(DDR_cas_n),
   // .DDR_ck_n(DDR_ck_n),
   // .DDR_ck_p(DDR_ck_p),
   // .DDR_cke(DDR_cke),
   // .DDR_cs_n(DDR_cs_n),
   // .DDR_dm(DDR_dm),
   // .DDR_dq(DDR_dq),
   // .DDR_dqs_n(DDR_dqs_n),
   // .DDR_dqs_p(DDR_dqs_p),
   // .DDR_odt(DDR_odt),
   // .DDR_ras_n(DDR_ras_n),
   // .DDR_reset_n(DDR_reset_n),
   // .DDR_we_n(DDR_we_n),
   // .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
   // .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
   // .FIXED_IO_mio(FIXED_IO_mio),
   // .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
   // .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
   // .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb)

);
 
 
 
// // User logic ends
// /*****************************PS to PL data communication area**********************************/

// //Instantiation of Axi Bus Interface S00_AXI
    // PS_PL_AXI4LITE#( 
		// //user define;
		// .C_S_AXI_DATA_LEN         (C_S00_AXI_DATA_LEN      ),
		// .C_S_AXI_DATA_WIDTH       (C_S00_AXI_DATA_WIDTH    ),
		// .C_S_AXI_ADDR_WIDTH       (C_S00_AXI_ADDR_WIDTH    )	
    // ) PS_PL_AXI4LITE_inst (
		// //user define port ;
    // /*pl--->ps*/
        // // .FREQ_OUT                (FREQ_OUT                ),
        // // .VR_ADC                  (VR_ADC                  ),
        // // .VF_ADC                  (VF_ADC                  ),
        // // .VR_CAL_I                (VR_CAL_I                ),
        // // .VR_CAL_Q                (VR_CAL_Q                ),
        // // .VF_CAL_I                (VF_CAL_I                ),
        // // .VF_CAL_Q                (VF_CAL_Q                ),
        // // .REFLECT_I               (REFLECT_I               ),
        // // .REFLECT_Q               (REFLECT_Q               ),
        // // .R_JX_I                  (R_JX_I                  ),
        // // .R_JX_Q                  (R_JX_Q                  ),	
        // // .VF_POWER                (VF_POWER                ),	
        // // .VR_POWER                (VR_POWER                ),	
        // // .VF_POWER_CALIB          (VF_POWER_CALIB          ),	
        // // .VR_POWER_CALIB          (VR_POWER_CALIB          ),	
        // // .VF_POWER_CALIB_K        (VF_POWER_CALIB_K        ),	
        // // .VF_POWER_CALIB_K1       (VF_POWER_CALIB_K1       ),	
        // // .VF_SENSOR0_K_AVG        (VF_SENSOR0_K_AVG        ),	
        // // .VR_SENSOR0_K_AVG        (VR_SENSOR0_K_AVG        ),	
        // // .VF_SENSOR1_K1_AVG       (VF_SENSOR1_K1_AVG       ),	
        // // .ADC_RAM_RD_DATA         (ADC_RAM_RD_DATA         ),
        // // .ADC_RAM_RD_DATA1        (ADC_RAM_RD_DATA1        ),		
        // // .ADC0_FILTER_I           (ADC0_FILTER_I           ),
        // // .ADC0_FILTER_Q           (ADC0_FILTER_Q           ),	
        // // .ADC1_FILTER_I           (ADC1_FILTER_I           ),
        // // .ADC1_FILTER_Q           (ADC1_FILTER_Q           ),	
        // // .I_DECOR_I               (I_DECOR_I               ),
        // // .I_DECOR_Q               (I_DECOR_Q               ),	
        // // .V_DECOR_I               (V_DECOR_I               ),
        // // .V_DECOR_Q               (V_DECOR_Q               ),	
        // // .R_DOUT                  (R_DOUT                  ),
        // // .JX_DOUT                 (JX_DOUT                 ),
        // // .R1_DOUT                 (R1_DOUT                 ),
        // // .JX1_DOUT                (JX1_DOUT                ),
        // // .AVG_IIR_R0              (AVG_IIR_R0              ),
        // // .AVG_IIR_JX0             (AVG_IIR_JX0             ),
        // // .AVG_IIR_R1              (AVG_IIR_R1              ),
        // // .AVG_IIR_JX1             (AVG_IIR_JX1             ),
        // // .SENOSR2_V_AVG           (SENOSR2_V_AVG           ),
        // // .SENOSR2_I_AVG           (SENOSR2_I_AVG           ),
        // // .PERIOD_NUM              (PERIOD_NUM              ),
        // // .PERIOD_TOTAL            (PERIOD_TOTAL            ),
        // // .FD_R_OUT                (FD_R_OUT                ),
        // // .FD_JX_DOUT              (FD_JX_DOUT              ),
    // // /*ps->pl*/
        // // .DEBUG_LED               (DEBUG_LED              ),
        // // .DCO_DLY                 (DCO_DLY                ),
        // // .BIAS_SET                (BIAS_SET               ),
        // // .RF_FREQ                 (RF_FREQ                ),
        // // .RF_EN                   (RF_EN                  ),
        // // .SET_POINT_VAL           (SET_POINT_VAL          ),
        // // .ADC_RAM_EN              (ADC_RAM_EN             ),
        // // .ADC_RAM_ADDR            (ADC_RAM_ADDR           ),
        // // .ADC0_MEAN0              (ADC0_MEAN0             ),
        // // .ADC1_MEAN0              (ADC1_MEAN0             ),
        // // .ADC0_MEAN1              (ADC0_MEAN1             ),
        // // .ADC1_MEAN1              (ADC1_MEAN1             ),		
        // // .M1A00_CH0               (M1A00_CH0              ),
        // // .M1A01_CH0               (M1A01_CH0              ),
        // // .M1A10_CH0               (M1A10_CH0              ),
        // // .M1A11_CH0               (M1A11_CH0              ),		
        // // .M1A00_CH1               (M1A00_CH1              ),
        // // .M1A01_CH1               (M1A01_CH1              ),
        // // .M1A10_CH1               (M1A10_CH1              ),
        // // .M1A11_CH1               (M1A11_CH1              ),
        // // .CALIB_R                 (CALIB_R                ),
        // // .CALIB_JX                (CALIB_JX               ),
        // // .ORIG_K                  (ORIG_K                 ),
        // // .ORIG_K1                 (ORIG_K1                ),
        // // .POWER_THRESHOLD         (POWER_THRESHOLD        ),  
        // // .FILTER_THRESHOLD        (FILTER_THRESHOLD       ),
        // // .DETECT_RISE_DLY         (DETECT_RISE_DLY        ), 
        // // .DETECT_FALL_DLY         (DETECT_FALL_DLY        ), 
        // // .RISE_JUMP               (RISE_JUMP              ), 
        // // .FALL_JUMP               (FALL_JUMP              ),
        // // .PULSE_START             (PULSE_START            ),	
        // // .PULSE_END               (PULSE_END              ),
        // // .POWER_PWM_DLY           (POWER_PWM_DLY          ),
        // // .SENSOR2_FILTER_THRESHOLD(SENSOR2_FILTER_THRESHOL),	
        // // .SENSOR2_DETECT_RISE_DLY (SENSOR2_DETECT_RISE_DLY), 
        // // .SENSOR2_DETECT_FALL_DLY (SENSOR2_DETECT_FALL_DLY), 
        // // .SENSOR2_RISE_JUMP       (SENSOR2_RISE_JUMP      ), 
        // // .SENSOR2_FALL_JUMP       (SENSOR2_FALL_JUMP      ),
        // // .SENSOR2_PULSE_START     (SENSOR2_PULSE_START    ),	
        // // .SENSOR2_PULSE_END       (SENSOR2_PULSE_END      ),
        // // .V_PWM_DLY               (V_PWM_DLY              ),
        // // .KEEP_DLY                (KEEP_DLY               ),
        // // .FFT_PERIOD              (FFT_PERIOD             ),
        // // .TDM_DIV_COEF            (TDM_DIV_COEF           ),
        // // .MATCH_DETECT            (MATCH_DETECT           ),		  				
        // // .DETECT_PULSE_WIDTH      (DETECT_PULSE_WIDTH     ),
        // // .MATCH_ON_DLY            (MATCH_ON_DLY           ),
        // // .OFF_NUM                 (OFF_NUM                ),
        // // .DETECT_PULSE            (DETECT_PULSE           ),
        // // .TDM_PERIOD              (TDM_PERIOD             ),
        // // .POWER_CALLAPSE          (POWER_CALLAPSE         ),
        // // .R_JX_CALLAPSE           (R_JX_CALLAPSE          ),
        // // .POWER_PREQ_COEF         (POWER_PREQ_COEF        ),		
        // // .RDADDR                  (RDADDR                 ),  
        // // .INPUT_SENSOR_FREQ       (INPUT_SENSOR_FREQ      ),
        // // .THRESHOLD2ON            (THRESHOLD2ON           ),
        // // .MEASURE_PERIOD          (MEASURE_PERIOD         ),


    // /*  pl_axi_slv  Port :*/
		// .S_AXI_ACLK              (s00_axi_aclk          ),
		// .S_AXI_ARESETN           (s00_axi_aresetn       ),
		// .S_AXI_AWADDR            (s00_axi_awaddr        ),
		// .S_AXI_AWPROT            (s00_axi_awprot        ),
		// .S_AXI_AWVALID           (s00_axi_awvalid       ),
		// .S_AXI_AWREADY           (s00_axi_awready       ),
		// .S_AXI_WDATA             (s00_axi_wdata         ),
		// .S_AXI_WSTRB             (s00_axi_wstrb         ),
		// .S_AXI_WVALID            (s00_axi_wvalid        ),
		// .S_AXI_WREADY            (s00_axi_wready        ),
		// .S_AXI_BRESP             (s00_axi_bresp         ),
		// .S_AXI_BVALID            (s00_axi_bvalid        ),
		// .S_AXI_BREADY            (s00_axi_bready        ),
		// .S_AXI_ARADDR            (s00_axi_araddr        ),
		// .S_AXI_ARPROT            (s00_axi_arprot        ),
		// .S_AXI_ARVALID           (s00_axi_arvalid       ),
		// .S_AXI_ARREADY           (s00_axi_arready       ),
		// .S_AXI_RDATA             (s00_axi_rdata         ),
		// .S_AXI_RRESP             (s00_axi_rresp         ),
		// .S_AXI_RVALID            (s00_axi_rvalid        ),
		// .S_AXI_RREADY            (s00_axi_rready        )
    // );



 /*udp lan to PC*/
	// UDP_TABLE#(
     // .P_DATA_WIDTH             (C_UDP_DATA_WIDTH       ),
     // .P_DATA_LEN               (C_UDP_DATA_LEN         ),
     // .P_IFG_WORD               (C_UDP_IFG_WORD         )
	// )UDP_TABLE_inst                                      
		// (                                                												 
     // .i_user_clk               (i_sys_clk              ), //100M
     // .i_user_rst               (~i_sys_rst             ),
     // .i_eth_start              (1'b1                   ), 
     // .i_row_din                ({64'd10,64'd20}        ),	

     // .i_rxc                    (i_rxc                  ),
     // .i_rxd                    (i_rxd                  ),
     // .i_rx_ctl                 (i_rx_ctl               ),	
     // .o_txc                    (o_txc                  ),
     // .o_txd                    (o_txd                  ),
     // .o_tx_ctl                 (o_tx_ctl               )		   
	// );

 
	// Do not modify the ports beyond this line
	// // Ports of Axi Slave Bus Interface S00_AXI
// wire                                  s00_axi_aclk   ;
// wire                                  s00_axi_aresetn;
// wire [C_S00_AXI_ADDR_WIDTH-1 : 0]     s00_axi_awaddr ;
// wire [2 : 0]                          s00_axi_awprot ;
// wire                                  s00_axi_awvalid;
// wire                                  s00_axi_awready;
// wire [C_S00_AXI_DATA_WIDTH-1 : 0]     s00_axi_wdata  ;
// wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb  ;
// wire                                  s00_axi_wvalid ;
// wire                                  s00_axi_wready ;
// wire [1 : 0]                          s00_axi_bresp  ;
// wire                                  s00_axi_bvalid ;
// wire                                  s00_axi_bready ;
// wire [C_S00_AXI_ADDR_WIDTH-1 : 0]     s00_axi_araddr ;
// wire [2 : 0]                          s00_axi_arprot ;
// wire                                  s00_axi_arvalid;
// wire                                  s00_axi_arready;
// wire [C_S00_AXI_DATA_WIDTH-1 : 0]     s00_axi_rdata  ;
// wire [1 : 0]                          s00_axi_rresp  ;
// wire                                  s00_axi_rvalid ;
// wire                                  s00_axi_rready ;
 
// wire    [31:0]  FREQ_OUT                 ;
// wire    [13:0]  VR_ADC                   ;
// wire    [13:0]  VF_ADC                   ;
// wire    [31:0]  VR_CAL_I                 ;
// wire    [31:0]  VR_CAL_Q                 ;
// wire    [31:0]  VF_CAL_I                 ;
// wire    [31:0]  VF_CAL_Q                 ;
// wire    [31:0]  REFLECT_I                ;
// wire    [31:0]  REFLECT_Q                ;
// wire    [31:0]  R_JX_I                   ;
// wire    [31:0]  R_JX_Q                   ;
// wire    [31:0]  VF_POWER                 ;
// wire    [31:0]  VR_POWER                 ;
// wire    [15:0]  VF_POWER_CALIB           ;
// wire    [15:0]  VR_POWER_CALIB           ;
// wire    [15:0]  VF_POWER_CALIB_K         ;
// wire    [15:0]  VF_POWER_CALIB_K1        ;
// wire    [15:0]  VF_SENSOR0_K_AVG         ;
// wire    [15:0]  VR_SENSOR0_K_AVG         ;
// wire    [15:0]  VF_SENSOR1_K1_AVG        ;
// wire    [31:0]  ADC_RAM_RD_DATA          ;
// wire    [31:0]  ADC_RAM_RD_DATA1         ;
// wire    [31:0]  ADC0_FILTER_I            ;
// wire    [31:0]  ADC0_FILTER_Q            ;
// wire    [31:0]  ADC1_FILTER_I            ;
// wire    [31:0]  ADC1_FILTER_Q            ;
// wire    [31:0]  I_DECOR_I                ;
// wire    [31:0]  I_DECOR_Q                ;
// wire    [31:0]  V_DECOR_I                ;
// wire    [31:0]  V_DECOR_Q                ;
// wire    [31:0]  R_DOUT                   ;
// wire    [31:0]  JX_DOUT                  ;
// wire    [31:0]  R1_DOUT                  ;
// wire    [31:0]  JX1_DOUT                 ;
// wire    [31:0]  AVG_IIR_R0               ;
// wire    [31:0]  AVG_IIR_JX0              ;
// wire    [31:0]  AVG_IIR_R1               ;
// wire    [31:0]  AVG_IIR_JX1              ;
// wire    [31:0]  SENOSR2_V_AVG            ;
// wire    [31:0]  SENOSR2_I_AVG            ;
// wire    [31:0]  PERIOD_NUM               ;
// wire    [31:0]  PERIOD_TOTAL             ;
// wire    [31:0]  FD_R_OUT                 ;
// wire    [31:0]  FD_JX_DOUT               ;
  
  
		// /*ps--->pl*/  
// wire  [7:0]   DEBUG_LED                  ;
// wire  [5:0]   DCO_DLY                    ;
// wire          BIAS_SET                   ;
// wire  [3:0]   RF_FREQ                    ;
// wire          RF_EN                      ;
// wire  [15:0]  SET_POINT_VAL              ;
// wire          ADC_RAM_EN                 ;
// wire  [11:0]  ADC_RAM_ADDR               ;
// wire  [31:0]  ADC0_MEAN0                 ;
// wire  [31:0]  ADC1_MEAN0                 ;
// wire  [31:0]  ADC0_MEAN1                 ;
// wire  [31:0]  ADC1_MEAN1                 ;
// wire  [31:0]  M1A00_CH0                  ;
// wire  [31:0]  M1A01_CH0                  ;
// wire  [31:0]  M1A10_CH0                  ;
// wire  [31:0]  M1A11_CH0                  ;
// wire  [31:0]  M1A00_CH1                  ;
// wire  [31:0]  M1A01_CH1                  ;
// wire  [31:0]  M1A10_CH1                  ;
// wire  [31:0]  M1A11_CH1                  ;
// wire  [31:0]  CALIB_R                    ;
// wire  [31:0]  CALIB_JX                   ;
// wire  [31:0]  ORIG_K                     ;
// wire  [31:0]  ORIG_K1                    ;
// wire  [31:0]  POWER_THRESHOLD            ;
// wire  [15:0]  FILTER_THRESHOLD           ;
// wire  [23:0]  DETECT_RISE_DLY            ;
// wire  [23:0]  DETECT_FALL_DLY            ;
// wire  [9:0]   RISE_JUMP                  ;
// wire  [9:0]   FALL_JUMP                  ;
// wire  [15:0]  PULSE_START                ;
// wire  [15:0]  PULSE_END                  ;
// wire  [15:0]  POWER_PWM_DLY              ;
// wire  [15:0]  SENSOR2_FILTER_THRESHOLD   ;
// wire  [23:0]  SENSOR2_DETECT_RISE_DLY    ;
// wire  [23:0]  SENSOR2_DETECT_FALL_DLY    ;
// wire  [9:0]   SENSOR2_RISE_JUMP          ;
// wire  [9:0]   SENSOR2_FALL_JUMP          ;
// wire  [15:0]  SENSOR2_PULSE_START        ;
// wire  [15:0]  SENSOR2_PULSE_END          ;
// wire  [15:0]  V_PWM_DLY                  ;
// wire  [35:0]  KEEP_DLY                   ;
// wire  [15:0]  FFT_PERIOD                 ;
// wire  [31:0]  TDM_DIV_COEF               ;
// wire  [15:0]  MATCH_DETECT               ;
// wire  [31:0]  DETECT_PULSE_WIDTH         ;
// wire  [31:0]  MATCH_ON_DLY               ;
// wire  [31:0]  OFF_NUM                    ;
// wire  [31:0]  DETECT_PULSE               ;
// wire  [31:0]  TDM_PERIOD                 ;
// wire  [31:0]  POWER_CALLAPSE             ;
// wire  [31:0]  R_JX_CALLAPSE              ;
// wire  [31:0]  POWER_PREQ_COEF            ;
// wire  [14:0]  RDADDR                     ;
// wire  [31:0]  INPUT_SENSOR_FREQ          ;
// wire  [15:0]  THRESHOLD2ON               ;
// wire  [31:0]  MEASURE_PERIOD             ;

endmodule
