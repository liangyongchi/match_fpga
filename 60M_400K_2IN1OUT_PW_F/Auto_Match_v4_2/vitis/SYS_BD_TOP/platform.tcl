# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct E:\1-code\match\60M_400K_DOUBLE_FREQ_2IN1OUT\60M_400K_2IN1OUT_PW_F\Auto_Match_v4_2\vitis\SYS_BD_TOP\platform.tcl
# 
# OR launch xsct and run below command.
# source E:\1-code\match\60M_400K_DOUBLE_FREQ_2IN1OUT\60M_400K_2IN1OUT_PW_F\Auto_Match_v4_2\vitis\SYS_BD_TOP\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {SYS_BD_TOP}\
-hw {E:\1-code\match\60M_400K_DOUBLE_FREQ_2IN1OUT\60M_400K_2IN1OUT_PW_F\Auto_Match_v4_2\vitis\SYS_BD_TOP.xsa}\
-fsbl-target {psu_cortexa53_0} -out {E:/1-code/match/60M_400K_DOUBLE_FREQ_2IN1OUT/60M_400K_2IN1OUT_PW_F/Auto_Match_v4_2/vitis}

platform write
domain create -name {freertos10_xilinx_ps7_cortexa9_0} -display-name {freertos10_xilinx_ps7_cortexa9_0} -os {freertos10_xilinx} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {freertos_hello_world}
platform generate -domains 
platform active {SYS_BD_TOP}
domain active {zynq_fsbl}
domain active {freertos10_xilinx_ps7_cortexa9_0}
platform generate -quick
platform generate
platform active {SYS_BD_TOP}
platform active {SYS_BD_TOP}
platform active {SYS_BD_TOP}
