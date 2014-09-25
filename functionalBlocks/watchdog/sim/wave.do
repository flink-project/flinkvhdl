onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /watchdog_rtl_tb/sl_clk
add wave -noupdate /watchdog_rtl_tb/sl_reset_n
add wave -noupdate -radix unsigned /watchdog_rtl_tb/usig_counter_set
add wave -noupdate /watchdog_rtl_tb/sl_rearm_counter
add wave -noupdate /watchdog_rtl_tb/sl_rearm
add wave -noupdate -radix unsigned /watchdog_rtl_tb/sl_counter_val
add wave -noupdate /watchdog_rtl_tb/sl_granted
add wave -noupdate /watchdog_rtl_tb/main_period
add wave -noupdate /watchdog_rtl_tb/resolution
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/ri.watchdog_fired
add wave -noupdate -radix unsigned /watchdog_rtl_tb/my_unit_under_test/ri.counter
add wave -noupdate -divider inside
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/gi_counter_resolution
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate -radix unsigned /watchdog_rtl_tb/my_unit_under_test/iusig_counter_set
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_rearm_counter
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/isl_rearm
add wave -noupdate -radix unsigned /watchdog_rtl_tb/my_unit_under_test/osl_counter_val
add wave -noupdate /watchdog_rtl_tb/my_unit_under_test/osl_granted
add wave -noupdate -childformat {{/watchdog_rtl_tb/my_unit_under_test/ri.counter -radix unsigned}} -expand -subitemconfig {/watchdog_rtl_tb/my_unit_under_test/ri.counter {-radix unsigned}} /watchdog_rtl_tb/my_unit_under_test/ri
add wave -noupdate -expand /watchdog_rtl_tb/my_unit_under_test/ri_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1920000 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {1621271 ps} {2418167 ps}
