// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

module ECS3_ClkDiv(
        input  clk,
        input  nRST,
        output clkTX,
        output clkRX
    );

	reg [1:0] ClockDiv;
	reg slowClock;

	 always @ (posedge clk or negedge nRST)
	 begin
		if (~nRST) begin
			ClockDiv <= 0;
			slowClock <= 0;
      end
      else if (ClockDiv == 2)
		begin
			ClockDiv <= 1;
			slowClock <= ~slowClock;
		end
		else
		begin
			ClockDiv <= ClockDiv + 1;
		end
		
	 end
	 
	 assign clkTX = slowClock;
	 assign clkRX = clk;

endmodule
