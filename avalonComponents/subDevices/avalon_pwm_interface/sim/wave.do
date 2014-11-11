onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {clk and reset}
add wave -noupdate /avalon_pwm_interface_tb/sl_clk
add wave -noupdate /avalon_pwm_interface_tb/sl_reset_n
add wave -noupdate -divider {avalon interface}
add wave -noupdate /avalon_pwm_interface_tb/slv_avs_address
add wave -noupdate /avalon_pwm_interface_tb/sl_avs_read
add wave -noupdate /avalon_pwm_interface_tb/sl_avs_write
add wave -noupdate /avalon_pwm_interface_tb/slv_avs_write_data
add wave -noupdate -radix unsigned /avalon_pwm_interface_tb/slv_avs_read_data
add wave -noupdate -divider {output signals}
add wave -noupdate -radix symbolic -childformat {{/avalon_pwm_interface_tb/slv_pwm(0) -radix symbolic}} -expand -subitemconfig {/avalon_pwm_interface_tb/slv_pwm(0) {-radix symbolic}} /avalon_pwm_interface_tb/slv_pwm
add wave -noupdate -divider {simulation parameter}
add wave -noupdate /avalon_pwm_interface_tb/main_period
add wave -noupdate /avalon_pwm_interface_tb/number_of_pwms
add wave -noupdate -divider {PWM 0}
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/frequency_resolution
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/sl_clk
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/sl_reset_n
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/slv_frequency_divider
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/slv_ratio
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/sl_pwm
add wave -noupdate /avalon_pwm_interface_tb/my_unit_under_test/gen_pwm(0)/my_adjustable_pwm/cycle_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {46996000 ps} 0}
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
WaveRestoreZoom {0 ps} {59148600 ps}
