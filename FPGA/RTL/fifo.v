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
// Single clock FIFO, made out of embedded RAM block
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module fifo (
	input				clk,	
	input				reset,

	// write side
	input	[63:0]		wdata_i,
	input				wvalid_i,
	output				wfull_o,

	// read side
	output reg	[63:0]	rdata_o,
	input				read_i,
	output reg 			rvalid_o,
	output reg	[7:0]	usedw_o // empty = usedw  == 0
);


wire [63:0] ram_rdata;
wire [7:0]	ram_raddr;
wire 		ram_re;
wire [63:0] ram_wdata;
wire [7:0]	ram_waddr;
wire 		ram_we;

//==============================================================================
// Write 

reg [7:0] 	wr_addr;
wire 		wr_addr_inc;

assign ram_wdata = wdata_i;
assign ram_waddr = wr_addr;
assign ram_we    = wvalid_i && !wfull_o;

assign wr_addr_inc = wvalid_i && !wfull_o;

always @ (posedge clk) begin
	if (reset) 				wr_addr <= 0;
	else if (wr_addr_inc)	wr_addr <= wr_addr + 1;
end


//==============================================================================
// Read

reg [7:0] 	rd_addr;
wire 		rd_addr_inc;
wire 		read;
reg			read_p;

assign read 	 = read_i && (usedw_o != 0);
assign ram_raddr = rd_addr;
assign ram_re    = read || read_p;


always @ (posedge clk) read_p <= read;

// TODO: there is a discrepancy between their functional model and Memory
//       usage guide (TN1250, Figure 3). The figure shows that data is ready
//       on the next clock cycle after the read signal is first asserted.
//       However, since they are using blocking assignment, this datum is 
//       not captured at posedge. Check with real hardware!

always @ (posedge clk) begin
	if (reset) begin
		rdata_o 	<= 0;
		rvalid_o	<= 1'b0;
	end else begin
		rvalid_o	<= 1'b0;
		if (read_p) begin
			rdata_o 	<= ram_rdata;
			rvalid_o	<= 1'b1;
		end
	end
end


assign rd_addr_inc = read;

always @ (posedge clk) begin
	if (reset) 				rd_addr	<= 0;
	else if (rd_addr_inc)	rd_addr <= rd_addr + 1;
end


//==============================================================================
// Used words

always @(posedge clk) begin
	if(reset) begin
		usedw_o <= 0;
	end else begin
		if (wr_addr_inc && !rd_addr_inc && !wfull_o) begin
			usedw_o	<= usedw_o + 1;
		end else if (!wr_addr_inc && rd_addr_inc ) begin
			usedw_o	<= usedw_o - 1;
		end
	end
end

assign wfull_o = usedw_o == {8{1'b1}};

//==============================================================================

genvar i;

generate
	for(i = 1; i < 5; i=i+1) begin
		SB_RAM256x16 ram256X16_0 (
			.RDATA 	( ram_rdata[(16*i-1) -: 16]	),
			.RADDR 	( ram_raddr		),
			.RCLK 	( clk 			),
			.RCLKE 	( 1'b1 			),
			.RE 	( ram_re		),
			.WADDR 	( ram_waddr		),
			.WCLK 	( clk 			),
			.WCLKE 	( 1'b1 			),
			.WDATA 	( ram_wdata[(16*i-1) -: 16] ),
			.WE 	( ram_we		),
			.MASK 	( 16'h0000 		)
		);
	end
endgenerate


endmodule
