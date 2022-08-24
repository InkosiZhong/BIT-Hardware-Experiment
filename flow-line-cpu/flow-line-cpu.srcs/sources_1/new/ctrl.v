`timescale 1ns / 1ps

module ctrl(
    input [5:0] i_op_code,
    input [5:0] i_func_code,
    output [1:0] o_alu_c,    // 0:+, 1:<<, 2:=, 3:==
    output o_br,        // branch
    output o_j,         // jump
    output o_reg_dc,    // dst control (addr)
    output o_alu_sc,    // src control
    output o_reg_wc,    // write control (data)
    output o_dmem_we,   // write enable for data memory
    output o_reg_we,    // write enable for register heap
    output o_ext_type
    );
    wire [2:0] inst_type; /* 0:lui, 1:lw, 2:sw, 3:addiu, 4:add, 5:srav, 6:beq, 7:j
    lui     001111
    lw      100011
    sw      101011
    addiu   001000
    add     000000 100000
    srav    000000 000111
    beq     000100
    j       000010
    */
    assign inst_type = (i_op_code == 6'b000010) ? 7 :
                       (i_op_code == 6'b000100) ? 6 :
                       (i_op_code == 6'b001001) ? 3 :
                       (i_op_code == 6'b001111) ? 0 :
                       (i_op_code == 6'b100011) ? 1 :
                       (i_op_code == 6'b101011) ? 2 :
                       (i_func_code == 6'b000111) ? 5 : 4;
    assign o_alu_c = (inst_type == 0) ? 2'b10 :
                     (inst_type == 5) ? 2'b01 : 
                     (inst_type == 6) ? 2'b11 : 2'b00;
    assign o_br = (inst_type == 6);
    assign o_j = (inst_type == 7);
    assign o_reg_dc = (inst_type == 4 || inst_type == 5 || inst_type == 6);
    assign o_alu_sc = o_reg_dc;
    assign o_reg_wc = inst_type == 1;
    assign o_dmem_we = (inst_type == 2);
    assign o_reg_we = ~(inst_type == 2 || inst_type == 6 || inst_type == 7);
    assign o_ext_type = (inst_type != 3);
endmodule
