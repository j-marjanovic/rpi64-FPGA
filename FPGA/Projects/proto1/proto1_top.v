module proto1_top(
	input		CLK_33,
	inout		N64_din,
	output	[3:0]	LEDS
);


reg	go;
reg	reset;
reg	select;

reg [31:0] 	counter;


always @ (posedge CLK_33) begin
	if (counter == 30_000) begin
		counter	<= 0;
		if( select ) 
			go	<= 1;
		else 
			reset	<= 1;
		
		select	<= !select;
		
	end else begin
		counter	<= counter + 1;
		go	<= 0;
		reset	<= 0;
	end
end



wire data_valid;
wire [31:0] data_out;
reg [31:0]	data_out_reg;

assign LEDS = data_out_reg[3:0];

always @ (posedge CLK_33) begin
	if (data_valid) begin
		data_out_reg <= data_out;
	end
end


N64_recv N64_recv_inst (
	.clk	( CLK_33		),	
	.reset	( reset		),

	.go	( go		),
	.din	( N64_din		),

	.data_out	( data_out		),
	.data_valid	( data_valid	)
);


endmodule