transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -93 -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -93 -work work {../../../../functionalBlocks/spi_master/src/spi_master.m.vhd}
vcom -93 -work work {../../../../functionalBlocks/dacad5668/src/dacad5668.m.vhd}
vcom -93 -work work {../src/avalon_dacad5668_interface.m.vhd}
vcom -93 -work work {../sim/avalon_dacad5668_interface_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" avalon_dacad5668_interface_tb 

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
