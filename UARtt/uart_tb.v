`timescale 1ns/1ps

module uart_tb;

reg clk_50m;
reg [7:0] din;
reg wr_en;
reg rdy_clr;
wire tx;
wire tx_busy;
wire rx;
wire rdy;
wire [7:0] dout;

// Loopback tx to rx
assign rx = tx;

// Instantiate UART
uart uut (
    .din(din),
    .wr_en(wr_en),
    .clk_50m(clk_50m),
    .tx(tx),
    .tx_busy(tx_busy),
    .rx(rx),
    .rdy(rdy),
    .rdy_clr(rdy_clr),
    .dout(dout)
);

// Clock generation (50 MHz -> 20 ns period)
initial begin
    clk_50m = 0;
    forever #10 clk_50m = ~clk_50m;
end

// Test procedure
initial begin
    // Initialize inputs
    din = 8'h00;
    wr_en = 1'b0;
    rdy_clr = 1'b0;

    // Reset and wait
    #100;
    
    // Test Case 1: Send 0xA5
    $display("Test 1: Sending 0xA5");
    din = 8'hA5;        // Data to send
    wr_en = 1'b1;       // Trigger write
    #20;                // Hold wr_en for one clock cycle
    wr_en = 1'b0;

    // Wait for transmission to complete
    wait(tx_busy == 1'b0);
    $display("Transmission complete");

    // Wait for reception
    wait(rdy == 1'b1);
    $display("Received data: 0x%h", dout);
    if (dout == 8'hA5)
        $display("Test 1 PASSED");
    else
        $display("Test 1 FAILED");

    // Clear ready signal
    rdy_clr = 1'b1;
    #20;
    rdy_clr = 1'b0;

    
    #10000000;
    $finish;
end

// Dump waveform
initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
end

endmodule