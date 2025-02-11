`timescale 1ns/1ps

module Image_Processing_tb();

    // Clock and Reset
    reg iCLK;
    reg iRST;

    // Input Signals
    reg [10:0] iX_Cont;
    reg [10:0] iY_Cont;
    reg [11:0] iDATA;
    reg iDVAL;
    reg iSW;

    // Output Signals
    wire [11:0] oRed;
    wire [11:0] oGreen;
    wire [11:0] oBlue;
    wire oDVAL;

    // Instantiate the Image Processing Module
    Image_Processing DUT (
        .iCLK(iCLK),
        .iRST(iRST),
        .iX_Cont(iX_Cont),
        .iY_Cont(iY_Cont),
        .iDATA(iDATA),
        .iDVAL(iDVAL),
        .iSW(iSW),
        .oRed(oRed),
        .oGreen(oGreen),
        .oBlue(oBlue),
        .oDVAL(oDVAL)
    );

    // Clock Generation
    always #5 iCLK = ~iCLK;  // 10ns period (100MHz)

    // Task to apply an entire row of 1280 pixels
    task apply_row(input [10:0] y);
        integer x;
        begin
            for (x = 0; x < 1280; x = x + 1) begin
                iX_Cont = x;
                iY_Cont = y;
                iDATA = (x ^ y) & 12'hFFF; // Generate a test pattern
                iDVAL = 1;
                #10;  // Wait for one clock cycle
            end
            iDVAL = 0;
            #20; // Small delay between rows
        end
    endtask

    initial begin
        // Initialize Signals
        iCLK = 0;
        iRST = 1;
        iX_Cont = 0;
        iY_Cont = 0;
        iDATA = 0;
        iDVAL = 0;
        iSW = 0;  // Horizontal filtering

        // Apply Reset
        #20 iRST = 0;
        #20 iRST = 1;

        // Wait for system stabilization
        #50;

        // Simulate 4x1280 Image (4 rows, each with 1280 pixels)
        apply_row(0);
        apply_row(1);
        apply_row(2);
        apply_row(3);

        // Switch to Vertical Edge Detection Mode
        #100;
        iSW = 1;  

        // Apply another set of 4 rows with vertical edge detection
        apply_row(0);
        apply_row(1);
        apply_row(2);
        apply_row(3);

        // Wait for processing
        #1000;

        // End Simulation
        $stop;
    end

    // Monitor Output
    initial begin
        $monitor("X=%d Y=%d | iDATA=%h | oDATA(R,G,B)=%h,%h,%h", 
                 iX_Cont, iY_Cont, iDATA, oRed, oGreen, oBlue);
    end

endmodule




