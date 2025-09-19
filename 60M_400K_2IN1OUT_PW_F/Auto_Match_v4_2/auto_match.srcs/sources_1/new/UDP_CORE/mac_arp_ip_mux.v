`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/18 17:10:49
// Design Name: 
// Module Name: mac_arp_ip_mux
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


module mac_arp_ip_mux(
    input               i_clk           ,
    input               i_rst           ,

    input  [15:0]       i_type          ,
    input  [7 :0]       i_data          ,
    input               i_last          ,
    input               i_valid         ,

    output [7 :0]       o_ip_data       ,
    output              o_ip_last       ,
    output              o_ip_valid      ,

    output [7 :0]       o_arp_data      ,
    output              o_arp_last      ,
    output              o_arp_valid     
);

reg  [7 :0]             ro_ip_data      ;
reg                     ro_ip_last      ;
reg                     ro_ip_valid     ;
reg  [7 :0]             ro_arp_data     ;
reg                     ro_arp_last     ;
reg                     ro_arp_valid    ;

assign o_ip_data   = ro_ip_data          ;
assign o_ip_last   = ro_ip_last          ;
assign o_ip_valid  = ro_ip_valid         ;
assign o_arp_data  = ro_arp_data         ;
assign o_arp_last  = ro_arp_last         ;
assign o_arp_valid = ro_arp_valid        ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_ip_data  <= 'd0;
        ro_ip_last  <= 'd0;
        ro_ip_valid <= 'd0;
    end else if(i_type == 16'h0800) begin
        ro_ip_data  <= i_data ;
        ro_ip_last  <= i_last ;
        ro_ip_valid <= i_valid;
    end else begin
        ro_ip_data  <= 'd0;
        ro_ip_last  <= 'd0;
        ro_ip_valid <= 'd0;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_arp_data  <= 'd0;
        ro_arp_last  <= 'd0;
        ro_arp_valid <= 'd0;
    end else if(i_type == 16'h0806) begin
        ro_arp_data   <= i_data ;
        ro_arp_last   <= i_last ;
        ro_arp_valid <= i_valid;
    end else begin
        ro_arp_data  <= 'd0;
        ro_arp_last  <= 'd0;
        ro_arp_valid <= 'd0;
    end 
end

endmodule
