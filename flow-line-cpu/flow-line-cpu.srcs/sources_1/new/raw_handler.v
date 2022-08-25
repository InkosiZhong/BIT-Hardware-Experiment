`timescale 1ns / 1ps

module raw_handler(
    // current instruction
    input [4:0] i_reg1_addr,
    input [4:0] i_reg2_addr,
    input i_en_reg1,
    input i_en_reg2,
    input i_en_spcl,          // enable special registers
    // last instructions
    input [4:0] i_last_waddr1,
    input [4:0] i_last_waddr2,
    input [4:0] i_last_waddr3,
    input [1:0] i_reg_wc1,    // 1: may need to wait
    input i_reg_we1,
    input i_reg_we2,
    input i_reg_we3,
    input [31:0] i_reg_wdata1,
    input [31:0] i_reg_wdata2,
    input [31:0] i_reg_wdata3,
    input [31:0] i_reg1_data, // read from reg_heap
    input [31:0] i_reg2_data,
    input [31:0] i_spcl_data, // read from spcl_reg
    output o_wait,
    output [31:0] o_reg1_data,
    output [31:0] o_reg2_data,
    output [31:0] o_spcl_data
    );
    wire [2:0] reg1_relate = (i_en_spcl | ~i_en_reg1) ? 0 :
                              {i_reg_we1 & (i_reg1_addr == i_last_waddr1),
                               i_reg_we2 & (i_reg1_addr == i_last_waddr2),
                               i_reg_we3 & (i_reg1_addr == i_last_waddr3)};
    wire [2:0] reg2_relate = (i_en_spcl | ~i_en_reg2) ? 0 :
                              {i_reg_we1 & (i_reg2_addr == i_last_waddr1),
                               i_reg_we2 & (i_reg2_addr == i_last_waddr2),
                               i_reg_we3 & (i_reg2_addr == i_last_waddr3)};
    wire [2:0] spcl_relate = i_en_spcl ? {i_reg_we1, i_reg_we2 , i_reg_we3} : 0;
    assign o_wait = (reg1_relate[2] | reg2_relate[2]) & (i_reg_wc1 == 1);
    assign o_reg1_data = reg1_relate[2] ? i_reg_wdata1 :
                         reg1_relate[1] ? i_reg_wdata2 :
                         reg1_relate[0] ? i_reg_wdata3 : i_reg1_data;
    assign o_reg2_data = reg2_relate[2] ? i_reg_wdata1 :
                         reg2_relate[1] ? i_reg_wdata2 :
                         reg2_relate[0] ? i_reg_wdata3 : i_reg2_data;
    assign o_spcl_data = spcl_relate[2] ? i_reg_wdata1 :
                         spcl_relate[1] ? i_reg_wdata2 :
                         spcl_relate[0] ? i_reg_wdata3 : i_spcl_data;
endmodule
