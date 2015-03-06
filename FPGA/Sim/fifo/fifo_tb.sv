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

module fifo_tb;

localparam time Tclk = 40ns;


bit				clk;	
bit				reset;

bit	[63:0]		wdata_i = 0;
bit				wvalid_i = 0;
wire			wfull_o;

wire	[63:0]	rdata_o;
bit				read_i;
wire 			rvalid_o;
wire	[7:0]	usedw_o;

//==============================================================================
always #(Tclk/2) clk = !clk;

initial begin
	#100;
	reset = 1;
	#100;
	reset = 0; 
end


//==============================================================================

fifo DUT ( .* );

//==============================================================================
logic [63:0] stim [$];
logic [63:0] resp [$];

task write (input [63:0] data);
	@ (posedge clk) begin
		wdata_i		<= data;
		wvalid_i	<= 1;
		if(!wfull_o) stim.push_back(data);
	end

	repeat(2)
		@ (posedge clk) begin
			wdata_i		<= 0;
			wvalid_i	<= 0;
		end
endtask


task read (); // (output [63:0] data);
	@ (posedge clk) begin
		read_i	<= 1;
	end

	fork 
	begin
		@ (posedge clk) 		read_i	<= 0;
		
	end
	begin
		repeat(3) begin
			@ (posedge clk) begin
				if (rvalid_o) resp.push_back(rdata_o);
			end
		end
	end
	join

endtask


task check ();
	automatic int stim_len = stim.size();
	automatic int resp_len = resp.size();
	$display(" Report: ");
	$display("   stim len: %d, resp len: %d", stim_len, resp_len);

	if( stim_len != resp_len) begin
		$display("   ERROR: response size does not match stimuli size");
		return;
	end

	for(int i = 0; i < resp_len; i++) begin
		if(stim[i] != resp[i]) begin
			$display("   ERROR: at %d, %x != %x", i, stim[i], resp[i]);
			return;
		end
	end

	$display("");
	$display("   DONE: everything OK!");
	$display("");
endtask


//==============================================================================
initial begin
	$display(" ---------------------------------------------- "); 
	$display("                FIFO tesetbench                 ");
	$display(" ---------------------------------------------- ");

	// Wait for reset
	#(500ns);


	// Read from empty
	read();

	write({$random(), $random()});
	write({$random(), $random()});
	write({$random(), $random()});


	read();
	read();
	read();

	for(int i = 0; i < 300; i++)
		write({$random(), $random()});


	fork 
		begin
			for(int i = 0; i < 300; i++)
				if($random() < 1000) 	
					write({$random(), $random()});
				else					
					#(2*Tclk);
		end
		begin
			for(int i = 0; i < 500; i++)
				read();
		end
	join


	check();
	#(1us);
	$stop();
end


endmodule
