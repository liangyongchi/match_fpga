module ADC_DATA_RAM(
	input 		    i_clk_64m,
	input 		    i_clk,	//read clk
	input 		    i_rstn,
	input 			vld,
	input [15:0]	CHA,	//vr
	input [15:0]	CHB,	//vf
	input 			ADC_RAM_EN      ,		//拉高1个周期
    input [11:0]    ADC_RAM_RD_ADDR ,
    output [31:0]   ADC_RAM_RD_DATA	
);

reg [3:0]	state;
reg			wr_en;
reg [11:0]	addra;
reg [31:0]	dina ;
reg 		ADC_RAM_EN_reg0,ADC_RAM_EN_reg1;

always @(posedge i_clk_64m) 
begin 
	ADC_RAM_EN_reg0 <= ADC_RAM_EN;
	ADC_RAM_EN_reg1 <= ADC_RAM_EN_reg0;
end 

always @(posedge i_clk_64m or negedge i_rstn)
	if(!i_rstn) begin 
		state <= 0;
		wr_en <= 0;
		addra <= 0;
		end 
	else case(state)
	0:	begin 
		wr_en <= 0;
		addra <= 0;
		if(ADC_RAM_EN_reg1)	state <= 1;
		end 
	1:	begin 	
		wr_en <= vld;
		if(addra == 4094 && vld) begin 
			state <= 2;
			end 
		else if(vld)
			addra <= addra+1;
			 
		end 
	2:	begin 
			wr_en <= 0;
			addra <= 0;
			state <= 0;
		end 
	default : state <= 0;
	endcase

always @(posedge i_clk_64m or negedge i_rstn)
	if(!i_rstn) 
		dina <= 0;
	else 
		dina <= {CHA,CHB};

// ADC_RAM ADC_RAM (
  // .clka		(i_clk),    // input wire clka
  // .ena		(1'b1),      // input wire ena
  // .wea		(wr_en),      // input wire [0 : 0] wea
  // .addra	(addra),  // input wire [11 : 0] addra
  // .dina		(dina),    // input wire [31 : 0] dina
  // .clkb		(i_clk),    // input wire clkb
  // .enb		(1'b1),      // input wire enb
  // .addrb	(ADC_RAM_RD_ADDR),  // input wire [11 : 0] addra
  // .doutb	(ADC_RAM_RD_DATA)  // output wire [31 : 0] doutb
// );

ADC_RAM ADC_RAM (
  .clka		(i_clk_64m),    // input wire clka
  .ena		(1'b1),      // input wire ena
  .wea		(wr_en),      // input wire [0 : 0] wea
  .addra	(addra),  // input wire [11 : 0] addra
  .dina		(dina),    // input wire [31 : 0] dina
  .clkb		(i_clk),    // input wire clkb
  .enb		(1'b1),      // input wire enb
  .addrb	(ADC_RAM_RD_ADDR),  // input wire [11 : 0] addrb
  .doutb	(ADC_RAM_RD_DATA)  // output wire [31 : 0] doutb
);

	


endmodule 