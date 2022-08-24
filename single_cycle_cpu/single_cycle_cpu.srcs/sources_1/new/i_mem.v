`timescale 1ns / 1ps

// instruction memory
module i_mem(
    input clk,
    input rst,
    input [31:0] addr,
    output [31:0] inst // instruction
    );
    reg [7:0] i_mem_space[255:0];
    initial begin
        $readmemh("D:/LAB/cpu/single_cycle_cpu/inst.txt", i_mem_space);
    end
    wire[7:0] low_addr = addr[7:0];
    assign inst = {i_mem_space[low_addr+3],
                   i_mem_space[low_addr+2],
                   i_mem_space[low_addr+1],
                   i_mem_space[low_addr]};
endmodule
