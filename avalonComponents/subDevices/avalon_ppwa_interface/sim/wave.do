onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_ppwa_interface_tb/sl_clk
add wave -noupdate /avalon_ppwa_interface_tb/sl_reset_n
add wave -noupdate /avalon_ppwa_interface_tb/slv_avs_address
add wave -noupdate /avalon_ppwa_interface_tb/sl_avs_read
add wave -noupdate /avalon_ppwa_interface_tb/sl_avs_write
add wave -noupdate /avalon_ppwa_interface_tb/slv_avs_write_data
add wave -noupdate /avalon_ppwa_interface_tb/slv_avs_read_data
add wave -noupdate /avalon_ppwa_interface_tb/slv_signals_to_measure
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {85770911 ps} 0}
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
WaveRestoreZoom {0 ps} {170137800 ps}
