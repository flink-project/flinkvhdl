transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -93 -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -93 -work work {../../../../functionalBlocks/i2c_master/src/i2c_master.m.vhd}
vcom -93 -work work {../../../../functionalBlocks/itg3200/src/itg3200.m.vhd}
vcom -93 -work work {../src/avalon_itg3200_interface.m.vhd}
vcom -93 -work work {../sim/avalon_itg3200_interface_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" avalon_itg3200_interface_tb 

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
