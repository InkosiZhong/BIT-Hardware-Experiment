`timescale 1ns / 1ps

module testbench(
    );
    reg clk;
    reg rst;
    reg [7:0] rx_in[7:0];
    initial begin
        clk=0;
        rst=1;
        #5
        rst=0;
        /*rx_in[0] = 51; // ASCII of 3
        rx_in[1] = 43; // ASCII of +
        rx_in[2] = 53; // ASCII of 5
        rx_in[3] = 42; // ASCII of *
        rx_in[4] = 50; // ASCII of 2
        rx_in[5] = 61; // ASCII of =*/
        rx_in[0] = 40; // ASCII of (
        rx_in[1] = 51; // ASCII of 3
        rx_in[2] = 43; // ASCII of +
        rx_in[3] = 53; // ASCII of 5
        rx_in[4] = 41; // ASCII of )
        rx_in[5] = 42; // ASCII of *
        rx_in[6] = 50; // ASCII of 2
        rx_in[7] = 61; // ASCII of =
        #5
        rst=1;
        $display("running...");
    end
    always #20 clk=~clk;
    /*cpu cpu(
        .clk(clk),
        .rst(rst)
    );*/
    reg rx_pin_in;
    wire tx_pin_out;
    sys_top sys(
        .clk(clk),
        .rst(rst),
        .rx_pin_in(rx_pin_in),
        .tx_pin_out(tx_pin_out)
    );
    
    wire tx_clk_bps;
    tx_band_gen tx_band_gen(
        .clk(clk),
        .rst(~rst),
        .band_sig(1),
        .clk_bps(tx_clk_bps)
    );
    
    localparam [3:0] IDLE = 4'd0, BEGIN1 = 4'd1,
                     DATA0 = 4'd2, END = 4'd10, BFREE = 4'd11; 
    reg [3:0] bit_cnt = 0;
    reg [2:0] byte_cnt = 0;
    reg finish = 0;
    always @(posedge clk) begin
        if(tx_clk_bps)
            if(bit_cnt < BFREE)
                bit_cnt <= bit_cnt + 1;
            else
                if(byte_cnt == 7)
                    finish <= 1;
                else begin
                    bit_cnt <= 0;
                    byte_cnt <= byte_cnt + 1;
                end
    end
    
    always @(posedge clk) begin
        if(~finish & tx_clk_bps) begin
            if(bit_cnt == IDLE | bit_cnt == END | bit_cnt == BFREE)
                rx_pin_in <= 1;
            else if(bit_cnt == BEGIN1)
                rx_pin_in <= 0;
            else
                rx_pin_in <= rx_in[byte_cnt][bit_cnt-DATA0];
        end
    end
    
endmodule