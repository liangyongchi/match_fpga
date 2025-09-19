`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST)\
       generate \
	   genvar pk_idx;\
	   for (pk_idx = 0; pk_idx<(PK_LEN);pk_idx = pk_idx +1 ) \
	   begin \
	         assign PK_DEST[( (PK_WDITH)*pk_idx+( (PK_WDITH)-1) ):((PK_WDITH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH) -1):0];\
	   end \
       endgenerate
	   
`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)\
       generate \
	   genvar unpk_idx;\
	   for (unpk_idx = 0; unpk_idx<(PK_LEN);unpk_idx = unpk_idx +1 ) \
	   begin \
	         assign PK_DEST[unpk_idx][((PK_WDITH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx +(PK_WIDTH -1)):((PK_WDITH)*unpk_idx)];\
	   end \
       endgenerate
	   
	   

parameter 
	
	ID_CHECK		             = 101,	//固定值0x5aa5, 23205
	ID_DEBUG_LED		         = 103,	//U8
	ID_dco_dly			         = 104,	//AD9643 设置DCO延时 5bit	
	ID_BIAS_SET			         = 114,	//设置bias电平

    ID_moto1_para1               = 115, //电机参数
    ID_moto1_para2               = 116,
    ID_moto2_para1               = 117,
    ID_moto2_para2               = 118,
    ID_moto3_para1               = 119,
    ID_moto3_para2               = 120,
    ID_moto4_para1               = 121,
    ID_moto4_para2               = 122,
    ID_moto5_para1               = 123,
    ID_moto5_para2               = 124,
    ID_moto6_para1               = 125,
    ID_moto6_para2               = 126,
    ID_moto7_para1               = 127,
    ID_moto7_para2               = 128,
    ID_moto8_para1               = 129,
    ID_moto8_para2               = 130,
	ID_decor_pulse               = 132,
	
    ID_pl_state                  = 131,	
	
    /*分段校准*/  
	ID_POWER2_CALIB_K0		     = 201,	//u24,功率校准K值，24位点定数,k_pow
	ID_POWER2_CALIB_K1		     = 202,	//u24,功率校准K值，24位点定数,
	ID_POWER2_CALIB_K2		     = 203,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K3		     = 204,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K4		     = 205,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K5		     = 206,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K6		     = 207,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K7		     = 208,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K8		     = 209,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K9		     = 210,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K10		     = 211,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K11		     = 212,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K12		     = 213,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K13		     = 214,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K14		     = 215,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K15		     = 216,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K16		     = 217,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K17		     = 218,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K18		     = 219,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K19		     = 220,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K20		     = 221,	//u24,功率校准K值，24位点定数,k_pow
	ID_POWER2_CALIB_K21		     = 222,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K22		     = 223,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K23		     = 224,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K24		     = 225,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K25		     = 226,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K26		     = 227,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K27		     = 228,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K28		     = 229,	//u24,功率校准K值，24位点定数
	ID_POWER2_CALIB_K29		     = 230,	//u24,功率校准K值，24位点定数		     
	
	ID_FREQ2_THR0 			     = 231,	//u32,频率校准段值,freq_data
	ID_FREQ2_THR1 			     = 232,	//u32,频率校准段值
	ID_FREQ2_THR2 			     = 233,	//u32,频率校准段值
	ID_FREQ2_THR3 			     = 234,	//u32,频率校准段值
	ID_FREQ2_THR4 			     = 235,	//u32,频率校准段值
	ID_FREQ2_THR5 			     = 236,	//u32,频率校准段值
	ID_FREQ2_THR6 			     = 237,	//u32,频率校准段值
	ID_FREQ2_THR7 			     = 238,	//u32,频率校准段值
	ID_FREQ2_THR8 			     = 239,	//u32,频率校准段值
	ID_FREQ2_THR9 			     = 240,	//u32,频率校准段值
	ID_FREQ2_THR10			     = 241,	//u32,频率校准段值
	ID_FREQ2_THR11			     = 242,	//u32,频率校准段值
	ID_FREQ2_THR12			     = 243,	//u32,频率校准段值
	ID_FREQ2_THR13			     = 244,	//u32,频率校准段值
	ID_FREQ2_THR14			     = 245,	//u32,频率校准段值
	ID_FREQ2_THR15			     = 246,	//u32,频率校准段值
	ID_FREQ2_THR16			     = 247,	//u32,频率校准段值
	ID_FREQ2_THR17			     = 248,	//u32,频率校准段值
	ID_FREQ2_THR18			     = 249,	//u32,频率校准段值
	ID_FREQ2_THR19			     = 250,	//u32,频率校准段值
	ID_FREQ2_THR20			     = 251,	//u32,频率校准段值
	ID_FREQ2_THR21			     = 252,	//u32,频率校准段值,freq_data
	ID_FREQ2_THR22			     = 253,	//u32,频率校准段值
	ID_FREQ2_THR23			     = 254,	//u32,频率校准段值
	ID_FREQ2_THR24			     = 255,	//u32,频率校准段值
	ID_FREQ2_THR25			     = 256,	//u32,频率校准段值
	ID_FREQ2_THR26			     = 257,	//u32,频率校准段值
	ID_FREQ2_THR27			     = 258,	//u32,频率校准段值
	ID_FREQ2_THR28			     = 259,	//u32,频率校准段值
	ID_FREQ2_THR29			     = 260,	//u32,频率校准段值
	ID_FREQ2_THR30			     = 261,	//u32,频率校准段值

	
	ID_K2_THR0 				     = 262,	//u24,分段频率校准K值,k_freq,校准表最后一个值不要
	ID_K2_THR1 				     = 263,	//u24,分段频率校准K值
	ID_K2_THR2 				     = 264,	//u24,分段频率校准K值
	ID_K2_THR3 				     = 265,	//u24,分段频率校准K值
	ID_K2_THR4 				     = 266,	//u24,分段频率校准K值
	ID_K2_THR5 				     = 267,	//u24,分段频率校准K值
	ID_K2_THR6 				     = 268,	//u24,分段频率校准K值
	ID_K2_THR7 				     = 269,	//u24,分段频率校准K值
	ID_K2_THR8 				     = 270,	//u24,分段频率校准K值
	ID_K2_THR9 				     = 271,	//u24,分段频率校准K值
	ID_K2_THR10				     = 272,	//u24,分段频率校准K值
	ID_K2_THR11				     = 273,	//u24,分段频率校准K值
	ID_K2_THR12				     = 274,	//u24,分段频率校准K值
	ID_K2_THR13				     = 275,	//u24,分段频率校准K值
	ID_K2_THR14				     = 276,	//u24,分段频率校准K值
	ID_K2_THR15				     = 277,	//u24,分段频率校准K值
	ID_K2_THR16				     = 278,	//u24,分段频率校准K值
	ID_K2_THR17				     = 279,	//u24,分段频率校准K值
	ID_K2_THR18				     = 280,	//u24,分段频率校准K值
	ID_K2_THR19				     = 281,	//u24,分段频率校准K值
	ID_K2_THR20				     = 282,	//u24,分段频率校准K值,k_freq,校准表最后一个值不要
	ID_K2_THR21				     = 283,	//u24,分段频率校准K值
	ID_K2_THR22				     = 284,	//u24,分段频率校准K值
	ID_K2_THR23				     = 285,	//u24,分段频率校准K值
	ID_K2_THR24				     = 286,	//u24,分段频率校准K值
	ID_K2_THR25				     = 287,	//u24,分段频率校准K值
	ID_K2_THR26				     = 288,	//u24,分段频率校准K值
	ID_K2_THR27				     = 289,	//u24,分段频率校准K值
	ID_K2_THR28				     = 290,	//u24,分段频率校准K值
	ID_K2_THR29				     = 291,	//u24,分段频率校准K值
	
	
	ID_freq_out0     	         = 309,	//只读,扫频输出
	ID_freq_out1     	         = 310,	//只读,扫频输出
	ID_freq_out2     	         = 311,	//只读,扫频输出	
	ID_freq_out3     	         = 312,	//只读,扫频输出
	ID_freq_out4     	         = 311,	//只读,扫频输出	

	
	ID_RF_EN			         = 503,	//射频功率开关,1开0关 
	ID_SET_POINT_VAL	         = 505,	//设置当前功率	
	ID_READ_ID			         = 512,	//获取版本号	
	
	ID_RF_FREQ0			         = 600,	//u4,机器射频频率,0-2M, 1-13.56M, 2-27.12M, 3-40.68M, 4-60M
	ID_RF_FREQ1			         = 599,
    ID_RF_FREQ2			         = 598,
    ID_RF_FREQ3                  = 597,
    ID_RF_FREQ4                  = 596,


	ID_POWER0_CALIB_K0		     = 601,	//u24,功率校准K值，24位点定数,k_pow
	ID_POWER0_CALIB_K1		     = 602,	//u24,功率校准K值，24位点定数,
	ID_POWER0_CALIB_K2		     = 603,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K3		     = 604,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K4		     = 605,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K5		     = 606,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K6		     = 607,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K7		     = 608,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K8		     = 609,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K9		     = 610,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K10		     = 611,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K11		     = 612,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K12		     = 613,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K13		     = 614,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K14		     = 615,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K15		     = 616,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K16		     = 617,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K17		     = 618,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K18		     = 619,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K19		     = 620,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K20		     = 621,	//u24,功率校准K值，24位点定数,k_pow
	ID_POWER0_CALIB_K21		     = 622,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K22		     = 623,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K23		     = 624,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K24		     = 625,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K25		     = 626,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K26		     = 627,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K27		     = 628,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K28		     = 629,	//u24,功率校准K值，24位点定数
	ID_POWER0_CALIB_K29		     = 630,	//u24,功率校准K值，24位点定数
	
	ID_FREQ0_THR0 			     = 631,	//u32,频率校准段值,freq_data
	ID_FREQ0_THR1 			     = 632,	//u32,频率校准段值
	ID_FREQ0_THR2 			     = 633,	//u32,频率校准段值
	ID_FREQ0_THR3 			     = 634,	//u32,频率校准段值
	ID_FREQ0_THR4 			     = 635,	//u32,频率校准段值
	ID_FREQ0_THR5 			     = 636,	//u32,频率校准段值
	ID_FREQ0_THR6 			     = 637,	//u32,频率校准段值
	ID_FREQ0_THR7 			     = 638,	//u32,频率校准段值
	ID_FREQ0_THR8 			     = 639,	//u32,频率校准段值
	ID_FREQ0_THR9 			     = 640,	//u32,频率校准段值
	ID_FREQ0_THR10			     = 641,	//u32,频率校准段值
	ID_FREQ0_THR11			     = 642,	//u32,频率校准段值
	ID_FREQ0_THR12			     = 643,	//u32,频率校准段值
	ID_FREQ0_THR13			     = 644,	//u32,频率校准段值
	ID_FREQ0_THR14			     = 645,	//u32,频率校准段值
	ID_FREQ0_THR15			     = 646,	//u32,频率校准段值
	ID_FREQ0_THR16			     = 647,	//u32,频率校准段值
	ID_FREQ0_THR17			     = 648,	//u32,频率校准段值
	ID_FREQ0_THR18			     = 649,	//u32,频率校准段值
	ID_FREQ0_THR19			     = 650,	//u32,频率校准段值
	ID_FREQ0_THR20			     = 651,	//u32,频率校准段值
	ID_FREQ0_THR21			     = 652,	//u32,频率校准段值,freq_data
	ID_FREQ0_THR22			     = 653,	//u32,频率校准段值
	ID_FREQ0_THR23			     = 654,	//u32,频率校准段值
	ID_FREQ0_THR24			     = 655,	//u32,频率校准段值
	ID_FREQ0_THR25			     = 656,	//u32,频率校准段值
	ID_FREQ0_THR26			     = 657,	//u32,频率校准段值
	ID_FREQ0_THR27			     = 658,	//u32,频率校准段值
	ID_FREQ0_THR28			     = 659,	//u32,频率校准段值
	ID_FREQ0_THR29			     = 660,	//u32,频率校准段值
	ID_FREQ0_THR30			     = 661,	//u32,频率校准段值
	
	ID_K0_THR0 				     = 662,	//u24,分段频率校准K值,k_freq,校准表最后一个值不要
	ID_K0_THR1 				     = 663,	//u24,分段频率校准K值
	ID_K0_THR2 				     = 664,	//u24,分段频率校准K值
	ID_K0_THR3 				     = 665,	//u24,分段频率校准K值
	ID_K0_THR4 				     = 666,	//u24,分段频率校准K值
	ID_K0_THR5 				     = 667,	//u24,分段频率校准K值
	ID_K0_THR6 				     = 668,	//u24,分段频率校准K值
	ID_K0_THR7 				     = 669,	//u24,分段频率校准K值
	ID_K0_THR8 				     = 670,	//u24,分段频率校准K值
	ID_K0_THR9 				     = 671,	//u24,分段频率校准K值
	ID_K0_THR10				     = 672,	//u24,分段频率校准K值
	ID_K0_THR11				     = 673,	//u24,分段频率校准K值
	ID_K0_THR12				     = 674,	//u24,分段频率校准K值
	ID_K0_THR13				     = 675,	//u24,分段频率校准K值
	ID_K0_THR14				     = 676,	//u24,分段频率校准K值
	ID_K0_THR15				     = 677,	//u24,分段频率校准K值
	ID_K0_THR16				     = 678,	//u24,分段频率校准K值
	ID_K0_THR17				     = 679,	//u24,分段频率校准K值
	ID_K0_THR18				     = 680,	//u24,分段频率校准K值
	ID_K0_THR19				     = 681,	//u24,分段频率校准K值
	ID_K0_THR20				     = 682,	//u24,分段频率校准K值,k_freq,校准表最后一个值不要
	ID_K0_THR21				     = 683,	//u24,分段频率校准K值
	ID_K0_THR22				     = 684,	//u24,分段频率校准K值
	ID_K0_THR23				     = 685,	//u24,分段频率校准K值
	ID_K0_THR24				     = 686,	//u24,分段频率校准K值
	ID_K0_THR25				     = 687,	//u24,分段频率校准K值
	ID_K0_THR26				     = 688,	//u24,分段频率校准K值
	ID_K0_THR27				     = 689,	//u24,分段频率校准K值
	ID_K0_THR28				     = 690,	//u24,分段频率校准K值
	ID_K0_THR29				     = 691,	//u24,分段频率校准K值
	
	
	ID_VR_ADC			         = 700,	//ADC-VR
	ID_VF_ADC			         = 701,	//ADC-VF
	ID_VR_CAL_I			         = 702,	//32,校准后的VR_I
	ID_VR_CAL_Q			         = 703,	//32,校准后的VR_Q
	ID_VF_CAL_I			         = 704,	//32,校准后的VF_I
	ID_VF_CAL_Q			         = 705,	//32,校准后的VF_Q	
	ID_PR_SRC			         = 706,	//32,反射功率,PR
	ID_PF_SRC			         = 707,	//32,入射功率,PF
	ID_PR_CALIB			         = 708,	//16,校准后的反射功率,PR
	ID_PF_CALIB			         = 709,	//16,校准后的入射功率,PF	
	
	
	ID_ADC_RAM_EN				 = 710,	//写1开始缓存ADC 4096个data，自动清零
	ID_ADC_RAM_RD_ADDR			 = 711,	//读缓存ADC的地址
	ID_ADC_RAM_RD_DATA			 = 712,	//读缓存ADC的数据，高16位VR，低16位VF
    ID_ADC_RAM_RD_DATA1          = 723,	
    ID_ADC_RAM_RD_DATA2          = 724,		
    ID_ADC_RAM_RD_DATA3          = 725,	
    ID_ADC_RAM_RD_DATA4          = 726,		
	
	ID_ADC_RAM_RD_DATA_DEMO_I	 = 713,	//解调后I,32BIT
	ID_ADC_RAM_RD_DATA_DEMO_Q	 = 714,	//解调后Q,32BIT
	ID_ADC_RAM_RD_DATA_LPF_I 	 = 715,	//低通滤波器I,32BIT
	ID_ADC_RAM_RD_DATA_LPF_Q 	 = 716,	//低通滤波器Q,32BIT
	ID_ADC_RAM_RD_DATA_CALB_I 	 = 717,	//校准后I,32BIT
	ID_ADC_RAM_RD_DATA_CALB_Q 	 = 718,	//校准后Q,32BIT	
	ID_demod_pack			     = 720,	//暂时不用，解调数据包，数据格式 32data（高16位实部，低16位虚部） + 15addr + 1wr
	ID_demod_rd_addr		     = 721,	//暂时不用，回读解调参数地址
	ID_demod_rd_data		     = 722,	//暂时不用，回读解调参数数据	
    //sensor1						 
	ID_adc1_mean0			     = 730,	//32,VR mean
	ID_adc0_mean0			     = 731,	//32,VF mean							 
	ID_adc1_mean1			     = 736, //OS2
	ID_adc0_mean1			     = 737,						    
	ID_adc1_mean2			     = 743,	//lf
	ID_adc0_mean2			     = 744,	
    ID_adc0_mean3                = 760 ,//OS1
    ID_adc1_mean3                = 761 ,
    ID_adc0_mean4                = 762 ,//OS2
    ID_adc1_mean4                = 763 ,

    ID_adc0_mean3_400k           = 780 ,//OS1
    ID_adc1_mean3_400k           = 781 ,
    ID_adc0_mean4_400k           = 782 ,//OS2
    ID_adc1_mean4_400k           = 783 ,

	
	
	ID_m1a00_ch0    		     = 732,	//32,高16位实部，低16位虚部 HF
	ID_m1a01_ch0    		     = 733,	//32,  
	ID_m1a10_ch0    		     = 734,	//32,
	ID_m1a11_ch0    		     = 735,	//32,	
	
	ID_m1a00_ch1    		     = 738,	//NO USE :FREE;
	ID_m1a01_ch1    		     = 739,	
	ID_m1a10_ch1    		     = 740,	
	ID_m1a11_ch1    		     = 741,		
	
	ID_m1a00_ch2    		     = 745,	//OS0
	ID_m1a01_ch2    		     = 746,	
	ID_m1a10_ch2    		     = 747,	
	ID_m1a11_ch2    		     = 748,	
	
	ID_m1a00_ch3    		     = 764,	//OS1
	ID_m1a01_ch3    		     = 765,	
	ID_m1a10_ch3    		     = 766,	
	ID_m1a11_ch3    		     = 767,	

	ID_m1a00_ch3_400k    		 = 784,	//OS1
	ID_m1a01_ch3_400k    		 = 785,	
	ID_m1a10_ch3_400k    		 = 786,	
	ID_m1a11_ch3_400k    		 = 787,	
	
	ID_m1a00_ch4    		     = 768,	//OS2
	ID_m1a01_ch4    		     = 769,	
	ID_m1a10_ch4    		     = 770,	
	ID_m1a11_ch4    		     = 771,	

	ID_m1a00_ch4_400k    		 = 788,	//OS2-400K
	ID_m1a01_ch4_400k    		 = 789,	
	ID_m1a10_ch4_400k    		 = 790,	
	ID_m1a11_ch4_400k    		 = 791,	


	
    ID_FREQ0_CALIB_MODE  	     = 742,
    ID_FREQ2_CALIB_MODE  	     = 759,	
	
	ID_ORIG_K0				     = 749,	//原始K值，通过该k值去校准，24位点定数
	ID_ORIG_K2				     = 750,	
	

	ID_adc0_filter0_i            = 751,//V   //OS0
	ID_adc0_filter0_q            = 752,
	ID_adc1_filter0_i            = 753,//I
	ID_adc1_filter0_q            = 754,	
	
	ID_adc0_filter1_i            = 772,//V   //OS1
	ID_adc0_filter1_q            = 773,
	ID_adc1_filter1_i            = 774,//I
	ID_adc1_filter1_q            = 775,	

	ID_adc0_filter2_i            = 776,//V   //OS2 60M
	ID_adc0_filter2_q            = 777,
	ID_adc1_filter2_i            = 778,//I
	ID_adc1_filter2_q            = 779,		



    ID_adc0_filter1_400k_i       =  537  ,
    ID_adc0_filter1_400k_q       =  538  ,
    ID_adc1_filter1_400k_i       =  539  ,
    ID_adc1_filter1_400k_q       =  540  ,
	
    ID_adc0_filter2_400k_i       =  541  , //400K
    ID_adc0_filter2_400k_q       =  542  ,
    ID_adc1_filter2_400k_i       =  543  ,
    ID_adc1_filter2_400k_q       =  544  ,
    


	ID_V_DECOR_i                 = 755, //V
	ID_V_DECOR_q                 = 756,	
	ID_I_DECOR_i                 = 757,//32bit
	ID_I_DECOR_q                 = 758,
	
	ID_refl_i				     = 800,	//反射率i
	ID_refl_q				     = 801,	//反射率q
	ID_R_JX_I				     = 802,	//32，r+jx实部
	ID_R_JX_Q				     = 803,	//32，r+jx虚部	
	ID_CALIB_R 				     = 810,	//R+JX校准K值,θ值，32bit，15位定点数
	ID_CALIB_JX				     = 811,	//不用	
								 
	//电机匹配专用r+jx;         
	ID_R_DOUT				     = 812,	//校准后的R  ADC0
	ID_JX_DOUT				     = 813,	//校准后的JX
	ID_R1_DOUT				     = 814,	//校准后的R  ADC1
	ID_JX1_DOUT				     = 815,	//校准后的JX
	ID_R2_DOUT				     = 847,	//校准后的R  ADC1
	ID_JX2_DOUT				     = 848,	//校准后的JX
	ID_R3_DOUT				     = 849,	//校准后的R  ADC1
	ID_JX3_DOUT				     = 897,	//校准后的JX
	ID_R4_DOUT				     = 898,	//校准后的R  ADC1
	ID_JX4_DOUT				     = 899,	//校准后的JX

	ID_R3_400K_DOUT	             = 908  ,
	ID_JX3_400K_DOUT             = 909  ,
	ID_R4_400K_DOUT	             = 910  ,
	ID_JX4_400K_DOUT             = 911  ,
					            

	
	ID_RAM_DATA_SEL              = 816,
	
	ID_vf_power_sensor0_k0       = 817,//未平均
	ID_vr_power_sensor0_k0       = 843,
	
	ID_vf_power_sensor1_k1       = 818,
	
	ID_vf_power_sensor2_k2       = 828,
	ID_vr_power_sensor2_k2       = 844,
	
    ID_vf_sensor0_k_avg          = 823,//平均后
	ID_vr_sensor0_k_avg          = 825,
    ID_vf_sensor2_k2_avg 	     = 824, 
	ID_vr_sensor2_k2_avg 	     = 829, 		
	
	//上位机显示                 
    ID_AVG_IIR_R0   	         = 819, 
    ID_AVG_IIR_JX0             	 = 820,
	
    ID_AVG_IIR_R1   	         = 821, //OS0
    ID_AVG_IIR_JX1  	         = 822,
	
    ID_AVG_IIR_R2   	         = 845,//lf
    ID_AVG_IIR_JX2  	         = 846,

    ID_AVG_IIR_R3                = 889, //OS1
    ID_AVG_IIR_JX3               = 890,
	
    ID_AVG_IIR_R4                = 891, //OS2
    ID_AVG_IIR_JX4               = 892,


    ID_AVG_IIR_400K_R3           = 900, //OS1
    ID_AVG_IIR_400K_JX3          = 901,
			  
    ID_AVG_IIR_400K_R4           = 902, //OS2
    ID_AVG_IIR_400K_JX4          = 903,


    	
    ID_OS0_V_AVG			     = 826,	//OS0				 
    ID_OS0_I_AVG		         = 827,		

    ID_OS1_V_AVG			     = 893,	//OS1	
    ID_OS1_I_AVG		         = 894,	
	
    ID_OS2_V_AVG			     = 895,	//OS2				 
    ID_OS2_I_AVG		         = 896,	

    ID_OS1_400K_V_AVG			 = 904,	//OS1	
    ID_OS1_400K_I_AVG		     = 905,	
								 
    ID_OS2_400K_V_AVG			 = 906,	//OS2				 
    ID_OS2_400K_I_AVG		     = 907,	




//--------------------------------------------------------------

//Address:
    ID_power_threshold           = 970        ,
	
	ID_filter_threshold          = 971        ,	
	ID_detect_rise_dly           = 972        , //两点检测法的间隔；（避免毛刺）
	ID_detect_fall_dly           = 973        , //两点检测法的间隔；（避免毛刺）
	
	ID_detect_rise_dly2          = 830        , //两点检测法的间隔；（避免毛刺）
	ID_detect_fall_dly2          = 831        , //两点检测法的间隔；（避免毛刺）	
	
	ID_keep_dly                  = 974        , //无用
	ID_rise_jump                 = 975        , //差值判断rise的跨度值；
	ID_fall_jump                 = 976        , //差值判断fall的跨度值；
	
	ID_rise_jump2                = 832        , //差值判断rise的跨度值；
	ID_fall_jump2                = 833        , //差值判断fall的跨度值；	
	 
	ID_pulse_start               = 996        ,
    ID_pulse_end                 = 997        ,	

	ID_pulse_start2              = 834        ,
    ID_pulse_end2                = 835        ,		
	
    ID_power_pwm_dly0            = 998       , //脉冲占空比延迟的周期个数，延迟得到Z的脉冲占空比；	
    ID_power_pwm_dly2            = 999       ,
	
	ID_OS0_filter_threshold      = 961        ,	
							     
	ID_OS0_detect_rise_dly       = 962        , //两点检测法的间隔；（避免毛刺）
	ID_OS0_detect_fall_dly       = 963        , //两点检测法的间隔；（避免毛刺）
	ID_OS0_rise_jump             = 965        , //差值判断rise的跨度值；
	ID_OS0_fall_jump             = 966        , //差值判断fall的跨度值；
	ID_OS0_pulse_start           = 967        ,
    ID_OS0_pulse_end             = 968        ,		
    ID_i_pwm_dly                 = 969        , //脉冲占空比延迟的周期个数，延迟得到Z的脉冲占空比；	

    ID_OS1_filter_threshold      = 873        ,
    ID_OS1_detect_rise_dly       = 874        ,
    ID_OS1_detect_fall_dly       = 875        ,
    ID_OS1_rise_jump             = 876        ,
    ID_OS1_fall_jump             = 877        ,
    ID_OS1_pulse_start           = 878        ,
    ID_OS1_pulse_end             = 879        ,
    ID_i1_pwm_dly                = 880        ,
								
    ID_OS2_filter_threshold      = 881        ,
    ID_OS2_detect_rise_dly       = 882        ,
    ID_OS2_detect_fall_dly       = 883        ,
    ID_OS2_rise_jump             = 884        ,
    ID_OS2_fall_jump             = 885        ,
    ID_OS2_pulse_start           = 886        ,
    ID_OS2_pulse_end             = 887        ,
    ID_i2_pwm_dly                = 888        ,



    ID_OS1_400K_DETECT_RISE_DLY  = 515        ,         
    ID_OS1_400K_DETECT_FALL_DLY  = 516        ,
    ID_OS1_400K_RISE_JUMP        = 517        ,
    ID_OS1_400K_FALL_JUMP        = 518        ,
    ID_OS1_400K_FILTER_THRESHOLD = 519        ,
    ID_OS1_400K_PULSE_START      = 520        ,
    ID_OS1_400K_PULSE_END        = 521        ,
    ID_I1_PWM_DLY_400K           = 522        ,
							
    ID_OS2_400K_DETECT_RISE_DLY  = 523        ,
    ID_OS2_400K_DETECT_FALL_DLY  = 524        ,
    ID_OS2_400K_RISE_JUMP        = 525        ,
    ID_OS2_400K_FALL_JUMP        = 526        ,
    ID_OS2_400K_FILTER_THRESHOLD = 527        ,
    ID_OS2_400K_PULSE_START      = 528        ,
    ID_OS2_400K_PULSE_END        = 529        ,
    ID_I2_PWM_DLY_400K           = 530        ,
								 
    ID_on_keep_num               = 550        ,
    ID_off_keep_num              = 551        ,






    ID_fd_r_out                  = 978        ,
	ID_fd_jx_out                 = 979        ,
 	ID_fft_period                = 980        ,
    ID_division_coef             = 981        ,//TDM的区间系数调节；默认5ms；
	ID_match_detect              = 982        ,
	
	ID_detect_pulse_width        = 983        ,	
	ID_match_on_dly              = 984        , //检测pw/cw模式的第一阶段启动延迟
	ID_off_num                   = 985        ,	//检测功率关闭的计数器上限触发关闭功率；
	
	ID_detect_pulse_width1       = 850        ,	
	ID_match_on_dly1             = 851        , //OS0
	ID_off_num1                  = 852        ,	//检测功率关闭的计数器上限触发关闭功率；
	
	ID_detect_pulse_width2       = 836        ,	
	ID_match_on_dly2             = 837        , //lf
	ID_off_num2                  = 838        ,	//检测功率关闭的计数器上限触发关闭功率；	

	ID_detect_pulse_width3       = 853        ,//OS1
	ID_match_on_dly3             = 854        ,
	ID_off_num3                  = 855        ,
	
	ID_detect_pulse_width4       = 856        ,//OS2
	ID_match_on_dly4             = 857        ,
	ID_off_num4                  = 858        ,

    ID_detect_pulse_width3_400k  = 531        ,
    ID_match_on_dly3_400k        = 532        ,
    ID_off_num3_400k             = 533        ,
											  
    ID_detect_pulse_width4_400k  = 534        ,
    ID_match_on_dly4_400k        = 535        ,
    ID_off_num4_400k             = 536        ,
								 




	
	
	ID_pulse_freq                = 986        ,
	ID_tdm_period                = 987        , //tdm的周期长度
	ID_power_callapse            = 988        , //功率tdm时的塌陷延迟；
    ID_r_jx_callapse             = 989        , //阻抗tdm时的塌陷延迟；
	
	
	
	
    ID_power_freq_coef0          = 990	      , //调频解调系数；
    ID_power_freq_coef1          = 960	      , //调频解调系数； os
    ID_power_freq_coef2          = 959	      , //调频解调系数；	LF
    ID_power_freq_coef3          = 871	      , //调频解调系数；
    ID_power_freq_coef4          = 872	      , //调频解调系数；	






	
    ID_input_sensor_freq         = 991        , //sensor1测量；
	
	ID_threshold2on0             = 992        , //HF
	ID_measure_period0           = 993        ,	//HF
	ID_period_num0               = 994        , //HF
	ID_period_total0             = 995        , //HF



	ID_threshold2on1             = 839        , //LF
	ID_measure_period1           = 840        , //LF
	ID_period_num1               = 841        , //LF
	ID_period_total1             = 842        , //LF

	
	ID_threshold2on2             = 859       , //OS0
	ID_measure_period2           = 860       , //OS0
	ID_period_num2               = 861       , //OS0
	ID_period_total2             = 862       , //OS0
											
	ID_threshold2on3             = 863       , //OS1
	ID_measure_period3           = 864       ,	//OS1
	ID_period_num3               = 865       , //OS1
	ID_period_total3             = 866       , //OS1
										
	ID_threshold2on4             = 867      , //OS2
	ID_measure_period4           = 868      ,	//OS2
	ID_period_num4               = 869      , //OS2
	ID_period_total4             = 870      , //OS2




//Value:	                                  
	DEFAULT_power_threshold      = 32'd30     ,		
	DEFUALT_keep_dly             = 36'd1000   , //double rise_dly;	
	
	DEFUALT_detect_rise_dly      = 24'd50     ,// 小功率30w 70
	DEFUALT_detect_fall_dly      = 24'd20     ,// 小功率30w 70
	
    DEFUALT_detect_rise_dly2     = 24'd50     ,// 小功率30w 70
	DEFUALT_detect_fall_dly2     = 24'd50     ,// 小功率30w 70

	DEFUALT_rise_jump            = 10'd19     , // 小功率30w 16
	DEFUALT_fall_jump            = 10'd15     , // 小功率30w 16
	
	DEFUALT_rise_jump2            = 10'd19     , // 小功率30w 16
	DEFUALT_fall_jump2            = 10'd19     , // 小功率30w 16
	
	DEFUALT_filter_threshold     = 16'd6000   ,
	DEFAULT_pulse_start          = 16'd100     , //调节功率拟合占空比的pwm的位置和宽度；
	DEFAULT_pulse_end            = 16'd700    ,	
	DEFAULT_pulse_start2         = 16'd100     ,
	DEFAULT_pulse_end2           = 16'd700     ,	
	
	DEFAULT_power_pwm_dly0        = 16'd100    ,//PW会跳修改这个参数延迟脉冲位置
	DEFAULT_power_pwm_dly2        = 16'd100    ,
	
	DEFUALT_OS0_detect_rise_dly  = 24'd100     ,// 小功率30w 70
	DEFUALT_OS0_detect_fall_dly  = 24'd100     ,// 小功率30w 70
	DEFUALT_OS0_rise_jump        = 10'd19     , // 小功率30w 16
	DEFUALT_OS0_fall_jump        = 10'd19     , // 小功率30w 16
	DEFUALT_OS0_filter_threshold = 16'd65535  , //位宽太小 是Vi2+Vq2；
	DEFAULT_OS0_pulse_start      = 16'd100    ,
	DEFAULT_OS0_pulse_end        = 16'd700    ,	
	DEFAULT_i_pwm_dly            = 16'd100    ,//PW会跳修改这个参数延迟脉冲位置


	DEFUALT_OS1_detect_rise_dly  = 24'd100      ,// 小功率30w 70
	DEFUALT_OS1_detect_fall_dly  = 24'd50      ,// 小功率30w 70
	DEFUALT_OS1_rise_jump        = 10'd19      , // 小功率30w 16
	DEFUALT_OS1_fall_jump        = 10'd19      , // 小功率30w 16
	DEFUALT_OS1_filter_threshold = 16'd65535   , //位宽太小 是Vi2+Vq2；
	DEFAULT_OS1_pulse_start      = 16'd100     ,
	DEFAULT_OS1_pulse_end        = 16'd700     ,	
	DEFAULT_i1_pwm_dly           = 16'd100     ,//PW会跳修改这个参数延迟脉冲位置


	DEFUALT_OS2_detect_rise_dly  = 24'd100    ,// 小功率30w 70
	DEFUALT_OS2_detect_fall_dly  = 24'd50     ,// 小功率30w 70
	DEFUALT_OS2_rise_jump        = 10'd19     , // 小功率30w 16
	DEFUALT_OS2_fall_jump        = 10'd19     , // 小功率30w 16
	DEFUALT_OS2_filter_threshold = 16'd65535  , //位宽太小 是Vi2+Vq2；
	DEFAULT_OS2_pulse_start      = 16'd100    ,
	DEFAULT_OS2_pulse_end        = 16'd700    ,	
	DEFAULT_i2_pwm_dly           = 16'd100    ,//PW会跳修改这个参数延迟脉冲位置

    DEFUALT_OS1_400k_detect_rise_dly   = 24'd100    , 
    DEFUALT_OS1_400k_detect_fall_dly   = 24'd50     ,
    DEFUALT_OS1_400k_rise_jump         = 10'd19     ,
    DEFUALT_OS1_400k_fall_jump         = 10'd19     ,
    DEFUALT_OS1_400k_filter_threshold  = 16'd65535  ,
    DEFAULT_OS1_400k_pulse_start       = 16'd100    ,
    DEFAULT_OS1_400k_pulse_end         = 16'd700    ,
    DEFAULT_i1_pwm_dly_400K            = 16'd100    ,
    
    DEFUALT_OS2_400k_detect_rise_dly   = 24'd100    ,
    DEFUALT_OS2_400k_detect_fall_dly   = 24'd50     ,
    DEFUALT_OS2_400k_rise_jump         = 10'd19     ,
    DEFUALT_OS2_400k_fall_jump         = 10'd19     ,
    DEFUALT_OS2_400k_filter_threshold  = 16'd65535  ,
    DEFAULT_OS2_400k_pulse_start       = 16'd100    ,
    DEFAULT_OS2_400k_pulse_end         = 16'd700    ,
    DEFAULT_i2_pwm_dly_400K            = 16'd100    ,


	
	DEFUALT_fft_period           = 16'd2000   ,
	//DEFUALT_division_coef        = 32'd100000 ,//1249999
    DEFUALT_division_coef        = 32'd11875000,//5ms;
	DEFAULT_match_detect         = 16'd20     ,
	DEFAULT_detect_pulse_width   = 32'd10000000,// 500us;
	DEFAULT_match_on_dly         = 32'd1000000,// 20 000 000/20 = 1 000 000
	DEFAULT_off_num              = 32'd3000000,         //60ms;

	DEFAULT_detect_pulse_width1   = 32'd10000000,// 500us;
	DEFAULT_match_on_dly1         = 32'd1000000,// 20 000 000/20 = 1 000 000
	DEFAULT_off_num1              = 32'd3000000,         //60ms;	
	
	DEFAULT_detect_pulse_width2  = 32'd10000000,// 500us;
	DEFAULT_match_on_dly2        = 32'd1000000,// 20 000 000/20 = 1 000 000
	DEFAULT_off_num2             = 32'd3000000,         //60ms;	
	
	DEFAULT_detect_pulse_width3  = 32'd10000000,// 500us;
	DEFAULT_match_on_dly3        = 32'd1000000 ,// 20 000 000/20 = 1 000 000
	DEFAULT_off_num3             = 32'd3000000 ,         //60ms;	

	DEFAULT_detect_pulse_width4  = 32'd10000000,// 500us;
	DEFAULT_match_on_dly4        = 32'd1000000 ,// 20 000 000/20 = 1 000 000
	DEFAULT_off_num4             = 32'd3000000 ,         //60ms;	


    DEFAULT_detect_pulse_width3_400k  = 32'd10000000,
    DEFAULT_match_on_dly3_400k        = 32'd1000000 ,
    DEFAULT_off_num3_400k             = 32'd3000000 ,
                                      
    DEFAULT_detect_pulse_width4_400k  = 32'd10000000,
    DEFAULT_match_on_dly4_400k        = 32'd1000000 ,
    DEFAULT_off_num4_400k             = 32'd3000000 ,



	
	DEFAULT_pulse_freq           = 32'd50000  ,         //60ms;	
	DEFAULT_tdm_period           = 32'd12500000,
	DEFAULT_power_callapse       = 32'd650    ,
	DEFAULT_r_jx_callapse        = 32'd1200   ,


	ID_END                       = 0          ;





































