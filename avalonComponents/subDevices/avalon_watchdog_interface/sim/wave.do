onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/number_of_watchdogs
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/base_clk
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/isl_clk
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/isl_reset_n
add wave -noupdate -radix unsigned /avalon_watchdog_interface_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/islv_signals_to_check
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/osl_granted
add wave -noupdate -expand -subitemconfig {/avalon_watchdog_interface_tb/my_unit_under_test/ri.counter_regs {-radix unsigned}} /avalon_watchdog_interface_tb/my_unit_under_test/ri
add wave -noupdate /avalon_watchdog_interface_tb/my_unit_under_test/ri_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1000 ps} 0}
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
WaveRestoreZoom {1691050 ps} {1692050 ps}
