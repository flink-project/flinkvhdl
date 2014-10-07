onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dacad5668_rtl_tb/sl_clk
add wave -noupdate /dacad5668_rtl_tb/sl_reset_n
add wave -noupdate /dacad5668_rtl_tb/values
add wave -noupdate /dacad5668_rtl_tb/sl_sclk
add wave -noupdate /dacad5668_rtl_tb/slv_Ss
add wave -noupdate /dacad5668_rtl_tb/sl_mosi
add wave -noupdate /dacad5668_rtl_tb/sl_miso
add wave -noupdate /dacad5668_rtl_tb/main_period
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/osl_LDAC_n
add wave -noupdate /dacad5668_rtl_tb/my_unit_under_test/osl_CLR_n
add wave -noupdate -expand /dacad5668_rtl_tb/my_unit_under_test/ri
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24015446 ps} 0}
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
WaveRestoreZoom {0 ps} {25216800 ps}
