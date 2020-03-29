

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "matrix_as_plus_e_mm_ip" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXI_BASEADDR" "C_S00_AXI_HIGHADDR" "C_S01_AXI_BASEADDR" "C_S01_AXI_HIGHADDR" "C_S02_AXI_BASEADDR" "C_S02_AXI_HIGHADDR"
}
