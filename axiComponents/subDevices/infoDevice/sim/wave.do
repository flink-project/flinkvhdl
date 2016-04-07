onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Reset}
add wave -noupdate /info_device_tb/axi_aclk
add wave -noupdate /info_device_tb/axi_areset_n
add wave -noupdate -divider {Write Address Channel}
add wave -noupdate /info_device_tb/axi_awid
add wave -noupdate /info_device_tb/axi_awaddr
add wave -noupdate /info_device_tb/axi_awlen
add wave -noupdate /info_device_tb/axi_awsize
add wave -noupdate /info_device_tb/axi_awburst
add wave -noupdate /info_device_tb/axi_awvalid
add wave -noupdate /info_device_tb/axi_awready
add wave -noupdate -divider {Write Data Channel}
add wave -noupdate /info_device_tb/axi_wdata
add wave -noupdate /info_device_tb/axi_wstrb
add wave -noupdate /info_device_tb/axi_wvalid
add wave -noupdate /info_device_tb/axi_wready
add wave -noupdate -divider {Read Address Channel}
add wave -noupdate -radix unsigned /info_device_tb/axi_araddr
add wave -noupdate /info_device_tb/axi_arvalid
add wave -noupdate /info_device_tb/axi_arready
add wave -noupdate /info_device_tb/axi_arid
add wave -noupdate /info_device_tb/axi_arlen
add wave -noupdate /info_device_tb/axi_arsize
add wave -noupdate /info_device_tb/axi_arburst
add wave -noupdate -divider {Read Data Channel}
add wave -noupdate -radix unsigned /info_device_tb/axi_rdata
add wave -noupdate /info_device_tb/axi_rresp
add wave -noupdate /info_device_tb/axi_rvalid
add wave -noupdate /info_device_tb/axi_rready
add wave -noupdate /info_device_tb/axi_rid
add wave -noupdate /info_device_tb/axi_rlast
add wave -noupdate -divider {Write Response Channel}
add wave -noupdate /info_device_tb/axi_bresp
add wave -noupdate /info_device_tb/axi_bvalid
add wave -noupdate /info_device_tb/axi_bready
add wave -noupdate /info_device_tb/axi_bid
add wave -noupdate -divider Constants
add wave -noupdate /info_device_tb/main_period
add wave -noupdate /info_device_tb/dev_size
add wave -noupdate /info_device_tb/unique_id
add wave -noupdate /info_device_tb/description
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1633000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 124
configure wave -valuecolwidth 77
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
WaveRestoreZoom {1513541 ps} {1739873 ps}
