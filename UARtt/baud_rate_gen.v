`timescale 1ns/1ps

module baud_rate_gen (
    input wire clk_50m,
    output reg rxclk_en,
    output reg txclk_en
);

parameter CLK_FREQ = 50_000_000;  // 50 MHz
parameter BAUD_RATE = 115_200;    // 115200 baud
parameter TX_DIV = CLK_FREQ / (BAUD_RATE);       // ~434 cycles
parameter RX_DIV = CLK_FREQ / (BAUD_RATE * 16);  // ~27 cycles for 16x oversampling

reg [15:0] tx_counter = 16'h0;
reg [15:0] rx_counter = 16'h0;

always @(posedge clk_50m) begin
    // TX clock enable
    if (tx_counter == (TX_DIV - 1)) begin
        txclk_en <= 1'b1;
        tx_counter <= 16'h0;
    end
    else begin
        txclk_en <= 1'b0;
        tx_counter <= tx_counter + 16'h1;
    end

    // RX clock enable (16x oversampling)
    if (rx_counter == (RX_DIV - 1)) begin
        rxclk_en <= 1'b1;
        rx_counter <= 16'h0;
    end
    else begin
        rxclk_en <= 1'b0;
        rx_counter <= rx_counter + 16'h1;
    end
end

endmodule