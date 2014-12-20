
if { [file exists work] } { vdel -lib work -all}


vlib work

vlog -sv SPI_master.sv
vlog ../../RTL/SPI_slave.v
vlog -sv SPI_slave_tb.sv

vsim work.SPI_slave_tb

add wave -divider "Clock and reset"
add wave -position insertpoint  \
sim:/SPI_slave_tb/clk \
sim:/SPI_slave_tb/reset

add wave -divider "SPI signals"
add wave -position insertpoint  \
sim:/SPI_slave_tb/MISO \
sim:/SPI_slave_tb/SCLK \
sim:/SPI_slave_tb/CS_n

add wave -divider "Internal"
add wave -position insertpoint  \
sim:/SPI_slave_tb/data_valid \
sim:/SPI_slave_tb/data_in

add wave -position insertpoint  \
sim:/SPI_slave_tb/SPI_slave_inst/tmp_reg

add wave -position insertpoint  \
sim:/SPI_slave_tb/SPI_slave_inst/state


run -All