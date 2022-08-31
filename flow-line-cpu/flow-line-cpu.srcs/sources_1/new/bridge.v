`timescale 1ns / 1ps

module bridge(
    input clk,
    input rst,
    // connect to cpu
    input i_rx_state,       // $t8 value
    input i_tx_state,       // $s0 value
    input [31:0] i_tx_data, // $s1 data
    output reg o_set_rx_new,    // set $t8 = 1 when a new $t9 is received by UART
    output reg o_set_tx_old,    // set $s0 = 0 when UART module already store the data into tx buffer
    output [7:0] o_rx_data, // $t9 data
    // connect to uart
    input i_rx_buf_not_empty,
    input i_tx_buf_not_full,
    input [7:0] i_rx_data,
    output o_en_uart,           // always 1
    output o_rx_read,       // read 1 byte
    output o_tx_write,          // write 1 byte
    output reg [7:0] o_tx_send_data // total 4 bytes
    );
    reg [2:0] cnt = 0;
    assign o_en_uart = 1;
    assign o_rx_read = ~i_rx_state & i_rx_buf_not_empty;
    assign o_tx_write = i_tx_buf_not_full & (i_tx_state | cnt > 0);
    assign o_rx_data = i_rx_data;
    
    reg hist_rx_buf_not_empty = 0;  // wait 1 clk for data trans to CPU
    always @(posedge clk) begin
        if(~i_rx_state & hist_rx_buf_not_empty) // $t8 -> 0
            o_set_rx_new <= 1;
        else
            o_set_rx_new <= 0;
        hist_rx_buf_not_empty <= i_rx_buf_not_empty;
    end
    
    wire [7:0] tx_data[3:0];
    assign tx_data[0] = i_tx_data / 1000 % 10;
    assign tx_data[1] = i_tx_data / 100 % 10;
    assign tx_data[2] = i_tx_data / 10 % 10;
    assign tx_data[3] = i_tx_data % 10;
    always @(posedge clk) begin
        if(i_tx_buf_not_full & (i_tx_state | cnt > 0)) begin    // $s0 -> 1
            if(cnt >= 4)
                cnt <= 0;
            else begin
                o_tx_send_data <= tx_data[cnt] + 48;
                o_set_tx_old <= 1;
                cnt <= cnt + 1;
            end
        end
    end
endmodule
