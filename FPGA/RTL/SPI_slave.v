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

///////////////////////////////////////////////////////////////////////////////
//
// SPI on RPi should use CPHA = 0, CPOL = 0
//
//                   +----+    +----+    +----+    +----+
//   SCK             |    |    |    |    |    |    |    |
//          ---------+    +----+    +----+    +----+    +----
//                        .         .         .         .
//                        .         .         .         .
//           --\./-------\./-------\./-------\./-------\./---
//   MxSx       X   D7    X   D6    X   D5    X    D4   X
//           --/.\-------/.\-------/.\-------/.\-------/.\---
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module SPI_slave # (
	parameter USE_DVALID = 1	// if 0, loads data from data_in when CS_n is asserted
								// if 1, loads data when data_valid is 1
)(
	input			clk,	
	input			reset,

	input			SCLK,
	//input			MOSI,
	output 			MISO,
	input			CS_n,

	input [31:0] 	data_in,
	input 			data_valid
);


//=============================================================================
// Chip select detection
reg CS_n_s;
reg CS_n_ss;
reg CS_n_sss;

always @ (posedge clk) begin
	CS_n_s	<= CS_n;
	CS_n_ss	<= CS_n_s;
	CS_n_sss<= CS_n_ss;
end

wire CS_n_posedge = (CS_n_sss == 1'b0) && (CS_n_ss == 1'b1);
wire CS_n_negedge = (CS_n_sss == 1'b1) && (CS_n_ss == 1'b0);

//=============================================================================
// SCLK detection
//   A double register is used to prevent metastability since SCLK is 
//   asynchronous to clk. This limits the maximum speed of communication,
//   since the state machine is always 2 clk cycles behind

reg SCLK_s;
reg SCLK_ss;
reg SCLK_sss;

always @ (posedge clk) begin
	SCLK_s	<= SCLK;
	SCLK_ss	<= SCLK_s;
	SCLK_sss<= SCLK_ss;
end

wire SCLK_posedge = (SCLK_sss == 1'b0) && (SCLK_ss == 1'b1);
wire SCLK_negedge = (SCLK_sss == 1'b1) && (SCLK_ss == 1'b0);



//=============================================================================
// 

wire MISO_wire;

reg [31:0] tmp_reg;

assign MISO_wire = tmp_reg[0];

assign MISO = (CS_n == 1'b1) ? 1'bz : MISO_wire;


//=============================================================================
// State machine

localparam [7:0]	S_IDLE	= 8'b0000_0001,
					S_COMM	= 8'b0000_0010;

reg [7:0] state;

always @ (posedge clk) begin
	if (reset) begin
		state	<= S_IDLE;
	end else begin
		case (state)
		//---------------------------------------------------------------------
		S_IDLE: begin
			if (CS_n_negedge) begin
				state	<= S_COMM;
				if (USE_DVALID == 0)			tmp_reg	<= data_in;
			end

			if (USE_DVALID == 1 && data_valid)	tmp_reg	<= data_in;
		end
		//---------------------------------------------------------------------
		S_COMM: begin
			if( SCLK_negedge ) 		tmp_reg	<= {1'b0, tmp_reg[31:1]};

			if( CS_n_posedge )		state	<= S_IDLE;
		end
		//---------------------------------------------------------------------
		endcase
	end
end

endmodule
