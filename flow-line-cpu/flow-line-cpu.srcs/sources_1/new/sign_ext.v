`timescale 1ns / 1ps

module sign_ext(
    input ext_type, // 0: all 0, 1: sign
    input [15:0] i_data,
    output [31:0] o_data
    );
    assign o_data = ext_type ? {{16{i_data[15]}}, i_data} : {16'b0, i_data};
endmodule
