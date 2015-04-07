onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mpu9250_interface_tb/sl_clk
add wave -noupdate /mpu9250_interface_tb/sl_reset_n
add wave -noupdate /mpu9250_interface_tb/slv_avs_address
add wave -noupdate /mpu9250_interface_tb/sl_avs_read
add wave -noupdate /mpu9250_interface_tb/sl_avs_write
add wave -noupdate /mpu9250_interface_tb/slv_avs_write_data
add wave -noupdate /mpu9250_interface_tb/slv_avs_read_data
add wave -noupdate /mpu9250_interface_tb/slv_avs_byteenable
add wave -noupdate /mpu9250_interface_tb/sl_sclk
add wave -noupdate /mpu9250_interface_tb/slv_cs_n
add wave -noupdate /mpu9250_interface_tb/isl_sdo
add wave -noupdate /mpu9250_interface_tb/osl_sdi
add wave -noupdate /mpu9250_interface_tb/main_period
add wave -noupdate /mpu9250_interface_tb/unique_id
add wave -noupdate -divider UUT
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/isl_clk
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/isl_reset_n
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/osl_sclk
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/oslv_cs_n
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/isl_sdo
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/osl_sdi
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/ot_data
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/it_conf
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/ot_conf
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/osl_configuring
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/isl_update_config
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/sl_update_done
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/slv_rx_data
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/sl_rx_done
add wave -noupdate -expand /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/ri
add wave -noupdate /mpu9250_interface_tb/my_unit_under_test/my_mpu9250/ri_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24344438 ps} 0}
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
WaveRestoreZoom {0 ps} {84606900 ps}
