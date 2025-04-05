module i2c_slave (
    inout sda,
    inout scl
);

    parameter ADDRESS_SLAVE = 7'b0000001;
    localparam READ_ADDR = 0, SEND_ACK1 = 1, READ_DATA = 2, WRITE_DATA = 3, SEND_ACK2 = 4;

    reg [7:0] addr;
    reg [3:0] counter;
    reg [2:0] state;
    reg [7:0] data_in;
    reg [7:0] data_out;
    reg sda_out;
    reg wr_enb;
    reg start;

    assign sda = wr_enb ? sda_out : 1'bz;

    // Detect start condition
    always @(negedge sda) begin
        if (!start && scl) begin
            start <= 1;
            counter <= 7;
            state <= READ_ADDR;
        end
    end

    // Detect stop condition
    always @(posedge sda) begin
        if (start && scl) begin
            start <= 0;
            wr_enb <= 0;
            state <= READ_ADDR;
        end
    end

    // Main state machine (data reception)
    always @(posedge scl) begin
        if (start) begin
            case (state)
                READ_ADDR: begin
                    addr[counter] <= sda;
                    if (counter == 0) state <= SEND_ACK1;
                    else counter <= counter - 1;
                end
                SEND_ACK1: begin
                    if (addr[7:1] == ADDRESS_SLAVE) begin
                        counter <= 7;
                        if (addr[0] == 0) state <= READ_DATA; // Write from master
                        else begin
                            state <= WRITE_DATA;
                            data_out <= 8'h5A; // Dummy data for read
                        end
                    end else begin
                        state <= READ_ADDR; // Address mismatch
                        start <= 0;
                    end
                end
                READ_DATA: begin
                    data_in[counter] <= sda;
                    if (counter == 0) state <= SEND_ACK2;
                    else counter <= counter - 1;
                end
                WRITE_DATA: begin
                    if (counter == 0) state <= SEND_ACK2;
                    else counter <= counter - 1;
                end
                SEND_ACK2: begin
                    state <= READ_ADDR;
                    start <= 0;
                end
            endcase
        end
    end

    // SDA output control
    always @(negedge scl) begin
        if (start) begin
            case (state)
                READ_ADDR: wr_enb <= 0;
                SEND_ACK1: begin
                    sda_out <= 0; // ACK
                    wr_enb <= 1;
                end
                READ_DATA: wr_enb <= 0;
                SEND_ACK2: begin
                    sda_out <= 0; // ACK
                    wr_enb <= 1;
                end
                WRITE_DATA: begin
                    sda_out <= data_out[counter];
                    wr_enb <= 1;
                end
            endcase
        end else begin
            wr_enb <= 0;
        end
    end

endmodule