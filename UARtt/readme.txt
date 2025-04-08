paste to run ------1) iverilog -o uart_sim uart.v tx.v rx.v baud_rate_gen.v uart_tb.v
                   2) vvp uart_sim
    for simulation               3) gtkwave uart_tb.vcd 
    din for data sent by TX
    dout for data recieved by RX