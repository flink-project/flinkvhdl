# TCL File Generated by Component Editor 13.0sp1
# Tue Feb 04 11:23:19 CET 2014
# DO NOT MODIFY


# 
# lpb_mpc5200b_to_avalon "lpb_mpc5200b_to_avalon" v1.0.1
#  2014.02.04.11:23:19
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module lpb_mpc5200b_to_avalon
# 
set_module_property DESCRIPTION ""
set_module_property NAME lpb_mpc5200b_to_avalon
set_module_property VERSION 1.0.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP PHYTEC
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME lpb_mpc5200b_to_avalon
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset quartus_synth QUARTUS_SYNTH "" "Quartus Synthesis"
set_fileset_property quartus_synth TOP_LEVEL lpb_mpc5200b_to_avalon
set_fileset_property quartus_synth ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file mpc5200b_lpb_to_avalon.vhd VHDL PATH mpc5200b_lpb_to_avalon.vhd TOP_LEVEL_FILE

add_fileset sim_vhdl SIM_VHDL "" "VHDL Simulation"
set_fileset_property sim_vhdl TOP_LEVEL lpb_mpc5200b_to_avalon
set_fileset_property sim_vhdl ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file mpc5200b_lpb_to_avalon.vhd VHDL PATH mpc5200b_lpb_to_avalon.vhd


# 
# parameters
# 
add_parameter LPBADDRWIDTH INTEGER 32 ""
set_parameter_property LPBADDRWIDTH DEFAULT_VALUE 32
set_parameter_property LPBADDRWIDTH DISPLAY_NAME LPBADDRWIDTH
set_parameter_property LPBADDRWIDTH TYPE INTEGER
set_parameter_property LPBADDRWIDTH UNITS None
set_parameter_property LPBADDRWIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LPBADDRWIDTH DESCRIPTION ""
set_parameter_property LPBADDRWIDTH HDL_PARAMETER true
add_parameter LPBDATAWIDTH INTEGER 32 ""
set_parameter_property LPBDATAWIDTH DEFAULT_VALUE 32
set_parameter_property LPBDATAWIDTH DISPLAY_NAME LPBDATAWIDTH
set_parameter_property LPBDATAWIDTH TYPE INTEGER
set_parameter_property LPBDATAWIDTH UNITS None
set_parameter_property LPBDATAWIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LPBDATAWIDTH DESCRIPTION ""
set_parameter_property LPBDATAWIDTH HDL_PARAMETER true
add_parameter LPBTSIZEWIDTH INTEGER 3 ""
set_parameter_property LPBTSIZEWIDTH DEFAULT_VALUE 3
set_parameter_property LPBTSIZEWIDTH DISPLAY_NAME LPBTSIZEWIDTH
set_parameter_property LPBTSIZEWIDTH TYPE INTEGER
set_parameter_property LPBTSIZEWIDTH UNITS None
set_parameter_property LPBTSIZEWIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LPBTSIZEWIDTH DESCRIPTION ""
set_parameter_property LPBTSIZEWIDTH HDL_PARAMETER true
add_parameter LPBCSWIDTH INTEGER 1 ""
set_parameter_property LPBCSWIDTH DEFAULT_VALUE 1
set_parameter_property LPBCSWIDTH DISPLAY_NAME LPBCSWIDTH
set_parameter_property LPBCSWIDTH TYPE INTEGER
set_parameter_property LPBCSWIDTH UNITS None
set_parameter_property LPBCSWIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LPBCSWIDTH DESCRIPTION ""
set_parameter_property LPBCSWIDTH HDL_PARAMETER true
add_parameter LPBBANKWIDTH INTEGER 2 ""
set_parameter_property LPBBANKWIDTH DEFAULT_VALUE 2
set_parameter_property LPBBANKWIDTH DISPLAY_NAME LPBBANKWIDTH
set_parameter_property LPBBANKWIDTH TYPE INTEGER
set_parameter_property LPBBANKWIDTH UNITS None
set_parameter_property LPBBANKWIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property LPBBANKWIDTH DESCRIPTION ""
set_parameter_property LPBBANKWIDTH HDL_PARAMETER true


# 
# display items
# 


# 
# connection point global
# 
add_interface global conduit end
set_interface_property global associatedClock clock
set_interface_property global associatedReset reset
set_interface_property global ENABLED true
set_interface_property global EXPORT_OF ""
set_interface_property global PORT_NAME_MAP ""
set_interface_property global SVD_ADDRESS_GROUP ""

add_interface_port global lpb_ad export Bidir lpbdatawidth
add_interface_port global lpb_cs_n export Input lpbcswidth
add_interface_port global lpb_oe_n export Input 1
add_interface_port global lpb_ack_n export Output 1
add_interface_port global lpb_ale_n export Input 1
add_interface_port global lpb_rdwr_n export Input 1
add_interface_port global lpb_ts_n export Input 1
add_interface_port global lpb_int export Output 1


# 
# connection point avalon_master_0
# 
add_interface avalon_master_0 avalon start
set_interface_property avalon_master_0 addressUnits SYMBOLS
set_interface_property avalon_master_0 associatedClock clock
set_interface_property avalon_master_0 associatedReset reset
set_interface_property avalon_master_0 bitsPerSymbol 8
set_interface_property avalon_master_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_master_0 burstcountUnits WORDS
set_interface_property avalon_master_0 doStreamReads false
set_interface_property avalon_master_0 doStreamWrites false
set_interface_property avalon_master_0 holdTime 0
set_interface_property avalon_master_0 linewrapBursts false
set_interface_property avalon_master_0 maximumPendingReadTransactions 0
set_interface_property avalon_master_0 readLatency 0
set_interface_property avalon_master_0 readWaitTime 1
set_interface_property avalon_master_0 setupTime 0
set_interface_property avalon_master_0 timingUnits Cycles
set_interface_property avalon_master_0 writeWaitTime 0
set_interface_property avalon_master_0 ENABLED true
set_interface_property avalon_master_0 EXPORT_OF ""
set_interface_property avalon_master_0 PORT_NAME_MAP ""
set_interface_property avalon_master_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_master_0 address address Output 32
add_interface_port avalon_master_0 read read Output 1
add_interface_port avalon_master_0 readdata readdata Input 32
add_interface_port avalon_master_0 write write Output 1
add_interface_port avalon_master_0 writedata writedata Output 32
add_interface_port avalon_master_0 byteenable byteenable Output 4
add_interface_port avalon_master_0 waitrequest waitrequest Input 1


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1
