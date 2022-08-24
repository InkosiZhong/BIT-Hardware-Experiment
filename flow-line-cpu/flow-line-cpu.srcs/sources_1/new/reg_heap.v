`timescale 1ns / 1ps

module reg_heap(
    input clk,
    input rst,
    input i_we,           // write_enable
    input i_reg_wc,
    input [4:0] i_reg1_addr,
    input [4:0] i_reg2_addr,
    input [4:0] i_reg3_addr,
    input [31:0] i_mem_wdata, // data from data memory
    input [31:0] i_alu_wdata, // data from alu
    output [31:0] o_reg1_data,
    output [31:0] o_reg2_data
    );
    reg [7:0] reg_space [127:0];
    initial begin
        $readmemh("D:/LAB/cpu/flow-line-cpu/reg.txt", reg_space);
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
    wire [31:0] wdata = i_reg_wc ? i_mem_wdata : i_alu_wdata;
    always @(posedge clk) begin
        if(i_we) begin
            reg_space[waddr+3] <= wdata[31:24];
            reg_space[waddr+2] <= wdata[23:16];
            reg_space[waddr+1] <= wdata[15:8];
            reg_space[waddr] <= wdata[7:0];
        end
    end
endmodule
