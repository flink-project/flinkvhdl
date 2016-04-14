onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gpio_device_tb/axi_aclk
add wave -noupdate /gpio_device_tb/axi_areset_n
add wave -noupdate /gpio_device_tb/axi_awid
add wave -noupdate /gpio_device_tb/axi_awaddr
add wave -noupdate /gpio_device_tb/axi_awlen
add wave -noupdate /gpio_device_tb/axi_awsize
add wave -noupdate /gpio_device_tb/axi_awburst
add wave -noupdate /gpio_device_tb/axi_awvalid
add wave -noupdate /gpio_device_tb/axi_wdata
add wave -noupdate /gpio_device_tb/axi_awready
add wave -noupdate /gpio_device_tb/axi_wstrb
add wave -noupdate /gpio_device_tb/axi_wvalid
add wave -noupdate /gpio_device_tb/axi_wready
add wave -noupdate /gpio_device_tb/axi_araddr
add wave -noupdate /gpio_device_tb/axi_arvalid
add wave -noupdate /gpio_device_tb/axi_arready
add wave -noupdate /gpio_device_tb/axi_arid
add wave -noupdate /gpio_device_tb/axi_arlen
add wave -noupdate /gpio_device_tb/axi_arsize
add wave -noupdate /gpio_device_tb/axi_arburst
add wave -noupdate /gpio_device_tb/axi_rdata
add wave -noupdate /gpio_device_tb/axi_rresp
add wave -noupdate /gpio_device_tb/axi_rvalid
add wave -noupdate /gpio_device_tb/axi_rready
add wave -noupdate /gpio_device_tb/axi_rid
add wave -noupdate /gpio_device_tb/axi_rlast
add wave -noupdate /gpio_device_tb/axi_bresp
add wave -noupdate /gpio_device_tb/axi_bvalid
add wave -noupdate /gpio_device_tb/axi_bready
add wave -noupdate /gpio_device_tb/axi_bid
add wave -noupdate /gpio_device_tb/slv_gpios
add wave -noupdate /gpio_device_tb/main_period
add wave -noupdate /gpio_device_tb/number_of_gpios
add wave -noupdate /gpio_device_tb/unique_id
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8019286 ps} 0}
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
WaveRestoreZoom {0 ps} {8421 ns}
