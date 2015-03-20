onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_clk
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_reset_n
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_address
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_data
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_cs_n
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_we_n
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_oe_n
add wave -noupdate /eim_slave_to_avalon_master_tb/sl_data_ack
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_avalon_address
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_read
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_write
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_readdata
add wave -noupdate -radix hexadecimal /eim_slave_to_avalon_master_tb/slv_writedata
add wave -noupdate /eim_slave_to_avalon_master_tb/slv_waitrequest
add wave -noupdate /eim_slave_to_avalon_master_tb/main_period
add wave -noupdate /eim_slave_to_avalon_master_tb/BUS_WIDTH
add wave -noupdate -divider UUT
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/isl_clk
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/islv_address
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/ioslv_data
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/isl_cs_n
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/isl_we_n
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/isl_oe_n
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/osl_data_ack
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/oslv_address
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/oslv_read
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/islv_readdata
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/oslv_write
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/oslv_writedata
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/islv_waitrequest
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/ri
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/ri_next
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/slv_address_out
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/sl_read_not_write
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/sl_got_address
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/slv_write_data
add wave -noupdate /eim_slave_to_avalon_master_tb/my_unit_under_test/sl_got_write_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10995011 ps} 0}
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
WaveRestoreZoom {0 ps} {21094500 ps}
