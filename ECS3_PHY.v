// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

module ECS3_PHY(
        input  SDIn,
        input  TXSelect,
        input  RXSelect,
        output SDOut,
        inout  ECS3Wire
    );

    //	PULLDOWN PD0 (.O (SDOut));
    //	PULLDOWN PD1 (.O (SDIn));
	
	/* To send out on ECS3Wire the stream received from MAC Layer */
	assign ECS3Wire = TXSelect ? SDIn : 1'bz;
	/* To collect from ECS3Wire the stream sent by external world (other nodes) */
	assign SDOut = RXSelect ? ECS3Wire : 1'b0;//1'bz;

endmodule
