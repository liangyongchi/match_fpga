`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/28 14:24:40
// Design Name: 
// Module Name: complex_mult
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

module complex_mult#(
    parameter  DEBUG = "NO"
)(
    input           i_clk,
    
    input   [31:0]  A,//A
    input   [63:0]  B,//B
    
    output  [97:0]  C
);
//=================================================================================
wire    [15:0]      A_i;//A
wire    [15:0]      A_q;//B
wire    [31:0]      B_i;//C
wire    [31:0]      B_q;//D

wire    [47:0]      s_mult_p0   ;
wire    [47:0]      s_mult_p1   ;
wire    [47:0]      s_mult_p2   ;
wire    [47:0]      s_mult_p3   ;

reg     [48:0]      r_C_i       ;
reg     [48:0]      r_C_q       ;
//=================================================================================
//��·������������Ƶ�ź� I·����cos(��?t) Q·����-sin(��?t)  s(t)=I(t)cos(2��fct)?Q(t)sin(2��fct)
//?I·�ָ�?�������ź� �� cos(��?t) �� ��ͨ�˲� �� ���I��(t)
//Q·�ָ�?�������ź� �� -sin(��?t) �� ��ͨ�˲� �� ���Q��(t)

// ?��λͬ���뿹����?
// �������ز��뷢���ز�������λ��ȣ���������Ϊ��
// I��(t)=I(t)cos��+Q(t)sin��,
// Q��(t)=?I(t)sin��+Q(t)cos��

assign A_i = A[31:16];//cos
assign A_q = A[15: 0];//sin 
assign B_i = B[63:32];//I(t) ԭʼ�ź�
assign B_q = B[31: 0];//Q(t) ԭʼ�ź�

mult_signed_16x16 mult_inst0(i_clk, A_i, B_i, s_mult_p0);//cos * I(t)
mult_signed_16x16 mult_inst1(i_clk, A_q, B_q, s_mult_p1);//sin * Q(t)
mult_signed_16x16 mult_inst2(i_clk, A_q, B_i, s_mult_p2);//sin * I(t)
mult_signed_16x16 mult_inst3(i_clk, A_i, B_q, s_mult_p3);//cos * Q(t)
//=================================================================================

// result_i = A_I*(B_I + B_Q) - B_Q*(A_I + A_Q) = A_I*B_I + A_I*B_Q - B_Q*A_I - B_Q*A_Q = A_I*B_I - B_Q*A_Q
// result_q = A_I*(B_I + B_Q) - B_I*(A_I - A_Q) = A_I*B_I + A_I*B_Q - B_I*A_I + B_I*A_Q = A_I*B_Q + B_I*A_Q


always@(posedge i_clk)
begin
    r_C_i <= {s_mult_p0[47],s_mult_p0} - {s_mult_p1[47],s_mult_p1};//cos * I(t) - sin * Q(t)
    r_C_q <= {s_mult_p2[47],s_mult_p2} + {s_mult_p3[47],s_mult_p3};//sin * I(t) + cos * Q(t)
end

assign C = {r_C_i,r_C_q};
//================================================================================
// generate if(DEBUG=="YES") begin : DEBUG_GEN
// ila_0 ila_complex_mult (
    // .clk    (i_clk),
    // .probe0 ({
                 // A_i         
                // ,A_q 
                // ,B_i
                // ,B_q
                // ,s_mult_p0
                // ,s_mult_p1
                // ,s_mult_p2
                // ,s_mult_p3 
                
                // ,r_C_i
                // ,r_C_q
            // })
// );
// end endgenerate

endmodule