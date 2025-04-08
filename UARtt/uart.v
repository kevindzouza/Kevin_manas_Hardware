`timescale 1ns/1ps

module uart (
    input wire [7:0] din,
    input wire wr_en,
    input wire clk_50m,
    output wire tx,
    output wire tx_busy,  // Changed from input to output
    input wire rx,
    output wire rdy,
    input wire rdy_clr,
    output wire [7:0] dout
);

wire rxclk_en, txclk_en;

baud_rate_gen uart_baud (
    .clk_50m(clk_50m),
    .rxclk_en(rxclk_en),
    .txclk_en(txclk_en)
);

tx uart_tx (
    .din(din),
    .wr_en(wr_en),
    .clk_50m(clk_50m),
    .clken(txclk_en),
    .tx(tx),
    .tx_busy(tx_busy)  // tx_busy is correctly wired as an output
);

rx uart_rx (
    .rx(rx),
    .rdy(rdy),
    .rdy_clr(rdy_clr),
    .clk_50m(clk_50m),
    .clken(rxclk_en),
    .data(dout)
);

endmodule