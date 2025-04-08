module i2c_master (
    input clk,
    input rst,
    input [6:0] addr_top,
    input [7:0] data_in_top,
    input enable,
    input rd_wr,
    output reg [7:0] data_out,
    output reg ready,
    inout sda,
    inout scl
);

    reg [3:0] state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg drive_sda;
    reg sda_out;
    reg scl_out;

    assign sda = drive_sda ? sda_out : 1'bz;
    assign scl = scl_out;

    // Clock divider (100 kHz SCL from 50 MHz clk)
    reg [7:0] clk_div;
    reg clk_en;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            clk_en <= 0;
        end else begin
            clk_div <= clk_div + 1;
            clk_en <= (clk_div == 249); // 50 MHz / 250 = 200 kHz, SCL toggles every half cycle
        end
    end

    // State machine
    localparam IDLE = 0, START = 1, ADDR = 2, ACK1 = 3, DATA = 4, ACK2 = 5, STOP = 6;
    always @(posedge scl or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            ready <= 1;
            drive_sda <= 0;
            sda_out <= 1;
            scl_out <= 1;
            bit_count <= 0;
            shift_reg <= 0;
            data_out <= 0;
        end else if (clk_en) begin
            case (state)
                IDLE: begin
                    ready <= 1;
                    scl_out <= 1;
                    sda_out <= 1;
                    if (enable) begin
                        drive_sda <= 1;
                        sda_out <= 0; // Start condition
                        state <= START;
                        ready <= 0;
                        shift_reg <= {addr_top, rd_wr};
                        bit_count <= 7;
                    end
                end
                START: begin
                    scl_out <= 0;
                    state <= ADDR;
                end
                ADDR: begin
                    scl_out <= 1;
                    drive_sda <= 1;
                    sda_out <= shift_reg[bit_count];
                    if (bit_count == 0) begin
                        state <= ACK1;
                        drive_sda <= 0; // Release SDA for ACK
                    end else begin
                        bit_count <= bit_count - 1;
                        scl_out <= 0;
                    end
                end
                ACK1: begin
                    scl_out <= 1;
                    if (sda == 0) begin // Check for ACK from slave
                        state <= DATA;
                        shift_reg <= data_in_top;
                        bit_count <= 7;
                        drive_sda <= 1;
                    end else begin
                        state <= STOP; // No ACK, abort
                    end
                    scl_out <= 0;
                end
                DATA: begin
                    scl_out <= 1;
                    drive_sda <= 1;
                    sda_out <= shift_reg[bit_count];
                    if (bit_count == 0) begin
                        state <= ACK2;
                        drive_sda <= 0; // Release SDA for ACK
                    end else begin
                        bit_count <= bit_count - 1;
                        scl_out <= 0;
                    end
                end
                ACK2: begin
                    scl_out <= 1;
                    if (sda == 0) state <= STOP; // Check for ACK
                    else state <= STOP; // Even if no ACK, stop
                    drive_sda <= 1;
                    sda_out <= 0;
                    scl_out <= 0;
                end
                STOP: begin
                    scl_out <= 1;
                    sda_out <= 1;
                    state <= IDLE;
                    ready <= 1;
                end
            endcase
        end
    end

endmodule