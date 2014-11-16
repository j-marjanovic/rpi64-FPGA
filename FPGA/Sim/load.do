
if { [file exists work] } { vdel -lib work -all}


vlib work
vlog -sv N64_controller.sv
vsim work.N64_controller
