`timescale 1ns / 1ps

module alu(
    // 1 +, 2 -, 3 *, 4 /, 5 +s, 6 -s, 7 *s, 8 /s, 9 =
    // 10 &, 11 |, 12 ^, 13 ~|, 14 <<, 15 >>, 16 >>a
    // 17 ==, 18 !=, 19 <=, 20 >=, 21 <, 22 >, 23 ==0, 24 !=0, 25 <=0, 26 >=0, 27 <0, 28 >0
    input [4:0] i_alu_c,
    input i_alu_sc,
    input [31:0] i_reg1_data,
    input [31:0] i_reg2_data,
    input [31:0] i_imm,
    output [31:0] o_res
    );
    wire [31:0] in1 = i_reg1_data;
    wire [31:0] in2 = i_alu_sc ? i_reg2_data : i_imm;
    assign o_res = (i_alu_c == 1 || i_alu_c == 5) ? in1 + in2 : 
                   (i_alu_c == 16) ? in2 >> in1 :
                   (i_alu_c == 17) ? in2 == in1 :
                   {i_imm, 16'h0000};   // lui
endmodule