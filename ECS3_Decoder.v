// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

module ECS3_Decoder(
        input  [2:0] ind0,
        input  [2:0] ind1,
        input  [2:0] ind2,
        input  [2:0] ind3,
        output [7:0] data
    );
	
	wire [3:0] SB0;
	wire [3:0] SB1;
	wire [3:0] SB2;
	wire [3:0] SB3;
	wire A0,B0,X0;
	wire A1,B1,X1;
	wire A2,B2,X2;
	wire A3,B3,X3;

	assign X0 = ind0[2];
	assign A0 = ind0[1];
	assign B0 = ind0[0];
	assign SB0 = {X0,(A0 & B0),(A0 & (~B0)),((~A0) & B0)};
	assign X1 = ind1[2];
	assign A1 = ind1[1];
	assign B1 = ind1[0];
	assign SB1 = {X1,(A1 & B1),(A1 & (~B1)),((~A1) & B1)};
	assign X2 = ind2[2];
	assign A2 = ind2[1];
	assign B2 = ind2[0];
	assign SB2 = {X2,(A2 & B2),(A2 & (~B2)),((~A2) & B2)};
	assign X3 = ind3[2];
	assign A3 = ind3[1];
	assign B3 = ind3[0];
	assign SB3 = {X3,(A3 & B3),(A3 & (~B3)),((~A3) & B3)};
	
	assign data = {(SB3 | SB2),(SB1 | SB0)};

endmodule
