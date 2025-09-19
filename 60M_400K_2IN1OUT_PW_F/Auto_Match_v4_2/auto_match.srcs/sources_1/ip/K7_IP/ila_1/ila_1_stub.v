// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Jun 20 15:18:47 2025
// Host        : GND_XWJ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/jason_xwj/Desktop/2INPUT2OUTPUT/INPUT_HF_60M/Auto_Match_v4_2/auto_match.srcs/sources_1/ip/K7_IP/ila_1/ila_1_stub.v
// Design      : ila_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.2" *)
module ila_1(clk, probe0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[511:0]" */;
  input clk;
  input [511:0]probe0;
endmodule
