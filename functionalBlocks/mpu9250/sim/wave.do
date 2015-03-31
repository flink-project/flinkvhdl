onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mpu9250_rtl_tb/sl_clk
add wave -noupdate /mpu9250_rtl_tb/sl_reset_n
add wave -noupdate /mpu9250_rtl_tb/sl_sclk
add wave -noupdate /mpu9250_rtl_tb/slv_cs_n
add wave -noupdate /mpu9250_rtl_tb/sl_sdo
add wave -noupdate /mpu9250_rtl_tb/sl_sdi
add wave -noupdate -childformat {{/mpu9250_rtl_tb/data.acceleration_x -radix hexadecimal} {/mpu9250_rtl_tb/data.acceleration_y -radix hexadecimal} {/mpu9250_rtl_tb/data.acceleration_z -radix hexadecimal} {/mpu9250_rtl_tb/data.gyro_data_x -radix hexadecimal} {/mpu9250_rtl_tb/data.gyro_data_y -radix hexadecimal} {/mpu9250_rtl_tb/data.gyro_data_z -radix hexadecimal} {/mpu9250_rtl_tb/data.mag_data_x -radix hexadecimal} {/mpu9250_rtl_tb/data.mag_data_y -radix hexadecimal} {/mpu9250_rtl_tb/data.mag_data_z -radix hexadecimal}} -expand -subitemconfig {/mpu9250_rtl_tb/data.acceleration_x {-radix hexadecimal} /mpu9250_rtl_tb/data.acceleration_y {-radix hexadecimal} /mpu9250_rtl_tb/data.acceleration_z {-radix hexadecimal} /mpu9250_rtl_tb/data.gyro_data_x {-radix hexadecimal} /mpu9250_rtl_tb/data.gyro_data_y {-radix hexadecimal} /mpu9250_rtl_tb/data.gyro_data_z {-radix hexadecimal} /mpu9250_rtl_tb/data.mag_data_x {-radix hexadecimal} /mpu9250_rtl_tb/data.mag_data_y {-radix hexadecimal} /mpu9250_rtl_tb/data.mag_data_z {-radix hexadecimal}} /mpu9250_rtl_tb/data
add wave -noupdate -divider UUT
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/SCLK_FREQUENCY
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/osl_sclk
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/oslv_cs_n
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/isl_sdo
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/osl_sdi
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/ot_data
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/slv_rx_data
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/sl_rx_done
add wave -noupdate /mpu9250_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000059819 ps} 0}
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
WaveRestoreZoom {2000059650 ps} {2000060650 ps}
