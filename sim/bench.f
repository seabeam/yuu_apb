-timescale=1ns/1ps
//-------------------------------------
// DUT Define 
//-------------------------------------

//-------------------------------------
// DUT Include 
//-------------------------------------

//-------------------------------------
// DUT Filelist
//-------------------------------------

//-------------------------------------
// C Define 
//-------------------------------------

//-------------------------------------
// C Include 
//-------------------------------------
//-I../src/c

//-------------------------------------
// C Filelist
//-------------------------------------

//-------------------------------------
// SV Define
//-------------------------------------
+define+YUU_APB_MASTER_NUM=1
+define+YUU_APB_SLAVE_NUM=1
+define+YUU_APB_ADDR_WIDTH=32
+define+YUU_APB_DATA_WIDTH=32

//-------------------------------------
// SV Include
//-------------------------------------
+incdir+../../yuu_common/include
+incdir+../../yuu_common/src/sv
+incdir+../../yuu_amba/include/
+incdir+../../yuu_amba/src/sv
+incdir+../include
+incdir+../src/sv/yuu_apb_common
+incdir+../src/sv/yuu_apb_master
+incdir+../src/sv/yuu_apb_slave
+incdir+../src/sv/yuu_apb_env
+incdir+../test

//-------------------------------------
// SV Filelist
//-------------------------------------
../../yuu_common/include/yuu_common_pkg.sv
../../yuu_amba/include/yuu_amba_pkg.sv
../include/yuu_apb_pkg.sv

//-------------------------------------
// Case List
//-------------------------------------
../test/yuu_apb_base_case.sv
../test/yuu_apb_direct_case.sv

//-------------------------------------
// Top Module
//-------------------------------------
top.sv
