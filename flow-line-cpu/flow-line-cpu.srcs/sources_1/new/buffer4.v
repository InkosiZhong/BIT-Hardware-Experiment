`timescale 1ns / 1ps

module buffer4(
    input clk,
    input rst,
    // cmd
    input i_reg_we,
    input i_reg_wc,
    // data
    input [31:0] i_alu_res,
    input [31:0] i_dmem_rdata,
    input [4:0] i_reg_waddr,
    // cmd
    output o_reg_we,
    output o_reg_wc,
    // data
    output [31:0] o_alu_res,
    output [31:0] o_dmem_rdata,
    output [4:0] o_reg_waddr
    );
    // cmd
    reg buf_reg_we, buf_reg_wc;
    assign o_reg_we = buf_reg_we;
    assign o_reg_wc = buf_reg_wc;
    
    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            buf_reg_we <= 0;
            buf_reg_wc <= 0;
        end
        else begin
            buf_reg_we <= i_reg_we;
            buf_reg_wc <= i_reg_wc;
        end
    end
    // data
    reg [31:0] buf_alu_res;
    reg [31:0] buf_dmem_rdata;
    reg [4:0] buf_reg_waddr;
    assign o_alu_res = buf_alu_res;
    assign o_dmem_rdata = buf_dmem_rdata;
    assign o_reg_waddr = buf_reg_waddr;
    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            buf_alu_res <= 0;
            buf_dmem_rdata <= 0;
            buf_reg_waddr <= 0;
        end
        else begin
            buf_alu_res <= i_alu_res;
            buf_dmem_rdata <= i_dmem_rdata;
            buf_reg_waddr <= i_reg_waddr;
        end
    end
endmodule
