onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adcad7606_4_rtl_tb/sl_clk
add wave -noupdate /adcad7606_4_rtl_tb/sl_reset_n
add wave -noupdate /adcad7606_4_rtl_tb/values
add wave -noupdate /adcad7606_4_rtl_tb/sl_sclk
add wave -noupdate /adcad7606_4_rtl_tb/slv_Ss
add wave -noupdate /adcad7606_4_rtl_tb/sl_mosi
add wave -noupdate /adcad7606_4_rtl_tb/sl_miso
add wave -noupdate /adcad7606_4_rtl_tb/sl_d_out_b
add wave -noupdate /adcad7606_4_rtl_tb/slv_conv_start
add wave -noupdate /adcad7606_4_rtl_tb/sl_range_select
add wave -noupdate /adcad7606_4_rtl_tb/sl_range
add wave -noupdate /adcad7606_4_rtl_tb/slv_oversampling_select
add wave -noupdate /adcad7606_4_rtl_tb/slv_os
add wave -noupdate /adcad7606_4_rtl_tb/sl_busy
add wave -noupdate /adcad7606_4_rtl_tb/sl_first_data
add wave -noupdate /adcad7606_4_rtl_tb/sl_stby_n
add wave -noupdate /adcad7606_4_rtl_tb/sl_adc_reset
add wave -noupdate /adcad7606_4_rtl_tb/main_period
add wave -noupdate -expand /adcad7606_4_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24015149 ps} 0}
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
WaveRestoreZoom {24015052 ps} {24016050 ps}
