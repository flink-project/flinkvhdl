onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {clk and reset}
add wave -noupdate /avalon_gpio_interface_tb/sl_clk
add wave -noupdate /avalon_gpio_interface_tb/sl_reset_n
add wave -noupdate -divider {avalon interface}
add wave -noupdate -radix unsigned /avalon_gpio_interface_tb/slv_avs_address
add wave -noupdate /avalon_gpio_interface_tb/sl_avs_read
add wave -noupdate /avalon_gpio_interface_tb/sl_avs_write
add wave -noupdate -radix hexadecimal /avalon_gpio_interface_tb/slv_avs_write_data
add wave -noupdate /avalon_gpio_interface_tb/slv_avs_read_data
add wave -noupdate /avalon_gpio_interface_tb/slv_avs_byteenable
add wave -noupdate -divider {in-output signals}
add wave -noupdate /avalon_gpio_interface_tb/slv_gpios
add wave -noupdate -divider {simulation parameter}
add wave -noupdate /avalon_gpio_interface_tb/main_period
add wave -noupdate /avalon_gpio_interface_tb/number_of_gpios
add wave -noupdate -divider {internal signals}
add wave -noupdate -expand /avalon_gpio_interface_tb/my_unit_under_test/ri
add wave -noupdate -childformat {{/avalon_gpio_interface_tb/my_unit_under_test/ri_next.conf_reg -radix hexadecimal} {/avalon_gpio_interface_tb/my_unit_under_test/ri_next.dir_reg -radix hexadecimal} {/avalon_gpio_interface_tb/my_unit_under_test/ri_next.value_reg -radix hexadecimal}} -expand -subitemconfig {/avalon_gpio_interface_tb/my_unit_under_test/ri_next.conf_reg {-radix hexadecimal} /avalon_gpio_interface_tb/my_unit_under_test/ri_next.dir_reg {-radix hexadecimal} /avalon_gpio_interface_tb/my_unit_under_test/ri_next.value_reg {-radix hexadecimal}} /avalon_gpio_interface_tb/my_unit_under_test/ri_next
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {14130395 ps} 0}
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
WaveRestoreZoom {0 ps} {42491400 ps}
