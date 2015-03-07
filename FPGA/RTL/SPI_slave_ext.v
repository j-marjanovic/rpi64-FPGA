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
//           --\ /-------\./-------\./-------\./-------\./---
//   MxSx       X   D7    X   D6    X   D5    X    D4   X
//           --/ \-------/ \-------/ \-------/ \-------/ \---
//
//
// Protocol:
//   Master send command (1 byte) and continues to send clock. Slave
//   will repsond with data. 
//  
//                 76543210
//         ------\ /-------\ /---------------\
//   MOSI         x   CMD   x   0s            X
//         ------/ \-------/ \---------------/
//
//         ------\ /-------\ /---------------\
//   MISO         x   0s   x   RESP           X
//         ------/ \-------/ \---------------/
//
//
// Commands:
//   
//   0x00 - read from controllers (total of 1 + 4*4 bytes)
//   0x80 - read number or packets in FIFO (1 byte)
//   0x40 - read word from FIFO (8 bytes)
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module SPI_slave_ext (
	input			clk,	
	input			reset,

	input			SCLK,
	input			MOSI,
	output 			MISO,
	input			CS_n,

	// controllers	
	input	[3:0]	ctrl_present,
	input	[127:0]	ctrl_data,

	// FIFO
	input	[63:0]	rdata_i,
	output reg		read_o,
	input 			rvalid_i,
	input	[7:0]	usedw_i
);


localparam MAX_LEN = 8*(1 + 4*4);

localparam [7:0] 	CMD_CTRLS	= 8'h00,
					CMD_RWRDS	= 8'h80,
					CMD_READ	= 8'h40;

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

wire  MISO_wire;
assign MISO = (CS_n == 1'b1) ? 1'bz : MISO_wire;

//=============================================================================
// Bit counter
wire load_tx_reg;
reg [3:0] bit_cntr;

always @ (posedge clk) begin
	if (reset) begin
		bit_cntr	<= 0;
	end else begin

		if (CS_n_ss)						
			bit_cntr	<= 0;

		else if (!CS_n_ss && SCLK_negedge && bit_cntr < 8)	
			bit_cntr	<= bit_cntr + 1;

	end
end

assign load_tx_reg = (!CS_n_ss && SCLK_negedge) && (bit_cntr == 7);

//=============================================================================
// Command reception


reg [7:0] command;

always @ (posedge clk) begin
	if (!CS_n_ss && SCLK_posedge && bit_cntr < 8)
		command <= {command[6:0], MOSI};
end


//=============================================================================
// State machine

reg [MAX_LEN-1:0] tx_tmp_reg;
assign MISO_wire = tx_tmp_reg[MAX_LEN-1];

localparam [7:0]	S_TX_IDLE	= 8'b0000_0001,
					S_TX_CMD	= 8'b0000_0010,
					S_TX_DATA	= 8'b0000_0100;

reg [7:0] state_tx;

// Selection of the data to be sent to SPI
task select_tx(input [7:0] cmd);
begin
	read_o	<= 1'b0;

	//---------------------------------------------------------------
	if (load_tx_reg && (cmd == CMD_CTRLS)) begin
		tx_tmp_reg <= {4'd0, ctrl_present, ctrl_data};
	//---------------------------------------------------------------
	end else if (load_tx_reg && (cmd == CMD_RWRDS)) begin
		tx_tmp_reg <= {usedw_i, {(MAX_LEN-8){1'b1}} };
	//---------------------------------------------------------------
	end else if (cmd == CMD_READ) begin
		if (load_tx_reg)	
			read_o		<= 1'b1;	
		if (rvalid_i)		
			tx_tmp_reg	<= {rdata_i, {(MAX_LEN-64){1'b1}} };
	end
	//---------------------------------------------------------------		
end	
endtask


always @ (posedge clk) begin
	if (reset) begin
		state_tx	<= S_TX_IDLE;
		//MISO_reg	<= 1'b0;
	end else begin
		select_tx(command);

		case (state_tx)
		//---------------------------------------------------------------------
		S_TX_IDLE: begin
			if (CS_n_negedge) 		state_tx	<= S_TX_CMD;
		end
		//---------------------------------------------------------------------
		S_TX_CMD: begin
			if (CS_n_ss)			state_tx	<= S_TX_IDLE;						
			else if (SCLK_negedge 
				&& (bit_cntr == 7))	state_tx	<= S_TX_DATA;
		end
		//---------------------------------------------------------------------
		S_TX_DATA: begin
			if (CS_n_ss)			state_tx	<= S_TX_IDLE;		
			else if(SCLK_negedge) begin
				//MISO_reg	<= tx_tmp_reg[MAX_LEN-1];
				tx_tmp_reg	<= {tx_tmp_reg[MAX_LEN-2:0], 1'b0};
			end				
		end
		//---------------------------------------------------------------------
		endcase
	end
end

endmodule
