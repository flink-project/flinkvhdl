onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dacad5668_rtl_tb/sl_clk
add wave -noupdate /dacad5668_rtl_tb/sl_reset_n
add wave -noupdate /dacad5668_rtl_tb/values
add wave -noupdate /dacad5668_rtl_tb/sl_sclk
add wave -noupdate /dacad5668_rtl_tb/slv_Ss
add wave -noupdate /dacad5668_rtl_tb/sl_mosi
add wave -noupdate /dacad5668_rtl_tb/sl_miso
add wave -noupdate /dacad5668_rtl_tb/main_period
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/osl_LDAC_n
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/osl_CLR_n
add wave -noupdate -expand /dacad5668_rtl_tb/my_unit_under_test/ri
add wave -noupdate -divider spi
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/isl_clk
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/isl_reset_n
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/islv_tx_data
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/isl_tx_start
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/oslv_rx_data
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/osl_rx_done
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/islv_ss_activ
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/osl_sclk
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/oslv_Ss
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/osl_mosi
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/isl_miso
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/ri
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/my_spi_master/ri_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1529453 ps} 0}
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
WaveRestoreZoom {0 ps} {25216800 ps}
