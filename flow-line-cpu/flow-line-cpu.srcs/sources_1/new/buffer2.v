`timescale 1ns / 1ps

module buffer2(
    input clk,
    input rst,
    input i_flush,
    // cmd
    input i_reg_we, // write enable
    input i_reg_wc, // write control
    input i_dmem_we,
    input i_br,
    input i_jmp,
    input [4:0] i_alu_c,
    input i_alu_sc, // src control
    input i_reg_dc, // dst control
    // data
    input [31:0] i_reg1_data,
    input [31:0] i_reg2_data,
    input [4:0] i_rt_addr,
    input [4:0] i_rd_addr,
    input [31:0] i_imm,
    input [31:0] i_pc,
    input [25:0] i_instr_index,
    // cmd
    output o_reg_we,
    output o_reg_wc,
    output o_dmem_we,
    output o_br,
    output o_jmp,
    output [4:0] o_alu_c,
    output o_alu_sc,
    output o_reg_dc,
    // data
    output [31:0] o_reg1_data,
    output [31:0] o_reg2_data,
    output [4:0] o_rt_addr,
    output [4:0] o_rd_addr,
    output [31:0] o_imm,
    output [31:0] o_pc,
    output [25:0] o_instr_index
    );
    // cmd
    reg buf_reg_we, buf_reg_wc, buf_dmem_we, buf_br, buf_jmp, buf_alu_sc, buf_reg_dc;
    reg [4:0] buf_alu_c;
    assign o_reg_we = buf_reg_we;
    assign o_reg_wc = buf_reg_wc;
    assign o_dmem_we = buf_dmem_we;
    assign o_br = buf_br;
    assign o_jmp = buf_jmp;
    assign o_alu_c = buf_alu_c;
    assign o_alu_sc = buf_alu_sc;
    assign o_reg_dc = buf_reg_dc;
    
    always @(posedge clk or negedge rst) begin
        if(~rst | i_flush) begin
            buf_reg_we <= 0;
            buf_reg_wc <= 0;
            buf_dmem_we <= 0;
            buf_br <= 0;
            buf_jmp <= 0;
            buf_alu_sc <= 0;
            buf_reg_dc <= 0;
            buf_alu_c <= 0;
        end
        else begin
            buf_reg_we <= i_reg_we;
            buf_reg_wc <= i_reg_wc;
            buf_dmem_we <= i_dmem_we;
            buf_br <= i_br;
            buf_jmp <= i_jmp;
            buf_alu_sc <= i_alu_sc;
            buf_reg_dc <= i_reg_dc;
            buf_alu_c <= i_alu_c;
        end
    end
    //data
    reg [31:0] buf_reg1_data;
    reg [31:0] buf_reg2_data;
    reg [4:0] buf_rt_addr;
    reg [4:0] buf_rd_addr;
    reg [31:0] buf_imm;
    reg [31:0] buf_pc;
    reg [25:0] buf_instr_index;
    assign o_reg1_data = buf_reg1_data;
    assign o_reg2_data = buf_reg2_data;
    assign o_rt_addr = buf_rt_addr;
    assign o_rd_addr = buf_rd_addr;
    assign o_imm = buf_imm;
    assign o_pc = buf_pc;
    assign o_instr_index = buf_instr_index;
    
    always @(posedge clk or negedge rst) begin
        if(~rst | i_flush) begin
            buf_reg1_data <= 0;
            buf_reg2_data <= 0;
            buf_rt_addr <= 0;
            buf_rd_addr <= 0;
            buf_imm <= 0;
            buf_pc <= 0;
            buf_instr_index <= 0;
        end
        else begin
            buf_reg1_data <= i_reg1_data;
            buf_reg2_data <= i_reg2_data;
            buf_rt_addr <= i_rt_addr;
            buf_rd_addr <= i_rd_addr;
            buf_imm <= i_imm;
            buf_pc <= i_pc;
            buf_instr_index <= i_instr_index;
        end
    end
endmodule
