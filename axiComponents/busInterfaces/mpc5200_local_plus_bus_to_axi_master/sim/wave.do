onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_aclk
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_areset_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awaddr
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awlen
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awsize
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awburst
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_wdata
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_awready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_wstrb
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_wvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_wready
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/axi_araddr
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arlen
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arsize
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_arburst
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rdata
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rresp
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_rlast
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_bresp
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_bvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_bready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_bid
add wave -noupdate -divider {My unit under test}
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/axi_aclk
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/lpb_ad
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_cs_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_oe_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_ack_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_ale_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_rdwr_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/lpb_ts_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/main_period
add wave -noupdate -divider {My unit under test}
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/LPBADDRWIDTH
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/LPBDATAWIDTH
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/LPBTSIZEWIDTH
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/LPBCSWIDTH
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/LPBBANKWIDTH
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/clk
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/reset_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awaddr
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awlen
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awsize
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awburst
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_awready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_wdata
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_wstrb
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_wvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_wready
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_araddr
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arlen
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arsize
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_arburst
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rdata
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rresp
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_rlast
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_bresp
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_bvalid
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_bready
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axi_bid
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ad
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_cs_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_oe_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ack_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ale_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_rdwr_n
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ts_n
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_adr_q
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_data_q
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_tsize_q
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_data_en
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_start
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_rd
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_wr
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ack_i
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_start_en
add wave -noupdate -radix unsigned /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ad_o
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/lpb_ad_en
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/my_unit_under_test/axistate
add wave -noupdate /mpc5200b_lpb_to_axi_master_tb/read_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1701797 ps} 0}
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
WaveRestoreZoom {1586357 ps} {1798303 ps}
