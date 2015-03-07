
if { [file exists work] } { vdel -lib work -all}


vlib work

vlog -sv SPI_master.sv
vlog ../../RTL/SPI_slave_ext.v
vlog -sv SPI_slave_ext_tb.sv

vsim work.SPI_slave_ext_tb

add wave -divider "Clock and reset"
add wave -position insertpoint  \
sim:/SPI_slave_ext_tb/clk \
sim:/SPI_slave_ext_tb/reset

add wave -divider "SPI signals"
add wave -position insertpoint  \
sim:/SPI_slave_ext_tb/MISO \
sim:/SPI_slave_ext_tb/MOSI \
sim:/SPI_slave_ext_tb/SCLK \
sim:/SPI_slave_ext_tb/CS_n

add wave -divider "Internal"
add wave -position insertpoint  \
sim:/SPI_slave_ext_tb/SPI_slave_inst/state_tx	\
sim:/SPI_slave_ext_tb/SPI_slave_inst/tx_tmp_reg	\
sim:/SPI_slave_ext_tb/SPI_slave_inst/load_tx_reg


run -All
