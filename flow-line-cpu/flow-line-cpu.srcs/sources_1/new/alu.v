`timescale 1ns / 1ps

module alu(
    input [1:0] i_alu_c,    // 0:+, 1:<<, 2:=, 3:==
    input i_alu_sc,
    input [31:0] i_reg1_data,
    input [31:0] i_reg2_data,
    input [31:0] i_imm,
    output [31:0] o_res
    );
    wire [31:0] in1 = i_reg1_data;
    wire [31:0] in2 = i_alu_sc ? i_reg2_data : i_imm;
    assign o_res = (i_alu_c == 0) ? in1 + in2 : 
                   (i_alu_c == 1) ? in2 >> in1 :
                   (i_alu_c == 3) ? in2 == in1 :
                   {i_imm, 16'h0000};   // lui
endmodule