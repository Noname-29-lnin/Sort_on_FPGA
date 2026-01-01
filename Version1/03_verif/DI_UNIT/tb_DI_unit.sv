`timescale 1ns/1ps
module tb_DI_unit ();

parameter SIZE_ADDR = 32;
parameter SIZE_DATA = 32;
parameter SIZE_LEVEL = 8;
logic                   i_clk       ;
logic                   i_rst_n     ;
logic                   i_start     ;
logic [SIZE_ADDR-1:0]   i_addr_si   ;
logic [SIZE_ADDR-1:0]   i_addr_ei   ;
logic                   i_done_PAMEM;
logic [SIZE_ADDR-1:0]   i_addr_pi   ;
logic [SIZE_ADDR-1:0]   o_addr_si   ;
logic [SIZE_ADDR-1:0]   o_addr_ei   ;
logic                   o_valid     ;
logic                   o_done      ;

DI_unit #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA),
    .SIZE_LEVEL         (SIZE_LEVEL)     
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_addr_si          (i_addr_si),
    .i_addr_ei          (i_addr_ei),
    .i_done_PAMEM       (i_done_PAMEM),
    .i_addr_pi          (i_addr_pi),
    .o_addr_si          (o_addr_si),
    .o_addr_ei          (o_addr_ei),
    .o_valid            (o_valid),
    .o_done             (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end
initial begin
    $shm_open("tb_DI_unit.shm");
    $shm_probe("ASM");
end

task automatic taskName(
    input logic [SIZE_ADDR-1:0] task_pi
);
  begin
    #500;
        @(posedge i_clk);
        i_addr_pi = task_pi;
        i_done_PAMEM = 1;
        @(posedge i_clk);
        i_done_PAMEM = 0;
  end  
endtask //automatic

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_addr_si   = 0;
    i_addr_ei   = 0;
    i_done_PAMEM    = 0;
    i_addr_pi   = 0;

    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_addr_si = 0;
    i_addr_ei = 1023;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;
    taskName(32'h0F);
    taskName(32'h0A);
    taskName(32'hB7);
    taskName(32'h05);
    taskName(32'h0C);
    taskName(32'h4B);
    taskName(32'hC3);
    @(posedge i_clk);
    i_done_PAMEM = 1;
    @(posedge i_clk);
    i_done_PAMEM = 0;

    #10000;
    #100;
    $display("Finish test...");
    $finish;
end

endmodule
