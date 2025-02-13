////////////////////////////////////////////////////////
// Module: Image_Processor.sv     		      //
// Authors: Aditi SHah, Cullen Krasselt		      //
////////////////////////////////////////////////////////

module Image_Processing(
    output [11:0] oRed,
    output [11:0] oGreen,
    output [11:0] oBlue,
    output        oDVAL,
    input  [10:0] iX_Cont,
    input  [10:0] iY_Cont,
    input  [11:0] iDATA,
    input         iDVAL,
    input         iCLK,
    input         iRST,
    input         iSW
);
    
    reg        mDVAL;
    ///////////////////////////////////////////
    // sub-module for greyscale conversion 
    //////////////////////////////////////////
    logic [11:0] o_grey;
    logic oDVAL_grey;

    greyscale u2 (
        .iCLK(iCLK),
        .iRST(iRST),
        .iDATA(iDATA),
        .iDVAL(iDVAL),
        .oGrey(o_grey),
        .oDVAL(oDVAL_grey),
        .iX_Cont(iX_Cont),
        .iY_Cont(iY_Cont)
    );

    ///////////////////////////////////////////
    // line buffer to hold one set of values
    //////////////////////////////////////////


    logic [11:0] rowc0, rowc1, rowc2;
    logic [11:0] rowb0, rowb1, rowb2;
    logic [11:0] rowa0, rowa1, rowa2;

    Line_Buffer2 u1 (
        .clken(mDVAL),
        .clock(iCLK),
        .shiftin(o_grey),
        .shiftout(),
        .taps0x(rowc0),
        .taps1x(rowc1),
        .taps2x(rowc2)
    );
    
    //////////////////////////////////////////
    // 3x3 filter 
    //////////////////////////////////////////

    logic signed [11:0] filter [8:0];
    // iSW = is horizontal
    assign filter[0] = -12'd1;
    assign filter[1] = iSW ? -12'd2 :  12'd0;
    assign filter[2] = iSW ? -12'd1 :  12'd1;
    assign filter[3] = iSW ?  12'd0 : -12'd2;
    assign filter[4] =  12'd0;
    assign filter[5] = iSW ?  12'd0 :  12'd2;
    assign filter[6] = iSW ? 12'd1 : -12'd1;
    assign filter[7] = iSW ?  12'd2 :  12'd0;
    assign filter[8] =  12'd1;


    //////////////////////////////////////////
    // double flop to get 9 values            
    //////////////////////////////////////////

    always @(posedge iCLK or negedge iRST) begin
        if (!iRST) begin
            rowb0  <= 0;
            rowb1  <= 0;
            rowb2  <= 0;
            rowa0 <= 0;
            rowa1 <= 0;
            rowa2 <= 0;
            mDVAL     <= 0;
        end else begin
            rowb0  <= rowc0;
            rowb1  <= rowc1;
            rowb2  <= rowc2;
            rowa0 <= rowb0;
            rowa1 <= rowb1;
            rowa2 <= rowb2;
            mDVAL     <= ({iY_Cont[0], iX_Cont[0]} == 2'b00) ? iDVAL : 1'b0;
            
        end
    end

    //////////////////////////////////////////
    // convolution
    //////////////////////////////////////////

    logic [11:0] conv_out, conv_abs, conv_final;

    assign conv_out = (rowa0 * filter[8]) + (rowa1 * filter[7]) + (rowa2 * filter[6]) +
                      (rowb0 * filter[5]) + (rowb1 * filter[4]) + (rowb2 * filter[3]) +
                      (rowc0 * filter[2]) + (rowc1 * filter[1]) + (rowc2 * filter[0]);

    //////////////////////////////////////////
    // absolute + edge-case elimination 
    //////////////////////////////////////////

    Abs a1 (
        .in(conv_out),
        .out(conv_abs)
    );

    assign conv_final = ((iX_Cont > 9) && (iX_Cont < 1270) &&
                    (iY_Cont > 9) && (iY_Cont < 940)) ? conv_abs : 12'b0;

    //////////////////////////////////////////
    // assign final output values  
    //////////////////////////////////////////

    assign oRed = conv_final;
    assign oBlue = conv_final;
    assign oGreen = conv_final;
    assign oDVAL = mDVAL;
	
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////


//    module Image_Processing(
//     iCLK,
//     iRST,
//     iDATA,
//     iDVAL,
//     iSW,
//     oRed,
//     oGreen,
//     oBlue,
//     oDVAL,
//     iX_Cont,
//     iY_Cont
// );

// input	[10:0]	iX_Cont;
// input	[10:0]	iY_Cont;
// input	[11:0]	iDATA;
// input			iDVAL;
// input           iSW;
// input			iCLK;
// input			iRST;
// output	[11:0]	oRed;
// output	[11:0]	oGreen;
// output	[11:0]	oBlue;
// output			oDVAL;

// //Filters
// logic signed [3:0] vert_filter [8:0];
// logic signed [3:0] horz_filter [8:0];
													 
													 
// initial begin
//     vert_filter[0] = -1;
//     vert_filter[1] = 0;
//     vert_filter[2] = 1;
//     vert_filter[3] = -2;
//     vert_filter[4] = 0;
//     vert_filter[5] = 2;
//     vert_filter[6] = -1;
//     vert_filter[7] = 0;
//     vert_filter[8] = 1;

//     horz_filter[0] = -1;
//     horz_filter[1] = -2;
//     horz_filter[2] = -1;
//     horz_filter[3] = 0;
//     horz_filter[4] = 0;
//     horz_filter[5] = 0;
//     horz_filter[6] = 1;
//     horz_filter[7] = 2;
//     horz_filter[8] = 1;
// end

// logic	[11:0]	o_grey;
// logic	[11:0]	tap0, tap1, tap2;
// logic oDVAL_grey;

// // sub-module for greyscale conversion 
// greyscale u2 (
//     .iCLK(iCLK),
//     .iRST(iRST),
//     .iDATA(iDATA),
//     .iDVAL(iDVAL),
//     .oGrey(o_grey),
//     .oDVAL(oDVAL_grey),
//     .iX_Cont(iX_Cont),
//     .iY_Cont(iY_Cont)
// );

// logic [11:0] top0, top1, top2;
// logic [11:0] middle0, middle1, middle2;
// logic [11:0] middleout;

// Line_Buffer2 u0 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(bottom[2]),
// 	.shiftout(middleout),
// 	.taps0x(middle2),  // gives i col
// 	.taps1x(middle1),  // gives i-1 col
// 	.taps2x(middle0)   // gives i-2 col
//     );

// Line_Buffer2 u1 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(middleout),
// 	.shiftout(),
// 	.taps0x(top2),  // gives i col
// 	.taps1x(top1),  // gives i-1 col
// 	.taps2x(top0)   // gives i-2 col
//     );

// logic [11:0] top[2:0];
// logic [11:0] middle[2:0];
// logic [11:0] bottom[2:0];

// // shift values to create a 3x3 grid
// always_ff @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         top[0] <= 12'd0;
//         top[1] <= 12'd0;
//         top[2] <= 12'd0;
//         middle[0] <= 12'd0;
//         middle[1] <= 12'd0;
//         middle[2] <= 12'd0;
//         bottom[0] <= 12'd0;
//         bottom[1] <= 12'd0;
//         bottom[2] <= 12'd0;
//     end
//     else if (oDVAL_grey) begin
//         top[2] <= top2;
//         top[1] <= top1;
//         top[0] <= top0;  

//         middle[2] <= middle2;
//         middle[1] <= middle1;
//         middle[0] <= middle0;

//         bottom[2] <= bottom[1];
//         bottom[1] <= bottom[0];
//         bottom[0] <= o_grey;
//     end
// end

// // top2,    top1,    top0
// // middle2, middle1, middle0
// // bottom2, bottom1, bottom0

// logic [15:0] conv_out, conv_out_abs;
// logic [3:0]filter_in_use[9];
// logic in_range;

// // if SW[0] is off then horixzointal else vertical
// assign filter_in_use = iSW ? horz_filter : vert_filter;

// assign conv_out = (top[2] * filter_in_use[0]) + (top[1] * filter_in_use[1]) + (top[0] * filter_in_use[2]) + 
//                 (middle[2] * filter_in_use[3]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[5]) +
//                 (bottom[2] * filter_in_use[6]) + (bottom[1] * filter_in_use[7]) + (bottom[0] * filter_in_use[8]); 

// assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;

// assign in_range = (oDVAL_grey) && (iX_Cont > 1 && iX_Cont < 1279) && (iY_Cont > 1 && iY_Cont < 959);

// always @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         oDVAL <= 1'b0;
//         oRed <= 12'b0;
//         oBlue <= 12'b0;
//         oGreen <= 12'b0;
//     end 
//     else if (in_range) begin
//         oDVAL <= 1'b1;
//         oRed <= conv_out_abs;
//         oBlue <= conv_out_abs;
//         oGreen <= conv_out_abs;
//     end 
//     else begin
//         oDVAL <= 1'b0;
//         oRed  <= 12'd0;
//         oBlue <= 12'd0;
//         oGreen<= 12'd0;
//         end
// end 

// endmodule


// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// module Image_Processing(
//     iCLK,
//     iRST,
//     iDATA,
//     iDVAL,
//     iSW,
//     oRed,
//     oGreen,
//     oBlue,
//     oDVAL,
//     iX_Cont,
//     iY_Cont
// );

// input	[10:0]	iX_Cont;
// input	[10:0]	iY_Cont;
// input	[11:0]	iDATA;
// input			iDVAL;
// input           iSW;
// input			iCLK;
// input			iRST;
// output	[11:0]	oRed;
// output	[11:0]	oGreen;
// output	[11:0]	oBlue;
// output			oDVAL;

// //Filters
// logic signed [3:0] vert_filter [8:0];
// logic signed [3:0] horz_filter [8:0];
													 
													 
// initial begin
//     vert_filter[0] = -1;
//     vert_filter[1] = 0;
//     vert_filter[2] = 1;
//     vert_filter[3] = -2;
//     vert_filter[4] = 0;
//     vert_filter[5] = 2;
//     vert_filter[6] = -1;
//     vert_filter[7] = 0;
//     vert_filter[8] = 1;

//     horz_filter[0] = -1;
//     horz_filter[1] = -2;
//     horz_filter[2] = -1;
//     horz_filter[3] = 0;
//     horz_filter[4] = 0;
//     horz_filter[5] = 0;
//     horz_filter[6] = 1;
//     horz_filter[7] = 2;
//     horz_filter[8] = 1;
// end

// logic	[11:0]	o_grey;
// logic	[11:0]	tap0, tap1, tap2;
// logic oDVAL_grey;

// // sub-module for greyscale conversion 
// greyscale u2 (
//     .iCLK(iCLK),
//     .iRST(iRST),
//     .iDATA(iDATA),
//     .iDVAL(iDVAL),
//     .oGrey(o_grey),
//     .oDVAL(oDVAL_grey),
//     .iX_Cont(iX_Cont),
//     .iY_Cont(iY_Cont)
// );

// logic [11:0] top0, top1, top2;
// logic [11:0] middle0, middle1, middle2;
// logic [11:0] bottom0, bottom1, bottom2;
// logic [11:0] middleout, bottomout;

// Line_Buffer2 u3 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(o_grey),
// 	.shiftout(bottomout),
// 	.taps0x(bottom2),  // gives i col
// 	.taps1x(bottom1),  // gives i-1 col
// 	.taps2x(bottom0)   // gives i-2 col
//     );

// Line_Buffer2 u0 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(bottomout),
// 	.shiftout(middleout),
// 	.taps0x(middle2),  // gives i col
// 	.taps1x(middle1),  // gives i-1 col
// 	.taps2x(middle0)   // gives i-2 col
//     );

// Line_Buffer2 u1 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(middleout),
// 	.shiftout(),
// 	.taps0x(top2),  // gives i col
// 	.taps1x(top1),  // gives i-1 col
// 	.taps2x(top0)   // gives i-2 col
//     );

// logic [11:0] top[2:0];
// logic [11:0] middle[2:0];
// logic [11:0] bottom[2:0];

// // shift values to create a 3x3 grid
// always_ff @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         top[2] <= 12'd0;
//         top[1] <= 12'd0;
//         top[0] <= 12'd0;
//         middle[2] <= 12'd0;
//         middle[1] <= 12'd0;
//         middle[0] <= 12'd0;
//         bottom[2] <= 12'd0;
//         bottom[1] <= 12'd0;
//         bottom[0] <= 12'd0;
//     end
//     else if (iDVAL) begin
//         top[2] <= top2;
//         top[1] <= top1;
//         top[0] <= top0;  

//         middle[2] <= middle2;
//         middle[1] <= middle1;
//         middle[0] <= middle0;

//         bottom[2] <= bottom2;
//         bottom[1] <= bottom1;
//         bottom[0] <= bottom0;
//     end
//     else begin
//         begin
//         top[2] <= 12'd0;
//         top[1] <= 12'd0;
//         top[0] <= 12'd0;
//         middle[2] <= 12'd0;
//         middle[1] <= 12'd0;
//         middle[0] <= 12'd0;
//         bottom[2] <= 12'd0;
//         bottom[1] <= 12'd0;
//         bottom[0] <= 12'd0;
//     end
//     end
// end

// // top2,    top1,    top0
// // middle2, middle1, middle0
// // bottom2, bottom1, bottom0

// logic [15:0] conv_out, conv_out_abs;
// logic [3:0]filter_in_use[9];
// logic in_range;

// // if SW[0] is off then horixzointal else vertical
// assign filter_in_use = iSW ? horz_filter : vert_filter;

// assign conv_out = (top[2] * filter_in_use[0]) + (top[1] * filter_in_use[1]) + (top[0] * filter_in_use[2]) + 
//                 (middle[2] * filter_in_use[3]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[5]) +
//                 (bottom[2] * filter_in_use[6]) + (bottom[1] * filter_in_use[7]) + (bottom[0] * filter_in_use[8]); 

// assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;

// assign in_range = (oDVAL_grey) && (iX_Cont > 1 && iX_Cont < 1279) && (iY_Cont > 1 && iY_Cont < 959);

// always @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         oDVAL <= 1'b0;
//         oRed <= 12'b0;
//         oBlue <= 12'b0;
//         oGreen <= 12'b0;
//     end 
//     else if (in_range) begin
//         oDVAL <= 1'b1;
//         oRed <= conv_out_abs;
//         oBlue <= conv_out_abs;
//         oGreen <= conv_out_abs;
//     end 
//     else begin
//         oDVAL <= 1'b0;
//         oRed  <= 12'd0;
//         oBlue <= 12'd0;
//         oGreen<= 12'd0;
//     end
// end 

// endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// module Image_Processing(
//     iCLK,
//     iRST,
//     iDATA,
//     iDVAL,
//     iSW,
//     oRed,
//     oGreen,
//     oBlue,
//     oDVAL,
//     iX_Cont,
//     iY_Cont
// );

// input	[10:0]	iX_Cont;
// input	[10:0]	iY_Cont;
// input	[11:0]	iDATA;
// input			iDVAL;
// input           iSW;
// input			iCLK;
// input			iRST;
// output	[11:0]	oRed;
// output	[11:0]	oGreen;
// output	[11:0]	oBlue;
// output			oDVAL;

// //Filters
// logic signed [3:0] vert_filter [8:0];
// logic signed [3:0] horz_filter [8:0];
													 
													 
// initial begin
//     vert_filter[0] = -1;
//     vert_filter[1] = 0;
//     vert_filter[2] = 1;
//     vert_filter[3] = -2;
//     vert_filter[4] = 0;
//     vert_filter[5] = 2;
//     vert_filter[6] = -1;
//     vert_filter[7] = 0;
//     vert_filter[8] = 1;

//     horz_filter[0] = -1;
//     horz_filter[1] = -2;
//     horz_filter[2] = -1;
//     horz_filter[3] = 0;
//     horz_filter[4] = 0;
//     horz_filter[5] = 0;
//     horz_filter[6] = 1;
//     horz_filter[7] = 2;
//     horz_filter[8] = 1;
// end

// logic	[11:0]	o_grey;
// logic	[11:0]	tap0, tap1, tap2;
// logic oDVAL_grey;
// logic mDVAL;

// assign oDVAL = mDVAL;

// // sub-module for greyscale conversion 
// greyscale u2 (
//     .iCLK(iCLK),
//     .iRST(iRST),
//     .iDATA(iDATA),
//     .iDVAL(iDVAL),
//     .oGrey(o_grey),
//     .oDVAL(oDVAL_grey),
//     .iX_Cont(iX_Cont),
//     .iY_Cont(iY_Cont)
// );

// //logic [11:0] top0, top1, top2;
// //logic [11:0] middle0, middle1, middle2;
// //logic [11:0] bottom0, bottom1, bottom2;
// logic [11:0] bottomout;
// logic [11:0] top[2:0];
// logic [11:0] middle[2:0];
// logic [11:0] bottom[2:0];

// Line_Buffer2 u3 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(o_grey),
// 	.shiftout(bottomout),
// 	.taps0x(bottom[2]),  // gives i col
// 	.taps1x(bottom[1]),  // gives i-1 col
// 	.taps2x(bottom[0])   // gives i-2 col
//     );

// // shift values to create a 3x3 grid
// always_ff @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         top[2]    <= 12'd0;
//         top[1]    <= 12'd0;
//         top[0]    <= 12'd0;
//         middle[2] <= 12'd0;
//         middle[1] <= 12'd0;
//         middle[0] <= 12'd0;
//         mDVAL     <= 1'b0;
//     end
//     else begin
//         top[2] <= middle[2];
//         top[1] <= middle[1];
//         top[0] <= middle[0];  
//         middle[2] <= bottom[2];
//         middle[1] <= bottom[1];
//         middle[0] <= bottom[0];
//         mDVAL     <= ({iY_Cont[0], iX_Cont[0]} == 2'b00) ? iDVAL : 1'b0;
//     end
// end

// // top2,    top1,    top0
// // middle2, middle1, middle0
// // bottom2, bottom1, bottom0

// logic [15:0] conv_out, conv_out_abs;
// logic [3:0]filter_in_use[9];
// logic in_range;

// // if SW[0] is off then horixzointal else vertical
// assign filter_in_use = iSW ? horz_filter : vert_filter;

// assign conv_out = (top[2] * filter_in_use[0]) + (top[1] * filter_in_use[1]) + (top[0] * filter_in_use[2]) + 
//                 (middle[2] * filter_in_use[3]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[5]) +
//                 (bottom[2] * filter_in_use[6]) + (bottom[1] * filter_in_use[7]) + (bottom[0] * filter_in_use[8]); 

// // assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;
// abs a1 (
//         .in(conv_out),
//         .out(conv_out_abs)
//     );

// assign conv_out_sat = (conv_out > 4095) ? 12'd4095 : (conv_out < 0) ? 12'd0 : conv_out_abs[11:0];

// assign in_range = (oDVAL_grey) && (iX_Cont > 1 && iX_Cont < 1279) && (iY_Cont > 1 && iY_Cont < 959);

// always @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         oRed <= 12'b0;
//         oBlue <= 12'b0;
//         oGreen <= 12'b0;
//     end 
//     else if (in_range) begin
//         oRed <= conv_out_sat;
//         oBlue <= conv_out_sat;
//         oGreen <= conv_out_sat;
//     end 
//     else begin
//         oRed  <= 12'd0;
//         oBlue <= 12'd0;
//         oGreen<= 12'd0;
//     end
// end 

// endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// module Image_Processing(
//     iCLK,
//     iRST,
//     iDATA,
//     iDVAL,
//     iSW,
//     oRed,
//     oGreen,
//     oBlue,
//     oDVAL,
//     iX_Cont,
//     iY_Cont
// );

// input	[10:0]	iX_Cont;
// input	[10:0]	iY_Cont;
// input	[11:0]	iDATA;
// input			iDVAL;
// input           iSW;
// input			iCLK;
// input			iRST;
// output	[11:0]	oRed;
// output	[11:0]	oGreen;
// output	[11:0]	oBlue;
// output			oDVAL;

// //Filters
// logic signed [3:0] vert_filter [8:0];
// logic signed [3:0] horz_filter [8:0];
													 
													 
// initial begin
//     vert_filter[0] = -1;
//     vert_filter[1] = 0;
//     vert_filter[2] = 1;
//     vert_filter[3] = -2;
//     vert_filter[4] = 0;
//     vert_filter[5] = 2;
//     vert_filter[6] = -1;
//     vert_filter[7] = 0;
//     vert_filter[8] = 1;

//     horz_filter[0] = -1;
//     horz_filter[1] = -2;
//     horz_filter[2] = -1;
//     horz_filter[3] = 0;
//     horz_filter[4] = 0;
//     horz_filter[5] = 0;
//     horz_filter[6] = 1;
//     horz_filter[7] = 2;
//     horz_filter[8] = 1;
// end

// logic	[11:0]	o_grey;
// logic	[11:0]	tap0, tap1, tap2;
// logic oDVAL_grey;

// // sub-module for greyscale conversion 
// greyscale u2 (
//     .iCLK(iCLK),
//     .iRST(iRST),
//     .iDATA(iDATA),
//     .iDVAL(iDVAL),
//     .oGrey(o_grey),
//     .oDVAL(oDVAL_grey),
//     .iX_Cont(iX_Cont),
//     .iY_Cont(iY_Cont)
// );

// logic [11:0] top0, top1, top2;
// logic [11:0] middle0, middle1, middle2;
// logic [11:0] bottom0, bottom1, bottom2;
// logic [11:0] middleout, bottomout;
// logic mDVAL;

// Line_Buffer2 u3 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(o_grey),
// 	.shiftout(bottomout),
// 	.taps0x(bottom2),  // gives i col
// 	.taps1x(bottom1),  // gives i-1 col
// 	.taps2x(bottom0)   // gives i-2 col
//     );

// assign oDVAL = mDVAL;

// logic [11:0] top[2:0];
// logic [11:0] middle[2:0];
// logic [11:0] bottom[2:0];

// // shift values to create a 3x3 grid
// always_ff @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         top[2] <= 12'd0;
//         top[1] <= 12'd0;
//         top[0] <= 12'd0;
//         middle[2] <= 12'd0;
//         middle[1] <= 12'd0;
//         middle[0] <= 12'd0;
//         bottom[2] <= 12'd0;
//         bottom[1] <= 12'd0;
//         bottom[0] <= 12'd0;
//         mDVAL     <= 0;
//     end
//     else if (iDVAL) begin
//         middle[2] <= bottom[2];
//         middle[1] <= bottom[1];
//         middle[0] <= bottom[0];
//         top[2] <= middle[2];
//         top[1] <= middle[1];
//         top[0] <= middle[0]; 
//         mDVAL     <= ({iY_Cont[0], iX_Cont[0]} == 2'b00) ? iDVAL : 1'b0;
//     end
// end

// // top2,    top1,    top0
// // middle2, middle1, middle0
// // bottom2, bottom1, bottom0

// logic [15:0] conv_out, conv_out_abs;
// logic [3:0]filter_in_use[9];
// logic in_range;

// // if SW[0] is off then horixzointal else vertical
// assign filter_in_use = iSW ? horz_filter : vert_filter;

// assign conv_out = (top[2] * filter_in_use[0]) + (top[1] * filter_in_use[1]) + (top[0] * filter_in_use[2]) + 
//                 (middle[2] * filter_in_use[3]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[5]) +
//                 (bottom[2] * filter_in_use[6]) + (bottom[1] * filter_in_use[7]) + (bottom[0] * filter_in_use[8]); 

// assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;

// assign in_range = (oDVAL_grey) && (iX_Cont > 1 && iX_Cont < 1279) && (iY_Cont > 1 && iY_Cont < 959);

// always @(posedge iCLK or negedge iRST) begin
//     if (!iRST) begin
//         //oDVAL <= 1'b0;
//         oRed <= 12'b0;
//         oBlue <= 12'b0;
//         oGreen <= 12'b0;
//     end 
//     else if (in_range) begin
//         //oDVAL <= 1'b1;
//         oRed <= conv_out_abs;
//         oBlue <= conv_out_abs;
//         oGreen <= conv_out_abs;
//     end 
//     else begin
//         //oDVAL <= 1'b0;
//         oRed  <= 12'd0;
//         oBlue <= 12'd0;
//         oGreen<= 12'd0;
//     end
// end 

// endmodule


/////////////////////////////////////////////////////////////////////////////////


// `timescale 1ns/1ps

// module Image_Processing(   
//     input         iCLK,
//     input         iRST,
//     input  [10:0] iX_Cont,
//     input  [10:0] iY_Cont,
//     input  [11:0] iDATA,
//     input         iDVAL,
//     input         iSW,
//     output [11:0] oRed,
//     output [11:0] oBlue,
//     output [11:0] oGreen,
//     output        oDVAL
// );


// logic signed [11:0] filter_in_use [8:0];

//     assign filter_in_use[0] = -12'd1;
//     assign filter_in_use[1] = iSW ? -12'd2 :  12'd0;
//     assign filter_in_use[2] = iSW ? -12'd1 :  12'd1;
//     assign filter_in_use[3] = iSW ?  12'd0 : -12'd2;
//     assign filter_in_use[4] =  12'd0;
//     assign filter_in_use[5] = iSW ?  12'd0 :  12'd2;
//     assign filter_in_use[6] =  12'd1;
//     assign filter_in_use[7] = iSW ?  12'd2 :  12'd0;
//     assign filter_in_use[8] =  12'd1;

//     logic [11:0] top[2:0];
//     logic [11:0] middle[2:0];
//     logic [11:0] bottom[2:0];


// logic	[11:0]	o_grey;
// logic oDVAL_grey;

// logic [11:0] conv_out, conv_out_abs, output_conv;

// // sub-module for greyscale conversion 
// greyscale u2 (
//     .iCLK(iCLK),
//     .iRST(iRST),
//     .iDATA(iDATA),
//     .iDVAL(iDVAL),
//     .oGrey(o_grey),
//     .oDVAL(oDVAL_grey),
//     .iX_Cont(iX_Cont),
//     .iY_Cont(iY_Cont)
// );


// Line_Buffer2 u3 (
// 	.clken(oDVAL_grey),
// 	.clock(iCLK),
// 	.shiftin(o_grey),
// 	.shiftout(),
// 	.taps0x(bottom[0]),  // gives i col
// 	.taps1x(bottom[1]),  // gives i-1 col
// 	.taps2x(bottom[2])   // gives i-2 col
//     );

//     assign conv_out = (top[2] * filter_in_use[8]) + (top[1] * filter_in_use[7]) + (top[0] * filter_in_use[6]) +
//                (middle[2] * filter_in_use[5]) + (middle[1] * filter_in_use[4]) + (middle[0] * filter_in_use[3]) +
//                (bottom[2] * filter_in_use[2]) + (bottom[1] * filter_in_use[1]) + (bottom[0] * filter_in_use[0]);

//     assign conv_out_abs = (conv_out > 0) ? conv_out : -conv_out;

//     assign output_conv = ((iX_Cont > 9) && (iX_Cont < 1270) &&
//                     (iY_Cont > 9) && (iY_Cont < 940)) ? conv_out_abs : 12'b0;
    
//     always @(posedge iCLK or negedge iRST) begin
//         if (!iRST) begin
//             top[2]    <= 12'd0;
//             top[1]    <= 12'd0;
//             top[0]    <= 12'd0;
//             middle[2] <= 12'd0;
//             middle[1] <= 12'd0;
//             middle[0] <= 12'd0;
//             mDVAL     <= 1'b0;
//         end else begin
//             middle[0] <= bottom[0];
//             middle[1] <= bottom[1];
//             middle[2] <= bottom[2];         
//             top[0] <= middle[0];
//             top[1] <= middle[1];
//             top[2] <= middle[2];
//             mDVAL     <= ({iY_Cont[0], iX_Cont[0]} == 2'b00) ? iDVAL : 1'b0;
                        
//         end
//     end

//     assign oDVAL = mDVAL;
//     assign oGrey_R = output_conv;
//     assign oGrey_G = output_conv;
//     assign oGrey_B = output_conv;

// endmodule
