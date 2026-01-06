`timescale 1ns/1ps

module tb_PACS_detect_done();

logic            i_clk;
logic            i_rst_n;
logic            i_start;
logic            i_done;
logic            o_done;

PACS_detect_done DUT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (i_done),
    .o_done         (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end
initial begin
    $shm_open("tb_PACS_detect_done.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_done  = 0;
    #100;
    i_rst_n = 1;
    #10;
    i_start = 1;
    #50;
    i_start = 0;

    repeat (3) begin
        @(posedge i_clk);
        i_start = 1;
        @(posedge i_clk);
        i_start = 0;
    end

    #200;
    repeat (2) begin
        @(posedge i_clk);
        i_done = 1;
        @(posedge i_clk);
        i_done = 0;
    end

    #100;
    $finish;
end

endmodule
