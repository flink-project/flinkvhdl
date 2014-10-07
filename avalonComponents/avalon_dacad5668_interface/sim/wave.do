onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_dacad5668_interface_tb/sl_clk
add wave -noupdate /avalon_dacad5668_interface_tb/sl_reset_n
add wave -noupdate /avalon_dacad5668_interface_tb/slv_avs_address
add wave -noupdate /avalon_dacad5668_interface_tb/sl_avs_read
add wave -noupdate /avalon_dacad5668_interface_tb/sl_avs_write
add wave -noupdate /avalon_dacad5668_interface_tb/slv_avs_write_data
add wave -noupdate /avalon_dacad5668_interface_tb/slv_avs_read_data
add wave -noupdate /avalon_dacad5668_interface_tb/sl_sclk
add wave -noupdate /avalon_dacad5668_interface_tb/slv_Ss
add wave -noupdate /avalon_dacad5668_interface_tb/sl_mosi
add wave -noupdate /avalon_dacad5668_interface_tb/sl_miso
add wave -noupdate /avalon_dacad5668_interface_tb/sl_LDAC_n
add wave -noupdate /avalon_dacad5668_interface_tb/sl_CLR_n
add wave -noupdate /avalon_dacad5668_interface_tb/main_period
add wave -noupdate -expand /avalon_dacad5668_interface_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {891339 ps} 0}
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
WaveRestoreZoom {0 ps} {936600 ps}
