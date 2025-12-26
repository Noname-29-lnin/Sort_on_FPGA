`timescale 1ns/1ps
module tb_SS_detect_start();

logic i_clk;
logic i_rst_n;
logic i_start;
logic i_done;
logic o_w_start;

SS_detect_start SSDS_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (i_done),
    .o_w_start      (o_w_start) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin 
    $shm_open("tb_SS_detect_start.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_done = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;
    
    #100;
    
    @(posedge i_clk);
    i_done = 1;
    @(posedge i_clk);
    i_done = 0;

    #100;
    $finish;
end

endmodule
