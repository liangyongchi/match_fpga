module AVG_FIFO_32(
    input           clk_i,
    input           rst_i,

    input [31:0]    data_in,
    input           den_in,

    output reg [31:0]   data_out,
    output reg          den_out
);



reg [36:0]  sum;
reg [31:0]  
    temp0 ,	temp16,	//temp32,	temp48,
    temp1 , temp17, //temp33, temp49,
    temp2 , temp18, //temp34, temp50,
    temp3 , temp19, //temp35, temp51,
    temp4 , temp20, //temp36, temp52,
    temp5 , temp21, //temp37, temp53,
    temp6 , temp22, //temp38, temp54,
    temp7 , temp23, //temp39, temp55,
    temp8 , temp24, //temp40, temp56,
    temp9 , temp25, //temp41, temp57,
    temp10, temp26, //temp42, temp58,
    temp11, temp27, //temp43, temp59,
    temp12, temp28, //temp44, temp60,
    temp13, temp29, //temp45, temp61,
    temp14, temp30, //temp46, temp62,
    temp15, temp31; //temp47, temp63;




always @(posedge clk_i or posedge rst_i)
    if(rst_i) begin 
        temp0  <= 0;	temp16 <= 0;	//temp32 <= 0;	temp48 <= 0;
        temp1  <= 0;    temp17 <= 0;    //temp33 <= 0;    temp49 <= 0;
        temp2  <= 0;    temp18 <= 0;    //temp34 <= 0;    temp50 <= 0;
        temp3  <= 0;    temp19 <= 0;    //temp35 <= 0;    temp51 <= 0;
        temp4  <= 0;    temp20 <= 0;    //temp36 <= 0;    temp52 <= 0;
        temp5  <= 0;    temp21 <= 0;    //temp37 <= 0;    temp53 <= 0;
        temp6  <= 0;    temp22 <= 0;    //temp38 <= 0;    temp54 <= 0;
        temp7  <= 0;    temp23 <= 0;    //temp39 <= 0;    temp55 <= 0;
        temp8  <= 0;    temp24 <= 0;    //temp40 <= 0;    temp56 <= 0;
        temp9  <= 0;    temp25 <= 0;    //temp41 <= 0;    temp57 <= 0;
        temp10 <= 0;    temp26 <= 0;    //temp42 <= 0;    temp58 <= 0;
        temp11 <= 0;    temp27 <= 0;    //temp43 <= 0;    temp59 <= 0;
        temp12 <= 0;    temp28 <= 0;    //temp44 <= 0;    temp60 <= 0;
        temp13 <= 0;    temp29 <= 0;    //temp45 <= 0;    temp61 <= 0;
        temp14 <= 0;    temp30 <= 0;    //temp46 <= 0;    temp62 <= 0;
        temp15 <= 0;    temp31 <= 0;    //temp47 <= 0;    temp63 <= 0;
    end 
    else if(den_in) begin 
        temp0  <= data_in;		//temp32 <= temp31;
        temp1  <= temp0 ;	    //temp33 <= temp32;
        temp2  <= temp1 ;       //temp34 <= temp33;
        temp3  <= temp2 ;       //temp35 <= temp34;
        temp4  <= temp3 ;       //temp36 <= temp35;
        temp5  <= temp4 ;       //temp37 <= temp36;
        temp6  <= temp5 ;       //temp38 <= temp37;
        temp7  <= temp6 ;       //temp39 <= temp38;
        temp8  <= temp7 ;       //temp40 <= temp39;
        temp9  <= temp8 ;       //temp41 <= temp40;
        temp10 <= temp9 ;       //temp42 <= temp41;
        temp11 <= temp10;       //temp43 <= temp42;
        temp12 <= temp11;       //temp44 <= temp43;
        temp13 <= temp12;       //temp45 <= temp44;
        temp14 <= temp13;       //temp46 <= temp45;
        temp15 <= temp14;       //temp47 <= temp46;
		                        //
		temp16 <= temp15;       //temp48 <= temp47;
        temp17 <= temp16;       //temp49 <= temp48;
        temp18 <= temp17;       //temp50 <= temp49;
        temp19 <= temp18;       //temp51 <= temp50;
        temp20 <= temp19;       //temp52 <= temp51;
        temp21 <= temp20;       //temp53 <= temp52;
        temp22 <= temp21;       //temp54 <= temp53;
        temp23 <= temp22;       //temp55 <= temp54;
        temp24 <= temp23;       //temp56 <= temp55;
        temp25 <= temp24;       //temp57 <= temp56;
        temp26 <= temp25;       //temp58 <= temp57;
        temp27 <= temp26;       //temp59 <= temp58;
        temp28 <= temp27;       //temp60 <= temp59;
        temp29 <= temp28;       //temp61 <= temp60;
        temp30 <= temp29;       //temp62 <= temp61;
        temp31 <= temp30;       //temp63 <= temp62;
	
    end 

always @(posedge clk_i or posedge rst_i)
    if(rst_i) begin 
        sum <= 0;
        data_out <= 0;
    end 
    else if(den_in) begin 
        sum <= sum + data_in - temp31; //temp63;
        data_out <= sum >> 5;
    end 

always @(posedge clk_i or posedge rst_i)
    if(rst_i) 
        den_out <= 0;
    else 
        den_out <= den_in;


// ila_avg_fifo ila_avg_fifo_inst (
	// .clk(clk_i), // input wire clk


	// .probe0(rst_i), // input wire [0:0]  probe0  
	// .probe1(data_in), // input wire [31:0]  probe1 
	// .probe2(den_in), // input wire [0:0]  probe2 
	// .probe3(data_out), // input wire [31:0]  probe3 
	// .probe4(den_out), // input wire [0:0]  probe4 
	// .probe5(sum) // input wire [36:0]  probe5
// );


endmodule