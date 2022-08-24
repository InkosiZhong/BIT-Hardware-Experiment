`timescale 1ns / 1ps

module d_mem(
    input clk,
    input rst,
    input i_we, // write_enable
    input [31:0] i_addr,
    input [31:0] i_wdata, // data to write
    output [31:0] o_rdata // data to read
    );
    reg [7:0] d_mem_space [255:0];
    initial begin
        $readmemh("D:/LAB/cpu/flow-line-cpu/data.txt", d_mem_space);
    end
    wire [7:0] low_addr = i_addr[7:0];
    assign o_rdata = {d_mem_space[low_addr+3],
                      d_mem_space[low_addr+2],
                      d_mem_space[low_addr+1],
                      d_mem_space[low_addr]};
                    
    always @(posedge clk) begin
        if(i_we) begin
            d_mem_space[low_addr+3] <= i_wdata[31:24];
            d_mem_space[low_addr+2] <= i_wdata[23:16];
            d_mem_space[low_addr+1] <= i_wdata[15:8];
            d_mem_space[low_addr] <= i_wdata[7:0];
        end
    end
endmodule
