`timescale 1ns / 1ps

`include "macro.vh"

module ctrl(
    input [5:0] i_op_code,
    input [5:0] i_func_code,
    output [4:0] o_alu_c,    // 0:+, 1:<<, 2:=, 3:==
    output o_br,        // branch
    output o_j,         // jump
    output o_reg_dc,    // dst control (addr)
    output o_alu_sc,    // src control
    output o_reg_wc,    // write control (data)
    output o_dmem_we,   // write enable for data memory
    output o_reg_we,    // write enable for register heap
    output o_ext_type
    );
    
    assign o_alu_c = (i_op_code == `OP_LUI) ? 9 :
                     (i_op_code == `OP_SPCL & i_func_code == `FUNC_SRAV) ? 16 : 
                     (i_op_code == `OP_BEQ) ? 17 : 
                     (i_op_code == `OP_ADDIU) ? 1 : 5;
    assign o_br = (i_op_code == `OP_BEQ);
    assign o_j = (i_op_code == `OP_J);
    assign o_reg_dc = (i_op_code == `OP_SPCL | i_op_code == `OP_BEQ);
    assign o_alu_sc = o_reg_dc;
    assign o_reg_wc = (i_op_code == `OP_LW);
    assign o_dmem_we = (i_op_code == `OP_SW);
    assign o_reg_we = ~(i_op_code == `OP_SW | i_op_code == `OP_BEQ | i_op_code == `OP_J);
    assign o_ext_type = (i_op_code != `OP_ADDIU);
endmodule
