// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Mon Apr 21 16:10:24 2025
// Host        : GND_XWJ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/jason_xwj/Desktop/match_FPGA/ZYNQ_match_prj/Auto_Match_v1/Auto_Match_v1/auto_match.srcs/sources_1/ip/K7_IP/ila_avg_fifo/ila_avg_fifo_stub.v
// Design      : ila_avg_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.2" *)
module ila_avg_fifo(clk, probe0, probe1, probe2, probe3, probe4, probe5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[31:0],probe2[0:0],probe3[31:0],probe4[0:0],probe5[36:0]" */;
  input clk;
  input [0:0]probe0;
  input [31:0]probe1;
  input [0:0]probe2;
  input [31:0]probe3;
  input [0:0]probe4;
  input [36:0]probe5;
endmodule
