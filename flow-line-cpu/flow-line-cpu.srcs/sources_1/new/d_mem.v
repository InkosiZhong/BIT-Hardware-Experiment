`timescale 1ns / 1ps

module d_mem(
    input clk,
    input rst,
    input i_we, // write_enable
    // 1:byte 2:halfword 3:byte(s) 4:halfword(s) 5:left 6:right 7:word
    input [2:0] i_mode,
    input [31:0] i_addr,
    input [31:0] i_wdata, // data to write
    output [31:0] o_rdata // data to read
    );
    reg [7:0] d_mem_space [255:0];
    initial begin
        $readmemh("../../../../data.txt", d_mem_space);
    end
    wire [7:0] low_addr = i_addr[7:0];
    wire [7:0] align_addr = low_addr >> 2 << 2;
    wire [31:0] rword = {d_mem_space[align_addr+3],
                         d_mem_space[align_addr+2],
                         d_mem_space[align_addr+1],
                         d_mem_space[align_addr]};
    assign o_rdata = i_mode == 1 ? {24'b0, rword[7:0]} :
                     i_mode == 2 ? {16'b0, rword[15:0]} :
                     i_mode == 3 ? {{24{rword[7]}}, rword[7:0]} :
                     i_mode == 4 ? {{16{rword[7]}}, rword[15:0]} :
                     i_mode == 5 ? rword << (3-low_addr%4)*8 :
                     i_mode == 6 ? rword >> (low_addr%4)*8 : rword;
                
    always @(posedge clk) begin
        if(i_we) begin
            if(i_mode == 1 || i_mode == 3)
                d_mem_space[low_addr] <= i_wdata[7:0];
            else if(i_mode == 2 || i_mode == 4) begin
                d_mem_space[low_addr+1] <= i_wdata[15:8];
                d_mem_space[low_addr] <= i_wdata[7:0];
            end
            else if(i_mode == 7 | (i_mode == 5 & low_addr % 4 == 3) |
                    (i_mode == 6 & low_addr % 4 == 0)) begin
                d_mem_space[align_addr+3] <= i_wdata[31:24];
                d_mem_space[align_addr+2] <= i_wdata[23:16];
                d_mem_space[align_addr+1] <= i_wdata[15:8];
                d_mem_space[align_addr] <= i_wdata[7:0];
            end
            else if(i_mode == 5) begin
                if(low_addr % 4 == 2) begin
                    d_mem_space[align_addr+2] <= i_wdata[31:24];
                    d_mem_space[align_addr+1] <= i_wdata[23:16];
                    d_mem_space[align_addr] <= i_wdata[15:8];
                end
                else if(low_addr % 4 == 1) begin
                    d_mem_space[align_addr+1] <= i_wdata[31:24];
                    d_mem_space[align_addr] <= i_wdata[23:16];
                end
                else if(low_addr % 4 == 0)
                    d_mem_space[align_addr] <= i_wdata[31:24];
            end
            else if(i_mode == 6) begin
                if(low_addr % 4 == 1) begin
                    d_mem_space[align_addr+3] <= i_wdata[23:16];
                    d_mem_space[align_addr+2] <= i_wdata[15:8];
                    d_mem_space[align_addr+1] <= i_wdata[7:0];
                end
                else if(low_addr % 4 == 2) begin
                    d_mem_space[align_addr+3] <= i_wdata[15:8];
                    d_mem_space[align_addr+2] <= i_wdata[7:0];
                end
                else if(low_addr % 4 == 3)
                    d_mem_space[align_addr+3] <= i_wdata[7:0];
            end
        end
    end
endmodule
