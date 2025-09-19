`include "param_def.vh"

module core(
	input				i_clk,
	input 				i_rst,

	output reg [7:0]	DEBUG_LED		 ,
	output reg [5:0]	dco_dly			 ,
	output reg 			BIAS_SET		 , 	
	output reg [3:0]	RF_FREQ0	     ,	
	output reg [3:0]	RF_FREQ1	     ,
	output reg [3:0]	RF_FREQ2	     ,
	output reg [3:0]	RF_FREQ3	     ,
	output reg [3:0]	RF_FREQ4	     ,
										 
	input [31:0]		freq_out0     	 ,   
	input [31:0]		freq_out1     	 ,   	
	input [31:0]		freq_out2     	 ,   
	input [31:0]		freq_out3     	 ,   	
	input [31:0]		freq_out4     	 ,
	
	output reg 			RF_EN			 ,//射频功率开关,1开0关  
	output reg [15:0]	SET_POINT_VAL	 ,//PID功率设置      	
	input [13:0]		VR_ADC			 ,			
	input [13:0]		VF_ADC			 ,		
	input [31:0]		VR_CAL_I		 ,
    input [31:0]		VR_CAL_Q		 ,
    input [31:0]		VF_CAL_I		 ,
    input [31:0]		VF_CAL_Q		 ,
	input [31:0]		refl_i			 ,
	input [31:0]		refl_q			 ,
	input [31:0]		r_jx_i			 ,			
	input [31:0]		r_jx_q			 ,			
	input [31:0]		VR_POWER0		 ,
	input [31:0]		VF_POWER0		 ,
	input [31:0]		VR_POWER2		 , //暂未分配spi地址读写
	input [31:0]		VF_POWER2		 , //暂未分配spi地址读写
	
	input [15:0]		VR_POWER_CALIB	 ,
	input [15:0]		VF_POWER_CALIB	 ,
	input [15:0]		VF_POWER_CALIB_K0,
	input [15:0]		VR_POWER_CALIB_K0,	
	
	input [15:0]		VF_POWER_CALIB_K1,	
	
	input [15:0]		VF_POWER_CALIB_K2,		
	input [15:0]		VR_POWER_CALIB_K2,	
	
	input [15:0]	    VF_SENSOR0_K_AVG ,
	input [15:0]	    VR_SENSOR0_K_AVG ,	
	
	input [15:0]	    VF_SENSOR2_K2_AVG,		
	input [15:0]	    VR_SENSOR2_K2_AVG,	

	
	output reg 			ADC_RAM_EN		,	
	output reg [11:0]	ADC_RAM_RD_ADDR	,	
	input [31:0]		ADC_RAM_RD_DATA	,
	input [31:0]		ADC_RAM_RD_DATA1,	
	input [31:0]		ADC_RAM_RD_DATA2,	
	input [31:0]		ADC_RAM_RD_DATA3,	
	input [31:0]		ADC_RAM_RD_DATA4,
	
	input [31:0]        ADC0_FILTER0_I  ,//0 error
	input [31:0]        ADC0_FILTER0_Q  ,
	input [31:0]        ADC1_FILTER0_I  ,//0 error
	input [31:0]        ADC1_FILTER0_Q  ,
	input [31:0]        ADC0_FILTER1_I  ,//0 error
	input [31:0]        ADC0_FILTER1_Q  ,
	input [31:0]        ADC1_FILTER1_I  ,//0 error
	input [31:0]        ADC1_FILTER1_Q  ,
	input [31:0]        ADC0_FILTER2_I  ,//0 error
	input [31:0]        ADC0_FILTER2_Q  ,
	input [31:0]        ADC1_FILTER2_I  ,//0 error
	input [31:0]        ADC1_FILTER2_Q  ,

	input [31:0]        ADC0_FILTER1_400K_I  ,//0 error
	input [31:0]        ADC0_FILTER1_400K_Q  ,
	input [31:0]        ADC1_FILTER1_400K_I  ,//0 error
	input [31:0]        ADC1_FILTER1_400K_Q  ,
	input [31:0]        ADC0_FILTER2_400K_I  ,//0 error
	input [31:0]        ADC0_FILTER2_400K_Q  ,
	input [31:0]        ADC1_FILTER2_400K_I  ,//0 error
	input [31:0]        ADC1_FILTER2_400K_Q  ,



	input [31:0]        I_DECOR_I       ,	
	input [31:0]        I_DECOR_Q       ,	
	input [31:0]        V_DECOR_I       ,	
	input [31:0]        V_DECOR_Q       ,	
	
	
	output reg [31:0]	adc0_mean0		,    	
	output reg [31:0]	adc1_mean0		, 
	output reg [31:0]	adc0_mean1		,
	output reg [31:0]	adc1_mean1		,   
	output reg [31:0]	adc0_mean2		,
	output reg [31:0]	adc1_mean2		, 
	output reg [31:0]	adc0_mean3		,
	output reg [31:0]	adc1_mean3		,   
	output reg [31:0]	adc0_mean4		,
	output reg [31:0]	adc1_mean4		, 
	output reg [31:0]	adc0_mean3_400k	,
	output reg [31:0]	adc1_mean3_400k	,   
	output reg [31:0]	adc0_mean4_400k	,
	output reg [31:0]	adc1_mean4_400k	, 


	
	output reg [31:0]	m1a00_ch0    	,    	
	output reg [31:0]	m1a01_ch0    	,    	
	output reg [31:0]	m1a10_ch0    	,    	
	output reg [31:0]	m1a11_ch0    	, 
	output reg [31:0]	m1a00_ch1    	, 
	output reg [31:0]	m1a01_ch1    	, 
	output reg [31:0]	m1a10_ch1    	, 
	output reg [31:0]	m1a11_ch1    	, 
	output reg [31:0]	m1a00_ch2    	, 
	output reg [31:0]	m1a01_ch2    	, 
	output reg [31:0]	m1a10_ch2    	, 
	output reg [31:0]	m1a11_ch2    	, 
	output reg [31:0]	m1a00_ch3    	, 
	output reg [31:0]	m1a01_ch3    	, 
	output reg [31:0]	m1a10_ch3    	, 
	output reg [31:0]	m1a11_ch3    	, 
	output reg [31:0]	m1a00_ch4    	, 
	output reg [31:0]	m1a01_ch4    	, 
	output reg [31:0]	m1a10_ch4    	, 
	output reg [31:0]	m1a11_ch4    	, 

	output reg [31:0]	m1a00_ch3_400k  , 
	output reg [31:0]	m1a01_ch3_400k  , 
	output reg [31:0]	m1a10_ch3_400k  , 
	output reg [31:0]	m1a11_ch3_400k  , 
	output reg [31:0]	m1a00_ch4_400k  , 
	output reg [31:0]	m1a01_ch4_400k  , 
	output reg [31:0]	m1a10_ch4_400k  , 
	output reg [31:0]	m1a11_ch4_400k  , 


	
	output reg [31:0]	CALIB_R 		,
	output reg [31:0]	CALIB_JX		,
	input [31:0]		R_DOUT			,
	input [31:0]		JX_DOUT 		, 
	input [31:0]		R1_DOUT			,
	input [31:0]		JX1_DOUT 		, 
	input [31:0]		R2_DOUT			,
	input [31:0]		JX2_DOUT 		, 
	input [31:0]		R3_DOUT			,
	input [31:0]		JX3_DOUT 		, 
	input [31:0]		R4_DOUT			,
	input [31:0]		JX4_DOUT 		, 
	input [31:0]		R3_400K_DOUT	,
	input [31:0]		JX3_400K_DOUT   , 
	input [31:0]		R4_400K_DOUT	,
	input [31:0]		JX4_400K_DOUT   , 


	
    input [31:0]        AVG_IIR_R0      ,
    input [31:0]        AVG_IIR_JX0     ,
    input [31:0]        AVG_IIR_R1      ,
    input [31:0]        AVG_IIR_JX1     ,
    input [31:0]        AVG_IIR_R2      ,
    input [31:0]        AVG_IIR_JX2     ,	
    input [31:0]        AVG_IIR_R3      ,
    input [31:0]        AVG_IIR_JX3     ,	
    input [31:0]        AVG_IIR_R4      ,
    input [31:0]        AVG_IIR_JX4     ,	

    input [31:0]        AVG_IIR_400K_R3 ,
    input [31:0]        AVG_IIR_400K_JX3,	
    input [31:0]        AVG_IIR_400K_R4 ,
    input [31:0]        AVG_IIR_400K_JX4,	




	
    input [31:0]        OS0_V_AVG       , 
    input [31:0]        OS0_I_AVG       , 
    input [31:0]        OS1_V_AVG       , 
    input [31:0]        OS1_I_AVG       , 
    input [31:0]        OS2_V_AVG       , 
    input [31:0]        OS2_I_AVG       , 
  

    input [31:0]       OS1_400K_V_AVG   ,
    input [31:0]       OS1_400K_I_AVG   ,
    input [31:0]       OS2_400K_V_AVG   ,
    input [31:0]       OS2_400K_I_AVG   ,





  
    input [31:0]        HF_PERIOD_NUM   ,
    input [31:0]        HF_PERIOD_TOTAL ,   
	input [31:0]        LF_PERIOD_NUM   ,
    input [31:0]        LF_PERIOD_TOTAL ,
	input [31:0]        OS0_PERIOD_NUM  ,
    input [31:0]        OS0_PERIOD_TOTAL,
	input [31:0]        OS1_PERIOD_NUM  ,
    input [31:0]        OS1_PERIOD_TOTAL,
	input [31:0]        OS2_PERIOD_NUM  ,
    input [31:0]        OS2_PERIOD_TOTAL,



    input [47:0]        PL_STATE        , 
    output reg [47:0]   MOTO1_PARA1     ,
    output reg [47:0]   MOTO1_PARA2     ,
    output reg [47:0]   MOTO2_PARA1     ,
    output reg [47:0]   MOTO2_PARA2     ,
    output reg [47:0]   MOTO3_PARA1     ,
    output reg [47:0]   MOTO3_PARA2     ,
    output reg [47:0]   MOTO4_PARA1     ,
    output reg [47:0]   MOTO4_PARA2     ,
    output reg [47:0]   MOTO5_PARA1     ,
    output reg [47:0]   MOTO5_PARA2     ,
    output reg [47:0]   MOTO6_PARA1     ,
    output reg [47:0]   MOTO6_PARA2     ,
    output reg [47:0]   MOTO7_PARA1     ,
    output reg [47:0]   MOTO7_PARA2     ,
    output reg [47:0]   MOTO8_PARA1     ,
    output reg [47:0]   MOTO8_PARA2     ,
	output reg          DECOR_PULSE     ,

	output reg [15:0]   HF_THRESHOLD2ON  ,                      
	output reg [31:0]   HF_MEASURE_PERIOD, //10ms DEFAULT; 测量电源波形频率的测量时间长度；	
	output reg [15:0]   LF_THRESHOLD2ON  ,                      
	output reg [31:0]   LF_MEASURE_PERIOD, //10ms DEFAULT; 测量电源波形频率的测量时间长度；	
	output reg [15:0]   OS0_THRESHOLD2ON  , 
	output reg [31:0]   OS0_MEASURE_PERIOD, 
	output reg [15:0]   OS1_THRESHOLD2ON  , 
	output reg [31:0]   OS1_MEASURE_PERIOD, 
	output reg [15:0]   OS2_THRESHOLD2ON  , 
	output reg [31:0]   OS2_MEASURE_PERIOD, 	
	
	output reg          FREQ0_CALIB_MODE ,
    output reg          FREQ2_CALIB_MODE ,
	output reg [23:0]	ORIG_K0		    ,
	output reg [23:0]	ORIG_K2		    ,	
	
//********************************************
    input      [31:0]   FD_R_OUT        ,
    input      [31:0]   FD_JX_OUT       ,	   
    output reg [31:0]   POWER_THRESHOLD ,
	
	output reg [15:0]   FILTER_THRESHOLD,	
	
	output reg [23:0]   DETECT_RISE_DLY ,
	output reg [23:0]   DETECT_FALL_DLY ,
	output reg [ 9:0]   RISE_JUMP       ,
	output reg [ 9:0]   FALL_JUMP       ,
	
	output reg [23:0]   DETECT_RISE_DLY2,
	output reg [23:0]   DETECT_FALL_DLY2,
	output reg [ 9:0]   RISE_JUMP2      ,
	output reg [ 9:0]   FALL_JUMP2      ,	
	
    output reg [15:0]   PULSE_START     ,
	output reg [15:0]   PULSE_END       ,

	
    output reg [15:0]   PULSE_START2     ,
	output reg [15:0]   PULSE_END2       ,	
	
    output reg [15:0]   POWER_PWM_DLY0   ,	
    output reg [15:0]   POWER_PWM_DLY2   ,	

	
	output reg [15:0]   OS0_FILTER_THRESHOLD,	
	output reg [23:0]   OS0_DETECT_RISE_DLY ,
	output reg [23:0]   OS0_DETECT_FALL_DLY ,
	output reg [ 9:0]   OS0_RISE_JUMP       ,
	output reg [ 9:0]   OS0_FALL_JUMP       ,
    output reg [15:0]   OS0_PULSE_START     ,
	output reg [15:0]   OS0_PULSE_END       ,		
    output reg [15:0]   I_PWM_DLY           ,	
	
	output reg [15:0]   OS1_FILTER_THRESHOLD,	
	output reg [23:0]   OS1_DETECT_RISE_DLY ,
	output reg [23:0]   OS1_DETECT_FALL_DLY ,
	output reg [ 9:0]   OS1_RISE_JUMP       ,
	output reg [ 9:0]   OS1_FALL_JUMP       ,
    output reg [15:0]   OS1_PULSE_START     ,
	output reg [15:0]   OS1_PULSE_END       ,		
    output reg [15:0]   I1_PWM_DLY           ,	
	output reg [15:0]   OS2_FILTER_THRESHOLD,	
	output reg [23:0]   OS2_DETECT_RISE_DLY ,
	output reg [23:0]   OS2_DETECT_FALL_DLY ,
	output reg [ 9:0]   OS2_RISE_JUMP       ,
	output reg [ 9:0]   OS2_FALL_JUMP       ,
    output reg [15:0]   OS2_PULSE_START     ,
	output reg [15:0]   OS2_PULSE_END       ,		
    output reg [15:0]   I2_PWM_DLY          ,		

	output reg [15:0]   OS1_400K_FILTER_THRESHOLD,	
	output reg [23:0]   OS1_400K_DETECT_RISE_DLY ,
	output reg [23:0]   OS1_400K_DETECT_FALL_DLY ,
	output reg [ 9:0]   OS1_400K_RISE_JUMP       ,
	output reg [ 9:0]   OS1_400K_FALL_JUMP       ,
    output reg [15:0]   OS1_400K_PULSE_START     ,
	output reg [15:0]   OS1_400K_PULSE_END       ,		
    output reg [15:0]   I1_PWM_DLY_400K          ,	
	output reg [15:0]   OS2_400K_FILTER_THRESHOLD,	
	output reg [23:0]   OS2_400K_DETECT_RISE_DLY ,
	output reg [23:0]   OS2_400K_DETECT_FALL_DLY ,
	output reg [ 9:0]   OS2_400K_RISE_JUMP       ,
	output reg [ 9:0]   OS2_400K_FALL_JUMP       ,
    output reg [15:0]   OS2_400K_PULSE_START     ,
	output reg [15:0]   OS2_400K_PULSE_END       ,		
    output reg [15:0]   I2_PWM_DLY_400K          ,	




	
	output reg [35:0]   KEEP_DLY           ,
	output reg [15:0]   FFT_PERIOD         ,
	output reg [32:0]   TDM_DIV_COEF       ,
										   
	output reg [15:0]   MATCH_DETECT       ,//NO USE;
										   
	output reg [31:0]   DETECT_PULSE_WIDTH ,	
	output reg [31:0]   MATCH_ON_DLY       ,
	output reg [31:0]   OFF_NUM            ,

	output reg [31:0]   DETECT_PULSE_WIDTH1,	
	output reg [31:0]   MATCH_ON_DLY1      ,
	output reg [31:0]   OFF_NUM1           ,

	output reg [31:0]   DETECT_PULSE_WIDTH2,	
	output reg [31:0]   MATCH_ON_DLY2      ,
	output reg [31:0]   OFF_NUM2           ,	
	
	output reg [31:0]   DETECT_PULSE_WIDTH3,	
	output reg [31:0]   MATCH_ON_DLY3      ,
	output reg [31:0]   OFF_NUM3           ,	

	output reg [31:0]   DETECT_PULSE_WIDTH4,	
	output reg [31:0]   MATCH_ON_DLY4      ,
	output reg [31:0]   OFF_NUM4           ,	


	output reg [31:0]   DETECT_PULSE_WIDTH3_400K  ,	
	output reg [31:0]   MATCH_ON_DLY3_400K        ,
	output reg [31:0]   OFF_NUM3_400K             ,	
                        
	output reg [31:0]   DETECT_PULSE_WIDTH4_400K  ,	
	output reg [31:0]   MATCH_ON_DLY4_400K        ,
	output reg [31:0]   OFF_NUM4_400K             ,	

    output reg [31:0]   ON_KEEP_NUM        , 
    output reg [31:0]   OFF_KEEP_NUM       , 
	
	
    output reg [31:0]   r_detect_pulse	   ,
	output reg [31:0]   TDM_PERIOD         ,
	output reg [31:0]   POWER_CALLAPSE     ,
	output reg [31:0]   R_JX_CALLAPSE      ,
										   
    output reg [31:0]   POWER_FREQ_COEF0   ,
    output reg [31:0]   POWER_FREQ_COEF1   ,	
    output reg [31:0]   POWER_FREQ_COEF2   ,	
    output reg [31:0]   POWER_FREQ_COEF3   ,	
    output reg [31:0]   POWER_FREQ_COEF4   ,

	output              RD                ,
    output    [14:0]	w_RDAddr          , //test for iq  lock;
	
 //   output reg [31:0]   INPUT_SENSOR_FREQ ,	
	
    output reg [23:0]	POWER0_CALIB_K0	  , 
    output reg [23:0]	POWER0_CALIB_K1	  , 
    output reg [23:0]	POWER0_CALIB_K2	  , 
    output reg [23:0]	POWER0_CALIB_K3	  , 
    output reg [23:0]	POWER0_CALIB_K4	  , 
    output reg [23:0]	POWER0_CALIB_K5	  , 
    output reg [23:0]	POWER0_CALIB_K6	  , 
    output reg [23:0]	POWER0_CALIB_K7	  , 
    output reg [23:0]	POWER0_CALIB_K8	  , 
    output reg [23:0]	POWER0_CALIB_K9	  , 
    output reg [23:0]	POWER0_CALIB_K10  , 
    output reg [23:0]	POWER0_CALIB_K11  , 
    output reg [23:0]	POWER0_CALIB_K12  , 
    output reg [23:0]	POWER0_CALIB_K13  , 
    output reg [23:0]	POWER0_CALIB_K14  , 
    output reg [23:0]	POWER0_CALIB_K15  , 
    output reg [23:0]	POWER0_CALIB_K16  , 
    output reg [23:0]	POWER0_CALIB_K17  , 
    output reg [23:0]	POWER0_CALIB_K18  , 
    output reg [23:0]	POWER0_CALIB_K19  , 
    output reg [23:0]	POWER0_CALIB_K20  , 
    output reg [23:0]	POWER0_CALIB_K21  , 
    output reg [23:0]	POWER0_CALIB_K22  , 
    output reg [23:0]	POWER0_CALIB_K23  , 
    output reg [23:0]	POWER0_CALIB_K24  , 
    output reg [23:0]	POWER0_CALIB_K25  , 
    output reg [23:0]	POWER0_CALIB_K26  , 
    output reg [23:0]	POWER0_CALIB_K27  , 
    output reg [23:0]	POWER0_CALIB_K28  , 
    output reg [23:0]	POWER0_CALIB_K29  , 

    output reg [23:0]   POWER2_CALIB_K0	  ,
    output reg [23:0]   POWER2_CALIB_K1	  ,
    output reg [23:0]   POWER2_CALIB_K2	  ,
    output reg [23:0]   POWER2_CALIB_K3	  ,
    output reg [23:0]   POWER2_CALIB_K4	  ,
    output reg [23:0]   POWER2_CALIB_K5	  ,
    output reg [23:0]   POWER2_CALIB_K6	  ,
    output reg [23:0]   POWER2_CALIB_K7	  ,
    output reg [23:0]   POWER2_CALIB_K8	  ,
    output reg [23:0]   POWER2_CALIB_K9	  ,
    output reg [23:0]   POWER2_CALIB_K10  ,
    output reg [23:0]   POWER2_CALIB_K11  ,
    output reg [23:0]   POWER2_CALIB_K12  ,
    output reg [23:0]   POWER2_CALIB_K13  ,
    output reg [23:0]   POWER2_CALIB_K14  ,
    output reg [23:0]   POWER2_CALIB_K15  ,
    output reg [23:0]   POWER2_CALIB_K16  ,
    output reg [23:0]   POWER2_CALIB_K17  ,
    output reg [23:0]   POWER2_CALIB_K18  ,
    output reg [23:0]   POWER2_CALIB_K19  ,
    output reg [23:0]   POWER2_CALIB_K20  ,
    output reg [23:0]   POWER2_CALIB_K21  ,
    output reg [23:0]   POWER2_CALIB_K22  ,
    output reg [23:0]   POWER2_CALIB_K23  ,
    output reg [23:0]   POWER2_CALIB_K24  ,
    output reg [23:0]   POWER2_CALIB_K25  ,
    output reg [23:0]   POWER2_CALIB_K26  ,
    output reg [23:0]   POWER2_CALIB_K27  ,
    output reg [23:0]   POWER2_CALIB_K28  ,
    output reg [23:0]   POWER2_CALIB_K29  ,
									  
    output reg [31:0]	FREQ0_THR0 		  ,  
    output reg [31:0]	FREQ0_THR1 		  ,  
    output reg [31:0]	FREQ0_THR2 		  ,  
    output reg [31:0]	FREQ0_THR3 		  ,  
    output reg [31:0]	FREQ0_THR4 		  ,  
    output reg [31:0]	FREQ0_THR5 		  ,  
    output reg [31:0]	FREQ0_THR6 		  ,  
    output reg [31:0]	FREQ0_THR7 		  ,  
    output reg [31:0]	FREQ0_THR8 		  ,  
    output reg [31:0]	FREQ0_THR9 		  ,  
    output reg [31:0]	FREQ0_THR10		  ,  
    output reg [31:0]	FREQ0_THR11		  ,  
    output reg [31:0]	FREQ0_THR12		  ,  
    output reg [31:0]	FREQ0_THR13		  ,  
    output reg [31:0]	FREQ0_THR14		  ,  
    output reg [31:0]	FREQ0_THR15		  ,  
    output reg [31:0]	FREQ0_THR16		  ,  
    output reg [31:0]	FREQ0_THR17		  ,  
    output reg [31:0]	FREQ0_THR18		  ,  
    output reg [31:0]	FREQ0_THR19		  ,  
    output reg [31:0]	FREQ0_THR20		  ,  
    output reg [31:0]	FREQ0_THR21		  ,  
    output reg [31:0]	FREQ0_THR22		  ,  
    output reg [31:0]	FREQ0_THR23		  ,  
    output reg [31:0]	FREQ0_THR24		  ,  
    output reg [31:0]	FREQ0_THR25		  ,  
    output reg [31:0]	FREQ0_THR26		  ,  
    output reg [31:0]	FREQ0_THR27		  ,  
    output reg [31:0]	FREQ0_THR28		  ,  
    output reg [31:0]	FREQ0_THR29		  ,  
    output reg [31:0]	FREQ0_THR30		  ,  
	
					
    output reg [31:0]   FREQ2_THR0 		  ,
    output reg [31:0]   FREQ2_THR1 		  ,
    output reg [31:0]   FREQ2_THR2 		  ,
    output reg [31:0]   FREQ2_THR3 		  ,
    output reg [31:0]   FREQ2_THR4 		  ,
    output reg [31:0]   FREQ2_THR5 		  ,
    output reg [31:0]   FREQ2_THR6 		  ,
    output reg [31:0]   FREQ2_THR7 		  ,
    output reg [31:0]   FREQ2_THR8 		  ,
    output reg [31:0]   FREQ2_THR9 		  ,
    output reg [31:0]   FREQ2_THR10		  ,
    output reg [31:0]   FREQ2_THR11		  ,
    output reg [31:0]   FREQ2_THR12		  ,
    output reg [31:0]   FREQ2_THR13		  ,
    output reg [31:0]   FREQ2_THR14		  ,
    output reg [31:0]   FREQ2_THR15		  ,
    output reg [31:0]   FREQ2_THR16		  ,
    output reg [31:0]   FREQ2_THR17		  ,
    output reg [31:0]   FREQ2_THR18		  ,
    output reg [31:0]   FREQ2_THR19		  ,
    output reg [31:0]   FREQ2_THR20		  ,
    output reg [31:0]   FREQ2_THR21		  ,
    output reg [31:0]   FREQ2_THR22		  ,
    output reg [31:0]   FREQ2_THR23		  ,
    output reg [31:0]   FREQ2_THR24		  ,
    output reg [31:0]   FREQ2_THR25		  ,
    output reg [31:0]   FREQ2_THR26		  ,
    output reg [31:0]   FREQ2_THR27		  ,
    output reg [31:0]   FREQ2_THR28		  ,
    output reg [31:0]   FREQ2_THR29		  ,
    output reg [31:0]   FREQ2_THR30		  ,	
	
    output reg [23:0]	K0_THR0 			  , 
    output reg [23:0]	K0_THR1 			  , 
    output reg [23:0]	K0_THR2 			  , 
    output reg [23:0]	K0_THR3 			  , 
    output reg [23:0]	K0_THR4 			  , 
    output reg [23:0]	K0_THR5 			  , 
    output reg [23:0]	K0_THR6 			  , 
    output reg [23:0]	K0_THR7 			  , 
    output reg [23:0]	K0_THR8 			  , 
    output reg [23:0]	K0_THR9 			  , 
    output reg [23:0]	K0_THR10			  , 
    output reg [23:0]	K0_THR11			  , 
    output reg [23:0]	K0_THR12			  , 
    output reg [23:0]	K0_THR13			  , 
    output reg [23:0]	K0_THR14			  , 
    output reg [23:0]	K0_THR15			  , 
    output reg [23:0]	K0_THR16			  , 
    output reg [23:0]	K0_THR17			  , 
    output reg [23:0]	K0_THR18			  , 
    output reg [23:0]	K0_THR19			  , 
    output reg [23:0]	K0_THR20			  , 
    output reg [23:0]	K0_THR21			  , 
    output reg [23:0]	K0_THR22			  , 
    output reg [23:0]	K0_THR23			  , 
    output reg [23:0]	K0_THR24			  , 
    output reg [23:0]	K0_THR25			  , 
    output reg [23:0]	K0_THR26			  , 
    output reg [23:0]	K0_THR27			  , 
    output reg [23:0]	K0_THR28			  , 
    output reg [23:0]	K0_THR29			  , 
	
    output reg [23:0]   K2_THR0 			  ,	
    output reg [23:0]   K2_THR1 			  ,	
    output reg [23:0]   K2_THR2 			  ,	
    output reg [23:0]   K2_THR3 			  ,	
    output reg [23:0]   K2_THR4 			  ,	
    output reg [23:0]   K2_THR5 			  ,	
    output reg [23:0]   K2_THR6 			  ,	
    output reg [23:0]   K2_THR7 			  ,	
    output reg [23:0]   K2_THR8 			  ,	
    output reg [23:0]   K2_THR9 			  ,	
    output reg [23:0]   K2_THR10			  ,	
    output reg [23:0]   K2_THR11			  ,	
    output reg [23:0]   K2_THR12			  ,	
    output reg [23:0]   K2_THR13			  ,	
    output reg [23:0]   K2_THR14			  ,	
    output reg [23:0]   K2_THR15			  ,	
    output reg [23:0]   K2_THR16			  ,	
    output reg [23:0]   K2_THR17			  ,	
    output reg [23:0]   K2_THR18			  ,	
    output reg [23:0]   K2_THR19			  ,	
    output reg [23:0]   K2_THR20			  ,	
    output reg [23:0]   K2_THR21			  ,	
    output reg [23:0]   K2_THR22			  ,	
    output reg [23:0]   K2_THR23			  ,	
    output reg [23:0]   K2_THR24			  ,	
    output reg [23:0]   K2_THR25			  ,	
    output reg [23:0]   K2_THR26			  ,	
    output reg [23:0]   K2_THR27			  ,	
    output reg [23:0]   K2_THR28			  ,	
    output reg [23:0]   K2_THR29			  ,	
	
	
//	output reg [31:0]   PULSE_FREQ      ,
//SPI	
	input				SPI_CS	          ,
	input				SPI_SDI	          ,
	input				SPI_SCLK          ,
	output  			SPI_SDO	        
);


parameter READ_ID = 32'd03010730;	//match

//SPI

//wire 			RD;
wire 			WR;
wire  [14:0]	RDAddr; 
wire  [14:0]	WrAddr;
wire  [47:0]	WRData;
reg   [47:0]	RDData;   
reg   [47:0]	demod_pack;
reg   [31:0]    PULSE_FREQ;

assign demod_wr_en = demod_pack[0];
assign demod_wr_addr = demod_pack[15:1];
assign demod_wr_data = demod_pack[47:16];
assign w_RDAddr = RDAddr;


//reg [31:0] r_detect_pulse;
always@(posedge i_clk or posedge i_rst)begin
    if(i_rst)
	    r_detect_pulse <= DEFAULT_detect_pulse_width;
	else if(PULSE_FREQ >=32'd10_000)
	    r_detect_pulse <= 32'd50_000;
    else if(PULSE_FREQ >=32'd1000 && PULSE_FREQ <2'd10_000)
	    r_detect_pulse <= 32'd500_000;
    else if(PULSE_FREQ >= 32'd100 && PULSE_FREQ <2'd1000)	
	    r_detect_pulse <= 32'd5000_000;
    else 
	    r_detect_pulse <= r_detect_pulse;
end

		
always @(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin 
		DEBUG_LED        <= 8'B0101_0101;	
		RF_FREQ0         <= 0;	
		RF_FREQ1         <= 0;	
		RF_FREQ2         <= 0;			
		RF_FREQ3         <= 0;	
		RF_FREQ4         <= 0;	
		
		BIAS_SET         <= 0;
		CALIB_R          <= 0;
		CALIB_JX         <= 0;
		
        FREQ0_CALIB_MODE <= 0; //上电默认进入校准计算K，此时没算出来用默认的ORIG_K; 		
        FREQ2_CALIB_MODE <= 0; //上电默认进入校准计算K，此时没算出来用默认的ORIG_K;		
		
		ORIG_K0		     <= 69300;//19770;		//*2^24
		ORIG_K2		     <= 69300;//19770;		//*2^24
        POWER_FREQ_COEF0 <= 257694000	;	//default :13.56M ;	HF  60M：60M
		POWER_FREQ_COEF1 <= 58239757	;	//default :13.56M ;	OS
		POWER_FREQ_COEF2 <= 58239757	;	//default :13.56M ;	LF
        POWER_FREQ_COEF3 <= 58239757	;		
        POWER_FREQ_COEF4 <= 58239757	;	
	
		HF_THRESHOLD2ON     <= 31 ;//小功率 脉冲 26  ；max:(-8191,8191) ; (-7500,7500);检波频率错误看这里；
		HF_MEASURE_PERIOD   <= 640000 ;//10ms=10 000 000/15.625 = 640 000;

		LF_THRESHOLD2ON     <= 31 ;//小功率 脉冲 26  ；max:(-8191,8191) ; (-7500,7500);检波频率错误看这里；
		LF_MEASURE_PERIOD   <= 640000 ;//10ms=10 000 000/15.625 = 640 000;

		OS0_THRESHOLD2ON     <= 12 ;//小功率 脉冲 26  ；max:(-8191,8191) ; (-7500,7500);检波频率错误看这里；
		OS0_MEASURE_PERIOD   <= 640000 ;//10ms=10 000 000/15.625 = 640 000;
		
		OS1_THRESHOLD2ON     <= 12 ;//小功率 脉冲 26  ；max:(-8191,8191) ; (-7500,7500);检波频率错误看这里；
		OS1_MEASURE_PERIOD   <= 640000 ;//10ms=10 000 000/15.625 = 640 000;
		
		OS2_THRESHOLD2ON     <= 12 ;//小功率 脉冲 26  ；max:(-8191,8191) ; (-7500,7500);检波频率错误看这里；
		OS2_MEASURE_PERIOD   <= 640000 ;//10ms=10 000 000/15.625 = 640 000;


        MOTO1_PARA1      <= 'd0;
        MOTO1_PARA2      <= 'h00060000000A;
        MOTO2_PARA1      <= 'd0;
        MOTO2_PARA2      <= 'h00060000000A;
        MOTO3_PARA1      <= 'd0;
        MOTO3_PARA2      <= 'h00060000000A;
        MOTO4_PARA1      <= 'd0;
        MOTO4_PARA2      <= 'h00060000000A;
        MOTO5_PARA1      <= 'd0;
        MOTO5_PARA2      <= 'h00060000000A;
        MOTO6_PARA1      <= 'd0;
        MOTO6_PARA2      <= 'h00060000000A;
        MOTO7_PARA1      <= 'd0;
        MOTO7_PARA2      <= 'h00060000000A;    
        MOTO8_PARA1      <= 'd0;
        MOTO8_PARA2      <= 'h00060000000A;					 

//--------------------------------------------------------
        POWER_THRESHOLD         <= DEFAULT_power_threshold    ;
		
        DETECT_RISE_DLY         <= DEFUALT_detect_rise_dly    ;
        DETECT_FALL_DLY         <= DEFUALT_detect_fall_dly    ;
		RISE_JUMP               <= DEFUALT_rise_jump          ;
		FALL_JUMP               <= DEFUALT_fall_jump          ;	
		
        DETECT_RISE_DLY2        <= DEFUALT_detect_rise_dly2   ;
        DETECT_FALL_DLY2        <= DEFUALT_detect_fall_dly2   ;
		RISE_JUMP2              <= DEFUALT_rise_jump2         ;
		FALL_JUMP2              <= DEFUALT_fall_jump2         ;			
		
		
		FILTER_THRESHOLD        <= DEFUALT_filter_threshold   ;
		PULSE_START             <= DEFAULT_pulse_start        ;
        PULSE_END               <= DEFAULT_pulse_end          ;		
		
		PULSE_START2            <= DEFAULT_pulse_start2       ;
        PULSE_END2              <= DEFAULT_pulse_end2         ;		
		
		POWER_PWM_DLY0          <= DEFAULT_power_pwm_dly0      ;	
		POWER_PWM_DLY2          <= DEFAULT_power_pwm_dly2      ;	
		
        OS0_DETECT_RISE_DLY     <= DEFUALT_OS0_detect_rise_dly ;
        OS0_DETECT_FALL_DLY     <= DEFUALT_OS0_detect_fall_dly ;
		OS0_RISE_JUMP           <= DEFUALT_OS0_rise_jump       ;
		OS0_FALL_JUMP           <= DEFUALT_OS0_fall_jump       ;	
		OS0_FILTER_THRESHOLD    <= DEFUALT_OS0_filter_threshold;
		OS0_PULSE_START         <= DEFAULT_OS0_pulse_start     ;
        OS0_PULSE_END           <= DEFAULT_OS0_pulse_end       ;			
		I_PWM_DLY               <= DEFAULT_i_pwm_dly           ;	

        OS1_DETECT_RISE_DLY     <= DEFUALT_OS1_detect_rise_dly ;
        OS1_DETECT_FALL_DLY     <= DEFUALT_OS1_detect_fall_dly ;
		OS1_RISE_JUMP           <= DEFUALT_OS1_rise_jump       ;
		OS1_FALL_JUMP           <= DEFUALT_OS1_fall_jump       ;	
		OS1_FILTER_THRESHOLD    <= DEFUALT_OS1_filter_threshold;
		OS1_PULSE_START         <= DEFAULT_OS1_pulse_start     ;
        OS1_PULSE_END           <= DEFAULT_OS1_pulse_end       ;			
		I1_PWM_DLY              <= DEFAULT_i1_pwm_dly          ;	

        OS2_DETECT_RISE_DLY     <= DEFUALT_OS2_detect_rise_dly ;
        OS2_DETECT_FALL_DLY     <= DEFUALT_OS2_detect_fall_dly ;
		OS2_RISE_JUMP           <= DEFUALT_OS2_rise_jump       ;
		OS2_FALL_JUMP           <= DEFUALT_OS2_fall_jump       ;	
		OS2_FILTER_THRESHOLD    <= DEFUALT_OS2_filter_threshold;
		OS2_PULSE_START         <= DEFAULT_OS2_pulse_start     ;
        OS2_PULSE_END           <= DEFAULT_OS2_pulse_end       ;			
		I2_PWM_DLY              <= DEFAULT_i2_pwm_dly          ;	


        OS1_400K_DETECT_RISE_DLY  <= DEFUALT_OS1_400k_detect_rise_dly ;
        OS1_400K_DETECT_FALL_DLY  <= DEFUALT_OS1_400k_detect_fall_dly ;
		OS1_400K_RISE_JUMP        <= DEFUALT_OS1_400k_rise_jump       ;
		OS1_400K_FALL_JUMP        <= DEFUALT_OS1_400k_fall_jump       ;	
		OS1_400K_FILTER_THRESHOLD <= DEFUALT_OS1_400k_filter_threshold;
		OS1_400K_PULSE_START      <= DEFAULT_OS1_400k_pulse_start     ;
        OS1_400K_PULSE_END        <= DEFAULT_OS1_400k_pulse_end       ;			
		I1_PWM_DLY_400K           <= DEFAULT_i1_pwm_dly_400K          ;	

        OS2_400K_DETECT_RISE_DLY  <= DEFUALT_OS2_400k_detect_rise_dly ;
        OS2_400K_DETECT_FALL_DLY  <= DEFUALT_OS2_400k_detect_fall_dly ;
		OS2_400K_RISE_JUMP        <= DEFUALT_OS2_400k_rise_jump       ;
		OS2_400K_FALL_JUMP        <= DEFUALT_OS2_400k_fall_jump       ;	
		OS2_400K_FILTER_THRESHOLD <= DEFUALT_OS2_400k_filter_threshold;
		OS2_400K_PULSE_START      <= DEFAULT_OS2_400k_pulse_start     ;
        OS2_400K_PULSE_END        <= DEFAULT_OS2_400k_pulse_end       ;			
		I2_PWM_DLY_400K           <= DEFAULT_i2_pwm_dly_400K          ;	



		
		KEEP_DLY                <= DEFUALT_keep_dly           ;	
		
		FFT_PERIOD              <= DEFUALT_fft_period         ;
		TDM_DIV_COEF            <= DEFUALT_division_coef      ;
		
		MATCH_DETECT            <= DEFAULT_match_detect       ;
		
		DETECT_PULSE_WIDTH      <= DEFAULT_detect_pulse_width ;
		MATCH_ON_DLY            <= DEFAULT_match_on_dly       ;
		OFF_NUM                 <= DEFAULT_off_num            ;

		DETECT_PULSE_WIDTH1     <= DEFAULT_detect_pulse_width1;
		MATCH_ON_DLY1           <= DEFAULT_match_on_dly1      ;
		OFF_NUM1                <= DEFAULT_off_num1           ;

		DETECT_PULSE_WIDTH2     <= DEFAULT_detect_pulse_width2;
		MATCH_ON_DLY2           <= DEFAULT_match_on_dly2      ;
		OFF_NUM2                <= DEFAULT_off_num2           ;

		DETECT_PULSE_WIDTH3     <= DEFAULT_detect_pulse_width3;
		MATCH_ON_DLY3           <= DEFAULT_match_on_dly3      ;
		OFF_NUM3                <= DEFAULT_off_num3           ;

		DETECT_PULSE_WIDTH4     <= DEFAULT_detect_pulse_width4;
		MATCH_ON_DLY4           <= DEFAULT_match_on_dly4      ;
		OFF_NUM4                <= DEFAULT_off_num4           ;


        DETECT_PULSE_WIDTH3_400K <= DEFAULT_detect_pulse_width3_400k;
        MATCH_ON_DLY3_400K       <= DEFAULT_match_on_dly3_400k      ;
        OFF_NUM3_400K            <= DEFAULT_off_num3_400k           ;
                                   
        DETECT_PULSE_WIDTH4_400K <= DEFAULT_detect_pulse_width4_400k;
        MATCH_ON_DLY4_400K       <= DEFAULT_match_on_dly4_400k      ;
        OFF_NUM4_400K            <= DEFAULT_off_num4_400k           ;
  
        ON_KEEP_NUM              <= 1000;
        OFF_KEEP_NUM             <= 3000; 
  
		
		PULSE_FREQ              <= DEFAULT_pulse_freq         ;
		TDM_PERIOD              <= DEFAULT_tdm_period         ;
		POWER_CALLAPSE          <= DEFAULT_power_callapse     ;
		R_JX_CALLAPSE           <= DEFAULT_r_jx_callapse      ;
		DECOR_PULSE             <= 0;


	end 
	else if(WR)
		case(WrAddr)
		ID_DEBUG_LED			:	DEBUG_LED			<= WRData;
		ID_dco_dly 				:	dco_dly				<= WRData;
		ID_BIAS_SET				:	BIAS_SET			<= WRData;
		ID_RF_EN				:	RF_EN			    <= WRData;
		ID_SET_POINT_VAL		:	SET_POINT_VAL	    <= WRData;
		ID_RF_FREQ0				:	RF_FREQ0		  	<= WRData;
		ID_RF_FREQ1				:	RF_FREQ1		  	<= WRData;
		ID_RF_FREQ2				:	RF_FREQ2		  	<= WRData;	
		ID_RF_FREQ3				:	RF_FREQ3		  	<= WRData;
		ID_RF_FREQ4				:	RF_FREQ4		  	<= WRData;	
		
		ID_FREQ0_CALIB_MODE     :   FREQ0_CALIB_MODE    <= WRData;
		ID_FREQ2_CALIB_MODE     :   FREQ2_CALIB_MODE    <= WRData;	
		
		ID_ADC_RAM_EN			:	ADC_RAM_EN			<= WRData;
		ID_ADC_RAM_RD_ADDR		:	ADC_RAM_RD_ADDR		<= WRData;
		ID_demod_pack			:	demod_pack	 		<= WRData;
		
		ID_adc0_mean0			:	adc0_mean0		    <= WRData;
		ID_adc1_mean0			:	adc1_mean0		    <= WRData;
		
	    ID_adc0_mean1			:	adc0_mean1		    <= WRData;	
		ID_adc1_mean1			:	adc1_mean1		    <= WRData;
		
	    ID_adc0_mean2			:	adc0_mean2		    <= WRData;	
		ID_adc1_mean2			:	adc1_mean2		    <= WRData;
	    ID_adc0_mean3			:	adc0_mean3		    <= WRData;	
		ID_adc1_mean3			:	adc1_mean3		    <= WRData;
	    ID_adc0_mean4			:	adc0_mean4		    <= WRData;	
		ID_adc1_mean4			:	adc1_mean4		    <= WRData;
		
	    ID_adc0_mean3_400k		:	adc0_mean3_400k		<= WRData;	
		ID_adc1_mean3_400k		:	adc1_mean3_400k		<= WRData;
	    ID_adc0_mean4_400k		:	adc0_mean4_400k		<= WRData;	
		ID_adc1_mean4_400k		:	adc1_mean4_400k		<= WRData;





		
		ID_m1a00_ch0   			:	m1a00_ch0     		<= WRData;
		ID_m1a01_ch0   			:	m1a01_ch0     		<= WRData;
		ID_m1a10_ch0   			:	m1a10_ch0     		<= WRData;
		ID_m1a11_ch0   			:	m1a11_ch0     		<= WRData;
		
		ID_m1a00_ch1   			:	m1a00_ch1     		<= WRData;
		ID_m1a01_ch1   			:	m1a01_ch1     		<= WRData;
		ID_m1a10_ch1   			:	m1a10_ch1     		<= WRData;
		ID_m1a11_ch1   			:	m1a11_ch1     		<= WRData;
		
		ID_m1a00_ch2   			:	m1a00_ch2    		<= WRData;
		ID_m1a01_ch2   			:	m1a01_ch2    		<= WRData;
		ID_m1a10_ch2   			:	m1a10_ch2    		<= WRData;
		ID_m1a11_ch2   			:	m1a11_ch2    		<= WRData;
		ID_m1a00_ch3   			:	m1a00_ch3    		<= WRData;
		ID_m1a01_ch3   			:	m1a01_ch3    		<= WRData;
		ID_m1a10_ch3   			:	m1a10_ch3    		<= WRData;
		ID_m1a11_ch3   			:	m1a11_ch3    		<= WRData;
		ID_m1a00_ch4   			:	m1a00_ch4    		<= WRData;
		ID_m1a01_ch4   			:	m1a01_ch4    		<= WRData;
		ID_m1a10_ch4   			:	m1a10_ch4    		<= WRData;
		ID_m1a11_ch4   			:	m1a11_ch4    		<= WRData;


		ID_m1a00_ch3_400k   	:   m1a00_ch3_400k      <= WRData;
		ID_m1a01_ch3_400k   	:   m1a01_ch3_400k      <= WRData;
		ID_m1a10_ch3_400k   	:   m1a10_ch3_400k      <= WRData;
		ID_m1a11_ch3_400k   	:   m1a11_ch3_400k      <= WRData;
		ID_m1a00_ch4_400k   	:   m1a00_ch4_400k      <= WRData;
		ID_m1a01_ch4_400k   	:   m1a01_ch4_400k      <= WRData;
		ID_m1a10_ch4_400k   	:   m1a10_ch4_400k      <= WRData;
		ID_m1a11_ch4_400k   	:   m1a11_ch4_400k      <= WRData;


       
        ID_moto1_para1          :   MOTO1_PARA1         <= WRData;
        ID_moto1_para2          :   MOTO1_PARA2         <= WRData;
        ID_moto2_para1          :   MOTO2_PARA1         <= WRData;
        ID_moto2_para2          :   MOTO2_PARA2         <= WRData;
        ID_moto3_para1          :   MOTO3_PARA1         <= WRData;
        ID_moto3_para2          :   MOTO3_PARA2         <= WRData;
        ID_moto4_para1          :   MOTO4_PARA1         <= WRData;
        ID_moto4_para2          :   MOTO4_PARA2         <= WRData;
        ID_moto5_para1          :   MOTO5_PARA1         <= WRData;
        ID_moto5_para2          :   MOTO5_PARA2         <= WRData;
        ID_moto6_para1          :   MOTO6_PARA1         <= WRData;
        ID_moto6_para2          :   MOTO6_PARA2         <= WRData;
        ID_moto7_para1          :   MOTO7_PARA1         <= WRData;
        ID_moto7_para2          :   MOTO7_PARA2         <= WRData;
        ID_moto8_para1          :   MOTO8_PARA1         <= WRData;
        ID_moto8_para2          :   MOTO8_PARA2         <= WRData;	
		ID_decor_pulse          :   DECOR_PULSE         <= WRData[0];	

		
		ID_CALIB_R 				 :	CALIB_R 			<= WRData;
		ID_CALIB_JX				 :	CALIB_JX			<= WRData;
								 
		ID_ORIG_K0				 :	ORIG_K0				<= WRData;
		ID_ORIG_K2				 :	ORIG_K2				<= WRData;		
		
		ID_POWER0_CALIB_K0       :  POWER0_CALIB_K0	        <= WRData;
		ID_POWER0_CALIB_K1       :  POWER0_CALIB_K1	        <= WRData;
		ID_POWER0_CALIB_K2       :  POWER0_CALIB_K2	        <= WRData;
		ID_POWER0_CALIB_K3       :  POWER0_CALIB_K3	        <= WRData;
		ID_POWER0_CALIB_K4       :  POWER0_CALIB_K4	        <= WRData;
		ID_POWER0_CALIB_K5       :  POWER0_CALIB_K5	        <= WRData;
		ID_POWER0_CALIB_K6       :  POWER0_CALIB_K6	        <= WRData;
		ID_POWER0_CALIB_K7       :  POWER0_CALIB_K7	        <= WRData;
		ID_POWER0_CALIB_K8       :  POWER0_CALIB_K8	        <= WRData;
		ID_POWER0_CALIB_K9       :  POWER0_CALIB_K9	        <= WRData;
		ID_POWER0_CALIB_K10      :	POWER0_CALIB_K10	    <= WRData;
		ID_POWER0_CALIB_K11      :	POWER0_CALIB_K11	    <= WRData;
		ID_POWER0_CALIB_K12      :	POWER0_CALIB_K12	    <= WRData;
		ID_POWER0_CALIB_K13      :	POWER0_CALIB_K13	    <= WRData;
		ID_POWER0_CALIB_K14      :	POWER0_CALIB_K14	    <= WRData;
		ID_POWER0_CALIB_K15      :	POWER0_CALIB_K15	    <= WRData;
		ID_POWER0_CALIB_K16      :	POWER0_CALIB_K16	    <= WRData;
		ID_POWER0_CALIB_K17      :	POWER0_CALIB_K17	    <= WRData;
		ID_POWER0_CALIB_K18      :	POWER0_CALIB_K18	    <= WRData;
		ID_POWER0_CALIB_K19      :	POWER0_CALIB_K19	    <= WRData;
		ID_POWER0_CALIB_K20      :	POWER0_CALIB_K20	    <= WRData;
		ID_POWER0_CALIB_K21      :	POWER0_CALIB_K21	    <= WRData;
		ID_POWER0_CALIB_K22      :	POWER0_CALIB_K22	    <= WRData;
		ID_POWER0_CALIB_K23      :	POWER0_CALIB_K23	    <= WRData;
		ID_POWER0_CALIB_K24      :	POWER0_CALIB_K24	    <= WRData;
		ID_POWER0_CALIB_K25      :	POWER0_CALIB_K25	    <= WRData;
		ID_POWER0_CALIB_K26      :	POWER0_CALIB_K26	    <= WRData;
		ID_POWER0_CALIB_K27      :	POWER0_CALIB_K27	    <= WRData;
		ID_POWER0_CALIB_K28      :	POWER0_CALIB_K28	    <= WRData;
		ID_POWER0_CALIB_K29      :	POWER0_CALIB_K29	    <= WRData;
		
        ID_FREQ0_THR0            :   FREQ0_THR0 		    <= WRData;				
        ID_FREQ0_THR1            :   FREQ0_THR1 		    <= WRData;				
        ID_FREQ0_THR2            :   FREQ0_THR2 		    <= WRData;				
        ID_FREQ0_THR3            :   FREQ0_THR3 		    <= WRData;				
        ID_FREQ0_THR4            :   FREQ0_THR4 		    <= WRData;				
        ID_FREQ0_THR5            :   FREQ0_THR5 		    <= WRData;				
        ID_FREQ0_THR6            :   FREQ0_THR6 		    <= WRData;				
        ID_FREQ0_THR7            :   FREQ0_THR7 		    <= WRData;				
        ID_FREQ0_THR8            :   FREQ0_THR8 		    <= WRData;				
        ID_FREQ0_THR9            :   FREQ0_THR9 		    <= WRData;				
        ID_FREQ0_THR10           :   FREQ0_THR10		    <= WRData;				
        ID_FREQ0_THR11           :   FREQ0_THR11		    <= WRData;				
        ID_FREQ0_THR12           :   FREQ0_THR12		    <= WRData;				
        ID_FREQ0_THR13           :   FREQ0_THR13		    <= WRData;				
        ID_FREQ0_THR14           :   FREQ0_THR14		    <= WRData;				
        ID_FREQ0_THR15           :   FREQ0_THR15		    <= WRData;				
        ID_FREQ0_THR16           :   FREQ0_THR16		    <= WRData;				
        ID_FREQ0_THR17           :   FREQ0_THR17		    <= WRData;				
        ID_FREQ0_THR18           :   FREQ0_THR18		    <= WRData;				
        ID_FREQ0_THR19           :   FREQ0_THR19		    <= WRData;				
        ID_FREQ0_THR20           :   FREQ0_THR20		    <= WRData;				
        ID_FREQ0_THR21           :   FREQ0_THR21		    <= WRData;				
        ID_FREQ0_THR22           :   FREQ0_THR22		    <= WRData;				
        ID_FREQ0_THR23           :   FREQ0_THR23		    <= WRData;				
        ID_FREQ0_THR24           :   FREQ0_THR24		    <= WRData;				
        ID_FREQ0_THR25           :   FREQ0_THR25		    <= WRData;				
        ID_FREQ0_THR26           :   FREQ0_THR26		    <= WRData;				
        ID_FREQ0_THR27           :   FREQ0_THR27		    <= WRData;				
        ID_FREQ0_THR28           :   FREQ0_THR28		    <= WRData;				
        ID_FREQ0_THR29           :   FREQ0_THR29		    <= WRData;				
        ID_FREQ0_THR30           :   FREQ0_THR30		    <= WRData;	

        ID_K0_THR0 				 :   K0_THR0                <= WRData;				
        ID_K0_THR1 				 :   K0_THR1                <= WRData;				
        ID_K0_THR2 				 :   K0_THR2                <= WRData;				
        ID_K0_THR3 				 :   K0_THR3                <= WRData;				
        ID_K0_THR4 				 :   K0_THR4                <= WRData;				
        ID_K0_THR5 				 :   K0_THR5                <= WRData;				
        ID_K0_THR6 				 :   K0_THR6                <= WRData;				
        ID_K0_THR7 				 :   K0_THR7                <= WRData;				
        ID_K0_THR8 				 :   K0_THR8                <= WRData;				
        ID_K0_THR9 				 :   K0_THR9                <= WRData;				
        ID_K0_THR10				 :   K0_THR10               <= WRData;				
        ID_K0_THR11				 :   K0_THR11               <= WRData;				
        ID_K0_THR12				 :   K0_THR12               <= WRData;				
        ID_K0_THR13				 :   K0_THR13               <= WRData;				
        ID_K0_THR14				 :   K0_THR14               <= WRData;				
        ID_K0_THR15				 :   K0_THR15               <= WRData;				
        ID_K0_THR16				 :   K0_THR16               <= WRData;				
        ID_K0_THR17				 :   K0_THR17               <= WRData;				
        ID_K0_THR18				 :   K0_THR18               <= WRData;				
        ID_K0_THR19				 :   K0_THR19               <= WRData;				
        ID_K0_THR20				 :   K0_THR20               <= WRData;				
        ID_K0_THR21				 :   K0_THR21               <= WRData;				
        ID_K0_THR22				 :   K0_THR22               <= WRData;				
        ID_K0_THR23				 :   K0_THR23               <= WRData;				
        ID_K0_THR24				 :   K0_THR24               <= WRData;				
        ID_K0_THR25				 :   K0_THR25               <= WRData;				
        ID_K0_THR26				 :   K0_THR26               <= WRData;				
        ID_K0_THR27				 :   K0_THR27               <= WRData;				
        ID_K0_THR28				 :   K0_THR28               <= WRData;				
        ID_K0_THR29				 :   K0_THR29               <= WRData;				
							     
		ID_POWER2_CALIB_K0	     :   POWER2_CALIB_K0	    <= WRData;
		ID_POWER2_CALIB_K1	     :   POWER2_CALIB_K1	    <= WRData;
		ID_POWER2_CALIB_K2	     :   POWER2_CALIB_K2	    <= WRData;
		ID_POWER2_CALIB_K3	     :   POWER2_CALIB_K3	    <= WRData;
		ID_POWER2_CALIB_K4	     :   POWER2_CALIB_K4	    <= WRData;
		ID_POWER2_CALIB_K5	     :   POWER2_CALIB_K5	    <= WRData;
		ID_POWER2_CALIB_K6	     :   POWER2_CALIB_K6	    <= WRData;
		ID_POWER2_CALIB_K7	     :   POWER2_CALIB_K7	    <= WRData;
		ID_POWER2_CALIB_K8	     :   POWER2_CALIB_K8	    <= WRData;
		ID_POWER2_CALIB_K9	     :   POWER2_CALIB_K9	    <= WRData;
		ID_POWER2_CALIB_K10      :	 POWER2_CALIB_K10	    <= WRData;
		ID_POWER2_CALIB_K11      :	 POWER2_CALIB_K11	    <= WRData;
		ID_POWER2_CALIB_K12      :	 POWER2_CALIB_K12	    <= WRData;
		ID_POWER2_CALIB_K13      :	 POWER2_CALIB_K13	    <= WRData;
		ID_POWER2_CALIB_K14      :	 POWER2_CALIB_K14	    <= WRData;
		ID_POWER2_CALIB_K15      :	 POWER2_CALIB_K15	    <= WRData;
		ID_POWER2_CALIB_K16      :	 POWER2_CALIB_K16	    <= WRData;
		ID_POWER2_CALIB_K17      :	 POWER2_CALIB_K17	    <= WRData;
		ID_POWER2_CALIB_K18      :	 POWER2_CALIB_K18	    <= WRData;
		ID_POWER2_CALIB_K19      :	 POWER2_CALIB_K19	    <= WRData;
		ID_POWER2_CALIB_K20      :	 POWER2_CALIB_K20	    <= WRData;
		ID_POWER2_CALIB_K21      :	 POWER2_CALIB_K21	    <= WRData;
		ID_POWER2_CALIB_K22      :	 POWER2_CALIB_K22	    <= WRData;
		ID_POWER2_CALIB_K23      :	 POWER2_CALIB_K23	    <= WRData;
		ID_POWER2_CALIB_K24      :	 POWER2_CALIB_K24	    <= WRData;
		ID_POWER2_CALIB_K25      :	 POWER2_CALIB_K25	    <= WRData;
		ID_POWER2_CALIB_K26      :	 POWER2_CALIB_K26	    <= WRData;
		ID_POWER2_CALIB_K27      :	 POWER2_CALIB_K27	    <= WRData;
		ID_POWER2_CALIB_K28      :	 POWER2_CALIB_K28	    <= WRData;
		ID_POWER2_CALIB_K29      :	 POWER2_CALIB_K29	    <= WRData;
							    
        ID_FREQ2_THR0            :   FREQ2_THR0 		    <= WRData;				
        ID_FREQ2_THR1            :   FREQ2_THR1 		    <= WRData;				
        ID_FREQ2_THR2            :   FREQ2_THR2 		    <= WRData;				
        ID_FREQ2_THR3            :   FREQ2_THR3 		    <= WRData;				
        ID_FREQ2_THR4            :   FREQ2_THR4 		    <= WRData;				
        ID_FREQ2_THR5            :   FREQ2_THR5 		    <= WRData;				
        ID_FREQ2_THR6            :   FREQ2_THR6 		    <= WRData;				
        ID_FREQ2_THR7            :   FREQ2_THR7 		    <= WRData;				
        ID_FREQ2_THR8            :   FREQ2_THR8 		    <= WRData;				
        ID_FREQ2_THR9            :   FREQ2_THR9 		    <= WRData;				
        ID_FREQ2_THR10           :   FREQ2_THR10		    <= WRData;				
        ID_FREQ2_THR11           :   FREQ2_THR11		    <= WRData;				
        ID_FREQ2_THR12           :   FREQ2_THR12		    <= WRData;				
        ID_FREQ2_THR13           :   FREQ2_THR13		    <= WRData;				
        ID_FREQ2_THR14           :   FREQ2_THR14		    <= WRData;				
        ID_FREQ2_THR15           :   FREQ2_THR15		    <= WRData;				
        ID_FREQ2_THR16           :   FREQ2_THR16		    <= WRData;				
        ID_FREQ2_THR17           :   FREQ2_THR17		    <= WRData;				
        ID_FREQ2_THR18           :   FREQ2_THR18		    <= WRData;				
        ID_FREQ2_THR19           :   FREQ2_THR19		    <= WRData;				
        ID_FREQ2_THR20           :   FREQ2_THR20		    <= WRData;				
        ID_FREQ2_THR21           :   FREQ2_THR21		    <= WRData;				
        ID_FREQ2_THR22           :   FREQ2_THR22		    <= WRData;				
        ID_FREQ2_THR23           :   FREQ2_THR23		    <= WRData;				
        ID_FREQ2_THR24           :   FREQ2_THR24		    <= WRData;				
        ID_FREQ2_THR25           :   FREQ2_THR25		    <= WRData;				
        ID_FREQ2_THR26           :   FREQ2_THR26		    <= WRData;				
        ID_FREQ2_THR27           :   FREQ2_THR27		    <= WRData;				
        ID_FREQ2_THR28           :   FREQ2_THR28		    <= WRData;				
        ID_FREQ2_THR29           :   FREQ2_THR29		    <= WRData;				
        ID_FREQ2_THR30           :   FREQ2_THR30		    <= WRData;	
										 
        ID_K2_THR0 				 :   K2_THR0                <= WRData;				
        ID_K2_THR1 				 :   K2_THR1                <= WRData;				
        ID_K2_THR2 				 :   K2_THR2                <= WRData;				
        ID_K2_THR3 				 :   K2_THR3                <= WRData;				
        ID_K2_THR4 				 :   K2_THR4                <= WRData;				
        ID_K2_THR5 				 :   K2_THR5                <= WRData;				
        ID_K2_THR6 				 :   K2_THR6                <= WRData;				
        ID_K2_THR7 				 :   K2_THR7                <= WRData;				
        ID_K2_THR8 				 :   K2_THR8                <= WRData;				
        ID_K2_THR9 				 :   K2_THR9                <= WRData;				
        ID_K2_THR10				 :   K2_THR10               <= WRData;				
        ID_K2_THR11				 :   K2_THR11               <= WRData;				
        ID_K2_THR12				 :   K2_THR12               <= WRData;				
        ID_K2_THR13				 :   K2_THR13               <= WRData;				
        ID_K2_THR14				 :   K2_THR14               <= WRData;				
        ID_K2_THR15				 :   K2_THR15               <= WRData;				
        ID_K2_THR16				 :   K2_THR16               <= WRData;				
        ID_K2_THR17				 :   K2_THR17               <= WRData;				
        ID_K2_THR18				 :   K2_THR18               <= WRData;				
        ID_K2_THR19				 :   K2_THR19               <= WRData;				
        ID_K2_THR20				 :   K2_THR20               <= WRData;				
        ID_K2_THR21				 :   K2_THR21               <= WRData;				
        ID_K2_THR22				 :   K2_THR22               <= WRData;				
        ID_K2_THR23				 :   K2_THR23               <= WRData;				
        ID_K2_THR24				 :   K2_THR24               <= WRData;				
        ID_K2_THR25				 :   K2_THR25               <= WRData;				
        ID_K2_THR26				 :   K2_THR26               <= WRData;				
        ID_K2_THR27				 :   K2_THR27               <= WRData;				
        ID_K2_THR28				 :   K2_THR28               <= WRData;				
        ID_K2_THR29				 :   K2_THR29               <= WRData;			
		
	
//******************************************************************		
        ID_power_threshold           :  POWER_THRESHOLD           <= WRData;
								     						      
		ID_filter_threshold          :  FILTER_THRESHOLD          <= WRData;		
        ID_detect_rise_dly           :  DETECT_RISE_DLY           <= WRData;	
        ID_detect_fall_dly           :  DETECT_FALL_DLY           <= WRData;
		ID_rise_jump                 :  RISE_JUMP                 <= WRData;
		ID_fall_jump                 :  FALL_JUMP                 <= WRData;
								     						      
        ID_detect_rise_dly2          :  DETECT_RISE_DLY2          <= WRData;	
        ID_detect_fall_dly2          :  DETECT_FALL_DLY2          <= WRData;
		ID_rise_jump2                :  RISE_JUMP2                <= WRData;
		ID_fall_jump2                :  FALL_JUMP2                <= WRData;		
								     						      
		ID_pulse_start               :  PULSE_START               <= WRData;
		ID_pulse_end                 :  PULSE_END                 <= WRData;	
								     						     
		ID_pulse_start2              :  PULSE_START2              <= WRData;
		ID_pulse_end2                :  PULSE_END2                <= WRData;			
								     						     
		ID_power_pwm_dly0            :  POWER_PWM_DLY0            <= WRData;
		ID_power_pwm_dly2            :  POWER_PWM_DLY2            <= WRData;
								        
								        
		ID_OS0_filter_threshold      :  OS0_FILTER_THRESHOLD      <= WRData;		
        ID_OS0_detect_rise_dly       :  OS0_DETECT_RISE_DLY       <= WRData;	
        ID_OS0_detect_fall_dly       :  OS0_DETECT_FALL_DLY       <= WRData;
		ID_OS0_rise_jump             :  OS0_RISE_JUMP             <= WRData;
		ID_OS0_fall_jump             :  OS0_FALL_JUMP             <= WRData;
		ID_OS0_pulse_start           :  OS0_PULSE_START           <= WRData;
		ID_OS0_pulse_end             :  OS0_PULSE_END             <= WRData;	
		ID_i_pwm_dly                 :  I_PWM_DLY                 <= WRData;		
								     						      
		ID_OS1_filter_threshold      :  OS1_FILTER_THRESHOLD      <= WRData;		
        ID_OS1_detect_rise_dly       :  OS1_DETECT_RISE_DLY       <= WRData;	
        ID_OS1_detect_fall_dly       :  OS1_DETECT_FALL_DLY       <= WRData;
		ID_OS1_rise_jump             :  OS1_RISE_JUMP             <= WRData;
		ID_OS1_fall_jump             :  OS1_FALL_JUMP             <= WRData;
		ID_OS1_pulse_start           :  OS1_PULSE_START           <= WRData;
		ID_OS1_pulse_end             :  OS1_PULSE_END             <= WRData;	
		ID_i1_pwm_dly                :  I1_PWM_DLY                <= WRData;	
								     						      
		ID_OS2_filter_threshold      :  OS2_FILTER_THRESHOLD      <= WRData;		
        ID_OS2_detect_rise_dly       :  OS2_DETECT_RISE_DLY       <= WRData;	
        ID_OS2_detect_fall_dly       :  OS2_DETECT_FALL_DLY       <= WRData;
		ID_OS2_rise_jump             :  OS2_RISE_JUMP             <= WRData;
		ID_OS2_fall_jump             :  OS2_FALL_JUMP             <= WRData;
		ID_OS2_pulse_start           :  OS2_PULSE_START           <= WRData;
		ID_OS2_pulse_end             :  OS2_PULSE_END             <= WRData;	
		ID_i2_pwm_dly                :  I2_PWM_DLY                <= WRData;			

        ID_OS1_400K_DETECT_RISE_DLY  :  OS1_400K_DETECT_RISE_DLY  <= WRData;
        ID_OS1_400K_DETECT_FALL_DLY  :  OS1_400K_DETECT_FALL_DLY  <= WRData;
        ID_OS1_400K_RISE_JUMP        :  OS1_400K_RISE_JUMP        <= WRData;
        ID_OS1_400K_FALL_JUMP        :  OS1_400K_FALL_JUMP        <= WRData;
        ID_OS1_400K_FILTER_THRESHOLD :  OS1_400K_FILTER_THRESHOLD <= WRData;
        ID_OS1_400K_PULSE_START      :  OS1_400K_PULSE_START      <= WRData;
        ID_OS1_400K_PULSE_END        :  OS1_400K_PULSE_END        <= WRData;
        ID_I1_PWM_DLY_400K           :  I1_PWM_DLY_400K           <= WRData;
									   
        ID_OS2_400K_DETECT_RISE_DLY  :  OS2_400K_DETECT_RISE_DLY  <= WRData;
        ID_OS2_400K_DETECT_FALL_DLY  :  OS2_400K_DETECT_FALL_DLY  <= WRData;
        ID_OS2_400K_RISE_JUMP        :  OS2_400K_RISE_JUMP        <= WRData;
        ID_OS2_400K_FALL_JUMP        :  OS2_400K_FALL_JUMP        <= WRData;
        ID_OS2_400K_FILTER_THRESHOLD :  OS2_400K_FILTER_THRESHOLD <= WRData;
        ID_OS2_400K_PULSE_START      :  OS2_400K_PULSE_START      <= WRData;
        ID_OS2_400K_PULSE_END        :  OS2_400K_PULSE_END        <= WRData;
        ID_I2_PWM_DLY_400K           :  I2_PWM_DLY_400K           <= WRData;


        ID_keep_dly                  :   KEEP_DLY              <= WRData;			
		ID_fft_period                :   FFT_PERIOD            <= WRData; 
		ID_division_coef             :   TDM_DIV_COEF          <= WRData; 
		ID_match_detect              :   MATCH_DETECT          <= WRData;
								     						  
		ID_detect_pulse_width        :   DETECT_PULSE_WIDTH    <= WRData;
		ID_match_on_dly              :   MATCH_ON_DLY          <= WRData;  
		ID_off_num                   :   OFF_NUM               <= WRData;
								     
		ID_detect_pulse_width1        :   DETECT_PULSE_WIDTH1  <= WRData;
		ID_match_on_dly1              :   MATCH_ON_DLY1        <= WRData;  
		ID_off_num1                   :   OFF_NUM1             <= WRData;
								     
		ID_detect_pulse_width2       :   DETECT_PULSE_WIDTH2   <= WRData;
		ID_match_on_dly2             :   MATCH_ON_DLY2         <= WRData;  
		ID_off_num2                  :   OFF_NUM2              <= WRData;
								     						  
		ID_detect_pulse_width3       :   DETECT_PULSE_WIDTH3   <= WRData;
        ID_match_on_dly3             :   MATCH_ON_DLY3         <= WRData;
        ID_off_num3                  :   OFF_NUM3              <= WRData;
								     					    
		ID_detect_pulse_width4       :   DETECT_PULSE_WIDTH4   <= WRData;
        ID_match_on_dly4             :   MATCH_ON_DLY4         <= WRData;
        ID_off_num4                  :   OFF_NUM4              <= WRData;

		ID_detect_pulse_width3_400k  :  DETECT_PULSE_WIDTH3_400K<= WRData;
        ID_match_on_dly3_400k        :  MATCH_ON_DLY3_400K      <= WRData;
        ID_off_num3_400k             :  OFF_NUM3_400K           <= WRData;
									 
		ID_detect_pulse_width4_400k  :  DETECT_PULSE_WIDTH4_400K<= WRData;
        ID_match_on_dly4_400k        :  MATCH_ON_DLY4_400K      <= WRData;
        ID_off_num4_400k             :  OFF_NUM4_400K           <= WRData;

        ID_on_keep_num              : ON_KEEP_NUM               <= WRData;
        ID_off_keep_num             : OFF_KEEP_NUM              <= WRData;


													  
		ID_pulse_freq           :   PULSE_FREQ            <= WRData;
		ID_tdm_period           :   TDM_PERIOD            <= WRData;
        ID_power_callapse       :   POWER_CALLAPSE        <= WRData;
        ID_r_jx_callapse  		:   R_JX_CALLAPSE         <= WRData;
		ID_power_freq_coef0     :   POWER_FREQ_COEF0      <= WRData;
		ID_power_freq_coef1     :   POWER_FREQ_COEF1      <= WRData;
		ID_power_freq_coef2     :   POWER_FREQ_COEF2      <= WRData;		
		ID_power_freq_coef3     :   POWER_FREQ_COEF3      <= WRData;
		ID_power_freq_coef4     :   POWER_FREQ_COEF4      <= WRData;		
														  
														  
		ID_threshold2on0        :   HF_THRESHOLD2ON       <= WRData;
		ID_measure_period0      :   HF_MEASURE_PERIOD     <= WRData;
		ID_threshold2on1        :   LF_THRESHOLD2ON       <= WRData;
		ID_measure_period1      :   LF_MEASURE_PERIOD     <= WRData;	

		ID_threshold2on2        :   OS0_THRESHOLD2ON      <= WRData;
		ID_measure_period2      :   OS0_MEASURE_PERIOD    <= WRData;
		ID_threshold2on3        :   OS1_THRESHOLD2ON      <= WRData;
		ID_measure_period3      :   OS1_MEASURE_PERIOD    <= WRData;
		ID_threshold2on4        :   OS2_THRESHOLD2ON      <= WRData;
		ID_measure_period4      :   OS2_MEASURE_PERIOD    <= WRData;


		default :	;
		
		endcase
		else begin 
			demod_pack[0] <= 0;	//只拉高一个周期	
            MOTO1_PARA2[32]   <= 0;
			MOTO2_PARA2[32]   <= 0;
			MOTO3_PARA2[32]  <= 0;
			MOTO4_PARA2[32]  <= 0;
            MOTO5_PARA2[32]  <= 0;
            MOTO6_PARA2[32]  <= 0;
            MOTO7_PARA2[32]  <= 0;
            MOTO8_PARA2[32]  <= 0;
			DECOR_PULSE      <= 0;
		end 
end


always @(posedge i_clk or posedge i_rst)begin
	if(i_rst)
		RDData <= 0;
	else if(RD)
		case(RDAddr)	
	
		ID_CHECK		        :	RDData <= 32'h5aa5	        ;
		ID_DEBUG_LED			:	RDData <= DEBUG_LED		    ;
		ID_dco_dly 				:	RDData <= dco_dly		    ;
		ID_BIAS_SET				:	RDData <= BIAS_SET		    ;
		ID_freq_out0     		:	RDData <= freq_out0     	;
		ID_freq_out1    		:	RDData <= freq_out1     	;
		ID_freq_out2     		:	RDData <= freq_out2     	;
		ID_freq_out3    		:	RDData <= freq_out3     	;
		ID_freq_out4     		:	RDData <= freq_out4     	;
		
		ID_FREQ0_CALIB_MODE     :   RDData <= FREQ0_CALIB_MODE  ;
		ID_FREQ2_CALIB_MODE     :   RDData <= FREQ2_CALIB_MODE  ;	
		
		ID_RF_EN				:	RDData <= RF_EN			    ;
		ID_SET_POINT_VAL		:	RDData <= SET_POINT_VAL	    ;
		ID_READ_ID				:	RDData <= READ_ID			;
		
		ID_RF_FREQ0				:	RDData <= RF_FREQ0		    ;
		ID_RF_FREQ1				:	RDData <= RF_FREQ1		    ;
		ID_RF_FREQ2				:	RDData <= RF_FREQ2		    ;
		ID_RF_FREQ3				:	RDData <= RF_FREQ3		  	;
		ID_RF_FREQ4				:	RDData <= RF_FREQ4		  	;	

		
		ID_VR_ADC				:	RDData <= {VR_ADC[13],VR_ADC[13],VR_ADC};
		ID_VF_ADC				:	RDData <= {VF_ADC[13],VF_ADC[13],VF_ADC};

	    ID_adc0_filter0_i       :   RDData <= ADC0_FILTER0_I    ; //  V-> vf
	    ID_adc0_filter0_q       :   RDData <= ADC0_FILTER0_Q    ;
	    ID_adc1_filter0_i       :   RDData <= ADC1_FILTER0_I    ;  // I ->vr
	    ID_adc1_filter0_q       :   RDData <= ADC1_FILTER0_Q    ;	
	    ID_adc0_filter1_i       :   RDData <= ADC0_FILTER1_I    ; //  V-> vf
	    ID_adc0_filter1_q       :   RDData <= ADC0_FILTER1_Q    ;
	    ID_adc1_filter1_i       :   RDData <= ADC1_FILTER1_I    ;  // I ->vr
	    ID_adc1_filter1_q       :   RDData <= ADC1_FILTER1_Q    ;	
	    ID_adc0_filter2_i       :   RDData <= ADC0_FILTER2_I    ; //  V-> vf
	    ID_adc0_filter2_q       :   RDData <= ADC0_FILTER2_Q    ;
	    ID_adc1_filter2_i       :   RDData <= ADC1_FILTER2_I    ;  // I ->vr
	    ID_adc1_filter2_q       :   RDData <= ADC1_FILTER2_Q    ;			
	    ID_adc0_filter1_400k_i  :   RDData <= ADC0_FILTER1_400K_I; //  V-> vf
	    ID_adc0_filter1_400k_q  :   RDData <= ADC0_FILTER1_400K_Q;
	    ID_adc1_filter1_400k_i  :   RDData <= ADC1_FILTER1_400K_I;  // I ->vr
	    ID_adc1_filter1_400k_q  :   RDData <= ADC1_FILTER1_400K_Q;	
	    ID_adc0_filter2_400k_i  :   RDData <= ADC0_FILTER2_400K_I; //  V-> vf
	    ID_adc0_filter2_400k_q  :   RDData <= ADC0_FILTER2_400K_Q;
	    ID_adc1_filter2_400k_i  :   RDData <= ADC1_FILTER2_400K_I;  // I ->vr
	    ID_adc1_filter2_400k_q  :   RDData <= ADC1_FILTER2_400K_Q;	


	    ID_I_DECOR_i            :   RDData <= I_DECOR_I         ;
	    ID_I_DECOR_q            :   RDData <= I_DECOR_Q         ;
	    ID_V_DECOR_i 		    :   RDData <= V_DECOR_I         ;
	    ID_V_DECOR_q 		    :   RDData <= V_DECOR_Q         ;
		
		ID_VR_CAL_I				:	RDData <= VR_CAL_I	        ;
		ID_VR_CAL_Q				:	RDData <= VR_CAL_Q	        ;
		ID_VF_CAL_I				:	RDData <= VF_CAL_I	        ;
		ID_VF_CAL_Q				:	RDData <= VF_CAL_Q	        ;
		ID_PR_SRC				:	RDData <= VR_POWER0			;
		ID_PF_SRC				:	RDData <= VF_POWER0			; //补多一组LF的原始功率获取值；
		
		
		ID_PR_CALIB				:	RDData <= VR_POWER_CALIB	;
		ID_PF_CALIB				:	RDData <= VF_POWER_CALIB	;
		ID_refl_i				:	RDData <= refl_i			;
		ID_refl_q				:	RDData <= refl_q			;
		ID_R_JX_I				:	RDData <= r_jx_i			;
		ID_R_JX_Q				:	RDData <= r_jx_q			;
		ID_CALIB_R 				:	RDData <= CALIB_R 			;
		ID_CALIB_JX				:	RDData <= CALIB_JX			;
		ID_R_DOUT 				:	RDData <= R_DOUT			;
		ID_JX_DOUT				:	RDData <= JX_DOUT           ;
		ID_R1_DOUT 				:	RDData <= R1_DOUT			;
		ID_JX1_DOUT				:	RDData <= JX1_DOUT          ;
		ID_R2_DOUT 				:	RDData <= R2_DOUT			;
		ID_JX2_DOUT				:	RDData <= JX2_DOUT          ;
		ID_R3_DOUT 				:	RDData <= R3_DOUT			;
		ID_JX3_DOUT				:	RDData <= JX3_DOUT          ;
		ID_R4_DOUT 				:	RDData <= R4_DOUT			;
		ID_JX4_DOUT				:	RDData <= JX4_DOUT          ;				
		ID_R3_400K_DOUT			:	RDData <= R3_400K_DOUT		;
		ID_JX3_400K_DOUT  		:	RDData <= JX3_400K_DOUT     ;
		ID_R4_400K_DOUT			:	RDData <= R4_400K_DOUT		;
		ID_JX4_400K_DOUT  		:	RDData <= JX4_400K_DOUT     ;		

	
		ID_AVG_IIR_R0   		:	RDData <= AVG_IIR_R0        ;
		ID_AVG_IIR_JX0  		:	RDData <= AVG_IIR_JX0       ;
		ID_AVG_IIR_R1   		:	RDData <= AVG_IIR_R1        ;
		ID_AVG_IIR_JX1  		:	RDData <= AVG_IIR_JX1       ;
		ID_AVG_IIR_R2   		:	RDData <= AVG_IIR_R2        ;
		ID_AVG_IIR_JX2  		:	RDData <= AVG_IIR_JX2       ;
		ID_AVG_IIR_R3   		:	RDData <= AVG_IIR_R3        ;
		ID_AVG_IIR_JX3  		:	RDData <= AVG_IIR_JX3       ;
		ID_AVG_IIR_R4   		:	RDData <= AVG_IIR_R4        ;
		ID_AVG_IIR_JX4  		:	RDData <= AVG_IIR_JX4       ;
	
		ID_AVG_IIR_400K_R3   	:	RDData <= AVG_IIR_400K_R3   ;
		ID_AVG_IIR_400K_JX3  	:	RDData <= AVG_IIR_400K_JX3  ;
		ID_AVG_IIR_400K_R4   	:	RDData <= AVG_IIR_400K_R4   ;
		ID_AVG_IIR_400K_JX4  	:	RDData <= AVG_IIR_400K_JX4  ;
	
        ID_OS0_V_AVG            :   RDData <= OS0_V_AVG         ;
        ID_OS0_I_AVG            :   RDData <= OS0_I_AVG         ;
        ID_OS1_V_AVG            :   RDData <= OS1_V_AVG         ;
        ID_OS1_I_AVG            :   RDData <= OS1_I_AVG         ;
        ID_OS2_V_AVG            :   RDData <= OS2_V_AVG         ;
        ID_OS2_I_AVG            :   RDData <= OS2_I_AVG         ;
	
	
        ID_OS1_400K_V_AVG       :   RDData <= OS1_400K_V_AVG    ;
        ID_OS1_400K_I_AVG       :   RDData <= OS1_400K_I_AVG    ;
        ID_OS2_400K_V_AVG       :   RDData <= OS2_400K_V_AVG    ;
        ID_OS2_400K_I_AVG       :   RDData <= OS2_400K_I_AVG    ;	
	

		ID_ADC_RAM_EN			:	RDData <= ADC_RAM_EN		;
		ID_ADC_RAM_RD_ADDR		:	RDData <= ADC_RAM_RD_ADDR	;
		ID_ADC_RAM_RD_DATA		:	RDData <= ADC_RAM_RD_DATA	;
		ID_ADC_RAM_RD_DATA1		:	RDData <= ADC_RAM_RD_DATA1	;
		ID_ADC_RAM_RD_DATA2		:	RDData <= ADC_RAM_RD_DATA2	;		
		ID_ADC_RAM_RD_DATA3		:	RDData <= ADC_RAM_RD_DATA3	;
		ID_ADC_RAM_RD_DATA4		:	RDData <= ADC_RAM_RD_DATA4	;	

		
		ID_demod_pack			:	RDData <= demod_pack		;
		
        ID_adc0_mean0			:	RDData <= adc0_mean0		;
        ID_adc1_mean0			:	RDData <= adc1_mean0		;
		
        ID_adc0_mean1	        :   RDData <= adc0_mean1		;
        ID_adc1_mean1	        :   RDData <= adc1_mean1		;
		
        ID_adc0_mean2	        :   RDData <= adc0_mean2		;
        ID_adc1_mean2	        :   RDData <= adc1_mean2		;
	    ID_adc0_mean3			:	RDData <= adc0_mean3		;	
		ID_adc1_mean3			:	RDData <= adc1_mean3		;
	    ID_adc0_mean4			:	RDData <= adc0_mean4		;	
		ID_adc1_mean4			:	RDData <= adc1_mean4		;

	    ID_adc0_mean3_400k		:	RDData <= adc0_mean3_400k	;	
		ID_adc1_mean3_400k		:	RDData <= adc1_mean3_400k	;
	    ID_adc0_mean4_400k		:	RDData <= adc0_mean4_400k	;	
		ID_adc1_mean4_400k		:	RDData <= adc1_mean4_400k	;




		
		ID_m1a00_ch0   			:	RDData <= m1a00_ch0    		;
		ID_m1a01_ch0   			:	RDData <= m1a01_ch0    		;
		ID_m1a10_ch0   			:	RDData <= m1a10_ch0    		;
		ID_m1a11_ch0   			:	RDData <= m1a11_ch0    		;
		
		ID_m1a00_ch1  			:	RDData <= m1a00_ch1   		;		
		ID_m1a01_ch1  			:	RDData <= m1a01_ch1   		;		
		ID_m1a10_ch1  			:	RDData <= m1a10_ch1   		;		
		ID_m1a11_ch1  			:	RDData <= m1a11_ch1   		;		

		ID_m1a00_ch2  			:	RDData <= m1a00_ch2   		;		
		ID_m1a01_ch2  			:	RDData <= m1a01_ch2   		;		
		ID_m1a10_ch2  			:	RDData <= m1a10_ch2   		;		
		ID_m1a11_ch2 			:	RDData <= m1a11_ch2   		;	

		ID_m1a00_ch3   			:	RDData <= m1a00_ch3    		;
		ID_m1a01_ch3   			:	RDData <= m1a01_ch3    		;
		ID_m1a10_ch3   			:	RDData <= m1a10_ch3    		;
		ID_m1a11_ch3   			:	RDData <= m1a11_ch3    		;
		ID_m1a00_ch4   			:	RDData <= m1a00_ch4    		;
		ID_m1a01_ch4   			:	RDData <= m1a01_ch4    		;
		ID_m1a10_ch4   			:	RDData <= m1a10_ch4    		;
		ID_m1a11_ch4   			:	RDData <= m1a11_ch4    		;

		ID_m1a00_ch3_400k   	:	RDData <= m1a00_ch3_400k    ;
		ID_m1a01_ch3_400k   	:	RDData <= m1a01_ch3_400k    ;
		ID_m1a10_ch3_400k   	:	RDData <= m1a10_ch3_400k    ;
		ID_m1a11_ch3_400k   	:	RDData <= m1a11_ch3_400k    ;
		ID_m1a00_ch4_400k   	:	RDData <= m1a00_ch4_400k    ;
		ID_m1a01_ch4_400k   	:	RDData <= m1a01_ch4_400k    ;
		ID_m1a10_ch4_400k   	:	RDData <= m1a10_ch4_400k    ;
		ID_m1a11_ch4_400k   	:	RDData <= m1a11_ch4_400k    ;


		
		ID_ORIG_K0				:	RDData <= ORIG_K0			;
		ID_ORIG_K2				:	RDData <= ORIG_K2			;	



        ID_pl_state             :   RDData <= PL_STATE          ;
        ID_moto1_para1          :   RDData <= MOTO1_PARA1       ;
        ID_moto1_para2          :   RDData <= MOTO1_PARA2       ;
        ID_moto2_para1          :   RDData <= MOTO2_PARA1       ;
        ID_moto2_para2          :   RDData <= MOTO2_PARA2       ;
        ID_moto3_para1          :   RDData <= MOTO3_PARA1       ;
        ID_moto3_para2          :   RDData <= MOTO3_PARA2       ;
        ID_moto4_para1          :   RDData <= MOTO4_PARA1       ;
        ID_moto4_para2          :   RDData <= MOTO4_PARA2       ;
        ID_moto5_para1          :   RDData <= MOTO5_PARA1       ;
        ID_moto5_para2          :   RDData <= MOTO5_PARA2       ;
        ID_moto6_para1          :   RDData <= MOTO6_PARA1       ;
        ID_moto6_para2          :   RDData <= MOTO6_PARA2       ;
        ID_moto7_para1          :   RDData <= MOTO7_PARA1       ;
        ID_moto7_para2          :   RDData <= MOTO7_PARA2       ;
        ID_moto8_para1          :   RDData <= MOTO8_PARA1       ;
        ID_moto8_para2          :   RDData <= MOTO8_PARA2       ;	
	
	
	
	
	
	
		ID_POWER0_CALIB_K0	    :   RDData <= POWER0_CALIB_K0	;
		ID_POWER0_CALIB_K1	    :   RDData <= POWER0_CALIB_K1	;
		ID_POWER0_CALIB_K2	    :   RDData <= POWER0_CALIB_K2	;
		ID_POWER0_CALIB_K3	    :   RDData <= POWER0_CALIB_K3	;
		ID_POWER0_CALIB_K4	    :   RDData <= POWER0_CALIB_K4	;
		ID_POWER0_CALIB_K5	    :   RDData <= POWER0_CALIB_K5	;
		ID_POWER0_CALIB_K6	    :   RDData <= POWER0_CALIB_K6	;
		ID_POWER0_CALIB_K7	    :   RDData <= POWER0_CALIB_K7	;
		ID_POWER0_CALIB_K8	    :   RDData <= POWER0_CALIB_K8	;
		ID_POWER0_CALIB_K9	    :   RDData <= POWER0_CALIB_K9	;
		ID_POWER0_CALIB_K10      :	RDData <= POWER0_CALIB_K10	;   
		ID_POWER0_CALIB_K11      :	RDData <= POWER0_CALIB_K11	;   
		ID_POWER0_CALIB_K12      :	RDData <= POWER0_CALIB_K12	;   
		ID_POWER0_CALIB_K13      :	RDData <= POWER0_CALIB_K13	;   
		ID_POWER0_CALIB_K14      :	RDData <= POWER0_CALIB_K14	;   
		ID_POWER0_CALIB_K15      :	RDData <= POWER0_CALIB_K15	;   
		ID_POWER0_CALIB_K16      :	RDData <= POWER0_CALIB_K16	;   
		ID_POWER0_CALIB_K17      :	RDData <= POWER0_CALIB_K17	;   
		ID_POWER0_CALIB_K18      :	RDData <= POWER0_CALIB_K18	;   
		ID_POWER0_CALIB_K19      :	RDData <= POWER0_CALIB_K19	;   
		ID_POWER0_CALIB_K20      :	RDData <= POWER0_CALIB_K20	;   
		ID_POWER0_CALIB_K21      :	RDData <= POWER0_CALIB_K21	;   
		ID_POWER0_CALIB_K22      :	RDData <= POWER0_CALIB_K22	;   
		ID_POWER0_CALIB_K23      :	RDData <= POWER0_CALIB_K23	;   
		ID_POWER0_CALIB_K24      :	RDData <= POWER0_CALIB_K24	;   
		ID_POWER0_CALIB_K25      :	RDData <= POWER0_CALIB_K25	;   
		ID_POWER0_CALIB_K26      :	RDData <= POWER0_CALIB_K26	;   
		ID_POWER0_CALIB_K27      :	RDData <= POWER0_CALIB_K27	;   
		ID_POWER0_CALIB_K28      :	RDData <= POWER0_CALIB_K28	;   
		ID_POWER0_CALIB_K29      :	RDData <= POWER0_CALIB_K29	;   
		
        ID_FREQ0_THR0            :   RDData <= FREQ0_THR0 		;
        ID_FREQ0_THR1            :   RDData <= FREQ0_THR1 		;
        ID_FREQ0_THR2            :   RDData <= FREQ0_THR2 		;
        ID_FREQ0_THR3            :   RDData <= FREQ0_THR3 		;
        ID_FREQ0_THR4            :   RDData <= FREQ0_THR4 		;
        ID_FREQ0_THR5            :   RDData <= FREQ0_THR5 		;
        ID_FREQ0_THR6            :   RDData <= FREQ0_THR6 		;
        ID_FREQ0_THR7            :   RDData <= FREQ0_THR7 		;
        ID_FREQ0_THR8            :   RDData <= FREQ0_THR8 		;
        ID_FREQ0_THR9            :   RDData <= FREQ0_THR9 		;
        ID_FREQ0_THR10           :   RDData <= FREQ0_THR10		;
        ID_FREQ0_THR11           :   RDData <= FREQ0_THR11		;
        ID_FREQ0_THR12           :   RDData <= FREQ0_THR12		;
        ID_FREQ0_THR13           :   RDData <= FREQ0_THR13		;
        ID_FREQ0_THR14           :   RDData <= FREQ0_THR14		;
        ID_FREQ0_THR15           :   RDData <= FREQ0_THR15		;
        ID_FREQ0_THR16           :   RDData <= FREQ0_THR16		;
        ID_FREQ0_THR17           :   RDData <= FREQ0_THR17		;
        ID_FREQ0_THR18           :   RDData <= FREQ0_THR18		;
        ID_FREQ0_THR19           :   RDData <= FREQ0_THR19		;
        ID_FREQ0_THR20           :   RDData <= FREQ0_THR20		;
        ID_FREQ0_THR21           :   RDData <= FREQ0_THR21		;
        ID_FREQ0_THR22           :   RDData <= FREQ0_THR22		;
        ID_FREQ0_THR23           :   RDData <= FREQ0_THR23		;
        ID_FREQ0_THR24           :   RDData <= FREQ0_THR24		;
        ID_FREQ0_THR25           :   RDData <= FREQ0_THR25		;
        ID_FREQ0_THR26           :   RDData <= FREQ0_THR26		;
        ID_FREQ0_THR27           :   RDData <= FREQ0_THR27		;
        ID_FREQ0_THR28           :   RDData <= FREQ0_THR28		;
        ID_FREQ0_THR29           :   RDData <= FREQ0_THR29		;
        ID_FREQ0_THR30           :   RDData <= FREQ0_THR30		;

        ID_K0_THR0 				:   RDData <= K0_THR0            ;
        ID_K0_THR1 				:   RDData <= K0_THR1            ;
        ID_K0_THR2 				:   RDData <= K0_THR2            ;
        ID_K0_THR3 				:   RDData <= K0_THR3            ;
        ID_K0_THR4 				:   RDData <= K0_THR4            ;
        ID_K0_THR5 				:   RDData <= K0_THR5            ;
        ID_K0_THR6 				:   RDData <= K0_THR6            ;
        ID_K0_THR7 				:   RDData <= K0_THR7            ;
        ID_K0_THR8 				:   RDData <= K0_THR8            ;
        ID_K0_THR9 				:   RDData <= K0_THR9            ;
        ID_K0_THR10				:   RDData <= K0_THR10           ;
        ID_K0_THR11				:   RDData <= K0_THR11           ;
        ID_K0_THR12				:   RDData <= K0_THR12           ;
        ID_K0_THR13				:   RDData <= K0_THR13           ;
        ID_K0_THR14				:   RDData <= K0_THR14           ;
        ID_K0_THR15				:   RDData <= K0_THR15           ;
        ID_K0_THR16				:   RDData <= K0_THR16           ;
        ID_K0_THR17				:   RDData <= K0_THR17           ;
        ID_K0_THR18				:   RDData <= K0_THR18           ;
        ID_K0_THR19				:   RDData <= K0_THR19           ;
        ID_K0_THR20				:   RDData <= K0_THR20           ;
        ID_K0_THR21				:   RDData <= K0_THR21           ;
        ID_K0_THR22				:   RDData <= K0_THR22           ;
        ID_K0_THR23				:   RDData <= K0_THR23           ;
        ID_K0_THR24				:   RDData <= K0_THR24           ;
        ID_K0_THR25				:   RDData <= K0_THR25           ;
        ID_K0_THR26				:   RDData <= K0_THR26           ;
        ID_K0_THR27				:   RDData <= K0_THR27           ;
        ID_K0_THR28				:   RDData <= K0_THR28           ;
        ID_K0_THR29				:   RDData <= K0_THR29           ;

		ID_POWER2_CALIB_K0	    :   RDData <= POWER2_CALIB_K0	  ;
		ID_POWER2_CALIB_K1	    :   RDData <= POWER2_CALIB_K1	  ;
		ID_POWER2_CALIB_K2	    :   RDData <= POWER2_CALIB_K2	  ;
		ID_POWER2_CALIB_K3	    :   RDData <= POWER2_CALIB_K3	  ;
		ID_POWER2_CALIB_K4	    :   RDData <= POWER2_CALIB_K4	  ;
		ID_POWER2_CALIB_K5	    :   RDData <= POWER2_CALIB_K5	  ;
		ID_POWER2_CALIB_K6	    :   RDData <= POWER2_CALIB_K6	  ;
		ID_POWER2_CALIB_K7	    :   RDData <= POWER2_CALIB_K7	  ;
		ID_POWER2_CALIB_K8	    :   RDData <= POWER2_CALIB_K8	  ;
		ID_POWER2_CALIB_K9	    :   RDData <= POWER2_CALIB_K9	  ;
		ID_POWER2_CALIB_K10      :	RDData <= POWER2_CALIB_K10	  ;   
		ID_POWER2_CALIB_K11      :	RDData <= POWER2_CALIB_K11	  ;   
		ID_POWER2_CALIB_K12      :	RDData <= POWER2_CALIB_K12	  ;   
		ID_POWER2_CALIB_K13      :	RDData <= POWER2_CALIB_K13	  ;   
		ID_POWER2_CALIB_K14      :	RDData <= POWER2_CALIB_K14	  ;   
		ID_POWER2_CALIB_K15      :	RDData <= POWER2_CALIB_K15	  ;   
		ID_POWER2_CALIB_K16      :	RDData <= POWER2_CALIB_K16	  ;   
		ID_POWER2_CALIB_K17      :	RDData <= POWER2_CALIB_K17	  ;   
		ID_POWER2_CALIB_K18      :	RDData <= POWER2_CALIB_K18	  ;   
		ID_POWER2_CALIB_K19      :	RDData <= POWER2_CALIB_K19	  ;   
		ID_POWER2_CALIB_K20      :	RDData <= POWER2_CALIB_K20	  ;   
		ID_POWER2_CALIB_K21      :	RDData <= POWER2_CALIB_K21	  ;   
		ID_POWER2_CALIB_K22      :	RDData <= POWER2_CALIB_K22	  ;   
		ID_POWER2_CALIB_K23      :	RDData <= POWER2_CALIB_K23	  ;   
		ID_POWER2_CALIB_K24      :	RDData <= POWER2_CALIB_K24	  ;   
		ID_POWER2_CALIB_K25      :	RDData <= POWER2_CALIB_K25	  ;   
		ID_POWER2_CALIB_K26      :	RDData <= POWER2_CALIB_K26	  ;   
		ID_POWER2_CALIB_K27      :	RDData <= POWER2_CALIB_K27	  ;   
		ID_POWER2_CALIB_K28      :	RDData <= POWER2_CALIB_K28	  ;   
		ID_POWER2_CALIB_K29      :	RDData <= POWER2_CALIB_K29	  ;   
																  
        ID_FREQ2_THR0            :   RDData <= FREQ2_THR0 		  ;
        ID_FREQ2_THR1            :   RDData <= FREQ2_THR1 		  ;
        ID_FREQ2_THR2            :   RDData <= FREQ2_THR2 		  ;
        ID_FREQ2_THR3            :   RDData <= FREQ2_THR3 		  ;
        ID_FREQ2_THR4            :   RDData <= FREQ2_THR4 		  ;
        ID_FREQ2_THR5            :   RDData <= FREQ2_THR5 		  ;
        ID_FREQ2_THR6            :   RDData <= FREQ2_THR6 		  ;
        ID_FREQ2_THR7            :   RDData <= FREQ2_THR7 		  ;
        ID_FREQ2_THR8            :   RDData <= FREQ2_THR8 		  ;
        ID_FREQ2_THR9            :   RDData <= FREQ2_THR9 		  ;
        ID_FREQ2_THR10           :   RDData <= FREQ2_THR10		  ;
        ID_FREQ2_THR11           :   RDData <= FREQ2_THR11		  ;
        ID_FREQ2_THR12           :   RDData <= FREQ2_THR12		  ;
        ID_FREQ2_THR13           :   RDData <= FREQ2_THR13		  ;
        ID_FREQ2_THR14           :   RDData <= FREQ2_THR14		  ;
        ID_FREQ2_THR15           :   RDData <= FREQ2_THR15		  ;
        ID_FREQ2_THR16           :   RDData <= FREQ2_THR16		  ;
        ID_FREQ2_THR17           :   RDData <= FREQ2_THR17		  ;
        ID_FREQ2_THR18           :   RDData <= FREQ2_THR18		  ;
        ID_FREQ2_THR19           :   RDData <= FREQ2_THR19		  ;
        ID_FREQ2_THR20           :   RDData <= FREQ2_THR20		  ;
        ID_FREQ2_THR21           :   RDData <= FREQ2_THR21		  ;
        ID_FREQ2_THR22           :   RDData <= FREQ2_THR22		  ;
        ID_FREQ2_THR23           :   RDData <= FREQ2_THR23		  ;
        ID_FREQ2_THR24           :   RDData <= FREQ2_THR24		  ;
        ID_FREQ2_THR25           :   RDData <= FREQ2_THR25		  ;
        ID_FREQ2_THR26           :   RDData <= FREQ2_THR26		  ;
        ID_FREQ2_THR27           :   RDData <= FREQ2_THR27		  ;
        ID_FREQ2_THR28           :   RDData <= FREQ2_THR28		  ;
        ID_FREQ2_THR29           :   RDData <= FREQ2_THR29		  ;
        ID_FREQ2_THR30           :   RDData <= FREQ2_THR30		  ;

        ID_K2_THR0 				:   RDData <= K2_THR0             ;
        ID_K2_THR1 				:   RDData <= K2_THR1             ;
        ID_K2_THR2 				:   RDData <= K2_THR2             ;
        ID_K2_THR3 				:   RDData <= K2_THR3             ;
        ID_K2_THR4 				:   RDData <= K2_THR4             ;
        ID_K2_THR5 				:   RDData <= K2_THR5             ;
        ID_K2_THR6 				:   RDData <= K2_THR6             ;
        ID_K2_THR7 				:   RDData <= K2_THR7             ;
        ID_K2_THR8 				:   RDData <= K2_THR8             ;
        ID_K2_THR9 				:   RDData <= K2_THR9             ;
        ID_K2_THR10				:   RDData <= K2_THR10            ;
        ID_K2_THR11				:   RDData <= K2_THR11            ;
        ID_K2_THR12				:   RDData <= K2_THR12            ;
        ID_K2_THR13				:   RDData <= K2_THR13            ;
        ID_K2_THR14				:   RDData <= K2_THR14            ;
        ID_K2_THR15				:   RDData <= K2_THR15            ;
        ID_K2_THR16				:   RDData <= K2_THR16            ;
        ID_K2_THR17				:   RDData <= K2_THR17            ;
        ID_K2_THR18				:   RDData <= K2_THR18            ;
        ID_K2_THR19				:   RDData <= K2_THR19            ;
        ID_K2_THR20				:   RDData <= K2_THR20            ;
        ID_K2_THR21				:   RDData <= K2_THR21            ;
        ID_K2_THR22				:   RDData <= K2_THR22            ;
        ID_K2_THR23				:   RDData <= K2_THR23            ;
        ID_K2_THR24				:   RDData <= K2_THR24            ;
        ID_K2_THR25				:   RDData <= K2_THR25            ;
        ID_K2_THR26				:   RDData <= K2_THR26            ;
        ID_K2_THR27				:   RDData <= K2_THR27            ;
        ID_K2_THR28				:   RDData <= K2_THR28            ;
        ID_K2_THR29				:   RDData <= K2_THR29            ;
															    
//************************************************************* ***		
        ID_power_threshold      :   RDData <= POWER_THRESHOLD       ;	
															       
		ID_filter_threshold     :   RDData <= FILTER_THRESHOLD      ;
        ID_detect_rise_dly      :   RDData <= DETECT_RISE_DLY       ;
        ID_detect_fall_dly      :   RDData <= DETECT_FALL_DLY       ;	
		ID_rise_jump            :   RDData <= RISE_JUMP             ;	
		ID_fall_jump            :   RDData <= FALL_JUMP             ;	
															       
        ID_detect_rise_dly2     :   RDData <= DETECT_RISE_DLY2      ;
        ID_detect_fall_dly2     :   RDData <= DETECT_FALL_DLY2      ;	
		ID_rise_jump2           :   RDData <= RISE_JUMP2            ;	
		ID_fall_jump2           :   RDData <= FALL_JUMP2            ;			
															       
		ID_pulse_start          :   RDData <= PULSE_START           ;
		ID_pulse_end            :   RDData <= PULSE_END             ;	
															       
		ID_pulse_start2         :   RDData <= PULSE_START2          ;
		ID_pulse_end2           :   RDData <= PULSE_END2            ;		
															       
		ID_power_pwm_dly0       :   RDData <= POWER_PWM_DLY0        ;
		ID_power_pwm_dly2       :   RDData <= POWER_PWM_DLY2        ;

		
		ID_OS0_filter_threshold :   RDData <= OS0_FILTER_THRESHOLD ;
        ID_OS0_detect_rise_dly  :   RDData <= OS0_DETECT_RISE_DLY  ;
        ID_OS0_detect_fall_dly  :   RDData <= OS0_DETECT_FALL_DLY  ;	
		ID_OS0_rise_jump        :   RDData <= OS0_RISE_JUMP        ;	
		ID_OS0_fall_jump        :   RDData <= OS0_FALL_JUMP        ;	
		ID_OS0_pulse_start      :   RDData <= OS0_PULSE_START      ;
		ID_OS0_pulse_end        :   RDData <= OS0_PULSE_END        ;		
		ID_i_pwm_dly            :   RDData <= I_PWM_DLY            ;	

		ID_OS1_filter_threshold :   RDData <= OS1_FILTER_THRESHOLD ;		
        ID_OS1_detect_rise_dly  :   RDData <= OS1_DETECT_RISE_DLY  ;	
        ID_OS1_detect_fall_dly  :   RDData <= OS1_DETECT_FALL_DLY  ;
		ID_OS1_rise_jump        :   RDData <= OS1_RISE_JUMP        ;
		ID_OS1_fall_jump        :   RDData <= OS1_FALL_JUMP        ;
		ID_OS1_pulse_start      :   RDData <= OS1_PULSE_START      ;
		ID_OS1_pulse_end        :   RDData <= OS1_PULSE_END        ;	
		ID_i1_pwm_dly           :   RDData <= I1_PWM_DLY           ;	
											  
		ID_OS2_filter_threshold :   RDData <= OS2_FILTER_THRESHOLD ;		
        ID_OS2_detect_rise_dly  :   RDData <= OS2_DETECT_RISE_DLY  ;	
        ID_OS2_detect_fall_dly  :   RDData <= OS2_DETECT_FALL_DLY  ;
		ID_OS2_rise_jump        :   RDData <= OS2_RISE_JUMP        ;
		ID_OS2_fall_jump        :   RDData <= OS2_FALL_JUMP        ;
		ID_OS2_pulse_start      :   RDData <= OS2_PULSE_START      ;
		ID_OS2_pulse_end        :   RDData <= OS2_PULSE_END        ;	
		ID_i2_pwm_dly           :   RDData <= I2_PWM_DLY           ;	


        ID_OS1_400K_DETECT_RISE_DLY  :  RDData <= OS1_400K_DETECT_RISE_DLY  ;
        ID_OS1_400K_DETECT_FALL_DLY  :  RDData <= OS1_400K_DETECT_FALL_DLY  ;
        ID_OS1_400K_RISE_JUMP        :  RDData <= OS1_400K_RISE_JUMP        ;
        ID_OS1_400K_FALL_JUMP        :  RDData <= OS1_400K_FALL_JUMP        ;
        ID_OS1_400K_FILTER_THRESHOLD :  RDData <= OS1_400K_FILTER_THRESHOLD ;
        ID_OS1_400K_PULSE_START      :  RDData <= OS1_400K_PULSE_START      ;
        ID_OS1_400K_PULSE_END        :  RDData <= OS1_400K_PULSE_END        ;
        ID_I1_PWM_DLY_400K           :  RDData <= I1_PWM_DLY_400K           ;
									   
        ID_OS2_400K_DETECT_RISE_DLY  : RDData <= OS2_400K_DETECT_RISE_DLY   ;
        ID_OS2_400K_DETECT_FALL_DLY  : RDData <= OS2_400K_DETECT_FALL_DLY   ;
        ID_OS2_400K_RISE_JUMP        : RDData <= OS2_400K_RISE_JUMP         ;
        ID_OS2_400K_FALL_JUMP        : RDData <= OS2_400K_FALL_JUMP         ;
        ID_OS2_400K_FILTER_THRESHOLD : RDData <= OS2_400K_FILTER_THRESHOLD  ;
        ID_OS2_400K_PULSE_START      : RDData <= OS2_400K_PULSE_START       ;
        ID_OS2_400K_PULSE_END        : RDData <= OS2_400K_PULSE_END         ;
        ID_I2_PWM_DLY_400K           : RDData <= I2_PWM_DLY_400K            ;





        ID_keep_dly                 :   RDData <= KEEP_DLY                  ;		
		ID_fd_r_out                 :   RDData <= FD_R_OUT                  ;
		ID_fd_jx_out                :   RDData <= FD_JX_OUT                 ;
		ID_fft_period               :   RDData <= FFT_PERIOD                ;
		ID_division_coef            :   RDData <= TDM_DIV_COEF              ;
		ID_match_detect             :   RDData <= MATCH_DETECT              ;
								    								        
		ID_detect_pulse_width       :   RDData <= DETECT_PULSE_WIDTH        ;
        ID_match_on_dly             :   RDData <= MATCH_ON_DLY              ;
        ID_off_num                  :   RDData <=  OFF_NUM                  ;
								    								        
		ID_detect_pulse_width1      :   RDData <= DETECT_PULSE_WIDTH1       ;
        ID_match_on_dly1            :   RDData <= MATCH_ON_DLY1             ;
        ID_off_num1                 :   RDData <=  OFF_NUM1                 ;
																	        
		ID_detect_pulse_width2      :   RDData <= DETECT_PULSE_WIDTH2       ;
        ID_match_on_dly2            :   RDData <= MATCH_ON_DLY2             ;
        ID_off_num2                 :   RDData <=  OFF_NUM2                 ;
																	        
																	        
		ID_detect_pulse_width3      :   RDData <= DETECT_PULSE_WIDTH3       ;
        ID_match_on_dly3            :   RDData <= MATCH_ON_DLY3             ;
        ID_off_num3                 :   RDData <=  OFF_NUM3                 ;
																	        
		ID_detect_pulse_width4      :   RDData <= DETECT_PULSE_WIDTH4       ;
        ID_match_on_dly4            :   RDData <= MATCH_ON_DLY4             ;
        ID_off_num4                 :   RDData <=  OFF_NUM4                 ;
																		    
		ID_detect_pulse_width3_400k :   RDData <= DETECT_PULSE_WIDTH3_400K  ;
        ID_match_on_dly3_400k       :   RDData <= MATCH_ON_DLY3_400K        ;
        ID_off_num3_400k            :   RDData <= OFF_NUM3_400K             ;
										 								    
		ID_detect_pulse_width4_400k :   RDData <= DETECT_PULSE_WIDTH4_400K  ;
        ID_match_on_dly4_400k       :   RDData <= MATCH_ON_DLY4_400K        ;
        ID_off_num4_400k            :   RDData <= OFF_NUM4_400K             ;

        ID_on_keep_num              :   RDData <= ON_KEEP_NUM               ;
        ID_off_keep_num             :   RDData <= OFF_KEEP_NUM              ;
	
        ID_pulse_freq               :   RDData <= PULSE_FREQ                ; 
        ID_tdm_period               :   RDData <= TDM_PERIOD                ;	
        ID_power_callapse           :   RDData <= POWER_CALLAPSE            ;
        ID_r_jx_callapse  		    :   RDData <= R_JX_CALLAPSE             ;
																	        
        ID_vf_power_sensor0_k0      :   RDData <= VF_POWER_CALIB_K0         ;//sensor1_vf* k	
		ID_vr_power_sensor0_k0      :   RDData <= VR_POWER_CALIB_K0         ;
																	        
        ID_vf_power_sensor1_k1      :   RDData <= VF_POWER_CALIB_K1         ;//sensor2_vf*k1	
																	        
        ID_vf_power_sensor2_k2      :   RDData <= VF_POWER_CALIB_K2         ;//sensor2_vf*k1	
		ID_vr_power_sensor2_k2      :   RDData <= VR_POWER_CALIB_K2         ;
																	        
		ID_vf_sensor0_k_avg  	    :	RDData <= VF_SENSOR0_K_AVG          ;// AVG32 to sensor1_vf* k 
		ID_vr_sensor0_k_avg  	    :	RDData <= VR_SENSOR0_K_AVG          ;
		ID_vf_sensor2_k2_avg 	    :	RDData <= VF_SENSOR2_K2_AVG         ;// AVG32 to sensor2_vf*k1 		
		ID_vr_sensor2_k2_avg 	    :	RDData <= VR_SENSOR2_K2_AVG         ;	
																	        
		ID_power_freq_coef0         :   RDData <= POWER_FREQ_COEF0          ;	
		ID_power_freq_coef1         :   RDData <= POWER_FREQ_COEF1          ;		
		ID_power_freq_coef2         :   RDData <= POWER_FREQ_COEF2          ;			
		ID_power_freq_coef3         :   RDData <= POWER_FREQ_COEF3          ;		
		ID_power_freq_coef4         :   RDData <= POWER_FREQ_COEF4          ;

		
//		ID_input_sensor_freq    :   RDData <= INPUT_SENSOR_FREQ ;
		
		ID_threshold2on0           :   RDData <= HF_THRESHOLD2ON            ;
		ID_measure_period0         :   RDData <= HF_MEASURE_PERIOD          ;
		ID_threshold2on1           :   RDData <= LF_THRESHOLD2ON            ;
		ID_measure_period1         :   RDData <= LF_MEASURE_PERIOD          ;
																            
		ID_threshold2on2           :   RDData <= OS0_THRESHOLD2ON           ;
		ID_measure_period2         :   RDData <= OS0_MEASURE_PERIOD         ;
																            
		ID_threshold2on3           :   RDData <= OS1_THRESHOLD2ON           ;
		ID_measure_period3         :   RDData <= OS1_MEASURE_PERIOD         ;
																            
		ID_threshold2on4           :   RDData <= OS2_THRESHOLD2ON           ;
		ID_measure_period4         :   RDData <= OS2_MEASURE_PERIOD         ;
																            
		ID_period_num0             :   RDData <= HF_PERIOD_NUM              ;
		ID_period_total0           :   RDData <= HF_PERIOD_TOTAL            ;
																            
		ID_period_num1             :   RDData <= LF_PERIOD_NUM              ;
		ID_period_total1           :   RDData <= LF_PERIOD_TOTAL            ;
																            
		ID_period_num2             :   RDData <= OS0_PERIOD_NUM             ;
		ID_period_total2           :   RDData <= OS0_PERIOD_TOTAL           ;
																            
		ID_period_num3             :   RDData <= OS1_PERIOD_NUM             ;
		ID_period_total3           :   RDData <= OS1_PERIOD_TOTAL           ;
																            
		ID_period_num4             :   RDData <= OS2_PERIOD_NUM             ;
		ID_period_total4           :   RDData <= OS2_PERIOD_TOTAL           ;
							      
		default : RDData <= 0;
	endcase
end

spi_48 spi_48(
	.CLK			(i_clk		),
	.SPI_CS			(SPI_CS		),
	.SPI_SDI		(SPI_SDI	),
	.SPI_SCLK		(SPI_SCLK	),
	.RDData			(RDData		),
	.SPI_SDO		(SPI_SDO	),
	.RD				(RD			),
	.WR				(WR			),
	.RDAddr			(RDAddr		),
	.WrAddr			(WrAddr		),
	.WRData			(WRData		) 
); 

// ila_1 ILA_core (
    // .clk    (i_clk),
    // .probe0 ({
			// RDAddr,
			// RD,
			// RDData,
			// SPI_CS,
			// SPI_SCLK,
			// SPI_SDO,
			// SPI_SDI
			// })
// );
endmodule 