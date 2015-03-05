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

module cart_capture_tb;

bit		clk = 0;
bit		reset = 0;

wire	[15:0]	cart_ad;
wire			cart_rd;
wire			cart_alel;
wire			cart_aleh;

wire	[31:0] 	addr_o;
wire	[31:0]	data_o;
wire			valid_o;

typedef struct {
	bit [31:0] addr;
	bit [31:0] data;
} packet_t;

//=============================================================================
always #20 clk = !clk;

initial begin
	#100;
	reset = 1;
	#100;
	reset = 0; 
end

//=============================================================================
cart_comm_wform cart_comm_wform_inst ( .* );

cart_capture cart_capture ( .* );

//=============================================================================
// Driver
packet_t stim [$];

task driver_tx(packet_t pkt);
	cart_comm_wform_inst.single_read(pkt.addr, pkt.data);
	stim.push_front(pkt);
endtask

task driver();
	packet_t pkt;
	#(1us);

	pkt = '{32'h1000_0000, 32'h1240_0037};
	driver_tx(pkt);

	pkt = '{32'h1000_0000, 32'h1240_0037};
	driver_tx(pkt);

	pkt = '{32'h1000_0040, 32'hABCD_1234};
	driver_tx(pkt);

	pkt = '{32'h1000_0044, 32'hA5B9_0102};
	driver_tx(pkt);

	pkt = '{32'h1000_0048, 32'h7788_9900};
	driver_tx(pkt);

	for(int i = 0; i < 10; i++) begin
		pkt = '{$random(), $random()};
		driver_tx(pkt);
	end
endtask

//=============================================================================
// Monitor
packet_t resp [$];

always @ (posedge clk) begin
	if (valid_o) begin
		resp.push_front( '{addr_o, data_o} );
	end
end

//=============================================================================
// Checker
task check(output bit result);
	automatic int stim_size = stim.size();
	automatic int resp_size = resp.size();

	if (resp_size != stim_size ) begin
		$display("size mismatch");
		result = 0;
		return;
	end

	for(int i = 0; i < resp_size; i++) begin
		if ((resp[i].addr != stim[i].addr ) ||
			(resp[i].data != stim[i].data )) begin
		result = 0;
		$display("mismatch at element %d", i);
		return;
	end
	end

	result = 1;
endtask


//=============================================================================
initial begin
	bit result;
	$display(" ---------------------------------------------- "); 
	$display("          Cartridge capture tesetbench          ");
	$display(" ---------------------------------------------- ");

	driver();

	#(5us);

	check(result);

	$display("Done, result: %s", result ? "SUCCESS" : "FAIL");

	$stop();
end


endmodule
