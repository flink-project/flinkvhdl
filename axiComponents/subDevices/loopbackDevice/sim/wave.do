onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Global Signals}
add wave -noupdate /loopback_device_tb/axi_aclk
add wave -noupdate /loopback_device_tb/axi_areset_n
add wave -noupdate -divider {Write address channel}
add wave -noupdate /loopback_device_tb/axi_awid
add wave -noupdate -radix unsigned /loopback_device_tb/axi_awaddr
add wave -noupdate /loopback_device_tb/axi_awlen
add wave -noupdate /loopback_device_tb/axi_awsize
add wave -noupdate /loopback_device_tb/axi_awburst
add wave -noupdate /loopback_device_tb/axi_awvalid
add wave -noupdate /loopback_device_tb/axi_awready
add wave -noupdate -divider {Write data channel}
add wave -noupdate -radix unsigned /loopback_device_tb/axi_wdata
add wave -noupdate /loopback_device_tb/axi_wstrb
add wave -noupdate /loopback_device_tb/axi_wvalid
add wave -noupdate /loopback_device_tb/axi_wready
add wave -noupdate -divider {Read address channel}
add wave -noupdate /loopback_device_tb/axi_araddr
add wave -noupdate /loopback_device_tb/axi_arvalid
add wave -noupdate /loopback_device_tb/axi_arready
add wave -noupdate /loopback_device_tb/axi_arid
add wave -noupdate /loopback_device_tb/axi_arlen
add wave -noupdate /loopback_device_tb/axi_arsize
add wave -noupdate /loopback_device_tb/axi_arburst
add wave -noupdate -divider {Read data channel}
add wave -noupdate -radix unsigned /loopback_device_tb/axi_rdata
add wave -noupdate /loopback_device_tb/axi_rresp
add wave -noupdate /loopback_device_tb/axi_rvalid
add wave -noupdate /loopback_device_tb/axi_rready
add wave -noupdate /loopback_device_tb/axi_rid
add wave -noupdate /loopback_device_tb/axi_rlast
add wave -noupdate -divider {Write response channel}
add wave -noupdate /loopback_device_tb/axi_bresp
add wave -noupdate /loopback_device_tb/axi_bvalid
add wave -noupdate /loopback_device_tb/axi_bready
add wave -noupdate /loopback_device_tb/axi_bid
add wave -noupdate -divider Constants
add wave -noupdate /loopback_device_tb/main_period
add wave -noupdate -radix hexadecimal /loopback_device_tb/unique_id
add wave -noupdate -divider {Axi slave internal signals}
add wave -noupdate -childformat {{/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.read_address -radix unsigned} {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.read_burst_len_cnt -radix unsigned} {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_address -radix unsigned} {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_burst_len_cnt -radix unsigned} {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_data -radix unsigned} {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.axi_rdata -radix unsigned}} -expand -subitemconfig {/loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.read_address {-height 15 -radix unsigned} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.read_burst_len_cnt {-height 15 -radix unsigned} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_address {-height 15 -radix unsigned} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_burst_len_cnt {-height 15 -radix unsigned} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.write_data {-height 15 -radix unsigned} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri.axi_rdata {-radix unsigned}} /loopback_device_tb/my_unit_under_test/axi_slave_interface/ri
add wave -noupdate -radix unsigned /loopback_device_tb/my_unit_under_test/slv_read_address
add wave -noupdate /loopback_device_tb/my_unit_under_test/sl_write_valid
add wave -noupdate /loopback_device_tb/my_unit_under_test/slv_write_address
add wave -noupdate /loopback_device_tb/my_unit_under_test/slv_write_data
add wave -noupdate -divider {Loopback internal signals}
add wave -noupdate -radix unsigned /loopback_device_tb/my_unit_under_test/ri.axi_rdata
add wave -noupdate -height 15 -radix unsigned -childformat {{/loopback_device_tb/my_unit_under_test/ri.mem_reg(55) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(54) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(53) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(52) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(51) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(50) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(49) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(48) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(47) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(46) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(45) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(44) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(43) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(42) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(41) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(40) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(39) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(38) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(37) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(36) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(35) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(34) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(33) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(32) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(31) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(30) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(29) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(28) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(27) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(26) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(25) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(24) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(23) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(22) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(21) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(20) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(19) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(18) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(17) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(16) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(15) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(14) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(13) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(12) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(11) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(10) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(9) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(8) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(7) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(6) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(5) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(4) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(3) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(2) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(1) -radix unsigned} {/loopback_device_tb/my_unit_under_test/ri.mem_reg(0) -radix unsigned}} -subitemconfig {/loopback_device_tb/my_unit_under_test/ri.mem_reg(55) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(54) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(53) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(52) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(51) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(50) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(49) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(48) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(47) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(46) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(45) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(44) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(43) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(42) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(41) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(40) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(39) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(38) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(37) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(36) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(35) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(34) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(33) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(32) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(31) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(30) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(29) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(28) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(27) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(26) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(25) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(24) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(23) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(22) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(21) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(20) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(19) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(18) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(17) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(16) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(15) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(14) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(13) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(12) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(11) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(10) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(9) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(8) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(7) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(6) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(5) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(4) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(3) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(2) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(1) {-radix unsigned} /loopback_device_tb/my_unit_under_test/ri.mem_reg(0) {-radix unsigned}} /loopback_device_tb/my_unit_under_test/ri.mem_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8070472 ps} 0}
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
WaveRestoreZoom {8098669 ps} {8178701 ps}
