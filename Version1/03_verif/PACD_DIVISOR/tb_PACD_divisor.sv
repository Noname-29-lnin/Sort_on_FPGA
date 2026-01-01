`timescale 1ns/1ps

module tb_PACD_divisor();

parameter SIZE_ADDR = 32;
parameter SIZE_DATA = 32;
logic                   i_clk;
logic                   i_rst_n;
logic                   i_start;
logic [SIZE_ADDR-1:0]   i_addr_si;
logic [SIZE_ADDR-1:0]   i_addr_ei;
logic [SIZE_DATA-1:0]   o_diff_addr;
logic                   o_done;


PACD_divisor #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA)
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_addr_si          (i_addr_si),
    .i_addr_ei          (i_addr_ei),
    .o_diff_addr        (o_diff_addr),
    .o_done             (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_addr_si = 0;
    i_addr_ei = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_addr_si = 0;
    i_addr_ei = 32'h0000012B;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;

    @(negedge o_done);
    $display("o_diff_addr = %h (%.4f)", o_diff_addr, $bitstoshortreal(o_diff_addr));

    @(posedge i_clk);
    i_addr_si = 0;
    i_addr_ei = 32'hffffffff;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;

    @(negedge o_done);
    $display("o_diff_addr = %h (%.4f)", o_diff_addr, $bitstoshortreal(o_diff_addr));

    @(posedge i_clk);
    i_addr_si = 32'd10;
    i_addr_ei = 32'd20;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;

    @(negedge o_done);
    $display("o_diff_addr = %h (%.4f)", o_diff_addr, $bitstoshortreal(o_diff_addr));
    
    @(posedge i_clk);
    i_addr_si = 32'd0;
    i_addr_ei = 32'd31;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;

    @(negedge o_done);
    $display("o_diff_addr = %h (%.4f)", o_diff_addr, $bitstoshortreal(o_diff_addr));
    $finish;
end

endmodule
