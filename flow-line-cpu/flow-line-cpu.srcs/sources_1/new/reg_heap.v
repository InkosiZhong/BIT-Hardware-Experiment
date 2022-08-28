`timescale 1ns / 1ps

module reg_heap(
    input clk,
    input rst,
    input i_we,           // write_enable
    input [1:0] i_reg_wc,
    input [4:0] i_reg1_addr,
    input [4:0] i_reg2_addr,
    input [4:0] i_reg3_addr,
    input [31:0] i_mem_wdata, // data from data memory
    input [31:0] i_alu_wdata, // data from alu
    input [31:0] i_spcl_wdata, // data from special registers
    output [31:0] o_reg1_data,
    output [31:0] o_reg2_data,
    // additional for uart
    input i_set_rx_new,     // set $t8 = 1 when a new $t9 is received by UART
    input i_set_tx_old,     // set $s0 = 0 when UART module already store the data into tx buffer
    input [7:0] i_rx_data,  // $t9 data
    output o_rx_state,      // $t8 value
    output o_tx_state,      // $s0 value
    output [31:0] o_tx_data // $s1 data
    );
    reg [7:0] reg_space [127:0];
    initial begin
        $readmemh("../../../../reg.txt", reg_space);
    end
    wire [7:0] full_reg1_addr = {3'b000, i_reg1_addr} << 2;
    assign o_reg1_data = {reg_space[full_reg1_addr+3],
                          reg_space[full_reg1_addr+2],
                          reg_space[full_reg1_addr+1],
                          reg_space[full_reg1_addr]};
    wire [7:0] full_reg2_addr = {3'b000, i_reg2_addr} << 2;
    assign o_reg2_data = {reg_space[full_reg2_addr+3],
                          reg_space[full_reg2_addr+2],
                          reg_space[full_reg2_addr+1],
                          reg_space[full_reg2_addr]};
    wire [7:0] waddr = {3'b000, i_reg3_addr} << 2;
    wire [31:0] wdata = (i_reg_wc == 1) ? i_mem_wdata : 
                        (i_reg_wc == 2) ? i_spcl_wdata : i_alu_wdata;
    always @(posedge clk) begin
        if(i_we) begin
            reg_space[waddr+3] <= wdata[31:24];
            reg_space[waddr+2] <= wdata[23:16];
            reg_space[waddr+1] <= wdata[15:8];
            reg_space[waddr] <= wdata[7:0];
        end
    end
    
    // $t8
    assign o_rx_state = reg_space[96][0];
    // $s0
    assign o_tx_state = reg_space[64][0];
    // $s1
    assign o_tx_data = {reg_space[71],
                        reg_space[70],
                        reg_space[69],
                        reg_space[68]};
    
    always @(posedge i_set_rx_new) begin
        reg_space[96] <= 1;
        reg_space[100] <= i_rx_data; // $t9
    end
    
    always @(posedge i_set_tx_old) begin
        reg_space[64] <= 0;
    end
endmodule
