`timescale 1ns / 1ps

module alu(
    input [1:0] cA,    // 0:+, 1:<<, 2:=
    input c2,
    input c3,
    input [31:0] reg1_in,
    input [31:0] reg2_in,
    input [15:0] imm_in,
    output [31:0] out,
    output err
    );
    wire [31:0] imm = {{16{imm_in[15]}}, imm_in};
    wire [31:0] in1 = c2 ? reg1_in : imm;
    wire [31:0] in2 = c3 ? reg2_in : imm;
    assign out = (cA == 0) ? in1 + in2 : 
                 (cA == 1) ? in2 >> in1 :
                 {imm_in, 16'h0000};   // lui
    assign err = (cA == 0) & c3 & (in1[31] == in2[31]) & (in1[31] != out[31]);
endmodule