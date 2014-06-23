onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Signals
add wave -noupdate /fqd_rtl_tb/sl_clk
add wave -noupdate /fqd_rtl_tb/sl_reset_n
add wave -noupdate /fqd_rtl_tb/sl_enc_A
add wave -noupdate /fqd_rtl_tb/sl_enc_B
add wave -noupdate -format Analog-Step -height 84 -max 327.0 -radix unsigned /fqd_rtl_tb/usig_pos
add wave -noupdate -divider {Simulation Parameters}
add wave -noupdate /fqd_rtl_tb/main_period
add wave -noupdate /fqd_rtl_tb/velocity
add wave -noupdate /fqd_rtl_tb/direction
add wave -noupdate /fqd_rtl_tb/enc_tick_per_turn
add wave -noupdate /fqd_rtl_tb/wait_time
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {284000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {8416800 ps}
