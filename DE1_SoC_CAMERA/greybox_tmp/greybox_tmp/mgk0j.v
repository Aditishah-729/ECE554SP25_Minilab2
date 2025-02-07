//altshift_taps CBX_SINGLE_OUTPUT_FILE="ON" INTENDED_DEVICE_FAMILY=""Cyclone V"" LPM_HINT="RAM_BLOCK_TYPE=MLAB" LPM_TYPE="altshift_taps" NUMBER_OF_TAPS=3 TAP_DISTANCE=0 WIDTH=12 clock shiftin shiftout taps
//VERSION_BEGIN 23.1 cbx_mgl 2023:11:29:19:36:47:SC cbx_stratixii 2023:11:29:19:36:39:SC cbx_util_mgl 2023:11:29:19:36:39:SC  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2023  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details, at
//  https://fpgasoftware.intel.com/eula.



//synthesis_resources = altshift_taps 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgk0j
	( 
	clock,
	shiftin,
	shiftout,
	taps) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   [11:0]  shiftin;
	output   [11:0]  shiftout;
	output   [35:0]  taps;

	wire  [11:0]   wire_mgl_prim1_shiftout;
	wire  [35:0]   wire_mgl_prim1_taps;

	altshift_taps   mgl_prim1
	( 
	.clock(clock),
	.shiftin(shiftin),
	.shiftout(wire_mgl_prim1_shiftout),
	.taps(wire_mgl_prim1_taps)
	// synopsys translate_off
	,
	.sclr(1'b0)
	// synopsys translate_on
	);
	defparam
		mgl_prim1.intended_device_family = ""Cyclone V"",
		mgl_prim1.lpm_type = "altshift_taps",
		mgl_prim1.number_of_taps = 3,
		mgl_prim1.tap_distance = 0,
		mgl_prim1.width = 12,
		mgl_prim1.lpm_hint = "RAM_BLOCK_TYPE=MLAB";
	assign
		shiftout = wire_mgl_prim1_shiftout,
		taps = wire_mgl_prim1_taps;
endmodule //mgk0j
//VALID FILE
