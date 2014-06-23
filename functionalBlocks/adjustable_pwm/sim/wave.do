onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider In/Output-Signals
add wave -noupdate /adjustable_pwm_rtl_tb/sl_clk
add wave -noupdate /adjustable_pwm_rtl_tb/sl_reset_n
add wave -noupdate -radix unsigned /adjustable_pwm_rtl_tb/slv_frequency_divider
add wave -noupdate -radix unsigned /adjustable_pwm_rtl_tb/slv_ratio
add wave -noupdate /adjustable_pwm_rtl_tb/sl_pwm
add wave -noupdate -divider {Simulation Parameter}
add wave -noupdate /adjustable_pwm_rtl_tb/main_period
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {8015050 ps} {8016050 ps}
