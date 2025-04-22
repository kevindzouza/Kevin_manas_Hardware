`timescale 1ns / 1ps

module i2c_tb();

    reg clk;
    reg rst;
    reg [6:0] addr_top;
    reg [7:0] data_in_top;
    reg enable;
    reg rd_wr;
    wire [7:0] data_out;
    wire ready;
    wire sda, scl;

    i2c_master master_inst (
        .clk(clk),
        .rst(rst),
        .addr_top(addr_top),
        .data_in_top(data_in_top),
        .enable(enable),
        .rd_wr(rd_wr),
        .data_out(data_out),
        .ready(ready),
        .sda(sda),
        .scl(scl)
    );

    i2c_slave slave_inst (
        .sda(sda),
        .scl(scl)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        addr_top = 7'b0000001; // Matches slave address
        data_in_top = 8'h9B;   // Data to send: 10011011
        enable = 0;
        rd_wr = 0;             // Write operation

        // Reset
        #20 rst = 0;

        // Start transaction
        #20 enable = 1;
        #20 enable = 0;

        // Wait for transaction to complete
        wait (ready == 1);
        #20000;

        // End simulation
        $finish;
    end

    // VCD generation
    initial begin
        $dumpfile("i2c_simulation.vcd");
        $dumpvars(0, i2c_tb);
    end

endmodule