`timescale 1ns / 1ps

module spcl_reg(
    input clk,
    input rst,
    input i_we,           // write enable
    input i_rc,           // read control
    input [31:0] i_hi_wdata,
    input [31:0] i_lo_wdata,
    output [31:0] o_spcl_data
    );
    reg [31:0] hi_reg = 0;
    reg [31:0] lo_reg = 0;
    assign o_spcl_data = i_rc ? hi_reg : lo_reg;
    
    always @(posedge clk) begin
        if(i_we) begin
            hi_reg <= i_hi_wdata;
            lo_reg <= i_lo_wdata;
        end
    end
endmodule
