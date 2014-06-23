onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/number_of_ppwes
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/base_clk
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/isl_clk
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/islv_signals_to_measure
add wave -noupdate /avalon_ppwe_interface_tb/my_unit_under_test/ri
add wave -noupdate -radix unsigned /avalon_ppwe_interface_tb/my_unit_under_test/usig_period_count_regs
add wave -noupdate -radix unsigned /avalon_ppwe_interface_tb/my_unit_under_test/usig_hightime_count_regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44654498 ps} 0}
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
WaveRestoreZoom {0 ps} {102795 ns}
