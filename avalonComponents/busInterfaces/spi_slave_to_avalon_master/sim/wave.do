onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/TRANSFER_WIDTH
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/CPOL
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/CPHA
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/SSPOL
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/isl_clk
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/isl_sclk
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/isl_ss
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/isl_mosi
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/osl_miso
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/oslv_address
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/oslv_read
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/islv_readdata
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/oslv_write
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/oslv_writedata
add wave -noupdate -expand /spi_slave_to_avalon_master_tb/my_unit_under_test/ri
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/spi_rx_data
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/spi_rx_trig
add wave -noupdate -divider spi_slave
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/isl_clk
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/isl_reset_n
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/islv_tx_data
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/oslv_rx_data
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/osl_rx_trig
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/isl_sclk
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/isl_ss
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/isl_mosi
add wave -noupdate /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/osl_miso
add wave -noupdate -expand /spi_slave_to_avalon_master_tb/my_unit_under_test/my_spi/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2372600 ps} 0}
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
WaveRestoreZoom {0 ps} {19874400 ps}
