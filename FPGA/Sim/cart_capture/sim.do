
if { [file exists work] } { vdel -lib work -all}


vlib work

vlog ../../RTL/cart_capture_synchronizer.v
vlog ../../RTL/cart_capture.v
vlog -sv cart_comm_wform.sv
vlog -sv cart_capture_tb.sv

vsim work.cart_capture_tb

add wave -divider "Clk and reset"
add wave -position insertpoint -radix hex \
sim:/cart_capture_tb/clk \
sim:/cart_capture_tb/reset


add wave -divider "Communication"
add wave -position insertpoint -radix hex \
sim:/cart_capture_tb/cart_ad \
sim:/cart_capture_tb/cart_rd \
sim:/cart_capture_tb/cart_alel \
sim:/cart_capture_tb/cart_aleh

add wave -divider "Output"
add wave -position insertpoint -radix hex \
sim:/cart_capture_tb/addr_o \
sim:/cart_capture_tb/data_o \
sim:/cart_capture_tb/valid_o

run -All
