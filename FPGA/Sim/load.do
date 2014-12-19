
if { [file exists work] } { vdel -lib work -all}


vlib work
vlog -sv N64_controller.sv
vlog ../RTL/N64_recv.v
vlog -sv N64_recv_tb.sv

vsim work.N64_recv_tb

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/N64_recv_tb/clk \
sim:/N64_recv_tb/reset

add wave -divider "Communication"
add wave -position insertpoint  \
sim:/N64_recv_tb/din

add wave -divider "Output"
add wave -position insertpoint -radix hex \
sim:/N64_recv_tb/data_out \
sim:/N64_recv_tb/data_valid

add wave -divider "Internal"
add wave -position insertpoint -radix unsigned  \
sim:/N64_recv_tb/DUT/state \
sim:/N64_recv_tb/DUT/bit_cntr \
sim:/N64_recv_tb/DUT/pulse_cntr \
sim:/N64_recv_tb/DUT/count


