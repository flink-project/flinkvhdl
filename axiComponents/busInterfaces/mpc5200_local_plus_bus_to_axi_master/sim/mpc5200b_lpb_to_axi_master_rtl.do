transcript quietly
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vcom -2008  -quiet -work work {../../../../fLink/core/flink_definitions.vhd}
vcom -2008  -quiet -work work {../src/mpc5200b_lpb_to_axi_master.vhd}
vcom -2008  -quiet -work work {../sim/mpc5200b_lpb_to_axi_master_tb.vhd}

vsim -quiet -t 1ps -L rtl_work -L work  mpc5200b_lpb_to_axi_master_tb 

if {[file exists wave.do]} {
	do wave.do 
}



run 150 ms