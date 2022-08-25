`timescale 1ns / 1ps

module cpu(
    input clk,
    input rst
    );
    wire jc;
    wire [31:0] j_pc;  // jump target
    wire [31:0] pc1;
    wire [31:0] inst1;
    wire [31:0] pc2;
    wire [31:0] inst2;
    wire wait1clk;
    
    pc pc(
        .clk(clk),
        .rst(rst),
        .i_jc(jc),
        .i_pc(j_pc),
        .i_wait(wait1clk),
        .o_pc(pc1)
    );
    
    // stage 1
    i_mem i_mem(
        .i_addr(pc1),
        .o_inst(inst1)
    );
    
    buffer1 buffer1(
        .clk(clk),
        .rst(rst),
        .i_flush(jc),
        .i_wait(wait1clk),
        .i_inst(inst1),
        .i_pc(pc1),
        .o_inst(inst2),
        .o_pc(pc2)
    );
    
    wire [5:0] op_code1 = inst2[31:26];
    wire [5:0] func_code1 = inst2[5:0];
    wire [4:0] reg1_addr = inst2[25:21];
    wire [4:0] rt_addr1 = inst2[20:16];
    wire [4:0] rd_addr1 = inst2[15:11];
    wire [4:0] rt_addr2;
    wire [4:0] rd_addr2;
    wire [15:0] src_imm = inst2[15:0];
    wire [25:0] instr_index1 = inst2[25:0];
    wire [25:0] instr_index2;
    wire [31:0] imm1;
    wire [31:0] imm2;
    wire [31:0] reg1_data1;
    wire [31:0] reg2_data1;
    wire [4:0] alu_c1;
    wire br1;
    wire j1;
    wire reg_dc1;
    wire alu_sc1;
    wire reg_wc1;
    wire dmem_we1;
    wire reg_we1;
    wire ext_type;
    wire [31:0] reg1_data2;
    wire [31:0] reg2_data2;
    wire [4:0] alu_c2;
    wire br2;
    wire j2;
    wire reg_dc2;
    wire alu_sc2;
    wire reg_wc2;
    wire dmem_we2;
    wire reg_we2;
    wire [2:0] dmem_mode1;
    wire [31:0] pc3;
    wire [31:0] dmem_rdata2;
    wire [31:0] alu_res3;
    wire [4:0] reg_waddr2;
    wire reg_we4, reg_wc4;
    
    // stage 2
    ctrl ctrl(
        .i_op_code(op_code1),
        .i_func_code(func_code1),
        .o_alu_c(alu_c1),
        .o_br(br1),
        .o_j(j1),
        .o_reg_dc(reg_dc1),
        .o_alu_sc(alu_sc1),
        .o_reg_wc(reg_wc1),
        .o_dmem_we(dmem_we1),
        .o_dmem_mode(dmem_mode1),
        .o_reg_we(reg_we1),
        .o_ext_type(ext_type)
    );
    
    reg_heap reg_heap(
        .clk(clk),
        .rst(rst),
        .i_we(reg_we4),
        .i_reg_wc(reg_wc4),
        .i_reg1_addr(reg1_addr),
        .i_reg2_addr(rt_addr1),
        .i_reg3_addr(reg_waddr2),
        .i_mem_wdata(dmem_rdata2),
        .i_alu_wdata(alu_res3),
        .o_reg1_data(reg1_data1),
        .o_reg2_data(reg2_data1)
    );
    
    wire [31:0] reg1_wo_raw;
    wire [31:0] reg2_wo_raw;
    wire reg_we3, reg_wc3;
    wire [2:0] dmem_mode2;
    wire [4:0] reg_waddr1;
    wire [31:0] alu_res1;
    wire [31:0] alu_res2;
    wire [31:0] dmem_rdata1;
    raw_handler raw_handler(
        // current instruction
        .i_reg1_addr(reg1_addr),
        .i_reg2_addr(rt_addr1),
        .i_en_reg1(alu_c2 != 9),
        .i_en_reg2(~alu_sc2),
        // last instructions
        .i_last_waddr1(reg_dc2 ? rd_addr2 : rt_addr2),
        .i_last_waddr2(reg_waddr1),
        .i_last_waddr3(reg_waddr2),
        .i_reg_wc1(reg_wc2),
        .i_reg_wc2(reg_wc3),
        .i_reg_wc3(reg_wc4),
        .i_reg_we1(reg_we2),
        .i_reg_we2(reg_we3),
        .i_reg_we3(reg_we4),
        .i_reg_wdata1(alu_res1),
        .i_reg_wdata2(reg_wc3 ? dmem_rdata1 : alu_res2),
        .i_reg_wdata3(reg_wc4 ? dmem_rdata2 : alu_res3),
        .i_reg1_data(reg1_data1),
        .i_reg2_data(reg2_data1),
        .o_wait(wait1clk),
        .o_reg1_data(reg1_wo_raw),
        .o_reg2_data(reg2_wo_raw)
    );
    
    sign_ext sign_ext(
        .ext_type(ext_type),
        .i_data(src_imm),
        .o_data(imm1)
    );
    
    buffer2 buffer2(
        .clk(clk),
        .rst(rst),
        .i_flush(jc | wait1clk),
        // cmd
        .i_reg_we(reg_we1),
        .i_reg_wc(reg_wc1),
        .i_dmem_we(dmem_we1),
        .i_dmem_mode(dmem_mode1),
        .i_br(br1),
        .i_jmp(j1),
        .i_alu_c(alu_c1),
        .i_alu_sc(alu_sc1),
        .i_reg_dc(reg_dc1),
        // data
        .i_reg1_data(reg1_wo_raw),
        .i_reg2_data(reg2_wo_raw),
        .i_rt_addr(rt_addr1),
        .i_rd_addr(rd_addr1),
        .i_imm(imm1),
        .i_pc(pc2),
        .i_instr_index(instr_index1),
        // cmd
        .o_reg_we(reg_we2),
        .o_reg_wc(reg_wc2),
        .o_dmem_we(dmem_we2),
        .o_dmem_mode(dmem_mode2),
        .o_br(br2),
        .o_jmp(j2),
        .o_alu_c(alu_c2),
        .o_alu_sc(alu_sc2),
        .o_reg_dc(reg_dc2),
        // data
        .o_reg1_data(reg1_data2),
        .o_reg2_data(reg2_data2),
        .o_rt_addr(rt_addr2),
        .o_rd_addr(rd_addr2),
        .o_imm(imm2),
        .o_pc(pc3),
        .o_instr_index(instr_index2)
    );
    
    wire [31:0] pc4;
    wire [31:0] dmem_wdata;
    wire [2:0] dmem_mode3;
    wire dmem_we3;
    // stage 3
    alu alu(
        .i_alu_c(alu_c2),
        .i_alu_sc(alu_sc2),
        .i_reg1_data(reg1_data2),
        .i_reg2_data(reg2_data2),
        .i_imm(imm2),
        .o_res(alu_res1)
    );
    
    br_unit br_unit(
        .i_offset(imm2),
        .i_pc(pc3),
        .i_instr_index(instr_index2),
        .i_br(br2),
        .i_j(j2),
        .o_pc(pc4)
    );
    
    buffer3 buffer3(
        .clk(clk),
        .rst(rst),
        .i_flush(jc),
        // cmd
        .i_reg_we(reg_we2),
        .i_reg_wc(reg_wc2),
        .i_dmem_we(dmem_we2),
        .i_dmem_mode(dmem_mode2),
        .i_br(br2),
        .i_jmp(j2),
        // data
        .i_alu_res(alu_res1),
        .i_dmem_wdata(reg2_data2),
        .i_reg_waddr(reg_dc2 ? rd_addr2 : rt_addr2),
        .i_pc(pc4),
        // cmd
        .o_reg_we(reg_we3),
        .o_reg_wc(reg_wc3),
        .o_dmem_we(dmem_we3),
        .o_dmem_mode(dmem_mode3),
        .o_jc(jc),
        // data
        .o_alu_res(alu_res2),
        .o_dmem_wdata(dmem_wdata),
        .o_reg_waddr(reg_waddr1),
        .o_pc(j_pc)
    );
    
    // stage 4
    d_mem d_mem(
        .clk(clk),
        .rst(rst),
        .i_we(dmem_we3),
        .i_mode(dmem_mode3),
        .i_addr(alu_res2),
        .i_wdata(dmem_wdata),
        .o_rdata(dmem_rdata1)
    );
    
    buffer4 buffer4(
        .clk(clk),
        .rst(rst),
        // cmd
        .i_reg_we(reg_we3),
        .i_reg_wc(reg_wc3),
        // data
        .i_alu_res(alu_res2),
        .i_dmem_rdata(dmem_rdata1),
        .i_reg_waddr(reg_waddr1),
        // cmd
        .o_reg_we(reg_we4),
        .o_reg_wc(reg_wc4),
        // data
        .o_alu_res(alu_res3),
        .o_dmem_rdata(dmem_rdata2),
        .o_reg_waddr(reg_waddr2)
    );
    
endmodule
