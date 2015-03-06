
# Set your iCEcube2 directory
set ICE_DIR /home/jan/opt/lscc/iCEcube2.2014.12



if { [file exists work] } { vdel -lib work -all}

vlib work

vlog $ICE_DIR/verilog/sb_ice_syn.v
vlog ../../RTL/fifo.v
vlog -sv fifo_tb.sv

vsim work.fifo_tb


add wave -divider "Clk and reset"
add wave -position insertpoint -radix hex \
sim:/fifo_tb/clk \
sim:/fifo_tb/reset


add wave -divider "Write"
add wave -position insertpoint -radix hex \
sim:/fifo_tb/wdata_i \
sim:/fifo_tb/wvalid_i \
sim:/fifo_tb/wfull_o


add wave -divider "Read"
add wave -position insertpoint -radix hex \
sim:/fifo_tb/rdata_o \
sim:/fifo_tb/read_i \
sim:/fifo_tb/rvalid_o \
sim:/fifo_tb/usedw_o


add wave -divider "RAM interface"
add wave -position insertpoint -radix hex \
sim:/fifo_tb/DUT/ram_r*
add wave -position insertpoint -radix hex \
sim:/fifo_tb/DUT/ram_w*


run -All
