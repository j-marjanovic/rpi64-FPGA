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
//  Simulates communciation between N64 and cartridge (extracted from
//  captures with logic analyzer)
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module cart_comm_wform (
	output reg	[15:0]	cart_ad,
	output reg			cart_rd,
	output reg			cart_alel,
	output reg			cart_aleh
);

task single_read (
	input [31:0] addr, 
	input [31:0] data
);

	cart_rd 	= 1;
	cart_alel	= 0;
	cart_aleh	= 0;

	#(100ns);
	cart_rd 	= 1;
	cart_alel	= 0;
	cart_aleh	= 1;

	#(2us);
	// ALEL high
	cart_ad		= addr[31:16];
	cart_rd 	= 1;
	cart_alel	= 1;
	cart_aleh	= 1;

	#(100ns);
	// ALEH low
	cart_rd 	= 1;
	cart_alel	= 1;
	cart_aleh	= 0;

	#(10ns);
	cart_ad		= addr[15:0];


	#(100ns);
	// ALEL low
	cart_rd 	= 1;
	cart_alel	= 0;
	cart_aleh	= 0;

	// here comes the date
	#(1us);
	cart_rd 	= 0;
	cart_alel	= 0;
	cart_aleh	= 0;


	#(100ns);
	cart_ad		= data[15:0];

	#(200ns);
	cart_rd 	= 1;
	cart_alel	= 0;
	cart_aleh	= 0;	

	#(100ns);
	cart_rd 	= 0;
	cart_alel	= 0;
	cart_aleh	= 0;


	#(100ns);
	cart_ad		= data[31:16];	

	#(200ns);
	cart_rd 	= 0;
	cart_alel	= 0;
	cart_aleh	= 0;	
endtask

//=============================================================================
initial begin
	cart_ad		= 0;
	cart_rd 	= 0;
	cart_alel	= 0;
	cart_aleh	= 0;

	#(1us);

	single_read(32'h1000_0000, 32'h1240_0037);
	single_read(32'h1000_0040, 32'hABCD_1234);
	single_read(32'h1000_0044, 32'hA5B9_0102);
	single_read(32'h1000_0048, 32'h7788_9900);
end

endmodule
