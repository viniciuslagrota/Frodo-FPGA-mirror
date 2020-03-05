-makelib ies_lib/xilinx_vip -sv \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "C:/Xilinx/Vivado/2019.1/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/axi_infrastructure_v1_1_0 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_vip_v1_1_5 -sv \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/d4a8/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib ies_lib/processing_system7_vip_v1_0_7 -sv \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8c62/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_processing_system7_0_0/sim/frodoBD_processing_system7_0_0.v" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_13 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_proc_sys_reset_0_0/sim/frodoBD_proc_sys_reset_0_0.vhd" \
-endlib
-makelib ies_lib/generic_baseblocks_v2_1_0 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_register_slice_v2_1_19 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/4d88/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_4 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_4 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_4 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/1f5a/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib ies_lib/axi_data_fifo_v2_1_18 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/5b9c/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/axi_crossbar_v2_1_20 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/ace7/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_xbar_0/sim/frodoBD_xbar_0.v" \
-endlib
-makelib ies_lib/axi_lite_ipif_v3_0_4 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/interrupt_control_v3_1_4 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies_lib/axi_gpio_v2_0_21 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/9c6e/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_axi_gpio_1_0/sim/frodoBD_axi_gpio_1_0.vhd" \
-endlib
-makelib ies_lib/lib_pkg_v1_0_2 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/lib_fifo_v1_0_13 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/4dac/hdl/lib_fifo_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/axi_fifo_mm_s_v4_2_1 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/fd10/hdl/axi_fifo_mm_s_v4_2_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_axi_fifo_mm_s_0_0/sim/frodoBD_axi_fifo_mm_s_0_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_axi_gpio_2_0/sim/frodoBD_axi_gpio_2_0.vhd" \
  "../../../bd/frodoBD/ipshared/ea3f/hdl/timer_v1_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_timer_0_2/sim/frodoBD_timer_0_2.vhd" \
  "../../../bd/frodoBD/ipshared/7d49/hdl/keccak_f1600_core.vhd" \
  "../../../bd/frodoBD/ipshared/7d49/hdl/keccak_f1600_ip_v1_0_M00_AXIS.vhd" \
  "../../../bd/frodoBD/ipshared/7d49/hdl/keccak_f1600_ip_v1_0_S00_AXIS.vhd" \
  "../../../bd/frodoBD/ipshared/7d49/hdl/keccak_f1600_ip_v1_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_keccak_f1600_ip_0_0/sim/frodoBD_keccak_f1600_ip_0_0.vhd" \
  "../../../bd/frodoBD/ipshared/355c/hdl/keccak_f1600_mm_core.vhd" \
  "../../../bd/frodoBD/ipshared/355c/hdl/keccak_f1600_mm_ip_v1_0_S00_AXI.vhd" \
  "../../../bd/frodoBD/ipshared/355c/hdl/keccak_f1600_mm_ip_v1_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_keccak_f1600_mm_ip_0_0/sim/frodoBD_keccak_f1600_mm_ip_0_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_timer_1_0/sim/frodoBD_timer_1_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_axi_gpio_0_1/sim/frodoBD_axi_gpio_0_1.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_axi_gpio_3_0/sim/frodoBD_axi_gpio_3_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_axi_gpio_4_0/sim/frodoBD_axi_gpio_4_0.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/src/controller.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/hdl/matrix_sa_plus_e_mm_ip_v1_0_S00_AXI.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/hdl/matrix_sa_plus_e_mm_ip_v1_0_S01_AXI.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/hdl/matrix_sa_plus_e_mm_ip_v1_0_S02_AXI.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/src/multiplicator.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/src/true_dual_bram.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/src/true_single_bram.vhd" \
  "../../../bd/frodoBD/ipshared/feb5/hdl/matrix_sa_plus_e_mm_ip_v1_0.vhd" \
  "../../../bd/frodoBD/ip/frodoBD_matrix_sa_plus_e_mm_ip_0_0/sim/frodoBD_matrix_sa_plus_e_mm_ip_0_0.vhd" \
-endlib
-makelib ies_lib/axi_protocol_converter_v2_1_19 \
  "../../../../frodo-fpga.srcs/sources_1/bd/frodoBD/ipshared/c83a/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/ip/frodoBD_auto_pc_0/sim/frodoBD_auto_pc_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../bd/frodoBD/sim/frodoBD.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

