onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/SCLK_FREQUENCY
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/isl_clk
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/osl_sclk
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/oslv_Ss
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/osl_mosi
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/isl_miso
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/ri
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/adc_values
add wave -noupdate -divider {SPI MASTER}
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/isl_clk
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/isl_reset_n
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/islv_tx_data
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/isl_tx_start
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/oslv_rx_data
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/osl_rx_done
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/islv_ss_activ
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/osl_sclk
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/oslv_Ss
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/osl_mosi
add wave -noupdate /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/isl_miso
add wave -noupdate -expand /avalon_adc128s102_interface_tb/my_unit_under_test/my_adc128S102/my_spi_master/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27207 ps} 0}
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
WaveRestoreZoom {0 ps} {29400 ps}
