`timescale 1ns / 1ps

module br_unit(
    input [31:0] rs_data,
    input [31:0] rt_data,
    input [15:0] src_offset,
    input [3:0] high_pc,
    input [25:0] instr_index,
    input [1:0] cB,
    output [31:0] offset,
    output [31:0] target,
    output br,       // branch, c5
    output jmp       // jump, c6
    );
    assign offset = {{16{src_offset[15]}}, src_offset} << 2;                // src_offset*4
    assign target = {high_pc, {{2{instr_index[25]}}, instr_index} << 2};    // [high_pc, instr_index*4]
    assign br = (cB != 2'b01 || rt_data != rs_data);
    assign jmp = (cB != 2'b10);
endmodule
