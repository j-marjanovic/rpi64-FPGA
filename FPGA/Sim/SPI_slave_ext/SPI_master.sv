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
//                                                                           //
//  SPI master BFM                                                           //
//  version 1.1                                                              //
//                                                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps

module SPI_master # (
	parameter time 	SCLK_PERIOD = 1us
) (
	output 	reg		SCLK,
	input 			MISO,
	output	reg		MOSI,
	output	reg		CS_n
);


logic [31:0] q_recv [$];


initial begin
	CS_n = 1;
	SCLK = 0;
	MOSI = 0;
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

//=============================================================================
task start_transfer(
	input bit [7:0] 	tx_data [],
	output bit [7:0] 	rx_data []
);

	rx_data = new[tx_data.size()];

	// Transfer
	CS_n = 0;
	#(SCLK_PERIOD);
	MOSI = tx_data[0][7];

	for(int i = 0; i < rx_data.size(); i++) begin
		for(int j = 0; j < 8; j++) begin
			
			rx_data[i][7-j] = MISO;

			SCLK 	= 1;
			#(SCLK_PERIOD/2);

			if(6-j >= 0)	
				MOSI = tx_data[i][6-j];
			else if (i < rx_data.size()) 
				MOSI = tx_data[i+1][7];
			
			SCLK	= 0;
			#(SCLK_PERIOD/2);
		end
	end
	#1;

	// End of transfer
	#(SCLK_PERIOD);
	CS_n = 1;

endtask

endmodule