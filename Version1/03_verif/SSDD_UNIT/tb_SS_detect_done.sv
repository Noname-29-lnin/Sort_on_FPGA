`timescale 1ns/1ps

module tb_SS_detect_done();

logic        i_clk;
logic        i_rst_n;
logic        i_done_a;
logic        i_done_b;
logic        o_done;

SS_detect_done DUT (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_done_a    (i_done_a),
    .i_done_b    (i_done_b),
    .o_done      (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end
initial begin
    $shm_open("tb_SS_detect_done.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_done_a = 0;
    i_done_b = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_done_a = 1;
    #100;
    @(posedge i_clk);
    i_done_a = 0;

    #100;
    @(posedge i_clk);
    i_done_b = 1;
    @(posedge i_clk);
    i_done_b = 0;

    #100;

    @(posedge i_clk);
    i_done_b = 1;
    @(posedge i_clk);
    i_done_b = 0;

    #1000;
    @(posedge i_clk);
    i_done_a = 1;
    @(posedge i_clk);
    i_done_a = 0;

    #100;
    $display("End simulation");
    $finish;
end

endmodule
