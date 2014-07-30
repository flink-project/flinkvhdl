# TCL File Generated by Component Editor 13.0sp1
# Wed Jul 30 12:17:03 CEST 2014
# DO NOT MODIFY


# 
# watchdog_block "Watchdog" v0.1.1
# NTB (inf.ntb.ch) 2014.07.30.12:17:03
# Provides access to a watchdog block
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module watchdog_block
# 
set_module_property DESCRIPTION "Provides access to a watchdog block"
set_module_property NAME watchdog_block
set_module_property VERSION 0.1.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP fLink
set_module_property AUTHOR "NTB (inf.ntb.ch)"
set_module_property DISPLAY_NAME Watchdog
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avalon_watchdog_interface
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file avalon_watchdog_interface.m.vhd VHDL PATH avalon_watchdog_interface.m.vhd TOP_LEVEL_FILE
add_fileset_file watchdog.m.vhd VHDL PATH ../../../functionalBlocks/watchdog/src/watchdog.m.vhd
add_fileset_file flink_definitions.vhd VHDL PATH ../../../fLink/core/flink_definitions.vhd


# 
# parameters
# 
add_parameter number_of_watchdogs INTEGER 1
set_parameter_property number_of_watchdogs DEFAULT_VALUE 1
set_parameter_property number_of_watchdogs DISPLAY_NAME number_of_watchdogs
set_parameter_property number_of_watchdogs TYPE INTEGER
set_parameter_property number_of_watchdogs UNITS None
set_parameter_property number_of_watchdogs ALLOWED_RANGES -2147483648:2147483647
set_parameter_property number_of_watchdogs HDL_PARAMETER true
add_parameter base_clk INTEGER 125000000
set_parameter_property base_clk DEFAULT_VALUE 125000000
set_parameter_property base_clk DISPLAY_NAME base_clk
set_parameter_property base_clk TYPE INTEGER
set_parameter_property base_clk UNITS None
set_parameter_property base_clk ALLOWED_RANGES -2147483648:2147483647
set_parameter_property base_clk HDL_PARAMETER true


# 
# display items
# 


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock_sink
set_interface_property avalon_slave_0 associatedReset reset_sink
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitTime 1
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 islv_avs_write_data writedata Input 32
add_interface_port avalon_slave_0 oslv_avs_read_data readdata Output 32
add_interface_port avalon_slave_0 isl_avs_write write Input 1
add_interface_port avalon_slave_0 isl_avs_read read Input 1
add_interface_port avalon_slave_0 islv_avs_address address Input 5
add_interface_port avalon_slave_0 osl_avs_waitrequest waitrequest Output 1
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink isl_clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink isl_reset_n reset_n Input 1


# 
# connection point conduit_end
# 
add_interface conduit_end conduit end
set_interface_property conduit_end associatedClock ""
set_interface_property conduit_end associatedReset ""
set_interface_property conduit_end ENABLED true
set_interface_property conduit_end EXPORT_OF ""
set_interface_property conduit_end PORT_NAME_MAP ""
set_interface_property conduit_end SVD_ADDRESS_GROUP ""

add_interface_port conduit_end islv_signals_to_check export Input number_of_watchdogs
add_interface_port conduit_end osl_granted export Output 1

