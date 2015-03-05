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
//   - the delay between rd down and data valid is 100 ns
//
// TODO: find out if first sends out lower or hgher part of 32-bit word
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module cart_capture #(
	parameter			CLK_FREQ = 25_000_000
) (
	input				clk,	
	input				reset,

	input	[15:0]		cart_ad,
	input				cart_rd,
	input				cart_alel,
	input				cart_aleh,

	output reg	[31:0] 	addr_o,
	output reg	[31:0]	data_o,
	output reg			valid_o
);

wire	[15:0]	cart_ad_s;
wire			cart_rd_s;
wire			cart_alel_s;
wire			cart_aleh_s;

cart_capture_synchonizer cart_capture_synchonizer_inst (
	.clk			( clk			),	
	.reset			( reset			),

	.cart_ad 		( cart_ad 		),
	.cart_rd 		( cart_rd 		),
	.cart_alel 		( cart_alel 	),
	.cart_aleh 		( cart_aleh 	),

	.cart_ad_sync	( cart_ad_s 	),
	.cart_rd_sync	( cart_rd_s 	),
	.cart_alel_sync	( cart_alel_s 	),
	.cart_aleh_sync	( cart_aleh_s 	)
);

//==============================================================================
// Address capture

reg cart_alel_p, cart_aleh_p;
always @ (posedge clk) cart_alel_p <= cart_alel_s;
always @ (posedge clk) cart_aleh_p <= cart_aleh_s;

wire cart_alel_negedge, cart_aleh_negedge;
assign cart_alel_negedge = (cart_alel_p) && (!cart_alel_s);
assign cart_aleh_negedge = (cart_aleh_p) && (!cart_aleh_s);

reg [31:0] 	addr_tmp;
reg [1:0]	addr_tmp_valid;
wire 		addr_tmp_ack;

always @(posedge clk) begin
	if ( cart_aleh_s ) 			addr_tmp[31:16]	<= cart_ad_s; 
	else if ( cart_alel_s )		addr_tmp[15:0]	<= cart_ad_s; 
end

always @(posedge clk) begin
	if( addr_tmp_ack )				addr_tmp_valid		<= 2'b00;
	else if ( cart_aleh_negedge ) 	addr_tmp_valid[1]	<= 1;
	else if ( cart_alel_negedge ) 	addr_tmp_valid[0]	<= 1;
end

//==============================================================================
// Data capture
reg cart_rd_p;
always @ (posedge clk) cart_rd_p <= cart_rd_s;

wire cart_rd_negedge;
assign cart_rd_negedge = (cart_rd_p) && (!cart_rd_s);

reg [31:0] 	data_tmp;
reg [1:0]	data_tmp_valid;
wire 		data_tmp_ack;

// data delay
localparam D_DELAY = 100 / (CLK_FREQ / 1_000_000) + 1;
reg [D_DELAY-1:0] delay_cntr;

always @ (posedge clk) begin
	if (reset) begin
		delay_cntr	<= 0;
	end else begin
		delay_cntr 	<= {delay_cntr[D_DELAY-2:0], cart_rd_negedge};
	end
end

wire data_store;
assign data_store = delay_cntr[D_DELAY-1];

// store
always @ (posedge clk) begin
	if (reset) begin
		data_tmp_valid	<= 0;
	end else begin
		if (data_tmp_ack) begin
			data_tmp_valid	<= 2'b00;
		end else if (data_store && data_tmp_valid == 2'b00) begin
			data_tmp_valid	<= 2'b01;
			data_tmp[15:0]	<= cart_ad_s; 
		end else if (data_store && data_tmp_valid == 2'b01) begin
			data_tmp_valid	<= 2'b11;
			data_tmp[31:16]	<= cart_ad_s; 
		end
	end
end

//==============================================================================
// Output

wire valid_s;
assign valid_s = addr_tmp_valid == 2'b11 && data_tmp_valid == 2'b11;

assign addr_tmp_ack = valid_s;
assign data_tmp_ack = valid_s;


always @(posedge clk) begin
	if (reset) begin
		valid_o	<= 1'b0;
		addr_o	<= 1'b0;
		data_o 	<= 1'b0;
	end else begin
		valid_o	<= 1'b0;

		if( valid_s ) begin
			addr_o	<= addr_tmp;
			data_o 	<= data_tmp;
			valid_o	<= 1'b1;
		end
	end
end


endmodule
