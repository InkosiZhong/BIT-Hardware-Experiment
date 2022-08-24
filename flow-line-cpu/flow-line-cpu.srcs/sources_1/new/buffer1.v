`timescale 1ns / 1ps

module buffer1(
    input clk,
    input rst,
    input i_flush,
    input i_wait,
    input [31:0] i_inst,
    input [31:0] i_pc,
    output [31:0] o_inst,
    output [31:0] o_pc
    );
    reg [31:0] buf_inst;
    reg [31:0] buf_pc;
    assign o_inst = buf_inst;
    assign o_pc = buf_pc;
    always @(posedge clk or negedge rst) begin
        if(~rst | i_flush) begin
            buf_inst <= 0;
            buf_pc <= 0;
        end
        else if (~i_wait) begin
            buf_inst <= i_inst;
            buf_pc <= i_pc;
        end
    end
endmodule
