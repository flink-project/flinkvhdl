transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -93 -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -93 -work work {../../../../functionalBlocks/spi_master/src/spi_master.m.vhd}
vcom -93 -work work {../../../../functionalBlocks/adjustable_pwm/src/adjustable_pwm.m.vhd}
vcom -93 -work work {../../../../functionalBlocks/ldc1000/src/ldc1000.m.vhd}
	
vcom -93 -work work {../src/ldc1000_interface.m.vhd}
vcom -93 -work work {../sim/ldc1000_interface_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" ldc1000_interface_tb 

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
