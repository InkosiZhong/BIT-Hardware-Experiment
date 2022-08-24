`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input i_jc,
    input i_wait,
    input [31:0] i_pc,
    output [31:0] o_pc
    );
    reg [31:0] pc_buf;
    assign o_pc = pc_buf;
    
    always @(posedge clk or negedge rst) begin
        if(~rst)
            pc_buf = 0;
        else if(i_jc)
                pc_buf <= i_pc;
        else if(~i_wait)
            pc_buf <= pc_buf + 4;
    end
endmodule