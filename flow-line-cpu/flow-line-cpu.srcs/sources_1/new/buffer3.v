`timescale 1ns / 1ps

module buffer3(
    input clk,
    input rst,
    input i_flush,
    // cmd
    input i_reg_we,
    input [1:0] i_reg_wc,
    input i_dmem_we,
    input i_spcl_we,
    input [2:0] i_dmem_mode,
    // data
    input [31:0] i_alu_lo_res,
    input [31:0] i_alu_hi_res,
    input [31:0] i_dmem_wdata, // reg2_data
    input [4:0] i_reg_waddr,
    input [31:0] i_pc,
    input [31:0] i_spcl_data,
    // cmd
    output o_reg_we,
    output [1:0] o_reg_wc,
    output o_dmem_we,
    output o_spcl_we,
    output [2:0] o_dmem_mode,
    // data
    output [31:0] o_alu_lo_res,
    output [31:0] o_alu_hi_res,
    output [31:0] o_dmem_wdata,
    output [4:0] o_reg_waddr,
    output [31:0] o_spcl_data
    );
    // cmd
    reg buf_reg_we, buf_dmem_we, buf_spcl_we, buf_br, buf_jmp;
    reg [1:0] buf_reg_wc;
    reg [2:0] buf_dmem_mode;
    assign o_reg_we = buf_reg_we;
    assign o_reg_wc = buf_reg_wc;
    assign o_dmem_we = buf_dmem_we;
    assign o_spcl_we = buf_spcl_we;
    assign o_dmem_mode = buf_dmem_mode;
    
    always @(posedge clk or negedge rst) begin
        if(~rst | i_flush) begin
            buf_reg_we <= 0;
            buf_reg_wc <= 0;
            buf_dmem_we <= 0;
            buf_spcl_we <= 0;
            buf_dmem_mode <= 0;
        end
        else begin
            buf_reg_we <= i_reg_we;
            buf_reg_wc <= i_reg_wc;
            buf_dmem_we <= i_dmem_we;
            buf_spcl_we <= i_spcl_we;
            buf_dmem_mode <= i_dmem_mode;
        end
    end
    // data
    reg [31:0] buf_alu_lo_res;
    reg [31:0] buf_alu_hi_res;
    reg [31:0] buf_dmem_wdata;
    reg [4:0] buf_reg_waddr;
    reg [31:0] buf_spcl_data;
    assign o_alu_lo_res = buf_alu_lo_res;
    assign o_alu_hi_res = buf_alu_hi_res;
    assign o_dmem_wdata = buf_dmem_wdata;
    assign o_reg_waddr = buf_reg_waddr;
    assign o_spcl_data = buf_spcl_data;
    always @(posedge clk or negedge rst) begin
        if(~rst | i_flush) begin
            buf_alu_lo_res <= 0;
            buf_alu_hi_res <= 0;
            buf_dmem_wdata <= 0;
            buf_reg_waddr <= 0;
            buf_spcl_data <= 0;
        end
        else begin
            buf_alu_lo_res <= i_alu_lo_res;
            buf_alu_hi_res <= i_alu_hi_res;
            buf_dmem_wdata <= i_dmem_wdata;
            buf_reg_waddr <= i_reg_waddr;
            buf_spcl_data <= i_spcl_data;
        end
    end
endmodule
