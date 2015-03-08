module proto1_top(
	input		CLK_25,

	inout		N64_din,

	input		SCLK,
	output 		MISO,
	input		MOSI,
	input		CS_n,

	input [15:0]	CART_AD,
	input			CART_RD,
	input			CART_ALEL,
	input			CART_ALEH,

	output	[2:0]	LEDS
);


//=============================================================================
wire reset;

reset_gen  # (
	.NR_CLK_CYCLES ( 3_000_000	)
) reset_gen_inst (
	.clk	( CLK_25	),	
	.reset	( reset	)
);

//=============================================================================
reg [2:0] 	leds_reg;
reg [31:0]	leds_cntr;
//assign LEDS = leds_reg;

/*

always @ (posedge CLK_25) begin
	if (leds_cntr == 3_000_000) begin
		leds_cntr	<= 0;
		leds_reg	<= leds_reg + 1;
	end else begin
		leds_cntr	<= leds_cntr + 1;
	end
end
*/


//=============================================================================
reg	go;
reg [31:0] 	counter;
reg [31:0] tmp;

always @ (posedge CLK_25) begin
	if (counter == 250_000) begin
		counter	<= 0;
		go	<= 1;
		tmp	<= tmp + 1;
		leds_reg <= leds_reg + 1;
	end else begin
		counter	<= counter + 1;
		go	<= 0;
	end
end


//=============================================================================

wire data_valid;
wire [31:0] data_out;
reg [31:0]	data_out_reg;

always @ (posedge CLK_25) begin
	if (data_valid) begin
		data_out_reg <= data_out;
	end
end

//=============================================================================
N64_recv # ( 
	.CLK_FREQ	( 25_000_000	)
) N64_recv_inst 
(
	.clk		( CLK_25		),	
	.reset		( reset			),

	.go			( go			),
	.din		( N64_din		),

	.data_out	( data_out		),
	.data_valid	( data_valid	)
);
//=============================================================================

wire [31:0] cart_addr, cart_data;
wire		cart_valid;

wire [63:0]	cart_spi_data;
wire		cart_spi_read;
wire		cart_spi_valid;
wire [7:0]	cart_spi_usedw;

cart_capture # (
	.CLK_FREQ	( 25_000_000	)
)  cart_capture_inst (
	.clk		( CLK_25		),	
	.reset		( reset			),

	.cart_ad	( CART_AD		),
	.cart_rd	( CART_RD		),
	.cart_alel	( CART_ALEL		),
	.cart_aleh	( CART_ALEH		),

	.addr_o		( cart_addr		),
	.data_o		( cart_data		),
	.valid_o	( cart_valid	)
);

fifo fifo_inst (
	.clk		( CLK_25		),	
	.reset		( reset			),

	.wdata_i	( {cart_addr, cart_data} ),
	.wvalid_i	( cart_valid	),
	.wfull_o	( 				),

	.rdata_o	( cart_spi_data	),
	.read_i		( cart_spi_read	),
	.rvalid_o	( cart_spi_valid),
	.usedw_o	( cart_spi_usedw)
);

//=============================================================================
wire [3:0] spi_debug;
assign LEDS = spi_debug[2:0];

SPI_slave_ext SPI_slave_inst (
	.clk		( CLK_25		),	
	.reset		( reset			),

	.SCLK		( SCLK			),
	.MISO		( MISO			),
	.MOSI		( MOSI			),
	.CS_n		( CS_n			),

	.ctrl_present	( 4'b1101	),
	.ctrl_data	( 128'h1234_5678_9012_3456_7890_1234_5678_9012	),

	.rdata_i	( cart_spi_data	),
	.read_o		( cart_spi_read	),
	.rvalid_i	( cart_spi_valid),
	.usedw_i	( cart_spi_usedw),

	.debug		( spi_debug 	)
);

endmodule
