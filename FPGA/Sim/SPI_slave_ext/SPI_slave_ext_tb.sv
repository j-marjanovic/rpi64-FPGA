///////////////////////////////////////////////////////////////////////////////
//   __  __          _____      _         _   _  ______      _______ _____   //
//  |  \/  |   /\   |  __ \    | |  /\   | \ | |/ __ \ \    / /_   _/ ____|  //
//  | \  / |  /  \  | |__) |   | | /  \  |  \| | |  | \ \  / /  | || |       //
//  | |\/| | / /\ \ |  _  /_   | |/ /\ \ | . ` | |  | |\ \/ /   | || |       //
//  | |  | |/ ____ \| | \ \ |__| / ____ \| |\  | |__| | \  /   _| || |____   //
//  |_|  |_/_/    \_\_|  \_\____/_/    \_\_| \_|\____/   \/   |_____\_____|  //
//                                                                           //
//                          JAN MARJANOVIC, 2014                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module SPI_slave_ext_tb;

bit		clk = 0;
bit		reset = 1;

wire MISO, MOSI, SCLK, CS_n;

// controllers	
bit	[3:0]	ctrl_present;
bit	[127:0]	ctrl_data;

// FIFO
bit	[63:0]	rdata_i;
wire		read_o;
bit 		rvalid_i;
bit	[7:0]	usedw_i;

//=============================================================================
always #16 clk = !clk;

initial begin
	reset 	<= 1;
	#200;
	@(posedge clk);
	reset	<= 0;
end

//=============================================================================
SPI_master SPIm ( .* );

SPI_slave_ext  SPI_slave_inst  ( .* );

//=============================================================================

bit [7:0] out_data[];
bit [7:0] in_data[];

initial begin
	$display(" SPI slave module test ");
	
	// Test read from controllers
	#(1us);
	ctrl_present = 4'b1101;
	ctrl_data    = 128'h0011_2233_4455_6677_8899_AABB_CCDD_EEFF;
	out_data = new[18]('{8'h00, 136'd0});
	SPIm.start_transfer(out_data, in_data);
	$display("in_data: %x", in_data);
	

	// Test read from controllers
	#(10us);
	ctrl_present = 4'b0010;
	ctrl_data    = 128'h1234_5678_9012_3456_7890_1234_5678_9012;
	out_data = new[18]('{8'h00, 136'd0});
	SPIm.start_transfer(out_data, in_data);
	$display("in_data: %x", in_data);


	// Test read from FIFO (usedw)
	#(10us);
	usedw_i = 8'd177;
	out_data = new[2]('{8'h80, 8'd0});
	SPIm.start_transfer(out_data, in_data);
	$display("in_data: %x", in_data);

	#(1us);
	$stop();
end



endmodule

