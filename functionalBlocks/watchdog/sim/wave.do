onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/gi_counter_resolution
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_signal_to_check
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_clk_pol
add wave -noupdate -radix unsigned /watchdog_rtl_tb/my_unit_under_test/iusig_counter_set
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/osl_granted
add wave -noupdate -expand -subitemconfig {/watchdog_rtl_tb/my_unit_under_test/ri.counter {-radix unsigned}} /watchdog_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8828000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 107
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
WaveRestoreZoom {0 ps} {9197229 ps}
