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

module N64_recv_tb;

bit		clk = 0;
bit		reset = 0;

bit go = 0;
//wire		din;

wire [31:0] 	data_out;
wire		data_valid;

bit A, B, R, L, Z, START;
bit yellow_UP, yellow_DOWN, yellow_LEFT, yellow_RIGHT;
bit gray_UP, gray_DOWN, gray_LEFT, gray_RIGHT;
bit [7:0] joystick_X, joystick_Y;
tri1 data;

//assign din = out;

//=============================================================================
always #16 clk = !clk;

//=============================================================================
N64_controller N64_controller_inst ( .out (data), .* );
N64_recv DUT ( .din(data),  .* );

//=============================================================================
initial begin
	$display(" N64 recv module test ");

	fork
	begin
		#100;
		reset = 1;
		#100;
		reset = 0;

		#(1ms);
		A = 1;

		#(1ms);
		B = 1;
/*
		#(1ms);
		R = 1;

		#(1ms);
		L = 1;*/
	end
	begin
		repeat (3) begin
			@(posedge clk)
				go	<= 1;
			@(posedge clk)
				go	<= 0;
				
			#(1ms);
		end
	end
	join
	
	$stop();
end


endmodule
