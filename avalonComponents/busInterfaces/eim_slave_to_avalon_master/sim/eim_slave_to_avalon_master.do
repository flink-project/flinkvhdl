transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -93 -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -93 -work work {../../../../functionalBlocks/eim_slave/src/eim_slave.m.vhd}
vcom -93 -work work {../src/eim_slave_to_avalon_master.m.vhd}
vcom -93 -work work {../sim/eim_slave_to_avalon_master_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" eim_slave_to_avalon_master_tb

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
