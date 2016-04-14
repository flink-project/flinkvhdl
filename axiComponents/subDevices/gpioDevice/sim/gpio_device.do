transcript quietly
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -2008  -quiet -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -2008  -quiet -work work {../../axiSlave/src/axi_slave.m.vhd}
vcom -2008  -quiet -work work {../src/gpio_device.m.vhd}
vcom -2008  -quiet -work work {../sim/gpio_device_tb.vhd}

vsim -quiet -t 1ps -L rtl_work -L work  gpio_device_tb 

if {[file exists wave.do]} {
	do wave.do 
}



run 150 ms