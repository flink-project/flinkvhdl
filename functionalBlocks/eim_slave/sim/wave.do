onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eim_slave_rtl_tb/sl_clk
add wave -noupdate /eim_slave_rtl_tb/sl_reset_n
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/slv_address
add wave -noupdate /eim_slave_rtl_tb/sl_cs_n
add wave -noupdate /eim_slave_rtl_tb/sl_we_n
add wave -noupdate /eim_slave_rtl_tb/sl_oe_n
add wave -noupdate /eim_slave_rtl_tb/slv_be_n
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/slv_data
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/slv_address_out
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/slv_read_data
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/slv_write_data
add wave -noupdate /eim_slave_rtl_tb/sl_read_not_write
add wave -noupdate /eim_slave_rtl_tb/sl_got_write_data
add wave -noupdate /eim_slave_rtl_tb/sl_got_address
add wave -noupdate /eim_slave_rtl_tb/sl_read_data_valid
add wave -noupdate /eim_slave_rtl_tb/main_period
add wave -noupdate /eim_slave_rtl_tb/transf_wdt
add wave -noupdate /eim_slave_rtl_tb/sl_data_ack
add wave -noupdate -divider UUT
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate -radix hexadecimal /eim_slave_rtl_tb/my_unit_under_test/islv_address
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/isl_cs_n
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/isl_we_n
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/isl_oe_n
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/islv_be_n
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/islv_read_data
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/oslv_write_data
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/osl_read_not_write
add wave -noupdate /eim_slave_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2084786 ps} 0}
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
WaveRestoreZoom {1728884 ps} {2461420 ps}
