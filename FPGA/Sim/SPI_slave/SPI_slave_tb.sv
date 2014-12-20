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

module SPI_slave_tb;

bit		clk = 0;
bit		reset = 1;

wire MISO, SCLK, CS_n;

logic 			data_valid;
logic [31:0] 	data_in;


//=============================================================================
always #16 clk = !clk;

initial begin
	reset 	<= 1;
	#200;
	@(posedge clk);
	reset	<= 0;
end

//=============================================================================
SPI_master SPI_master_inst ( .* );

SPI_slave  SPI_slave_inst  ( .* );


//=============================================================================
logic [31:0] q_sent [$];

task send_data (input [31:0] data);
	@(posedge clk);
		data_valid	<= 1;
		data_in		<= data;
		q_sent.push_back( data );
		
	@(posedge clk);
		data_valid	<= 0;
		data_in		<= 'X;
		
	
endtask

task verify_data ();
	while ( q_sent.size() ) begin
		logic [31:0] sent, recv;
		
		sent = q_sent.pop_front();
		recv = SPI_master_inst.q_recv.pop_front();
		
		if ( sent == recv )
			$display("OK: %x == %x", sent, recv );
		else begin
			$display("Error: %x == %x", sent, recv );
			$stop();
		end
	end

endtask

//=============================================================================
initial begin
	$display(" SPI slave module test ");
	
	repeat (10) begin
		#10us;
		send_data( $random() );
		SPI_master_inst.start_read();
	end
	
	$display("%t End of transactions", $time());
	
	verify_data();
	
	$display("%t Data sucessfully verified", $time());
	
	$stop();
end



endmodule

