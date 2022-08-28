`timescale 1ns / 1ps

module sys_top(
    input clk,
    input rst,
    input rx_pin_in,
    output tx_pin_out
    );
    wire set_rx_new, set_tx_old, rx_state, tx_state;
    wire [7:0] cpu_rx_data;
    wire [31:0] cpu_tx_data;
    cpu cpu(
        .clk(clk),
        .rst(rst),
        // additional for uart
        .i_set_rx_new(set_rx_new),
        .i_set_tx_old(set_tx_old),
        .i_rx_data(cpu_rx_data),
        .o_rx_state(rx_state),
        .o_tx_state(tx_state),
        .o_tx_data(cpu_tx_data)
    );
    
    wire rx_buf_not_empty, rx_buf_full, rx_read, en_uart;
    wire tx_buf_not_full, tx_write;
    wire [7:0] uart_rx_data;
    wire [7:0] uart_tx_data;
    uart_top uart(
        .clk(clk),
        .rst(~rst),
        .en(en_uart),
        .rx_read(rx_read),
        .rx_pin_in(rx_pin_in),
        .rx_buf_not_empty(rx_buf_not_empty),
        .rx_buf_full(rx_buf_full),
        .rx_get_data(uart_rx_data),
        .tx_write(tx_write),
        .tx_send_data(uart_tx_data),
        .tx_pin_out(tx_pin_out),
        .tx_buf_not_full(tx_buf_not_full)
    );
    
    bridge bridge(
        .clk(clk),
        .rst(rst),
        // connect to cpu
        .i_rx_state(rx_state),
        .i_tx_state(tx_state),
        .i_tx_data(cpu_tx_data),
        .o_set_rx_new(set_rx_new),
        .o_set_tx_old(set_tx_old),
        .o_rx_data(cpu_rx_data),
        // connect to uart
        .i_rx_buf_not_empty(rx_buf_not_empty),
        .i_tx_buf_not_full(tx_buf_not_full),
        .i_rx_data(uart_rx_data),
        .o_en_uart(en_uart),
        .o_rx_read(rx_read),
        .o_tx_write(tx_write),
        .o_tx_send_data(uart_tx_data)
    );
endmodule
