onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {clk and reset}
add wave -noupdate /avalon_fqd_counter_interface_tb/sl_clk
add wave -noupdate /avalon_fqd_counter_interface_tb/sl_reset_n
add wave -noupdate -divider {avalon bus}
add wave -noupdate /avalon_fqd_counter_interface_tb/slv_avs_address
add wave -noupdate /avalon_fqd_counter_interface_tb/sl_avs_read
add wave -noupdate /avalon_fqd_counter_interface_tb/sl_avs_write
add wave -noupdate /avalon_fqd_counter_interface_tb/slv_avs_write_data
add wave -noupdate /avalon_fqd_counter_interface_tb/slv_avs_read_data
add wave -noupdate -divider encoder
add wave -noupdate /avalon_fqd_counter_interface_tb/slv_enc_A
add wave -noupdate /avalon_fqd_counter_interface_tb/slv_enc_B
add wave -noupdate -divider {sim parameter}
add wave -noupdate /avalon_fqd_counter_interface_tb/main_period
add wave -noupdate /avalon_fqd_counter_interface_tb/number_of_fqds
add wave -noupdate /avalon_fqd_counter_interface_tb/velocity
add wave -noupdate /avalon_fqd_counter_interface_tb/direction
add wave -noupdate /avalon_fqd_counter_interface_tb/enc_tick_per_turn
add wave -noupdate /avalon_fqd_counter_interface_tb/wait_time
add wave -noupdate -divider {fqd block 0}
add wave -noupdate /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/gi_pos_length
add wave -noupdate /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/isl_clk
add wave -noupdate /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/isl_reset_n
add wave -noupdate /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/isl_enc_A
add wave -noupdate /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/isl_enc_B
add wave -noupdate -childformat {{/avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/ri.usig_pos -radix unsigned}} -expand -subitemconfig {/avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/ri.usig_pos {-radix unsigned}} /avalon_fqd_counter_interface_tb/my_unit_under_test/gen_fqd(0)/my_fqd/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {104000 ps} 0}
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
WaveRestoreZoom {0 ps} {561404 ps}
