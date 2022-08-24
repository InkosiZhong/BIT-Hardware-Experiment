`timescale 1ns / 1ps

module single_cycle_cpu(
    input clk,
    input rst
    );
    wire jmp;
    wire branch;
    wire [31:0] offset;
    wire [31:0] target;
    wire [31:0] pc_value;
    wire [31:0] inst;
    wire [5:0] op_code = inst[31:26];
    wire [4:0] rs_addr = inst[25:21]; // also for base
    wire [4:0] rt_addr = inst[20:16];
    wire [4:0] rd_addr = inst[15:11];
    wire [5:0] func_code = inst[5:0];
    wire [15:0] imm_num = inst[15:0];   // immediate number
    wire [25:0] instr_index = inst[25:0];
    wire [3:0] high_pc = pc_value[31:28];
    wire [1:0] cA;
    wire [1:0] cB;
    wire c1;
    wire c2;
    wire c3;
    wire c4;
    wire we_d_mem;
    wire we_reg;
    wire [31:0] d_mem_data;
    wire [31:0] alu_res;
    wire [31:0] reg1_data;
    wire [31:0] reg2_data;
    wire alu_err;
    
    controller controller(
        .op_code(op_code),
        .func_code(func_code),
        .cA(cA),    // 0:+, 1:<<, 2:=
        .cB(cB),    // c5 and c6 are depend on cB and br_unit
        .c1(c1),
        .c2(c2),
        .c3(c3),
        .c4(c4),
        .we_d_mem(we_d_mem),    // write enable for data memory
        .we_reg(we_reg)       // write enable for register heap
    );
    
    pc pc(
        .clk(clk),
        .rst(rst),
        .jmp(jmp),
        .br(branch),
        .offset(offset),
        .target(target),
        .pc_output(pc_value)
    );
    
    i_mem i_mem(
        .clk(clk),
        .rst(rst),
        .addr(pc_value),
        .inst(inst)
    );
    
    d_mem d_mem(
        .clk(clk),
        .rst(rst),
        .we(we_d_mem),
        .addr(alu_res),
        .wdata(reg2_data),
        .rdata(d_mem_data)
    );
    
    alu alu(
        .cA(cA),
        .c2(c2),
        .c3(c3),
        .reg1_in(reg1_data),
        .reg2_in(reg2_data),
        .imm_in(imm_num),
        .out(alu_res),
        .err(alu_err)
    );
    
    reg_heap reg_heap(
        .clk(clk),
        .rst(rst),
        .we(we_reg),           // write_enable
        .c1(c1),
        .c4(c4),
        .reg1_addr(rs_addr),
        .reg2_addr(rt_addr),
        .rt_addr(rt_addr),
        .rd_addr(rd_addr),
        .mem_wdata(d_mem_data),   // data from data memory
        .alu_wdata(alu_res),   // data from alu
        .reg1_data(reg1_data),
        .reg2_data(reg2_data)
    );
    
    br_unit br_unit(
        .rs_data(reg1_data),
        .rt_data(reg2_data),
        .src_offset(imm_num),
        .high_pc(high_pc),
        .instr_index(instr_index),
        .cB(cB),
        .offset(offset),
        .target(target),
        .br(branch),
        .jmp(jmp)
    );
endmodule
