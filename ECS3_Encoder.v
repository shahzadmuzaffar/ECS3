// ============================================================================
// Author: Shahzad Muzaffar
// Email: dr.smuzaffar@gmail.com
// ============================================================================

module ECS3_Encoder(
        input        A,
        input        B,
        input        C,
        input        D,
        output [1:0] NOI,
        output [2:0] Ind0,
        output [2:0] Ind1,
        output       Flag
    );
	
    assign Flag = B&C&D | A&C&D | A&B&D | A&B&C;

    assign NOI[0] = ((~A)&(~B)&(~C)&D) | ((~A)&(~B)&C&(~D)) | (~A)&B&(~C)&(~D) | (~A)&B&C&D | A&(~B)&(~C)&(~D) | A&(~B)&C&D | A&B&(~C)&D | A&B&C&(~D);
    assign NOI[1] = (~A)&(~B)&C&D | (~A)&B&(~C)&D | (~A)&B&C&(~D) | A&(~B)&(~C)&D | A&(~B)&C&(~D) | A&B&(~C)&(~D);

    assign Ind0[0] = (~B)&D | (~A)&B&(~C) | A&B&(~D);
    assign Ind0[1] = (~A)&C&(~D) | (~A)&B&(~D) | A&(~B)&C | A&B&(~C);
    assign Ind0[2] = (~A)&B&C&D | A&(~B)&(~C)&(~D);

    assign Ind1[0] = (~A)&B&(~C)&D | (~A)&B&C&(~D);
    assign Ind1[1] = (~A)&(~B)&C&D | (~A)&B&(~C)&D | (~A)&B&C&(~D);
    assign Ind1[2] = A&(~B)&(~C)&D | A&(~B)&C&(~D) | A&B&(~C)&(~D);

endmodule
