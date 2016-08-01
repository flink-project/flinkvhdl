onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /itg3200_rtl_tb/sl_clk
add wave -noupdate /itg3200_rtl_tb/sl_reset_n
add wave -noupdate /itg3200_rtl_tb/scl
add wave -noupdate /itg3200_rtl_tb/sda
add wave -noupdate /itg3200_rtl_tb/data
add wave -noupdate /itg3200_rtl_tb/main_period
add wave -noupdate /itg3200_rtl_tb/spi_period
add wave -noupdate -divider UUT
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/osl_scl
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/oisl_sda
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/ot_data
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/ri
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/ri_next
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/read_data
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/transfer_done
add wave -noupdate /itg3200_rtl_tb/my_unit_under_test/INTERNAL_REG_RESET
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2000302314 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {2000302050 ps} {2000303050 ps}
