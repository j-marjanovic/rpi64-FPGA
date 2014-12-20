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

module N64_recv #(
	parameter CLK_FREQ	= 30_000_000
)(
	input				clk,	
	input				reset,
	
	input				go,
	inout				din,

	output reg [31:0] 	data_out,
	output reg			data_valid
);


localparam 	S_IDLE = 0,
			S_REQ0 = 1,
			S_REQ1 = 2,
			S_REQS = 3,
			S_RECV = 4;

reg [4:0] 	state;
reg [5:0] 	bit_cntr;

reg [9:0]	pulse_cntr;
reg			count;

reg 		dout;
assign din = (state == S_REQ0 || state == S_REQ1 || state == S_REQS) ?  dout : 1'bz;

reg din_prev;

localparam PULSE_0_DELAY		= 30 * (CLK_FREQ/10_000_000); // 3.0us 
localparam PULSE_1_DELAY		= 10 * (CLK_FREQ/10_000_000); // 1.0us 
localparam PULSE_STOP_TIME		= 30 * (CLK_FREQ/10_000_000); // 3.0us 
localparam PULSE_FULL_TIME		= 40 * (CLK_FREQ/10_000_000); // 4.0us 

localparam PULSE_SAMPLE_DELAY 	= 20 * (CLK_FREQ/10_000_000); // 2.0us

always @ (posedge clk)
	if (reset) begin
		state	<= S_IDLE;
		
	end else begin

		data_valid	<= 0;
		din_prev	<= din;

		case (state)
		//=================================================
		S_IDLE: begin
			if ( go ) begin
				state		<= S_REQ0;
				bit_cntr	<= 0;
				pulse_cntr	<= 0;	
				dout		<= 1'b0;
			end
		end
		//=================================================
		S_REQ0: begin
			pulse_cntr	<= pulse_cntr + 1;
			
			if (pulse_cntr == PULSE_0_DELAY) begin
				dout		<= 	1'b1;						
			end else if (pulse_cntr == PULSE_FULL_TIME) begin
				dout		<= 	1'b0;	
				pulse_cntr	<= 0;
				bit_cntr	<= bit_cntr + 1;
				if (bit_cntr == 6)	begin
					state		<= S_REQ1;	
					bit_cntr 	<= 0;
				end
			end	
		end
		//=================================================
		S_REQ1: begin
			pulse_cntr	<= pulse_cntr + 1;
			
			if (pulse_cntr == PULSE_1_DELAY) begin
				dout		<= 	1'b1;						
			end else if (pulse_cntr == PULSE_FULL_TIME) begin
				dout		<= 1'b0;	
				pulse_cntr	<= 0;
				state		<= S_REQS;	
				bit_cntr 	<= 0;	
			end	
		end
		//=================================================
		S_REQS: begin
			pulse_cntr	<= pulse_cntr + 1;
			
			if (pulse_cntr == PULSE_1_DELAY) begin
				dout		<= 	1'b1;						
			end else if (pulse_cntr == PULSE_STOP_TIME) begin
				dout		<= 1'b0;	
				pulse_cntr	<= 0;
				state		<= S_RECV;	
				bit_cntr 	<= 0;	
			end	
		end
		//=================================================
		S_RECV: begin
			if (din_prev && !din) begin
				count		<= 1;
				pulse_cntr	<= 0;
			end

			if (count) begin
				if(pulse_cntr == PULSE_SAMPLE_DELAY) begin
					count		<= 0;
					data_out	<= {din, data_out[31:1]}; // LSB first
					if (bit_cntr == 31) begin
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
