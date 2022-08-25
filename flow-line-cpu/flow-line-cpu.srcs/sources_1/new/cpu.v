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
    wire br1, j1;
    wire reg_dc1;
    wire alu_sc1;
    wire [1:0] reg_wc1;
    wire dmem_we1, dmem_we2;
    wire reg_we1, reg_we2, reg_we4;
    wire ext_type;
    wire [31:0] reg1_data2;
    wire [31:0] reg2_data2;
    wire [4:0] alu_c2;
    wire br2;
    wire j2;
    wire reg_dc2;
    wire alu_sc2;
    wire [1:0] reg_wc2;
    wire [2:0] dmem_mode1;
    wire [31:0] pc3;
    wire [31:0] dmem_rdata2;
    wire [31:0] alu_lo_res3;
    wire [31:0] alu_hi_res3;
    wire [4:0] reg_waddr2;
    wire [1:0] reg_wc4;
    wire spcl_we1, spcl_we4;
    wire spcl_rc;
    wire [31:0] spcl_data1;
    wire [31:0] spcl_data3;
    wire [31:0] spcl_data4;
    
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
        .o_spcl_we(spcl_we1),
        .o_spcl_rc(spcl_rc),
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
        .i_alu_wdata(alu_lo_res3),
        .i_spcl_wdata(spcl_data4),
        .o_reg1_data(reg1_data1),
        .o_reg2_data(reg2_data1)
    );
    
    spcl_reg spcl_reg(
        .clk(clk),
        .rst(rst),
        .i_we(spcl_we4),
        .i_rc(spcl_rc),
        .i_lo_wdata(alu_lo_res3),
        .i_hi_wdata(alu_hi_res3),
        .o_spcl_data(spcl_data1)
    );
    
    wire [31:0] reg1_wo_raw;
    wire [31:0] reg2_wo_raw;
    wire [31:0] spcl_wo_raw;
    wire reg_we3, spcl_we2;
    wire [1:0] reg_wc3;
    wire [2:0] dmem_mode2;
    wire [4:0] reg_waddr1;
    wire [31:0] alu_lo_res1;
    wire [31:0] alu_lo_res2;
    wire [31:0] alu_hi_res1;
    wire [31:0] alu_hi_res2;
    wire [31:0] dmem_rdata1;
    wire [31:0] spcl_data2;
    wire spcl_we3;
    raw_handler raw_handler(
        // current instruction
        .i_reg1_addr(reg1_addr),
        .i_reg2_addr(rt_addr1),
        .i_en_reg1(alu_c1 != 9),
        .i_en_reg2(~alu_sc1),
        .i_en_spcl(reg_wc1 == 2),
        // last instructions
        .i_last_waddr1(reg_dc2 ? rd_addr2 : rt_addr2),
        .i_last_waddr2(reg_waddr1),
        .i_last_waddr3(reg_waddr2),
        .i_reg_wc1(reg_wc2),
        .i_reg_we1((reg_wc1 == 2) ? spcl_we2 : reg_we2),
        .i_reg_we2((reg_wc1 == 2) ? spcl_we3 : reg_we3),
        .i_reg_we3((reg_wc1 == 2) ? spcl_we4 : reg_we4),
        .i_reg_wdata1(((reg_we2 & reg_wc2 == 0) | ~spcl_rc) ?  alu_lo_res1 : alu_hi_res1),
        .i_reg_wdata2((reg_we3 & reg_wc3 == 1) ? dmem_rdata1 : 
                      ((reg_we3 & reg_wc3 == 0) | ~spcl_rc) ? alu_lo_res2 : alu_hi_res2),
        .i_reg_wdata3((reg_we4 & reg_wc4 == 1) ? dmem_rdata2 : 
                      ((reg_we4 & reg_wc4 == 0) | ~spcl_rc) ? alu_lo_res3 : alu_hi_res3),
        .i_reg1_data(reg1_data1),
        .i_reg2_data(reg2_data1),
        .i_spcl_data(spcl_data1),
        .o_wait(wait1clk),
        .o_reg1_data(reg1_wo_raw),
        .o_reg2_data(reg2_wo_raw),
        .o_spcl_data(spcl_wo_raw)
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
        .i_spcl_we(spcl_we1),
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
        .i_spcl_data(spcl_wo_raw),
        // cmd
        .o_reg_we(reg_we2),
        .o_reg_wc(reg_wc2),
        .o_dmem_we(dmem_we2),
        .o_spcl_we(spcl_we2),
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
        .o_instr_index(instr_index2),
        .o_spcl_data(spcl_data2)
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
        .o_lo_res(alu_lo_res1),
        .o_hi_res(alu_hi_res1)
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
        .i_spcl_we(spcl_we2),
        .i_dmem_mode(dmem_mode2),
        .i_br(br2),
        .i_jmp(j2),
        // data
        .i_alu_lo_res(alu_lo_res1),
        .i_alu_hi_res(alu_hi_res1),
        .i_dmem_wdata(reg2_data2),
        .i_reg_waddr(reg_dc2 ? rd_addr2 : rt_addr2),
        .i_pc(pc4),
        .i_spcl_data(spcl_data2),
        // cmd
        .o_reg_we(reg_we3),
        .o_reg_wc(reg_wc3),
        .o_dmem_we(dmem_we3),
        .o_spcl_we(spcl_we3),
        .o_dmem_mode(dmem_mode3),
        .o_jc(jc),
        // data
        .o_alu_lo_res(alu_lo_res2),
        .o_alu_hi_res(alu_hi_res2),
        .o_dmem_wdata(dmem_wdata),
        .o_reg_waddr(reg_waddr1),
        .o_pc(j_pc),
        .o_spcl_data(spcl_data3)
    );
    
    // stage 4
    d_mem d_mem(
        .clk(clk),
        .rst(rst),
        .i_we(dmem_we3),
        .i_mode(dmem_mode3),
        .i_addr(alu_lo_res2),
        .i_wdata(dmem_wdata),
        .o_rdata(dmem_rdata1)
    );
    
    buffer4 buffer4(
        .clk(clk),
        .rst(rst),
        // cmd
        .i_reg_we(reg_we3),
        .i_reg_wc(reg_wc3),
        .i_spcl_we(spcl_we3),
        // data
        .i_alu_lo_res(alu_lo_res2),
        .i_alu_hi_res(alu_hi_res2),
        .i_dmem_rdata(dmem_rdata1),
        .i_reg_waddr(reg_waddr1),
        .i_spcl_data(spcl_data3),
        // cmd
        .o_reg_we(reg_we4),
        .o_reg_wc(reg_wc4),
        .o_spcl_we(spcl_we4),
        // data
        .o_alu_lo_res(alu_lo_res3),
        .o_alu_hi_res(alu_hi_res3),
        .o_dmem_rdata(dmem_rdata2),
        .o_reg_waddr(reg_waddr2),
        .o_spcl_data(spcl_data4)
    );
    
endmodule
