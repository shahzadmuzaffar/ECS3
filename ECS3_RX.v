// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

`include "ECS3_Decoder.v"

module ECS3_RX(
        input         clk,             //input clock
        input         nRST,            //negative reset
        input         ECS3_In,         //Input line for reception
        output [15:0] RXData_Out,      //Inferred Received data
        output        RXBusy_Ready     //Receiver Busy/Ready signal
    );

	wire [3:0] delayThreshold;
	assign delayThreshold = (8);
	
	wire CnRST;
	reg [3:0] delayCount;
	reg [4:0] pulseCount;
	
	reg [2:0] Ind0_0;
	reg [2:0] Ind0_1;
	reg [2:0] Ind1_0; 
	reg [2:0] Ind1_1;
	reg [3:0] NOI0_0;
	reg [1:0] seg;
	reg Busy_Ready;
	reg clkStart;
	reg [15:0] RXData;
	wire [7:0] DecDataOut;
	wire Flag0,Flag1,Flag2,Flag3;
	wire [3:0] SS0,SS1,SS2,SS3;
	
	wire PulseStartEnd;
	wire ECS3_In_Pulse;
	reg PulseStart, PulseEnd;
	
	assign RXBusy_Ready = Busy_Ready;
	assign CnRST = ((~nRST) | ECS3_In_Pulse);
	assign PulseStartEnd = PulseStart^PulseEnd;
	
	assign Flag0 = NOI0_0[0];
	assign Flag1 = NOI0_0[1];
	assign Flag2 = NOI0_0[2];
	assign Flag3 = NOI0_0[3];
	assign SS0 = RXData[3:0]^{Flag0,Flag0,Flag0,Flag0};
	assign SS1 = RXData[7:4]^{Flag1,Flag1,Flag1,Flag1};
	assign SS2 = RXData[11:8]^{Flag2,Flag2,Flag2,Flag2};
	assign SS3 = RXData[15:12]^{Flag3,Flag3,Flag3,Flag3};
	assign RXData_Out = {SS3,SS2,SS1,SS0};
	
	ECS3_Decoder ECS3_Decoder (
        .ind0(Ind0_0), 
        .ind1(Ind0_1), 
        .ind2(Ind1_0), 
        .ind3(Ind1_1), 
        .data(DecDataOut)
    );
	 
	 LevelToPulse LevelToPulse (
        .clk(clk),
        .in(ECS3_In),
        .out(ECS3_In_Pulse)
    );

	/* Reception */
	
	/* State Machine Defines */
	parameter ECS3_RX_NOI        = 3'b000;
	parameter ECS3_RX_IND0       = 3'b001;
	parameter ECS3_RX_IND1       = 3'b010;
	parameter ECS3_RX_IND10      = 3'b011;
	parameter ECS3_RX_IND11      = 3'b100;

	reg [2:0] state;

	/* Single Wire Receiver Code, Please see the 
	 * diagrams for data flow on the line
	 */
	wire clkControlled;
	assign clkControlled = (clk & clkStart);
	
	always@(posedge clkControlled or posedge CnRST) begin
		if (CnRST) begin
			if (~nRST) begin
				state <= ECS3_RX_NOI;
				Busy_Ready <= 0;
				RXData <= 0;
				delayCount <= 0;
				pulseCount <= 0;
				Ind0_0 <= 0;
				Ind0_1 <= 0;
				Ind1_0 <= 0;
				Ind1_1 <= 0;
				seg <= 0;
				PulseStart <= 0;
				clkStart <= 0;
			end
			else if (ECS3_In_Pulse && (~PulseStartEnd)) begin
				delayCount <= 0;
				pulseCount <= pulseCount + 1;
				Busy_Ready <= 1;
				PulseStart <= ~PulseStart;
				clkStart <= 1;
			end
		end
		else begin
			
			if (delayCount == delayThreshold) begin
				// ------------------------------------------
				case (state)
					ECS3_RX_NOI : begin
						NOI0_0 <= pulseCount - 1;
						if(pulseCount == 1)
							state <= ECS3_RX_NOI; // When No index at all for 1st segment
						else if(pulseCount[1])
							state <= ECS3_RX_IND0;
						else begin
							state <= ECS3_RX_IND10; // if not 0 and 1st part is zero, then only second SS indices would be here
						end
							
						if(seg == 0) begin
							seg <= 1;
						end
						else if(seg == 1) begin
							RXData[7:0] <= DecDataOut;
							seg <= 2;
						end
						else if(seg == 2) begin
							RXData[15:8] <= DecDataOut;
							seg <= 0;
							Busy_Ready <= 0;
							clkStart <= 0;
						end
						Ind0_0 <= 0;
						Ind0_1 <= 0;
						Ind1_0 <= 0;
						Ind1_1 <= 0;
					end
					ECS3_RX_IND0 : begin
						Ind0_0 <= pulseCount;
						if(NOI0_0[1]) 					// Checking again 1st bit cos now it has decremented version of pulseCount
							state <= ECS3_RX_IND1;
						else if (NOI0_0[2] | NOI0_0[3])
							state <= ECS3_RX_IND10;     // If no 2nd index of part 1 and second part is not zero, 2nd part have some indexes
						else
							state <= ECS3_RX_NOI;      // If no index of part 2
					end
					ECS3_RX_IND1 : begin
						Ind0_1 <= pulseCount;
						if(NOI0_0[3] | NOI0_0[2])
							state <= ECS3_RX_IND10;
						else
							state <= ECS3_RX_NOI;     // When No index at all for 2nd segment
					end
					ECS3_RX_IND10 : begin
						Ind1_0 <= pulseCount;
						if(NOI0_0[3])
							state <= ECS3_RX_IND11;
						else
							state <= ECS3_RX_NOI;    // when 2nd index wont come
					end
					ECS3_RX_IND11 : begin
						Ind1_1 <= pulseCount;
						state <= ECS3_RX_NOI;        // When all  four indices are arrived
					end
					default : begin  // Fault Recovery
						state <= ECS3_RX_NOI;
					end
				endcase
				// ------------------------------------------
				delayCount <= delayCount + 1;
			end
			else if (delayCount == (delayThreshold + 1)) begin
				pulseCount <= 0;
			end
			else begin
				if (delayCount < 15)
					delayCount <= delayCount + 1;
			end
		
		end
	end

	always@(negedge ECS3_In_Pulse or negedge nRST) begin
		if (~nRST) begin
			PulseEnd <= 0;
		end
		else begin
			PulseEnd <= ~PulseEnd;
		end
	end

endmodule

module LevelToPulse(clk,in,out);
	input clk;
	input in;
	output out;
	reg r1,r2;
	
	always @ (posedge clk)
	begin
		r1 <= in; // first reg in synchronizer
		r2 <= r1; // second reg in synchronizer, output is in sync!
	end
	
	// rising edge = old value is 0, new value is 1
	assign out = ~r2 & r1;
endmodule
