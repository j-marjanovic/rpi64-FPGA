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

module SPI_master # (
	parameter time 	SCLK_PERIOD = 1us
) (
	output 	reg		SCLK,
	input 			MISO,
	output	reg		CS_n

);


logic [31:0] q_recv [$];


initial begin
	CS_n = 1;
	SCLK = 0;
end


task start_read();
	logic [31:0] tmp;
	
	CS_n <= 0;
	#(SCLK_PERIOD);
	
	for(int i = 0; i < 32; i++) begin
		
		SCLK <= 1;
		tmp	<= {MISO, tmp[31:1]};
		#(SCLK_PERIOD/2);
		
		SCLK <= 0;
		#(SCLK_PERIOD/2);
	end

	CS_n <= 1;
	//$display("tmp: %x\n", tmp);
	q_recv.push_back( tmp );

endtask


endmodule