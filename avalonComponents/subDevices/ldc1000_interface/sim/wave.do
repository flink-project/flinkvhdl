onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ldc1000_interface_tb/sl_clk
add wave -noupdate /ldc1000_interface_tb/sl_reset_n
add wave -noupdate /ldc1000_interface_tb/slv_avs_address
add wave -noupdate /ldc1000_interface_tb/sl_avs_read
add wave -noupdate /ldc1000_interface_tb/sl_avs_write
add wave -noupdate /ldc1000_interface_tb/slv_avs_write_data
add wave -noupdate /ldc1000_interface_tb/slv_avs_read_data
add wave -noupdate /ldc1000_interface_tb/slv_avs_byteenable
add wave -noupdate /ldc1000_interface_tb/sl_sclk
add wave -noupdate /ldc1000_interface_tb/oslv_csb
add wave -noupdate /ldc1000_interface_tb/isl_sdo
add wave -noupdate /ldc1000_interface_tb/osl_sdi
add wave -noupdate /ldc1000_interface_tb/osl_tbclk
add wave -noupdate /ldc1000_interface_tb/main_period
add wave -noupdate /ldc1000_interface_tb/unique_id
add wave -noupdate -divider UUT
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/SCLK_FREQUENCY
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/UNIQUE_ID
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/isl_clk
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/islv_avs_address
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/isl_avs_read
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/isl_avs_write
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/islv_avs_write_data
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/islv_avs_byteenable
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/oslv_avs_read_data
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/osl_avs_waitrequest
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/osl_sclk
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/oslv_csb
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/isl_sdo
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/osl_sdi
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/osl_tbclk
add wave -noupdate -expand -subitemconfig {/ldc1000_interface_tb/my_unit_under_test/ri.config_reg -expand} /ldc1000_interface_tb/my_unit_under_test/ri
add wave -noupdate -expand /ldc1000_interface_tb/my_unit_under_test/out_config
add wave -noupdate -divider ldc1000
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/BASE_CLK
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/SCLK_FREQUENCY
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/isl_clk
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/isl_reset_n
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/osl_sclk
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/oslv_csb
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/isl_sdo
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/osl_sdi
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/osl_tbclk
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/it_config
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/ot_config
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/slv_rx_data
add wave -noupdate /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/sl_rx_done
add wave -noupdate -expand /ldc1000_interface_tb/my_unit_under_test/my_ldc1000/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26240112 ps} 0}
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
WaveRestoreZoom {0 ps} {84606900 ps}
