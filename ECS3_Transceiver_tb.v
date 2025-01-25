`timescale 1ns / 1ps
`include "ECS3_Transceiver.v"

module ECS3_Transceiver_tb;

	// Inputs
	reg clk_1, clk_2;
	reg nRST;
	reg        StartTX_1;
	reg [15:0] TXData_In_1;

    reg        StartTX_2;
	reg [15:0] TXData_In_2;

	// Outputs
	wire        TXSelect_1;
	wire        RXSelect_1;
	wire        TXBusy_Ready_1;
	wire        RXBusy_Ready_1;
	wire        ECS3_Out_1;
    wire        ECS3_In_1;
	wire [15:0] RXData_Out_1;

    wire        TXSelect_2;
	wire        RXSelect_2;
	wire        TXBusy_Ready_2;
	wire        RXBusy_Ready_2;
	wire        ECS3_Out_2;
    wire        ECS3_In_2;
	wire [15:0] RXData_Out_2;

	// Transceiver 1
	ECS3_Transceiver dut_1 (
		.clk          (clk_1),
		.nRST         (nRST),

		.StartTX      (StartTX_1),
		.TXData_In    (TXData_In_1),
        .TXSelect     (TXSelect_1),
		.RXSelect     (RXSelect_1),
        .TXBusy_Ready (TXBusy_Ready_1),
        .ECS3_Out     (ECS3_Out_1),

        .ECS3_In      (ECS3_In_1),
		.RXBusy_Ready (RXBusy_Ready_1),
		.RXData_Out   (RXData_Out_1)
		
	);

    // Transceiver 2
    ECS3_Transceiver dut_2 (
		.clk          (clk_2),
		.nRST         (nRST),
        
		.StartTX      (StartTX_2),
		.TXData_In    (TXData_In_2),
        .TXSelect     (TXSelect_2),
		.RXSelect     (RXSelect_2),
        .TXBusy_Ready (TXBusy_Ready_2),
        .ECS3_Out     (ECS3_Out_2),

        .ECS3_In      (ECS3_In_2),
		.RXBusy_Ready (RXBusy_Ready_2),
		.RXData_Out   (RXData_Out_2)
		
	);

    // Phy/Tristate logic for simulation - to connect both transceivers to create a full chain
    pulldown pulldown_ECS3Wire (ECS3Wire);
    assign ECS3Wire  = TXSelect_1 ? ECS3_Out_1 : 1'bz;
    assign ECS3_In_1 = RXSelect_1 ? ECS3Wire   : 1'b0;
    assign ECS3Wire  = TXSelect_2 ? ECS3_Out_2 : 1'bz;
    assign ECS3_In_2 = RXSelect_2 ? ECS3Wire   : 1'b0;
	
    // Clocks
	always
		#5 clk_1 <= ~clk_1;   // 100 MHz

    always
		#3.7 clk_2 <= ~clk_2; // 135 MHz

	initial begin
        $dumpfile("ECS3_Transceiver_sim.vcd");
        $dumpvars;

		// Initialize Inputs
		clk_1       = 0;
        clk_2       = 0;
		nRST        = 1;
		StartTX_1   = 0;
		TXData_In_1 = 0;
        StartTX_2   = 0;
		TXData_In_2 = 0;

		// Wait 100 ns for global reset to finish
		#20;
		nRST = 0;
		#20;
		
		#20;
		nRST = 1;
		#20;
		
		// Transceiver 1 -> Transceiver 2
		TXData_In_1 <= 16'h0505;
		StartTX_1 = 1;
		#40;
		StartTX_1 = 0;
		
		#2000;
		
		// Transceiver 2 -> Transceiver 1
		TXData_In_2 <= 16'h0202;
		StartTX_2 = 1;
		#40;
		StartTX_2 = 0;
		
		#4000;

        $finish;
	end
      
endmodule

