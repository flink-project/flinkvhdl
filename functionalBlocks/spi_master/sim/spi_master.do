transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {../src/spi_master.m.vhd}
vcom -93 -work work {../sim/spi_master_rtl_tb.vhd}

vsim -t 1ps -L rtl_work -L work -voptargs="+acc" spi_master_rtl_tb

if {[file exists wave.do]} {
	do wave.do 
}

view structure
view signals
run 150 ms
