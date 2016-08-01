transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {../../i2c_master/src/i2c_master.m.vhd}
vcom -93 -work work {../src/itg3200.m.vhd}
vcom -93 -work work {../sim/itg3200_rtl_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" itg3200_rtl_tb

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
