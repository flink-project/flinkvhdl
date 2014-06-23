onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ppwe_rtl_tb/sl_clk
add wave -noupdate /ppwe_rtl_tb/sl_reset_n
add wave -noupdate /ppwe_rtl_tb/sl_measure_signal
add wave -noupdate -radix unsigned /ppwe_rtl_tb/usig_period_count
add wave -noupdate -radix unsigned /ppwe_rtl_tb/usig_hightime_count
add wave -noupdate -expand -subitemconfig {/ppwe_rtl_tb/my_unit_under_test/ri.usig_counter {-radix unsigned}} /ppwe_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {400000 ps} 0}
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
