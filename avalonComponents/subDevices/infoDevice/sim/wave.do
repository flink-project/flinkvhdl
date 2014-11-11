onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /info_device_tb/my_unit_under_test/unice_id
add wave -noupdate -radix ascii /info_device_tb/my_unit_under_test/description
add wave -noupdate /info_device_tb/my_unit_under_test/dev_size
add wave -noupdate /info_device_tb/my_unit_under_test/isl_clk
add wave -noupdate /info_device_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /info_device_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /info_device_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /info_device_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /info_device_tb/my_unit_under_test/osl_avs_waitrequest
add wave -noupdate /info_device_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate -radix hexadecimal /info_device_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /info_device_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {995760 ps} 0}
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
WaveRestoreZoom {1235426 ps} {1358136 ps}
