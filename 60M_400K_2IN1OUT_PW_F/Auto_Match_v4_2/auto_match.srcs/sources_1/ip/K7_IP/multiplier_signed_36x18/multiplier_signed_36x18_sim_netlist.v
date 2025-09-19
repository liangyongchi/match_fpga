// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Jul 14 19:43:52 2023
// Host        : DESKTOP-I02G0S2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Jonlen/MyWork/GEN2/FPGA/DiCoupler_v1/03_imp/DiCoupler/DiCoupler.srcs/sources_1/ip/multiplier_signed_36x18/multiplier_signed_36x18_sim_netlist.v
// Design      : multiplier_signed_36x18
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "multiplier_signed_36x18,mult_gen_v12_0_15,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_15,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module multiplier_signed_36x18
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

  (* C_A_TYPE = "0" *) 
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
  multiplier_signed_36x18_mult_gen_v12_0_15 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "36" *) (* C_B_TYPE = "1" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "1" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "53" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintex7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_15" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module multiplier_signed_36x18_mult_gen_v12_0_15
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
  (* C_A_TYPE = "0" *) 
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
  multiplier_signed_36x18_mult_gen_v12_0_15_viv i_mult
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
gUE1IDh1vET8nF868TIyiadLbI8uyKXXHCrtTT9qraDvcI26F+39ANOw5Krn1VcRkuNylT3gav4r
4V0BYLxsENpaOPwana5Xu9hujaMHWNpymukfEcI1usRNHyKm8pYPn3Tz67JvGbnAUQm/mCzqPGw2
emrF2+jVSRzvTIYjn8oAFUzcPU5lFhCtdGQ0UvQC2HR6wPlHeKMzjF+iiMH2WS90nsPDol/Y4dHE
qG6yIf7PB4Qmu3kDusmV6zC4+9JngYaUcY7ewosxC8ydTlw35t+q0xvqAVlDWI+xqxioi+mmUCxQ
hiYH3lidmNJGu/xnaoN/2vjCeGL1mkotVgsg6g==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
4TzYdKDMO4u5MYsAuX/wxDV+V01R+/4/4YhZkOSzOcIcI3CRt32xkQDV83MdHlOePS4IJ8vELWu4
Kp/608xbyEfp5N5Yd3XkOMOtY4lxndJTWJYIaMYr2X4wNO0cfH9oZ+ekIPpEGAEdEdkjggv8QhBv
76CKW7Ky2jGkCOLBsW7yrndthYbULneg/ovKIa4iLbXmUbY2T/gJvZlD7BClmeg1ECXuI4XH6h26
cCegDFw4yy199+ngxmY3DxgWZfdNATNmWkfWiF0kRSLp5NhMR+oYmOwV228eFu2xgJpU8Loz8EPx
Hx5Bdq9CyMz73AGJNBiufaz/x3WwuZsjs3Yiag==

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
