onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/SCLK_FREQUENCY
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/ot_values
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/osl_sclk
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/oslv_Ss
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/osl_mosi
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/isl_miso
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/slv_rx_data
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/sl_rx_done
add wave -noupdate -expand /adc128s102_rtl_tb/my_unit_under_test/ri
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/SS_HOLD_FREQUENCY
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/SS_HOLD_CYCLES
add wave -noupdate /adc128s102_rtl_tb/my_unit_under_test/TRANSFER_WIDTH
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
configure wave -timelineunits ns
update
WaveRestoreZoom {24015052 ps} {24016050 ps}
