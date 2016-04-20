transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -93 -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -93 -work work {../../../../functionalBlocks/adjustable_pwm/src/adjustable_pwm.m.vhd}
vcom -2008  -quiet -work work {../../axiSlave/src/axi_slave.m.vhd}
vcom -93 -work work {../src/pwm_device.m.vhd}
vcom -93 -work work {../sim/pwm_device_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" pwm_device_tb 

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
