// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

`include "ECS3_ClkDiv.v"
`include "ECS3_TX.v"
`include "ECS3_RX.v"

module ECS3_Transceiver(
        input         clk,          //input clock
        input         nRST,         //negative reset
        
        input         StartTX,      //Start transmission flag
        input  [15:0] TXData_In,    //Data to transmit
        output        TXSelect,     //TX selection Signal
        output        RXSelect,     //TX selection Signal
        output        TXBusy_Ready, //Transmitter Busy/Ready signal
        output        ECS3_Out,

        input         ECS3_In,
        output        RXBusy_Ready, //Transmitter Busy/Ready signal
        output [15:0] RXData_Out
        
    );

	wire clkTX, clkRX;
	
	ECS3_ClkDiv ECS3_ClkDiv (
        .clk(clk), 
        .nRST(nRST), 
        .clkTX(clkTX), 
        .clkRX(clkRX)
    );
	
	ECS3_TX ECS3_TX (
        .clk(clkTX), 
        .nRST(nRST), 
        .StartTX(StartTX), 
        .TXData_In(TXData_In), 
        .TXSelect(TXSelect), 
        .RXSelect(RXSelect), 
        .TXBusy_Ready(TXBusy_Ready), 
        .ECS3_Out(ECS3_Out)
    );
	 
	ECS3_RX ECS3_RX (
        .clk(clkRX), 
        .nRST(nRST), 
        .ECS3_In(ECS3_In), 
        .RXData_Out(RXData_Out), 
        .RXBusy_Ready(RXBusy_Ready)
    );

endmodule
