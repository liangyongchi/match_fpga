//
//
//
//
//
//
//
//
//
//
module spi_48(
	//
	input			CLK,
	input			SPI_CS,
	input			SPI_SDI,
	input			SPI_SCLK,
	input [47:0]	RDData,
	//
	output reg		SPI_SDO,
	output			RD,
	output			WR,
	output [14:0]	RDAddr,
	output [14:0]	WrAddr,
	output [47:0]	WRData
);


parameter 	WR_DATA = 0,
			RD_DATA = 1;
reg [47+16:0]	SPI_SDIDATAReg;
reg [31+16:0]	SPI_SDODATAReg;
reg			State;
reg [7:0]	ByteCount;
reg			CLKSignal,CLKSamp;
reg			CSSignal,CSSamp;
reg			SELECT;

assign RDAddr = {SPI_SDIDATAReg[13+16:0],SPI_SDI};
assign RD = (ByteCount==15) && (!SPI_SDIDATAReg[14]); //0=read,1=write
assign WrAddr = SPI_SDIDATAReg[46+16:32+16];
assign WR = (State==WR_DATA) && (ByteCount==48+16) && (!SELECT);
assign WRData = SPI_SDIDATAReg[31+16:0];

always @(posedge CLK)
begin
	CLKSamp <= SPI_SCLK;
	CLKSignal <= CLKSamp;
end
always @(posedge CLK)
begin 
	CSSamp <= SPI_CS;
	CSSignal <= CSSamp;
	if(CSSamp && !CSSignal) //上升沿
		SELECT <= 0;
	else if(CSSignal && !CSSamp)
		SELECT <= 1;
end
always @(posedge CLK)
begin 
	if(SELECT)
	begin 
		if (State==WR_DATA)
		begin 
			if(CLKSamp && !CLKSignal) //clk上升沿 
			begin
				/*write fpga*/
				SPI_SDIDATAReg[0] <= SPI_SDI;
				SPI_SDIDATAReg[47+16:1] <= SPI_SDIDATAReg[46+16:0];
				if(ByteCount==15 && !SPI_SDIDATAReg[14])
				begin 
					State <= RD_DATA;
					SPI_SDODATAReg <= RDData;
				end 
				ByteCount <= ByteCount+1;
			end 
		end 
		else begin 
			if(CLKSignal && !CLKSamp)	//clk下降沿 
			begin 
				SPI_SDO <= SPI_SDODATAReg[47];
				//
				SPI_SDODATAReg[47:0] <= {SPI_SDODATAReg[46:0],1'b0};
			end 
		end 
	end 
	else begin 
		State <= WR_DATA;
		ByteCount <= 0;
		SPI_SDIDATAReg <= 0;
	end 
end 

/*
ila_SPI ila_SPI (
	.clk(CLK), // input wire clk


	.probe0(SPI_CS), // input wire [0:0]  probe0  
	.probe1(SPI_SCLK), // input wire [0:0]  probe1 
	.probe2(SPI_SDI), // input wire [0:0]  probe2 
	.probe3(SPI_SDO), // input wire [0:0]  probe3 
	.probe4(RDData), // input wire [47:0]  probe4 
	.probe5(WRData) // input wire [47:0]  probe5
);
*/

endmodule