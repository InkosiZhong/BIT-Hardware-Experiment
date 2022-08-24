`timescale 1ns / 1ps

module controller(
    input [5:0] op_code,
    input [5:0] func_code,
    output [1:0] cA,    // 0:+, 1:<<, 2:=
    output [1:0] cB,    // c5 and c6 are depend on cB and br_unit
    output c1,
    output c2,
    output c3,
    output c4,
    output we_d_mem,    // write enable for data memory
    output we_reg       // write enable for register heap
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
    assign inst_type = (op_code == 6'b000010) ? 7 :
                       (op_code == 6'b000100) ? 6 :
                       (op_code == 6'b001001) ? 3 :
                       (op_code == 6'b001111) ? 0 :
                       (op_code == 6'b100011) ? 1 :
                       (op_code == 6'b101011) ? 2 :
                       (func_code == 6'b000111) ? 5 : 4;
    assign cA = (inst_type == 0) ? 2'b10 :
                (inst_type == 5) ? 2'b01 : 2'b00;
    assign cB = (inst_type == 6) ? 2'b01 :
                (inst_type == 7) ? 2'b10 : 2'b00;
    assign c1 = (inst_type == 4 || inst_type == 5);
    assign c2 = 1;
    assign c3 = c1;
    assign c4 = inst_type != 1;
    assign we_d_mem = (inst_type == 2);
    assign we_reg = ~(inst_type == 2 || inst_type == 6 || inst_type == 7);
endmodule
