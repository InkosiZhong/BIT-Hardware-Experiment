`timescale 1ns / 1ps

`include "macro.vh"

module ctrl(
    input [5:0] i_op_code,
    input [5:0] i_func_code,
    // 1 +, 2 -, 3 *, 4 /, 5 +s, 6 -s, 7 *s, 8 /s, 9 =
    // 10 &, 11 |, 12 ^, 13 ~|, 14 <<, 15 >>, 16 >>a
    // 17 ==, 18 !=, 19 <=, 20 >=, 21 <, 22 >, 23 ==0, 24 !=0, 25 <=0, 26 >=0, 27 <0, 28 >0
    output [4:0] o_alu_c,
    output o_br,        // branch
    output o_j,         // jump
    output o_reg_dc,    // dst control (addr)
    output o_alu_sc,    // src control
    output o_reg_wc,    // write control (data)
    // 1:byte 2:halfword 3:byte(s) 4:halfword(s) 5:left 6:right 7:word
    output [2:0] o_dmem_mode, // write / read mode
    output o_dmem_we,   // write enable for data memory
    output o_reg_we,    // write enable for register heap
    output o_ext_type
    );
    
    assign o_alu_c = // +
                     (i_op_code == `OP_J | i_op_code == `OP_JAL | i_op_code == `OP_ADDIU | 
                      i_op_code == `OP_LB | i_op_code == `OP_LH | i_op_code == `OP_LWL | 
                      i_op_code == `OP_LW | i_op_code == `OP_LBU | i_op_code == `OP_LHU |
                      i_op_code == `OP_LWR | i_op_code == `OP_SB | i_op_code == `OP_SH | 
                      i_op_code == `OP_SH | i_op_code == `OP_SWL | i_op_code == `OP_SW |
                      i_op_code == `OP_SWR | 
                      (i_op_code == `OP_SPCL & i_func_code == `FUNC_ADDU)) ? 1 : 
                      // -
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_SUBU) ? 2 :
                      // *
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_MULTU) ? 3 :
                      // /
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_DIVU) ? 4 :
                      // +s
                     (i_op_code == `OP_ADDI | 
                      (i_op_code == `OP_SPCL & i_func_code == `FUNC_ADD)) ? 5 :
                      // -s
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_SUB) ? 6 : 
                      // *s
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_MULT) ? 7 : 
                      // /s
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_DIV) ? 8 : 
                      // =
                     (i_op_code == `OP_LUI) ? 9 : 
                      // &
                     (i_op_code == `OP_ANDI | 
                      (i_op_code == `OP_SPCL & i_func_code == `FUNC_AND)) ? 10 : 
                      // |
                     (i_op_code == `OP_ORI | 
                      (i_op_code == `OP_SPCL & i_func_code == `FUNC_OR)) ? 11 : 
                      // ^
                     (i_op_code == `OP_XORI | 
                      (i_op_code == `OP_SPCL & i_func_code == `FUNC_XOR)) ? 12 : 
                      // ~|
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_NOR) ? 13 : 
                      // <<
                     (i_op_code == `OP_SPCL & 
                      (i_func_code == `FUNC_SLL | i_func_code == `FUNC_SLLV)) ? 14 : 
                      // >>
                     (i_op_code == `OP_SPCL & 
                      (i_func_code == `FUNC_SRL | i_func_code == `FUNC_SRLV)) ? 15 : 
                      // >>a
                     (i_op_code == `OP_SPCL & 
                      (i_func_code == `FUNC_SRA | i_func_code == `FUNC_SRAV)) ? 16 : 
                      // ==
                     (i_op_code == `OP_BEQ) ? 17 :  
                      // !=
                     (i_op_code == `OP_BNE) ? 18 : 
                      // <
                     (i_op_code == `OP_SLTI | i_op_code == `OP_SLTIU) ? 21 : 
                      // ==0
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_MOVZ) ? 23 : 
                      // <=0
                     (i_op_code == `OP_BLEZ) ? 25 : 
                      // >0
                     (i_op_code == `OP_BGTZ) ? 28 : 0;
    assign o_br = (i_op_code == `OP_BEQ | i_op_code == `OP_BNE | 
                   i_op_code == `OP_BLEZ | i_op_code == `OP_BGTZ);
    assign o_j = (i_op_code == `OP_J | i_op_code == `OP_JAL |
                  i_op_code == `OP_SPCL & (i_func_code == `FUNC_JR | i_func_code == `FUNC_JALR));
    assign o_reg_dc = (i_op_code == `OP_SPCL & 
                       (i_func_code == `FUNC_SLLV | i_func_code == `FUNC_SRLV |
                        i_func_code == `FUNC_SRAV | i_func_code == `FUNC_MULT |
                        i_func_code == `FUNC_MULTU | i_func_code == `FUNC_DIV |
                        i_func_code == `FUNC_DIVU | i_func_code == `FUNC_ADD |
                        i_func_code == `FUNC_ADDU | i_func_code == `FUNC_SUB |
                        i_func_code == `FUNC_SUBU | i_func_code == `FUNC_AND |
                        i_func_code == `FUNC_OR | i_func_code == `FUNC_XOR |
                        i_func_code == `FUNC_NOR));
    assign o_alu_sc = (i_op_code == `OP_ADDI | i_op_code == `OP_ADDIU | i_op_code == `OP_SLTI |
                       i_op_code == `OP_SLTIU | i_op_code == `OP_ANDI | i_op_code == `OP_ORI |
                       i_op_code == `OP_XORI | i_op_code == `OP_LUI | i_op_code == `OP_LB |
                       i_op_code == `OP_LH | i_op_code == `OP_LWL | i_op_code == `OP_LW |
                       i_op_code == `OP_LBU | i_op_code == `OP_LHU | i_op_code == `OP_LWR |
                       i_op_code == `OP_SB | i_op_code == `OP_SH | i_op_code == `OP_SWL |
                       i_op_code == `OP_SW | i_op_code == `OP_SWR | (i_op_code == `OP_SPCL & 
                       (i_func_code == `FUNC_SLL | i_func_code == `FUNC_SRL | 
                        i_func_code == `FUNC_SRA)));
    assign o_reg_wc = (i_op_code == `OP_LB | i_op_code == `OP_LH | i_op_code == `OP_LWL | 
                       i_op_code == `OP_LW | i_op_code == `OP_LBU | i_op_code == `OP_LHU | 
                       i_op_code == `OP_LWR);
    assign o_dmem_we = (i_op_code == `OP_SB | i_op_code == `OP_SH | i_op_code == `OP_SWL | 
                        i_op_code == `OP_SW | i_op_code == `OP_SWR);
    assign o_reg_we = ~(i_op_code == `OP_J | i_op_code == `OP_BEQ | i_op_code == `OP_BNE |
                        i_op_code == `OP_BLEZ | i_op_code == `OP_BGTZ | i_op_code == `OP_SB |
                        i_op_code == `OP_SH | i_op_code == `OP_SWL | i_op_code == `OP_SW |
                        i_op_code == `OP_SWR | (i_op_code == `OP_SPCL & i_func_code == `FUNC_JR));
    assign o_ext_type = ~(i_op_code == `OP_ADDIU | i_op_code == `OP_SLTIU | i_op_code == `OP_LBU |
                          i_op_code == `OP_LHU | (i_op_code == `OP_SPCL & 
                          (i_func_code == `FUNC_MULTU | i_func_code == `FUNC_DIVU |
                           i_func_code == `FUNC_ADDU | i_func_code == `FUNC_SUBU)));
    // 1:byte 2:halfword 3:byte(s) 4:halfword(s) 5:left 6:right 7:word
    assign o_dmem_mode = (i_op_code == `OP_LBU) ? 1 :
                         (i_op_code == `OP_LHU) ? 2 :
                         (i_op_code == `OP_LB | i_op_code == `OP_SB) ? 3 :
                         (i_op_code == `OP_LH | i_op_code == `OP_SH) ? 4 :
                         (i_op_code == `OP_LWL | i_op_code == `OP_SWL) ? 5 :
                         (i_op_code == `OP_LWR | i_op_code == `OP_SWR) ? 6 :
                         (i_op_code == `OP_LW | i_op_code == `OP_SW) ? 7 : 0;
endmodule
