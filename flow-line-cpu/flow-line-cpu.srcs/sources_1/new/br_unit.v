`timescale 1ns / 1ps

module br_unit(
    input [31:0] i_offset,
    input [31:0] i_pc,
    input [25:0] i_instr_index,
    input i_br,        // branch
    input i_j,         // jump
    output [31:0] o_pc
    );
    wire [31:0] offset;
    wire [31:0] target;
    assign offset = i_offset << 2;
    assign target = {i_pc[31:28], {{2{i_instr_index[25]}}, i_instr_index} << 2};
    assign o_pc = i_br ? i_pc + 4 + offset : target;
endmodule
