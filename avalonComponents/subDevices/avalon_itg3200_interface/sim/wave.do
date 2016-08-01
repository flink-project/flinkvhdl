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
add wave -noupdate -expand /avalon_itg3200_interface_tb/my_unit_under_test/ri
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/ri_next
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/itg3200_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/c_usig_data_0_address
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/c_usig_last_address
add wave -noupdate -divider itg3200
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/isl_clk
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/isl_reset_n
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/osl_scl
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/oisl_sda
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/ot_data
add wave -noupdate -expand /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/ri
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/ri_next
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/read_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/transfer_done
add wave -noupdate -divider i2c
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/BASE_CLK
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/isl_clk
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/isl_reset_n
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/osl_scl
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/oisl_sda
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/islv_dev_address
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/islv_register_address
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/islv_write_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/oslv_read_data
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/isl_start_transfer
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/isl_write_n_read
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/isl_enable_burst_transfer
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/osl_transfer_done
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/ri
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/ri_next
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/I2C_PERIOD_COUNT
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/I2C_HALF_PERIOD_COUNT
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/START_CONDITION_HOLD_CYCLES
add wave -noupdate /avalon_itg3200_interface_tb/my_unit_under_test/my_itg3200/my_i2c/INTERNAL_REG_RESET
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {223917388 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 141
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
WaveRestoreZoom {75413225 ps} {1681458251 ps}
