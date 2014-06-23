transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {../src/adjustable_pwm.m.vhd}
vcom -93 -work work {../sim/adjustable_pwm_rtl_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" adjustable_pwm_rtl_tb

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
