`timescale 1ns / 1ps

module testbench(
    );
    reg clk;
    reg rst;
    initial begin
        clk=0;
        rst=1;
        #5
        rst=0;
        #5
        rst=1;
        $display("running...");
    end
    always #20 clk=~clk;
    cpu cpu(
        .clk(clk),
        .rst(rst)
    );
endmodule