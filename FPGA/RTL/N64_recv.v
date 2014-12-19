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

module N64_recv(
	input			clk,	
	input			reset,
	input			din,

	output reg [31:0] 	data_out,
	output reg		data_valid
);


localparam 	S_IDLE = 0,
			S_HEAD = 1,
			S_RECV = 2;

reg [4:0] 	state;
reg [5:0] 	bit_cntr;

reg [4:0]	pulse_cntr;
reg			count;

reg din_prev;

always @ (posedge clk)
	if (reset) begin
		state	<= S_IDLE;
	end else begin

		data_valid	<= 0;
		din_prev	<= din;

		case (state)
		//=================================================
		S_IDLE: begin
			if ( din_prev && !din ) begin
				state		<= S_HEAD;
				bit_cntr	<= 0;
			end
		end
		//=================================================
		S_HEAD: begin
			if (din_prev && !din) begin
				bit_cntr<= bit_cntr + 1;
				if (bit_cntr == 8)	state	<= S_RECV;			
			end
		end
		//=================================================
		S_RECV: begin
			if (!din_prev && din) begin
				count		<= 1;
				pulse_cntr	<= 0;
			end

			if (count) begin
				if(pulse_cntr == 10) begin
					count		<= 0;
					data_out	<= {din, data_out[31:1]}; // LSB first
					if (bit_cntr == 40) begin
						state		<= S_IDLE;
						data_valid	<= 1;
					end else begin
						bit_cntr 	<= bit_cntr + 1;
					end
				end else begin
					pulse_cntr	<= pulse_cntr + 1;
				end
			end
		end
		//=================================================
		endcase
	end
endmodule
