module Image_Processing(
    iCLK,
    iRST,
    iDATA,
    iDVAL,
    oRed,
    oGreen,
    oBlue,
    oDVAL,
    iX_Cont,
    iY_Cont
);

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;

//Filters
logic signed [3:0] vert_filter [3][3] = 
{{-1, 0, 1},
{-2, 0, 2},
{-1, 0, 1}};

logic signed [3:0] horz_filter [3][3] = 
{{-1, -2, -1},
{0, 0, 0},
{1, 2, 1}};




logic	[11:0]	o_grey;

logic oDVAL_grey;


greyscale u1 (
    .iCLK(iCLK),
    .iRST(iRST),
    .iDATA(iDATA),
    .iDVAL(iDVAL),
    .oGrey(o_grey),
    .oDVAL(oDVAL_grey),
    .iX_Cont(iX_Cont),
    .iY_Cont(iY_Cont)
);

Line_Buffer2 	top	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

Line_Buffer2 	center	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

endmodule
