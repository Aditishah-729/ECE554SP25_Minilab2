   module Image_Processing(
    iCLK,
    iRST,
    iDATA,
    iDVAL,
    iSW,
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
input           iSW;
input			iCLK;
input			iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDVAL;

//Filters
logic signed [3:0] vert_filter [8:0];
logic signed [3:0] horz_filter [8:0];
													 
													 
initial begin
    vert_filter[0] = -1;
    vert_filter[1] = 0;
    vert_filter[2] = 1;
    vert_filter[3] = -2;
    vert_filter[4] = 0;
    vert_filter[5] = 2;
    vert_filter[6] = -1;
    vert_filter[7] = 0;
    vert_filter[8] = 1;

    horz_filter[0] = -1;
    horz_filter[1] = -2;
    horz_filter[2] = -1;
    horz_filter[3] = 0;
    horz_filter[4] = 0;
    horz_filter[5] = 0;
    horz_filter[6] = 1;
    horz_filter[7] = 2;
    horz_filter[8] = 1;
end

logic	[11:0]	o_grey;
logic	[11:0]	tap0, tap1, tap2;
logic oDVAL_grey;

// sub-module for greyscale conversion 
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

Line_Buffer2 (
	.clken(oDVAL_grey),
	.clock(iCLK),
	.shiftin(o_grey),
	.shiftout(),
	.taps0x(tap2),  // gives i row
	.taps1x(tap1),  // gives i-1 row
	.taps2x(tap0)   // gives i-2 row
    );

logic [11:0] top[2:0];
logic [11:0] middle[2:0];
logic [11:0] bottom[2:0];

// shift values to create a 3x3 grid
always_ff @(posedge iCLK or negedge iRST) begin
    if (!iRST) begin
        top[0] <= 12'd0;
        top[1] <= 12'd0;
        top[2] <= 12'd0;
        middle[0] <= 12'd0;
        middle[1] <= 12'd0;
        middle[2] <= 12'd0;
        bottom[0] <= 12'd0;
        bottom[1] <= 12'd0;
        bottom[2] <= 12'd0;
    end
    else if (oDVAL_grey) begin
        top[2] <= top[1];
        top[1] <= top[0];
        top[0] <= tap0;  

        middle[2] <= middle[1];
        middle[1] <= middle[0];
        middle[0] <= tap1;

        bottom[2] <= bottom[1];
        bottom[1] <= bottom[0];
        bottom[0] <= tap2;
    end
end

// top2,    top1,    top0
// middle2, middle1, middle0
// bottom2, bottom1, bottom0

logic [11:0] conv_out, conv_out_abs;
logic [3:0]filter_in_use[9];
logic in_range;

// if SW[0] is off then horixzointal else vertical
assign filter_in_use = iSW ? horz_filter : vert_filter;

assign conv_out = (top[2] * filter_in_use[0]) + (top[1] * filter_in_use[1]) + (top[0] * filter_in_use[2]) + 
                (middle[2] * filter_in_use[3]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[5]) +
                (bottom[2] * filter_in_use[6]) + (bottom[1] * filter_in_use[7]) + (bottom[0] * filter_in_use[8]); 

assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;

assign in_range = (oDVAL_grey) && (iX_Cont > 1 && iX_Cont < 1279) && (iY_Cont > 1 && iY_Cont < 959);

always @(posedge iCLK or negedge iRST) begin
    if (!iRST) begin
        oDVAL <= 1'b0;
        oRed <= 12'b0;
        oBlue <= 12'b0;
        oGreen <= 12'b0;
    end 
    else if (in_range) begin
        oDVAL <= 1'b1;
        oRed <= conv_out_abs;
        oBlue <= conv_out_abs;
        oGreen <= conv_out_abs;
    end 
end 

endmodule
