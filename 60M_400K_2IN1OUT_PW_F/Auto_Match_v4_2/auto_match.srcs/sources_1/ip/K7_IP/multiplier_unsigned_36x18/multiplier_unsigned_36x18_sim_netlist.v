// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Jul 14 19:42:23 2023
// Host        : DESKTOP-I02G0S2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Jonlen/MyWork/GEN2/FPGA/DiCoupler_v1/03_imp/DiCoupler/DiCoupler.srcs/sources_1/ip/multiplier_unsigned_36x18/multiplier_unsigned_36x18_sim_netlist.v
// Design      : multiplier_unsigned_36x18
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "multiplier_unsigned_36x18,mult_gen_v12_0_15,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_15,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module multiplier_unsigned_36x18
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [35:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [17:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [53:0]P;

  wire [35:0]A;
  wire [17:0]B;
  wire CLK;
  wire [53:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "36" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "53" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multiplier_unsigned_36x18_mult_gen_v12_0_15 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "1" *) (* C_A_WIDTH = "36" *) (* C_B_TYPE = "1" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "1" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "53" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintex7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_15" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module multiplier_unsigned_36x18_mult_gen_v12_0_15
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [35:0]A;
  input [17:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [53:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [35:0]A;
  wire [17:0]B;
  wire CLK;
  wire [53:0]P;
  wire [47:0]PCASC;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "36" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000001" *) 
  (* C_B_WIDTH = "18" *) 
  (* C_CCM_IMP = "0" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "1" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "53" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multiplier_unsigned_36x18_mult_gen_v12_0_15_viv i_mult
       (.A(A),
        .B(B),
        .CE(1'b0),
        .CLK(CLK),
        .P(P),
        .PCASC(PCASC),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_i_mult_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2019.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
KGg++J83s0yJ7o2/XMVLkRRTRjS0oC9h86tQjl1+xE1m53Uwmm0+K41skiYHo3Urr6lMQ4q2jL5Y
R/1NOu1WGg==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jCBx8aLaNWpgdwu0tsffQfmLNKET4Uy44Upxw9AlkO9Ma9Y+tqZHrHroYhGJUxa/dyJZ7Z0HDJ1t
hUhVV6SjuhVMs1NLM1MVw9F3MTSW7MB/qx7j0WAj62FJgoxsCtt6g392p1JAAosX8yACeLKiQ0KF
mnMpugzqSRDI445k7So=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zdO8kU0uCj5Mggk0oLUcYcllNQJVD7vxIj25evesPPwBvXuv6EUsbKmUaCAlFUyG0YQ0mxWxXmzV
V/dRqKxqZ1ZI8+mX4IFaTJSCcYctMZsCl+2EWvQQHakV4QzWuCyca1phNacrRJfur8Ssc/Mhbez3
GLQCRrSfyBYyi3u9J+SAJRcJapyB1syXXhclDtup6m1z2C5S+NX/ql6kVXkcd9P+C5ordunfutgU
6uco8UymF/9QFYiBCWlTkHAgd7DH3dCI1E72N2H/KpX0/0xFBk++NCVuNucOwd9h4/hAyr4L+SI0
6Dzmn6kaBO4lnMAj5P58GIeWO/EtqrPeWg4UJw==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
FdbUT4bIXyyFULrG0eEn0kqX6tjVoWssNb1FURO5jvyN5IkvkkDKCSLsd4J+2RE35ttJ20+4IZm2
p3H/UGCxkuCYtlZzovVpVf93DlhFUM2iSGd/L3evdLLL8VYETZTScGFdFXqiqe4ggXPHQCSEPD+e
PmMIJTGQka0DD3H+w+9t5Po/+M8b4r1y70l3Py7aYMeCEsZ/yHRmk8szsOjUbwvFEJk8SPXrEERg
EYMIrbryPHXq5E2fCL7hTgHa+bzIdFQOc2/8wn8YMVTmIJCZLBZDXvGSSm16cifWzXKHbPSly8js
RAoD2yYva4rr9cUy8jEyEpUcPGnaJXBDnB7lsQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_02", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
eGYl/A3vBqVYodgklvBXVlduDkQKDOe941//b/7D71XaDbW1Cqv7m5eqy+I7bUTyBfnKRV6WeTtg
K2eZlSMADPLNGmIEawb1T81kHA95L4SgxCaMDbzt0t5pO+IQTca0KxjvPFPjj860AZ/Y4IJCgD9Z
vZNfcSeez7bqGB9kVNzxh40hdeBm7XY8a+5R/yPufF2S8KSSaiPSvYwD8yXOBzVoRhqA9q5PWKTd
u6qoeWMnQ1r/hIDsge5oDE06b6+zC7odC460K8KIOtKzeCrfWezkynmD7wBR1fdIwh9FGe2Uq4lO
ZbT2QFx8Ga5NQIwIIZZci/uL4Tw/7+CPKEoddw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
k1GN+kT7KgRIHJs5Cw+hQb7EZrReCsvXgXeCjz4o0RyqpPm8XlxoPCNX4kR8BSaVxBTPm8qGrOj8
IkQcLP4XpLGNjMzOE8knGvgjraCBhhY/bboSihIYbJYXuKW0k/ErxcqbMup3dsmp8N5M+ZYpiEuF
88HraBjchDshDh5xlcY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jzBUDUoUQBD0tzi9B/VXNwpoyjUIKBzxkVyikkxc/QHKpaIlgud+eCQD6psG9RUWZouQN8CQmJEY
0K5qgvfm7GxXMbjLUwnVBRg4Uzfc4OTySfJMu1k9/qGISvYwf4r0rzMMp9aPgp+ElEwTGx3z9N0A
vWNdEjCI2mqdxmP3Q9AYUPTudILppELRMP4SJijczuRIhtAKpxFjTP2gL8zQE0aq1kkWRZfaHW1t
wV7tZ/jCUxkX8uj8DL6Bei6oBC1nTm/FjPhi+htKla8XNUEftaqUre2/0Sxhsxl/FTAzaex9fCj4
AMt2l6o0FpW5JlLhGnTYhWm/bgsyGCPBg6lSjQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Z6fBo4BhzsCATpk1i06Z0mWQfloRBhdF9wM5v8a5+iCx5rqUWGtaKN8oR4Wg7n5kNHP3zCgBBAv9
pIXr6ztNvuQz5yRmuquVbXR7jzqnKT6J5wszzK1OgyVRtbrRFboRuLWOKpJ+rEgJ8wJALNhTdDgg
+YQiDRDYh46DMRP6T6XDSZXSrfupAuuMrr88F1N40D9EFiLh4oBd9uF4B0YlBJJ5jJc1uKXoM3G3
0OK007mqxg1+EokqW40UnqWOC7b6yUCJkg57VwupK1C+TPC8mFqkCmLL/MZCIadPNRH/PsBsTzzE
fspHUNnzrod05d6y/hvX9k7H94KApVt6J1zIlA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
xeOxTjU8yMhu+8nb4nmnuLoB60COIC6oriB9d6NSiIRMLTHfL/+gOr9fJEz7ZK5ssDkknGiRXffn
lOKEFSKAujLgUCcjOZhlfNTafTzVlhRtyOCFTo8xcbny1Ojip1K5pj/GtyaMMZ/ceR6PQpyFnbjR
qgHrSTG86CqzIiScmea7YFTodKEQMZ6uG9mLM/v1GNV7PVLidOB8dj6S5LCVEopv2rPTvhwWsv/w
etqM4hz84+nNtflWMH0x1VAbB84WQN42n8wRWgD/0llr64NIUtEgDYculv0hpbAR6AAYU8FPjp9R
2xNq+coKfqp+OsSsHcFAJV/+ftcLPeysYZ/JSg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 22160)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
