`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input br,
    input jmp,
    input [31:0] offset,
    input [31:0] target,
    output [31:0] pc_output
    );
    reg [31:0] pc_value = 0;
    assign pc_output = pc_value;
    
    always @(posedge clk) begin
        if(~jmp)
            pc_value <= target;
        else if(~br)
            pc_value <= pc_value + 4 + offset;
        else
            pc_value <= pc_value + 4;
    end
endmodule
