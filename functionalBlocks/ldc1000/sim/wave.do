onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ldc1000_rtl_tb/sl_clk
add wave -noupdate /ldc1000_rtl_tb/sl_reset_n
add wave -noupdate /ldc1000_rtl_tb/sl_sclk
add wave -noupdate /ldc1000_rtl_tb/slv_csb
add wave -noupdate /ldc1000_rtl_tb/sl_sdo
add wave -noupdate /ldc1000_rtl_tb/sl_sdi
add wave -noupdate /ldc1000_rtl_tb/sl_tbclk
add wave -noupdate /ldc1000_rtl_tb/main_period
add wave -noupdate -divider UUT
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/BASE_CLK
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/SCLK_FREQUENCY
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/isl_clk
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/isl_reset_n
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/osl_sclk
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/oslv_csb
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/isl_sdo
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/osl_sdi
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/osl_tbclk
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/slv_rx_data
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/sl_rx_done
add wave -noupdate -childformat {{/ldc1000_rtl_tb/my_unit_under_test/ri.in_config -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/ri.out_config -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/ri.config_read_address -radix unsigned}} -expand -subitemconfig {/ldc1000_rtl_tb/my_unit_under_test/ri.in_config {-height 15 -radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/ri.out_config {-height 15 -radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/ri.config_read_address {-height 15 -radix unsigned}} /ldc1000_rtl_tb/my_unit_under_test/ri
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/SS_HOLD_CYCLES
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/TRANSFER_WIDTH
add wave -noupdate /ldc1000_rtl_tb/sl_cache_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83987797 ps} 0}
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
WaveRestoreZoom {0 ps} {88208400 ps}
