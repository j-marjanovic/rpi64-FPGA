///////////////////////////////////////////////////////////////////////////////
//   __  __          _____      _         _   _  ______      _______ _____   //
//  |  \/  |   /\   |  __ \    | |  /\   | \ | |/ __ \ \    / /_   _/ ____|  //
//  | \  / |  /  \  | |__) |   | | /  \  |  \| | |  | \ \  / /  | || |       //
//  | |\/| | / /\ \ |  _  /_   | |/ /\ \ | . ` | |  | |\ \/ /   | || |       //
//  | |  | |/ ____ \| | \ \ |__| / ____ \| |\  | |__| | \  /   _| || |____   //
//  |_|  |_/_/    \_\_|  \_\____/_/    \_\_| \_|\____/   \/   |_____\_____|  //
//                                                                           //
//                          JAN MARJANOVIC, 2015                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//
// Captures communciation from N64 cartridge
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module cart_capture_synchonizer (
	input				clk,	
	input				reset,

	input	[15:0]		cart_ad,
	input				cart_rd,
	input				cart_alel,
	input				cart_aleh,

	output reg	[15:0]	cart_ad_sync,
	output reg			cart_rd_sync,
	output reg			cart_alel_sync,
	output reg			cart_aleh_sync
);

//==============================================================================
// First stage
reg	[15:0]	cart_ad_p;
reg			cart_rd_p;
reg			cart_alel_p;
reg			cart_aleh_p;

always @(posedge clk) begin
	cart_ad_p	<= cart_ad;
	cart_rd_p	<= cart_rd;
	cart_alel_p	<= cart_alel;
	cart_aleh_p	<= cart_aleh;
end


//==============================================================================
// Second stage
always @(posedge clk) begin
	cart_ad_sync	<= cart_ad_p;
	cart_rd_sync	<= cart_rd_p;
	cart_alel_sync	<= cart_alel_p;
	cart_aleh_sync	<= cart_aleh_p;
end


endmodule
