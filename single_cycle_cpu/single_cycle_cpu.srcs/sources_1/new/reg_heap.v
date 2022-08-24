`timescale 1ns / 1ps

module reg_heap(
    input clk,
    input rst,
    input we,           // write_enable
    input c1,
    input c4,
    input [4:0] reg1_addr,
    input [4:0] reg2_addr,
    input [4:0] rt_addr,
    input [4:0] rd_addr,
    input [31:0] mem_wdata, // data from data memory
    input [31:0] alu_wdata, // data from alu
    output [31:0] reg1_data,
    output [31:0] reg2_data
    );
    reg [7:0] reg_space [127:0];
    initial begin
        $readmemh("D:/LAB/cpu/single_cycle_cpu/reg.txt", reg_space);
    end
    wire [7:0] full_reg1_addr = {3'b000, reg1_addr} << 2;
    assign reg1_data = {reg_space[full_reg1_addr+3],
                        reg_space[full_reg1_addr+2],
                        reg_space[full_reg1_addr+1],
                        reg_space[full_reg1_addr]};
    wire [7:0] full_reg2_addr = {3'b000, reg2_addr} << 2;
    assign reg2_data = {reg_space[full_reg2_addr+3],
                        reg_space[full_reg2_addr+2],
                        reg_space[full_reg2_addr+1],
                        reg_space[full_reg2_addr]};
    wire [7:0] waddr = {3'b000, c1 ? rd_addr : rt_addr} << 2;
    wire [31:0] wdata = c4 ? alu_wdata : mem_wdata;
    always @(posedge clk) begin
        if(we) begin
            reg_space[waddr+3] <= wdata[31:24];
            reg_space[waddr+2] <= wdata[23:16];
            reg_space[waddr+1] <= wdata[15:8];
            reg_space[waddr] <= wdata[7:0];
        end
    end
endmodule
