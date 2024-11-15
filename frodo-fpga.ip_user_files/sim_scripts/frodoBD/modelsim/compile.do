vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/axi_vip_v1_1_5
vlib modelsim_lib/msim/processing_system7_vip_v1_0_7
vlib modelsim_lib/msim/lib_cdc_v1_0_2
vlib modelsim_lib/msim/proc_sys_reset_v5_0_13
vlib modelsim_lib/msim/generic_baseblocks_v2_1_0
vlib modelsim_lib/msim/axi_register_slice_v2_1_19
vlib modelsim_lib/msim/fifo_generator_v13_2_4
vlib modelsim_lib/msim/axi_data_fifo_v2_1_18
vlib modelsim_lib/msim/axi_crossbar_v2_1_20
vlib modelsim_lib/msim/axi_lite_ipif_v3_0_4
vlib modelsim_lib/msim/interrupt_control_v3_1_4
vlib modelsim_lib/msim/axi_gpio_v2_0_21
vlib modelsim_lib/msim/axi_protocol_converter_v2_1_19

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_5 modelsim_lib/msim/axi_vip_v1_1_5
vmap processing_system7_vip_v1_0_7 modelsim_lib/msim/processing_system7_vip_v1_0_7
vmap lib_cdc_v1_0_2 modelsim_lib/msim/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 modelsim_lib/msim/proc_sys_reset_v5_0_13
vmap generic_baseblocks_v2_1_0 modelsim_lib/msim/generic_baseblocks_v2_1_0
vmap axi_register_slice_v2_1_19 modelsim_lib/msim/axi_register_slice_v2_1_19
vmap fifo_generator_v13_2_4 modelsim_lib/msim/fifo_generator_v13_2_4
vmap axi_data_fifo_v2_1_18 modelsim_lib/msim/axi_data_fifo_v2_1_18
vmap axi_crossbar_v2_1_20 modelsim_lib/msim/axi_crossbar_v2_1_20
vmap axi_lite_ipif_v3_0_4 modelsim_lib/msim/axi_lite_ipif_v3_0_4
vmap interrupt_control_v3_1_4 modelsim_lib/msim/interrupt_control_v3_1_4
vmap axi_gpio_v2_0_21 modelsim_lib/msim/axi_gpio_v2_0_21
vmap axi_protocol_converter_v2_1_19 modelsim_lib/msim/axi_protocol_converter_v2_1_19

vlog -work xilinx_vip -64 -incr -sv -L axi_vip_v1_1_5 -L processing_system7_vip_v1_0_7 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib -64 -incr -sv -L axi_vip_v1_1_5 -L processing_system7_vip_v1_0_7 -L xilinx_vip "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_5 -64 -incr -sv -L axi_vip_v1_1_5 -L processing_system7_vip_v1_0_7 -L xilinx_vip "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/d4a8/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_7 -64 -incr -sv -L axi_vip_v1_1_5 -L processing_system7_vip_v1_0_7 -L xilinx_vip "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/frodoBD/ip/frodoBD_processing_system7_0_0/sim/frodoBD_processing_system7_0_0.v" \

vcom -work lib_cdc_v1_0_2 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/frodoBD/ip/frodoBD_proc_sys_reset_0_0/sim/frodoBD_proc_sys_reset_0_0.vhd" \

vlog -work generic_baseblocks_v2_1_0 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_19 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/4d88/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_4 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_4 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_4 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_18 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/5b9c/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_20 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ace7/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/frodoBD/ip/frodoBD_xbar_0/sim/frodoBD_xbar_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work interrupt_control_v3_1_4 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \

vcom -work axi_gpio_v2_0_21 -64 -93 \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/9c6e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93 \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_4_0/sim/frodoBD_axi_gpio_4_0.vhd" \
"../../../bd/frodoBD/ipshared/ff14/src/controller.vhd" \
"../../../bd/frodoBD/ipshared/ff14/hdl/matrix_sa_plus_e_mm_ip_v1_0_S00_AXI.vhd" \
"../../../bd/frodoBD/ipshared/ff14/hdl/matrix_sa_plus_e_mm_ip_v1_0_S01_AXI.vhd" \
"../../../bd/frodoBD/ipshared/ff14/hdl/matrix_sa_plus_e_mm_ip_v1_0_S02_AXI.vhd" \
"../../../bd/frodoBD/ipshared/ff14/src/multiplicator.vhd" \
"../../../bd/frodoBD/ipshared/ff14/hdl/timer_controller.vhd" \
"../../../bd/frodoBD/ipshared/ff14/src/true_dual_bram.vhd" \
"../../../bd/frodoBD/ipshared/ff14/src/true_single_bram.vhd" \
"../../../bd/frodoBD/ipshared/ff14/hdl/matrix_sa_plus_e_mm_ip_v1_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_matrix_sa_plus_e_mm_ip_0_0/sim/frodoBD_matrix_sa_plus_e_mm_ip_0_0.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/controller2.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/matrix_as_plus_e_mm_ip_v1_0_S00_AXI.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/matrix_as_plus_e_mm_ip_v1_0_S01_AXI.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/matrix_as_plus_e_mm_ip_v1_0_S02_AXI.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/multiplicator2.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/timer_controller2.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/true_single_bram2.vhd" \
"../../../bd/frodoBD/ipshared/bdb9/hdl/matrix_as_plus_e_mm_ip_v1_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_matrix_as_plus_e_mm_0_0/sim/frodoBD_matrix_as_plus_e_mm_0_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_5_0/sim/frodoBD_axi_gpio_5_0.vhd" \
"../../../bd/frodoBD/ipshared/ea3f/hdl/timer_v1_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_2_0/sim/frodoBD_timer_2_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_3_0/sim/frodoBD_timer_3_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_0_3/sim/frodoBD_axi_gpio_0_3.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_1_0/sim/frodoBD_axi_gpio_1_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_4_0/sim/frodoBD_timer_4_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_5_0/sim/frodoBD_timer_5_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_4_1/sim/frodoBD_axi_gpio_4_1.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_7_0/sim/frodoBD_axi_gpio_7_0.vhd" \
"../../../bd/frodoBD/ipshared/63bc/src/keccak_global2.vhd" \
"../../../bd/frodoBD/ipshared/63bc/src/keccak_f1600_mm_core_fast2.vhd" \
"../../../bd/frodoBD/ipshared/63bc/src/shake128_core.vhd" \
"../../../bd/frodoBD/ipshared/63bc/hdl/shake128_ip_v1_0_S00_AXI.vhd" \
"../../../bd/frodoBD/ipshared/63bc/hdl/timer_controller3.vhd" \
"../../../bd/frodoBD/ipshared/63bc/src/true_single_bram3.vhd" \
"../../../bd/frodoBD/ipshared/63bc/hdl/shake128_ip_v1_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_shake128_ip_0_0/sim/frodoBD_shake128_ip_0_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_6_0/sim/frodoBD_timer_6_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_7_0/sim/frodoBD_timer_7_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_8_1/sim/frodoBD_axi_gpio_8_1.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_9_0/sim/frodoBD_axi_gpio_9_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_10_0/sim/frodoBD_axi_gpio_10_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_11_0/sim/frodoBD_axi_gpio_11_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_8_0/sim/frodoBD_timer_8_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_12_0/sim/frodoBD_axi_gpio_12_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_13_0/sim/frodoBD_axi_gpio_13_0.vhd" \
"../../../bd/frodoBD/sim/frodoBD.vhd" \
"../../../bd/frodoBD/ip/frodoBD_timer_0_0/sim/frodoBD_timer_0_0.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_0_4/sim/frodoBD_axi_gpio_0_4.vhd" \
"../../../bd/frodoBD/ip/frodoBD_axi_gpio_3_0/sim/frodoBD_axi_gpio_3_0.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/frodoBD/ip/frodoBD_tier2_xbar_0_0/sim/frodoBD_tier2_xbar_0_0.v" \
"../../../bd/frodoBD/ip/frodoBD_tier2_xbar_1_0/sim/frodoBD_tier2_xbar_1_0.v" \
"../../../bd/frodoBD/ip/frodoBD_tier2_xbar_2_0/sim/frodoBD_tier2_xbar_2_0.v" \

vlog -work axi_protocol_converter_v2_1_19 -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/c83a/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl" "+incdir+../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ip/frodoBD_processing_system7_0_0" "+incdir+C:/Xilinx/Vivado/2019.1/data/xilinx_vip/include" \
"../../../bd/frodoBD/ip/frodoBD_auto_pc_0/sim/frodoBD_auto_pc_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

