`timescale 1ns / 1ps

// instruction memory
module i_mem(
    input [31:0] i_addr,
    output [31:0] o_inst // instruction
    );
    reg [7:0] i_mem_space[1023:0];
    initial begin
        $readmemh("../../../../inst.txt", i_mem_space);
    end
    wire[9:0] low_addr = i_addr[9:0];
    assign o_inst = {i_mem_space[low_addr+3],
                     i_mem_space[low_addr+2],
                     i_mem_space[low_addr+1],
                     i_mem_space[low_addr]};
endmodule