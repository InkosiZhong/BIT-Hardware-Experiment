`timescale 1ns / 1ps

// data memory
module d_mem(
    input clk,
    input rst,
    input we, // write_enable
    input [31:0] addr,
    input [31:0] wdata, // data to write
    output [31:0] rdata // data to read
    );
    reg [7:0] d_mem_space [255:0];
    initial begin
        $readmemh("D:/LAB/cpu/single_cycle_cpu/data.txt", d_mem_space);
    end
    wire [7:0] low_addr = addr[7:0];
    assign rdata = {d_mem_space[low_addr+3],
                    d_mem_space[low_addr+2],
                    d_mem_space[low_addr+1],
                    d_mem_space[low_addr]};
                    
    always @(posedge clk) begin
        if(we) begin
            d_mem_space[low_addr+3] <= wdata[31:24];
            d_mem_space[low_addr+2] <= wdata[23:16];
            d_mem_space[low_addr+1] <= wdata[15:8];
            d_mem_space[low_addr] <= wdata[7:0];
        end
    end
endmodule
