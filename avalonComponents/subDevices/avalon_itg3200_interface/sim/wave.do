onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/UNIQUE_ID
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/isl_clk
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/islv_avs_byteenable
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/osl_avs_waitrequest
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/osl_scl
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/oisl_sda
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/ri
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/ri_next
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/itg3200_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/c_usig_data_0_address
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/c_usig_last_address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
configure wave -timelineunits ps
update
WaveRestoreZoom {81155050 ps} {81156050 ps}
