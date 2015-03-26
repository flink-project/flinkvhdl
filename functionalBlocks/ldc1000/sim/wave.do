onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ldc1000_rtl_tb/sl_clk
add wave -noupdate /ldc1000_rtl_tb/sl_reset_n
add wave -noupdate /ldc1000_rtl_tb/sl_sclk
add wave -noupdate /ldc1000_rtl_tb/slv_csb
add wave -noupdate /ldc1000_rtl_tb/sl_sdo
add wave -noupdate /ldc1000_rtl_tb/sl_sdi
add wave -noupdate /ldc1000_rtl_tb/sl_tbclk
add wave -noupdate -radix hexadecimal -childformat {{/ldc1000_rtl_tb/in_config.device_id -radix hexadecimal} {/ldc1000_rtl_tb/in_config.rp_max -radix hexadecimal} {/ldc1000_rtl_tb/in_config.rp_min -radix hexadecimal} {/ldc1000_rtl_tb/in_config.min_sens_freq -radix hexadecimal} {/ldc1000_rtl_tb/in_config.threshold_high_msb -radix hexadecimal} {/ldc1000_rtl_tb/in_config.threshold_low_msb -radix hexadecimal} {/ldc1000_rtl_tb/in_config.amplitude -radix hexadecimal} {/ldc1000_rtl_tb/in_config.response_time -radix hexadecimal} {/ldc1000_rtl_tb/in_config.intb_mode -radix hexadecimal} {/ldc1000_rtl_tb/in_config.pwr_mode -radix hexadecimal}} -expand -subitemconfig {/ldc1000_rtl_tb/in_config.device_id {-radix hexadecimal} /ldc1000_rtl_tb/in_config.rp_max {-radix hexadecimal} /ldc1000_rtl_tb/in_config.rp_min {-radix hexadecimal} /ldc1000_rtl_tb/in_config.min_sens_freq {-radix hexadecimal} /ldc1000_rtl_tb/in_config.threshold_high_msb {-radix hexadecimal} /ldc1000_rtl_tb/in_config.threshold_low_msb {-radix hexadecimal} /ldc1000_rtl_tb/in_config.amplitude {-radix hexadecimal} /ldc1000_rtl_tb/in_config.response_time {-radix hexadecimal} /ldc1000_rtl_tb/in_config.intb_mode {-radix hexadecimal} /ldc1000_rtl_tb/in_config.pwr_mode {-radix hexadecimal}} /ldc1000_rtl_tb/in_config
add wave -noupdate -radix hexadecimal -childformat {{/ldc1000_rtl_tb/out_config.device_id -radix hexadecimal} {/ldc1000_rtl_tb/out_config.rp_max -radix hexadecimal} {/ldc1000_rtl_tb/out_config.rp_min -radix hexadecimal} {/ldc1000_rtl_tb/out_config.min_sens_freq -radix hexadecimal} {/ldc1000_rtl_tb/out_config.threshold_high_msb -radix hexadecimal} {/ldc1000_rtl_tb/out_config.threshold_low_msb -radix hexadecimal} {/ldc1000_rtl_tb/out_config.amplitude -radix hexadecimal} {/ldc1000_rtl_tb/out_config.response_time -radix hexadecimal} {/ldc1000_rtl_tb/out_config.intb_mode -radix hexadecimal} {/ldc1000_rtl_tb/out_config.pwr_mode -radix hexadecimal}} -expand -subitemconfig {/ldc1000_rtl_tb/out_config.device_id {-radix hexadecimal} /ldc1000_rtl_tb/out_config.rp_max {-radix hexadecimal} /ldc1000_rtl_tb/out_config.rp_min {-radix hexadecimal} /ldc1000_rtl_tb/out_config.min_sens_freq {-radix hexadecimal} /ldc1000_rtl_tb/out_config.threshold_high_msb {-radix hexadecimal} /ldc1000_rtl_tb/out_config.threshold_low_msb {-radix hexadecimal} /ldc1000_rtl_tb/out_config.amplitude {-radix hexadecimal} /ldc1000_rtl_tb/out_config.response_time {-radix hexadecimal} /ldc1000_rtl_tb/out_config.intb_mode {-radix hexadecimal} /ldc1000_rtl_tb/out_config.pwr_mode {-radix hexadecimal}} /ldc1000_rtl_tb/out_config
add wave -noupdate /ldc1000_rtl_tb/data
add wave -noupdate /ldc1000_rtl_tb/sl_update_config
add wave -noupdate /ldc1000_rtl_tb/main_period
add wave -noupdate /ldc1000_rtl_tb/spi_period
add wave -noupdate /ldc1000_rtl_tb/configuring
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
add wave -noupdate -radix hexadecimal -childformat {{/ldc1000_rtl_tb/my_unit_under_test/it_config.device_id -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.rp_max -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.rp_min -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.min_sens_freq -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.threshold_high_msb -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.threshold_low_msb -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.amplitude -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.response_time -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.intb_mode -radix hexadecimal} {/ldc1000_rtl_tb/my_unit_under_test/it_config.pwr_mode -radix hexadecimal}} -expand -subitemconfig {/ldc1000_rtl_tb/my_unit_under_test/it_config.device_id {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.rp_max {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.rp_min {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.min_sens_freq {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.threshold_high_msb {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.threshold_low_msb {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.amplitude {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.response_time {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.intb_mode {-radix hexadecimal} /ldc1000_rtl_tb/my_unit_under_test/it_config.pwr_mode {-radix hexadecimal}} /ldc1000_rtl_tb/my_unit_under_test/it_config
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/ot_config
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/ot_data
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/osl_configuring
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/isl_update_config
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/slv_rx_data
add wave -noupdate /ldc1000_rtl_tb/my_unit_under_test/sl_rx_done
add wave -noupdate -expand /ldc1000_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {90231820 ps} 0}
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
WaveRestoreZoom {0 ps} {172170600 ps}
