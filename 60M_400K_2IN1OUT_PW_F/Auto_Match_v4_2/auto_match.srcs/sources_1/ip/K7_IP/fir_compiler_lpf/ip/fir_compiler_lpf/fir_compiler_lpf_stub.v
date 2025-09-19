// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed Jun 11 19:41:00 2025
// Host        : GND_XWJ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top fir_compiler_lpf -prefix
//               fir_compiler_lpf_ fir_compiler_lpf_400k_stub.v
// Design      : fir_compiler_lpf_400k
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fir_compiler_v7_2_15,Vivado 2020.2" *)
module fir_compiler_lpf(aclk, s_axis_data_tvalid, s_axis_data_tready, 
  s_axis_data_tuser, s_axis_data_tdata, s_axis_config_tvalid, s_axis_config_tready, 
  s_axis_config_tdata, s_axis_reload_tvalid, s_axis_reload_tready, s_axis_reload_tlast, 
  s_axis_reload_tdata, m_axis_data_tvalid, m_axis_data_tuser, m_axis_data_tdata, 
  event_s_data_chanid_incorrect, event_s_reload_tlast_missing, 
  event_s_reload_tlast_unexpected)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_data_tvalid,s_axis_data_tready,s_axis_data_tuser[1:0],s_axis_data_tdata[63:0],s_axis_config_tvalid,s_axis_config_tready,s_axis_config_tdata[7:0],s_axis_reload_tvalid,s_axis_reload_tready,s_axis_reload_tlast,s_axis_reload_tdata[15:0],m_axis_data_tvalid,m_axis_data_tuser[1:0],m_axis_data_tdata[79:0],event_s_data_chanid_incorrect,event_s_reload_tlast_missing,event_s_reload_tlast_unexpected" */;
  input aclk;
  input s_axis_data_tvalid;
  output s_axis_data_tready;
  input [1:0]s_axis_data_tuser;
  input [63:0]s_axis_data_tdata;
  input s_axis_config_tvalid;
  output s_axis_config_tready;
  input [7:0]s_axis_config_tdata;
  input s_axis_reload_tvalid;
  output s_axis_reload_tready;
  input s_axis_reload_tlast;
  input [15:0]s_axis_reload_tdata;
  output m_axis_data_tvalid;
  output [1:0]m_axis_data_tuser;
  output [79:0]m_axis_data_tdata;
  output event_s_data_chanid_incorrect;
  output event_s_reload_tlast_missing;
  output event_s_reload_tlast_unexpected;
endmodule
