`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/18 09:59:56
// Design Name: 
// Module Name: ARP_Table
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


module ARP_Table(
    input               i_clk           ,
    input               i_rst           ,

    input  [31:0]       i_seek_ip       ,
    input               i_seek_valid    ,

    input  [31:0]       i_updata_ip     ,
    input  [47:0]       i_updata_mac    ,
    input               i_updata_valid  ,

    output [47:0]       o_active_mac    ,
    output              o_active_valid  
);  

/***************function**************/

/***************parameter*************/
localparam              P_ST_IDLE       =   0   ,
                        P_ST_SEEK       =   1   ,
                        P_ST_UPDATA_S   =   2   ,
                        P_ST_UPDATA     =   3   ,
                        P_ST_MAC        =   4   ;

/***************port******************/             

/***************mechine***************/
reg  [7 :0]             r_st_current    ;
reg  [7 :0]             r_st_next       ;

/***************reg*******************/
reg  [31:0]             r_seek_ip       ;
reg  [31:0]             r_updata_ip     ;
reg  [47:0]             r_updata_mac    ;
reg  [47:0]             ro_active_mac   ;
reg                     ro_active_valid ;
reg                     ri_seek_valid   ;
reg                     ri_updata_valid ;
reg                     r_ram_ip_en     ;
reg                     r_ram_ip_we     ;
reg  [2 :0]             r_ram_ip_addr   ;
reg                     r_ram_ip_dv     ;
reg                     r_ram_mac_en    ;
reg                     r_ram_mac_we    ;
reg  [2 :0]             r_ram_mac_addr  ;
reg                     r_ram_mac_dv    ;
reg                     r_ip_access     ;
reg  [2 :0]             r_access_addr   ;
reg                     r_ram_ip_end    ;
reg                     r_ram_ip_end_1d ;
reg                     r_updata_acc    ;
reg  [2 :0]             r_up_data_addr  ;

/***************wire******************/
wire [31:0]             w_ram_ip_dout   ;
wire [47:0]             w_ram_mac_dout  ;
wire                    w_seek_v_pos    ;
wire                    w_seek_v_neg    ;
wire                    w_updata_v_pos  ;
wire                    w_updata_v_neg  ;
wire                    r_ram_ip_end_neg;


/***************component*************/
RAM_IP RAM_IP_U0 (
  .clka     (i_clk          ),
  .ena      (r_ram_ip_en    ),
  .wea      (r_ram_ip_we    ),
  .addra    (r_ram_ip_addr  ),
  .dina     (r_updata_ip    ),
  .douta    (w_ram_ip_dout  ) 
);

RAM_MAC RAM_MAC_U0 (
  .clka     (i_clk          ), 
  .ena      (r_ram_mac_en   ), 
  .wea      (r_ram_mac_we   ), 
  .addra    (r_ram_mac_addr ), 
  .dina     (r_updata_mac   ), 
  .douta    (w_ram_mac_dout )  
);
/***************assign****************/
assign o_active_mac   = ro_active_mac   ;
assign o_active_valid = ro_active_valid ;
assign w_seek_v_pos   = i_seek_valid & !ri_seek_valid;
assign w_seek_v_neg   = !i_seek_valid & ri_seek_valid;
assign w_updata_v_pos = i_updata_valid & !ri_updata_valid;
assign w_updata_v_neg = !i_updata_valid & ri_updata_valid;
assign r_ram_ip_end_neg = r_ram_ip_end & !r_ram_ip_end_1d;

/***************always****************/
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st_current <= P_ST_IDLE;
    else 
        r_st_current <= r_st_next;
end

always@(*)
begin
    case(r_st_current)
        P_ST_IDLE       :r_st_next = w_seek_v_pos   ? P_ST_SEEK     : 
                                     i_updata_valid ? P_ST_UPDATA_S : P_ST_IDLE;
        P_ST_SEEK       :r_st_next = r_ip_access || (r_ram_ip_end_neg && !r_ip_access)? P_ST_MAC    : P_ST_SEEK;
        P_ST_UPDATA_S   :r_st_next = r_updata_acc ? P_ST_IDLE : 
                                     (r_ram_ip_end_neg && !r_updata_acc) ? P_ST_UPDATA : P_ST_UPDATA_S;
        P_ST_UPDATA     :r_st_next = P_ST_IDLE;
        P_ST_MAC        :r_st_next = P_ST_IDLE;
        default         :r_st_next = P_ST_IDLE;
    endcase 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_seek_ip <= 'd0;
    else if(i_seek_valid)
        r_seek_ip <= i_seek_ip;
    else 
        r_seek_ip <= r_seek_ip;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_updata_ip  <= 'd0;
        r_updata_mac <= 'd0;
    end else if(i_updata_valid) begin     
        r_updata_ip  <= i_updata_ip ;
        r_updata_mac <= i_updata_mac;
    end else begin
        r_updata_ip  <= r_updata_ip ;
        r_updata_mac <= r_updata_mac;
    end 
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_seek_valid   <= 'd0;
        ri_updata_valid <= 'd0;
    end else begin
        ri_seek_valid   <= i_seek_valid  ;
        ri_updata_valid <= i_updata_valid;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin  
        r_ram_ip_en   <= 'd0;
        r_ram_ip_we   <= 'd0;
        r_ram_ip_addr <= 'd0;   
    end else if(r_st_current == P_ST_SEEK && !r_ram_ip_end) begin
        r_ram_ip_en   <= 'd1;
        r_ram_ip_we   <= 'd0;
        if(r_ram_ip_en) r_ram_ip_addr <= r_ram_ip_addr + 1;
        else r_ram_ip_addr <= 'd0;

    end else if(r_st_current == P_ST_UPDATA_S && !r_ram_ip_end) begin
        r_ram_ip_en   <= 'd1;
        r_ram_ip_we   <= 'd0;
        if(r_ram_ip_en) r_ram_ip_addr <= r_ram_ip_addr + 1;
        else r_ram_ip_addr <= 'd0;
        
    end else if(r_st_current == P_ST_UPDATA) begin
        r_ram_ip_en   <= 'd1;
        r_ram_ip_we   <= 'd1;
        r_ram_ip_addr <= r_up_data_addr;
    end else begin
        r_ram_ip_en   <= 'd0;
        r_ram_ip_we   <= 'd0;
        r_ram_ip_addr <= 'd0;
    end 
end



always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin  
        r_ram_mac_en   <= 'd0;
        r_ram_mac_we   <= 'd0;
        r_ram_mac_addr <= 'd0;   
    end else if(r_st_current == P_ST_UPDATA_S && !r_ram_ip_end) begin
        r_ram_mac_en   <= 'd1;
        r_ram_mac_we   <= 'd0;
        r_ram_mac_addr <= r_ram_mac_addr + 1;
    end else if(r_st_current == P_ST_UPDATA) begin
        r_ram_mac_en   <= 'd1;
        r_ram_mac_we   <= 'd1;
        r_ram_mac_addr <= r_up_data_addr;
    end else if(r_ram_ip_dv && w_ram_ip_dout == r_seek_ip) begin
        r_ram_mac_en   <= 'd1;
        r_ram_mac_we   <= 'd0;
        r_ram_mac_addr <= r_access_addr;
    end else begin
        r_ram_mac_en   <= 'd0;
        r_ram_mac_we   <= 'd0;
        r_ram_mac_addr <= 'd0;
    end 
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_ip_end <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        r_ram_ip_end <= 'd0;
    else if(r_st_current == P_ST_SEEK && r_ram_ip_addr == 7)
        r_ram_ip_end <= 'd1;
    else if(r_st_current == P_ST_UPDATA_S && r_ram_ip_addr == 7)
        r_ram_ip_end <= 'd1;
    else 
        r_ram_ip_end <= r_ram_ip_end;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_ip_end_1d <= 'd0;
    else
        r_ram_ip_end_1d <= r_ram_ip_end;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ram_ip_dv <= 'd0;
    else if(r_ram_ip_en && !r_ram_ip_we && !r_ip_access)
        r_ram_ip_dv <= 'd1;
    else 
        r_ram_ip_dv <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_ip_access <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        r_ip_access <= 'd0;
    else if(r_ram_ip_dv && w_ram_ip_dout == r_seek_ip)
        r_ip_access <= 'd1;
    else 
        r_ip_access <= r_ip_access;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_access_addr <= 'd0;
    else if(r_st_current == P_ST_IDLE)
        r_access_addr <= 'd0;
    else if(r_ram_ip_dv && !r_ip_access)
        r_access_addr <= r_access_addr + 1;
    else 
        r_access_addr <= r_access_addr;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_updata_acc <= 'd0;
    else if(r_ram_ip_dv && w_ram_ip_dout == r_updata_ip && w_ram_mac_dout == r_updata_mac)
        r_updata_acc <= 'd1;
    else 
        r_updata_acc <= 'd0;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_up_data_addr <= 'd0;
    else if(r_st_current == P_ST_UPDATA)
        r_up_data_addr <= r_up_data_addr + 1;
    else 
        r_up_data_addr <= r_up_data_addr;
end

  

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_active_mac <= 48'd0;
    else if(r_st_current == P_ST_MAC && r_ip_access)
        ro_active_mac <= w_ram_mac_dout;
    else        
        ro_active_mac <= 48'hffffffffffff;
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_active_valid <= 'd0;
    else if(r_st_current == P_ST_MAC)
        ro_active_valid <= 'd1;
    else 
        ro_active_valid <= 'd0;
end
endmodule
