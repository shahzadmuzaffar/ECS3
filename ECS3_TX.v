// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

`include "ECS3_Encoder.v"

module ECS3_TX(
        input         clk,               //input clock
        input         nRST,              //negative reset
        input         StartTX,           //Start transmission flag
        input  [15:0] TXData_In,         //Data to transmit
        output        TXSelect,          //TX selection Signal
        output        RXSelect,          //TX selection Signal
        output        TXBusy_Ready,      //Transmitter Busy/Ready signal
        output        ECS3_Out          //Output line to send
    );


	 /* Defines */
	 wire [2:0] TagDelay;
	 assign TagDelay = (1);

	 /* variables */

	 wire ECS3_TRX_Clock;
	 reg [3:0] TXData;
	 reg ECS3_TX_EN;
	 reg ECS3_RX_EN;
	 wire ECS3_Active_Stop;
	 reg Busy_Ready;
	 
	 assign ECS3_Out = (ECS3_TRX_Clock & ECS3_Active_Stop);
	 assign TXSelect = ECS3_TX_EN;
	 assign RXSelect = ECS3_RX_EN;
	 assign TXBusy_Ready = Busy_Ready;

	 /* ------------------------------------------- */

	 assign ECS3_TRX_Clock = clk;
	 
    // ==================================================================================================
    // ========================== Sends No of Pulses ====================================================
	/* This block is used to prevent the generation of an extra pulse at end due to race condition 
	 * due to Rep_Start_255 signal which will be changed with a little delay as compared to rising 
	 * edge of clock. 
	 */
	 wire StartPulses;
	 reg sendPulses;
	 reg pulsesSent;
	 reg [7:0] sentPulsesCount;
	 reg [4:0] noOfPulses;
	 reg isThisDelay;
	 
	assign StartPulses = (sendPulses ^ pulsesSent);
	
   always@(posedge ECS3_TRX_Clock or negedge nRST)
	begin
      if (~nRST) begin
			sentPulsesCount <= 1;
			pulsesSent <= 0;
		end
      else begin
			if(StartPulses == 1) begin
				if (noOfPulses == sentPulsesCount) begin
					sentPulsesCount <= 1;
					pulsesSent <= ~pulsesSent;
				end
				else begin
					sentPulsesCount <= sentPulsesCount + 1;
				end
			end
		end
	end
    // ==================================================================================================

    // ==================== Output -ve Edge Flipflop ====================================================
    assign ECS3_Active_Stop = (StartPulses & (~isThisDelay));
    // ==================================================================================================

    // ==================================== Encoder =====================================================
    wire [1:0] NOI;
    wire [2:0] Ind0;
    wire [2:0] Ind1;
    wire Flag;

    ECS3_Encoder ECS3_Encoder (
        .A(TXData[3]), 
        .B(TXData[2]), 
        .C(TXData[1]), 
        .D(TXData[0]), 
        .NOI(NOI), 
        .Ind0(Ind0), 
        .Ind1(Ind1), 
        .Flag(Flag)
    );
    // ==================================================================================================

        reg [2:0] Ind0_0; 
        reg [2:0] Ind1_0;
        reg [1:0] NOI0_0;
        reg [3:0] CFlags;
        reg [2:0] Iteration;
        reg flagsSent;
        reg seg;
        
        /* State Machine Defines */
        parameter ECS3_TRX_IDLE0       = 3'b000;
        parameter ECS3_TRX_IDLE        = 3'b001;
        parameter ECS3_TRX_SELECT      = 3'b010;
        parameter ECS3_TRX_PULSES      = 3'b011;
        parameter ECS3_TRX_FLAGS       = 3'b100;
        parameter ECS3_TRX_DELAY       = 3'b101;

        reg [2:0] state;

        /* Single Wire Transmit Code, Please see the 
        * diagrams for data flow on the line
        */
        always@(posedge ECS3_TRX_Clock or negedge nRST)
            if (~nRST) begin
                state <= ECS3_TRX_IDLE0;
                Busy_Ready <= 0;
                ECS3_TX_EN <= 0;
                ECS3_RX_EN <= 1;
                sendPulses <= 0;
                noOfPulses <= 0;
                isThisDelay <= 0;
                TXData <= 0;
                Ind0_0 <= 0; 
                Ind1_0 <= 0; 
                CFlags <= 0;
                Iteration <= 0;
                flagsSent <= 0;
                seg <= 0;
            end else
                case (state)
                    ECS3_TRX_IDLE0 : begin
                        if(StartTX == 1) begin
                            ECS3_RX_EN <= 0;
                            flagsSent <= 0;
                            Busy_Ready <= 1;
                            TXData <= TXData_In[3:0];
                            state <= ECS3_TRX_IDLE;
                        end
                        else begin
                            ECS3_RX_EN <= 1;
                            ECS3_TX_EN <= 0;
                            Busy_Ready <= 0;
                            state <= ECS3_TRX_IDLE0;
                        end
                    end
                    ECS3_TRX_IDLE : begin
                        ECS3_TX_EN <= 1;
                        NOI0_0 <= NOI;
                        Ind0_0 <= Ind0; 
                        Ind1_0 <= Ind1; 
                        CFlags[0] <= Flag;
                        TXData <= TXData_In[7:4];
                        state <= ECS3_TRX_SELECT;
                    end
                    
                    /* NOIs */
                    ECS3_TRX_SELECT : begin
                        if(Iteration == 0) begin
                            noOfPulses <= {NOI,NOI0_0}+1; // 2nd Seg NOI
                            sendPulses <= (~sendPulses);
                            
                            if(seg == 0)
                                CFlags[1] <= Flag;
                            else
                                CFlags[3] <= Flag;
                            
                            state <= ECS3_TRX_PULSES;
                        end else if(Iteration == 1 && (NOI0_0[0] | NOI0_0[1])) begin
                            noOfPulses <= Ind0_0;
                            sendPulses <= (~sendPulses);
                            state <= ECS3_TRX_PULSES;
                        end else if(Iteration == 2 && NOI0_0[1] == 1) begin
                            noOfPulses <= Ind1_0;
                            sendPulses <= (~sendPulses);
                            state <= ECS3_TRX_PULSES;
                        end else if(Iteration == 3 && (NOI[0] | NOI[1])) begin
                            noOfPulses <= Ind0;
                            sendPulses <= (~sendPulses);
                            state <= ECS3_TRX_PULSES;
                        end else if(Iteration == 4) begin
                            if(NOI[1] == 1) begin
                                noOfPulses <= Ind1;
                                sendPulses <= (~sendPulses);
                                state <= ECS3_TRX_PULSES;
                            end
                            TXData <= TXData_In[11:8];
                        end else if(Iteration == 5) begin
                            if(seg == 0) begin
                                NOI0_0 <= NOI;
                                Ind0_0 <= Ind0; 
                                Ind1_0 <= Ind1; 
                                CFlags[2] <= Flag;
                                TXData <= TXData_In[15:12];
                                seg <= 1;
                            end else begin
                                seg <= 0;
                                state <= ECS3_TRX_FLAGS;
                            end
                        end else begin
                            state <= ECS3_TRX_SELECT;
                        end
                        
                        if(Iteration == 5)
                            Iteration <= 0;
                        else
                            Iteration <= Iteration + 1;
                    end

                    /* CFlags */
                    ECS3_TRX_FLAGS : begin
                        sendPulses <= (~sendPulses);
                        noOfPulses <= CFlags+1;
                        flagsSent <= 1;
                        state <= ECS3_TRX_PULSES;
                    end

                    /* Delay */
                    ECS3_TRX_PULSES : begin					
                        if (StartPulses == 0) begin
                                sendPulses <= (~sendPulses);
                                noOfPulses <= TagDelay; // instead of 4, as 2 pulse are wasted in transition to this state - For delay, this much are wasred
                                isThisDelay <= 1;
                                state <= ECS3_TRX_DELAY;
                        end else begin
                            state <= ECS3_TRX_PULSES;
                        end
                    end
                            
                    /* Delay */
                    ECS3_TRX_DELAY : begin					
                        if (StartPulses == 0) begin
                            isThisDelay <= 0;
                            if(flagsSent == 0) begin
                                state <= ECS3_TRX_SELECT;
                            end else begin
                                flagsSent <= 0;
                                ECS3_TX_EN <= 0;
                                state <= ECS3_TRX_IDLE0;
                            end
                        end else begin
                            state <= ECS3_TRX_DELAY;
                        end
                    end

                    default : begin  // Fault Recovery
                        state <= ECS3_TRX_IDLE0;
                    end
                endcase

endmodule
