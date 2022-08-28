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
    output [31:0] o_lo_res,
    output [31:0] o_hi_res
    );
    wire [31:0] in1 = i_reg1_data;
    wire [31:0] in2 = i_alu_sc ? i_imm : i_reg2_data;
    wire s1 = in1[31];
    wire s2 = in2[31];
    wire [31:0] in1u = s1 ? ~in1+1 : in1;
    wire [31:0] in2u = s2 ? ~in2+1 : in2;
    wire [64:0] full_res = (i_alu_c == 3) ? in1 * in2 : 
                           (i_alu_c == 7) ? (s1 ^ s2) ? ~(in1u * in2u) + 1 : in1u * in2u : 0;
    assign o_lo_res = (i_alu_c == 1 || i_alu_c == 5) ? in1 + in2 : 
                      (i_alu_c == 2 || i_alu_c == 6) ? in1 - in2 : 
                      (i_alu_c == 3 || i_alu_c == 7) ? full_res[31:0] :
                      (i_alu_c == 4) ? in1 / in2 :
                      (i_alu_c == 8) ? (s1 ^ s2) ? ~(in1u / in2u) + 1 : in1u / in2u :
                      (i_alu_c == 9) ? {i_imm, 16'h0000} :
                      (i_alu_c == 10) ? in1 & in2 :
                      (i_alu_c == 11) ? in1 | in2 :
                      (i_alu_c == 12) ? in1 ^ in2 :
                      (i_alu_c == 13) ? ~(in1 | in2) :
                      (i_alu_c == 14) ? in2 << in1 :   // SLLV
                      (i_alu_c == 15) ? in2 >> in1 :   // SRLV
                      (i_alu_c == 16) ? in2 >>> in1 :  // SRAV
                      (i_alu_c == 17) ? in1 == in2 :
                      (i_alu_c == 18) ? in1 != in2 :
                      (i_alu_c == 19) ? in1 <= in2 :
                      (i_alu_c == 20) ? in1 >= in2 :
                      (i_alu_c == 21) ? in1 < in2 :
                      (i_alu_c == 22) ? in1 > in2 :
                      (i_alu_c == 23) ? in2 == 0 :     // MOVZ
                      (i_alu_c == 24) ? in2 != 0 :     // MOVN
                      (i_alu_c == 25) ? in1[31] == 1 | in1 == 0 :     // BLEZ
                      (i_alu_c == 26) ? in1[31] == 0 :                // BGEZ
                      (i_alu_c == 27) ? in1[31] == 1 :                // BLTZ
                      (i_alu_c == 28) ? in1[31] == 0 & in1 > 0 :      // BGTZ
                      32'b0;   // default
      assign o_hi_res = (i_alu_c == 3 || i_alu_c == 7) ? full_res[63:32] :
                        (i_alu_c == 4) ? in1 % in2 : 
                        (i_alu_c == 8) ? s1 ? ~(in1u / in2u) + 1 : in1u / in2u : 0;
endmodule