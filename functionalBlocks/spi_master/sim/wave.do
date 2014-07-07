onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_master_rtl_tb/sl_clk
add wave -noupdate /spi_master_rtl_tb/sl_reset_n
add wave -noupdate /spi_master_rtl_tb/slv_tx_data
add wave -noupdate /spi_master_rtl_tb/sl_tx_start
add wave -noupdate /spi_master_rtl_tb/slv_rx_data
add wave -noupdate /spi_master_rtl_tb/sl_rx_start
add wave -noupdate /spi_master_rtl_tb/slv_ss_activ
add wave -noupdate /spi_master_rtl_tb/sl_sclk
add wave -noupdate /spi_master_rtl_tb/slv_Ss
add wave -noupdate /spi_master_rtl_tb/sl_mosi
add wave -noupdate /spi_master_rtl_tb/sl_miso
add wave -noupdate -expand /spi_master_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1686558 ps} 0}
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
WaveRestoreZoom {0 ps} {17656800 ps}
