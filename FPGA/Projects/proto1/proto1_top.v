module proto1_top(
	input		CLK_25,

	inout		N64_din,

	input		SCLK,
	output 		MISO,
	input		CS_n,

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
assign LEDS = leds_reg;

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
SPI_slave SPI_slave_inst (
	.clk		( CLK_25		),	
	.reset		( reset			),

	.SCLK		( SCLK			),
	.MISO		( MISO			),
	.CS_n		( CS_n			),

	.data_in	( data_out		),
	.data_valid	( data_valid	)
);

endmodule
