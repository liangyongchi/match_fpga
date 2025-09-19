// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Jul 14 19:42:32 2023
// Host        : DESKTOP-I02G0S2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               C:/Jonlen/MyWork/GEN2/FPGA/DiCoupler_v1/03_imp/DiCoupler/DiCoupler.srcs/sources_1/ip/multiplier_signed_32x18/multiplier_signed_32x18_sim_netlist.v
// Design      : multiplier_signed_32x18
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "multiplier_signed_32x18,mult_gen_v12_0_15,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_15,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module multiplier_signed_32x18
   (CLK,
    A,
    B,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [17:0]B;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [49:0]P;

  wire [31:0]A;
  wire [17:0]B;
  wire CLK;
  wire [49:0]P;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "0" *) 
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
  (* C_OUT_HIGH = "49" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multiplier_signed_32x18_mult_gen_v12_0_15 U0
       (.A(A),
        .B(B),
        .CE(1'b1),
        .CLK(CLK),
        .P(P),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule

(* C_A_TYPE = "0" *) (* C_A_WIDTH = "32" *) (* C_B_TYPE = "0" *) 
(* C_B_VALUE = "10000001" *) (* C_B_WIDTH = "18" *) (* C_CCM_IMP = "0" *) 
(* C_CE_OVERRIDES_SCLR = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) 
(* C_HAS_ZERO_DETECT = "0" *) (* C_LATENCY = "1" *) (* C_MODEL_TYPE = "0" *) 
(* C_MULT_TYPE = "1" *) (* C_OPTIMIZE_GOAL = "1" *) (* C_OUT_HIGH = "49" *) 
(* C_OUT_LOW = "0" *) (* C_ROUND_OUTPUT = "0" *) (* C_ROUND_PT = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintex7" *) (* ORIG_REF_NAME = "mult_gen_v12_0_15" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module multiplier_signed_32x18_mult_gen_v12_0_15
   (CLK,
    A,
    B,
    CE,
    SCLR,
    ZERO_DETECT,
    P,
    PCASC);
  input CLK;
  input [31:0]A;
  input [17:0]B;
  input CE;
  input SCLR;
  output [1:0]ZERO_DETECT;
  output [49:0]P;
  output [47:0]PCASC;

  wire \<const0> ;
  wire [31:0]A;
  wire [17:0]B;
  wire CLK;
  wire [49:0]P;
  wire [47:0]PCASC;
  wire [1:0]NLW_i_mult_ZERO_DETECT_UNCONNECTED;

  assign ZERO_DETECT[1] = \<const0> ;
  assign ZERO_DETECT[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "0" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_B_TYPE = "0" *) 
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
  (* C_OUT_HIGH = "49" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  multiplier_signed_32x18_mult_gen_v12_0_15_viv i_mult
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
G742efinKFgnurR18kblRFHTk+bPAP/VsMi6BUdJ6VhyBlyfAKQSiC9XLO6LhNADiieTtrrS9+Fn
pZBJGoMgAtRJ5nUimwa6mx0UfTHZKQlzzGe0WHHoXLZuzENJXsgkRXtapLov29nIyz41aWONiyOl
8AMXrIWzWjs2J30WgBj2N7ZdsVf0tgFuBqC8N7IZOP9Uaum8WmffhMPI6TzqhkxI8uqRycIdAW2q
AtY/nhRPW64HuumS1bmfczHUlnO4Z2mMAsTchQ6zfegVrrwa9UcGyeJnHRjUG/h6QkbHE7DD+IXG
VAxopWuFjHhSkA270mUS+dyq7+ZSXHtlhAOGGw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LMryshhXBjTw5xiSAf5Z9SQ+fqPTTSz3s8ipNI0/qRvsuxXs2sQ2XosdoD9g3V7WoJOZWYnfszfs
/34naZd/YBrGRvtxrL4VQ6y/duiJEeoei1twDjP/Gc8+cm/oo2NknS6mIz1UnNQd2/SIWL5023Js
eUNJvk1LpGhwSK5cKVwLUTAjxOzUMxbuBNOwPmkanhyCNueCS6tjpZORR526VC0AH7o1QMyApPBY
IjAQPMFsmxNmI5FoBXJTtFDtpfhNAQ18nWGQp/vDlRQEuidt6XaF8vRmK1MyIb6pF3Ean1lMSTQ7
YhPCAbepWLM8fFhyLKur0ZwVrSEn7XDBmiUUeg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 14368)
`pragma protect data_block
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
7RNsoQ==
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
