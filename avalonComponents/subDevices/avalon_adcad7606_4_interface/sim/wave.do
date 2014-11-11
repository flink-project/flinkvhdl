onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_clk
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_reset_n
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_avs_address
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_avs_read
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_avs_write
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_avs_write_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_avs_read_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_sclk
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_Ss
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_mosi
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_miso
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_d_out_b
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_conv_start
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_range
add wave -noupdate /avalon_adcad7606_4_interface_tb/slv_os
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_busy
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_first_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_adc_reset
add wave -noupdate /avalon_adcad7606_4_interface_tb/sl_stby_n
add wave -noupdate /avalon_adcad7606_4_interface_tb/main_period
add wave -noupdate -divider {unit under test}
add wave -noupdate -expand -subitemconfig {/avalon_adcad7606_4_interface_tb/my_unit_under_test/ri.config -expand} /avalon_adcad7606_4_interface_tb/my_unit_under_test/ri
add wave -noupdate -divider adc
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/BASE_CLK
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/SCLK_FREQUENCY
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_clk
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_reset_n
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/ot_values
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/config
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/osl_sclk
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/oslv_Ss
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/osl_mosi
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_miso
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_d_out_b
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/oslv_conv_start
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/osl_range
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/oslv_os
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_busy
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/isl_first_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/osl_adc_reset
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/osl_stby_n
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/slv_rx_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/sl_rx_done
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/ri
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/ri_next
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/SS_HOLD_CYCLES
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/TRANSFER_WIDTH
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/CHANEL_COUNT_WIDTH
add wave -noupdate -divider spi
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/BASE_CLK
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/SCLK_FREQUENCY
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/CS_SETUP_CYLES
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/TRANSFER_WIDTH
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/NR_OF_SS
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/CPOL
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/CPHA
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/MSBFIRST
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/SSPOL
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/isl_clk
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/isl_reset_n
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/islv_tx_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/isl_tx_start
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/oslv_rx_data
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/osl_rx_done
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/islv_ss_activ
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/osl_sclk
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/oslv_Ss
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/osl_mosi
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/isl_miso
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/ri
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/ri_next
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/NR_OF_TICKS_PER_SCLK_EDGE
add wave -noupdate /avalon_adcad7606_4_interface_tb/my_unit_under_test/my_adcad7606_4/my_spi_master/CYCLE_COUNTHER_WIDTH
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20577697 ps} 0}
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
WaveRestoreZoom {0 ps} {85121400 ps}
