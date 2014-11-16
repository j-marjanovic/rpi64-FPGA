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

module N64_controller 
(
	input A, B, R, L, Z, START,
	input yellow_UP, yellow_DOWN, yellow_LEFT, yellow_RIGHT,
	input gray_UP, gray_DOWN, gray_LEFT, gray_RIGHT,
	input [7:0] joystick_X, joystick_Y,
	wire out
);


logic out_reg;
assign out = out_reg;

task out_0();
	out_reg	= 1'b1;
	#800;
	out_reg	= 1'b0;
	#3_200;
endtask

task out_1();
	out_reg	= 1'b1;
	#2_500;
	out_reg	= 1'b0;
	#1_500;
endtask



initial begin
	out_reg	<= 1'b1;

	forever begin
		$display("dasd");

		#40_000_000;

		out_reg	<= 1'b0;
		#4_000;

		// Header
		for ( int i = 0; i < 7; i++) begin
			out_0();
		end
		out_1();
		out_1();

		// A, B, Z, START
		if( A )		out_1(); else out_0();
		if( B )		out_1(); else out_0();
		if( Z )		out_1(); else out_0();
		if( START )	out_1(); else out_0();

		// Gray
		if( gray_UP )		out_1(); else out_0();
		if( gray_DOWN )		out_1(); else out_0();
		if( gray_LEFT )		out_1(); else out_0();
		if( gray_RIGHT )	out_1(); else out_0();

		// Two ?
		out_0();
		out_0();

		// L, R
		if( L )		out_1(); else out_0();
		if( R )		out_1(); else out_0();

		// Yellow
		if( yellow_UP )		out_1(); else out_0();
		if( yellow_DOWN )	out_1(); else out_0();
		if( yellow_LEFT )	out_1(); else out_0();
		if( yellow_RIGHT )	out_1(); else out_0();

		// Joystick X
		for ( int i = 7; i >= 0; i--) begin
			if( joystick_X[i] )	out_1(); else out_0();
		end

		// Joystick Y
		for ( int i = 7; i >= 0; i--) begin
			if( joystick_Y[i] )	out_1(); else out_0();
		end

		out_reg	<= 1'b1;
	end
end


endmodule

