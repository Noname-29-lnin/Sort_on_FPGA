`timescale 1ns/1ps

module tb_DI_fifo ();

parameter SIZE_ADDR = 32;
parameter SIZE_DATA = 32;
parameter SIZE_LEVEL= 8;
logic                   i_clk;
logic                   i_rst_n;
logic                   i_wr_en;
logic                   i_rd_en;
logic [SIZE_LEVEL-1:0]  i_level;
logic [SIZE_ADDR-1:0]   i_addr_si;
logic [SIZE_ADDR-1:0]   i_addr_ei;
logic [SIZE_ADDR-1:0]   o_level;
logic [SIZE_ADDR-1:0]   o_addr_si;
logic [SIZE_ADDR-1:0]   o_addr_ei;
logic                   o_done;

DI_fifo #(
  .SIZE_ADDR        (SIZE_ADDR),
  .SIZE_DATA        (SIZE_DATA),
  .SIZE_LEVEL       (SIZE_LEVEL)
) DUT (
  .i_clk            (i_clk),
  .i_rst_n          (i_rst_n),
  .i_wr_en          (i_wr_en),
  .i_rd_en          (i_rd_en),
  .i_level          (i_level),
  .i_addr_si        (i_addr_si),
  .i_addr_ei        (i_addr_ei),
  .o_level          (o_level),
  .o_addr_si        (o_addr_si),
  .o_addr_ei        (o_addr_ei),
  .o_done           (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin
    $shm_open("tb_DI_fifo.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_wr_en = 0;
    i_rd_en = 0;
    i_level = 0;
    i_addr_si   = 0;
    i_addr_ei   = 0;
    #100;
    i_rst_n = 1;
    #100;

    @(posedge i_clk);
    i_level = 0;
    i_addr_si = 0;
    i_addr_ei = 15;
    i_wr_en = 1;
    @(posedge i_clk);
    i_wr_en = 0;

    repeat (7) begin
        // @(posedge o_done);
        #100;
        @(posedge i_clk);
        i_level += 1;
        i_addr_si = 0;
        i_addr_ei = 7;
        i_wr_en = 1;
        @(posedge i_clk);
        i_wr_en = 0;
    end

    repeat (8) begin
        // @(posedge o_done);
        #100;
        @(posedge i_clk);
        i_rd_en = 1;
        @(posedge i_clk);
        i_rd_en = 0;
    end

    repeat (8) begin
        // @(posedge o_done);
        #100;
        @(posedge i_clk);
        i_level += 1;
        i_addr_si = 0;
        i_addr_ei = 7;
        i_wr_en = 1;
        @(posedge i_clk);
        i_wr_en = 0;
    end

    repeat (8) begin
        // @(posedge o_done);
        #100;
        @(posedge i_clk);
        i_rd_en = 1;
        @(posedge i_clk);
        i_rd_en = 0;
    end

    repeat (8) begin
        repeat (2) begin
            // @(posedge o_done);
            #100;
            @(posedge i_clk);
            i_level += 1;
            i_addr_si = 0;
            i_addr_ei = 7;
            i_wr_en = 1;
            @(posedge i_clk);
            i_wr_en = 0;
        end
        repeat (2) begin
            // @(posedge o_done);
            #100;
            @(posedge i_clk);
            i_rd_en = 1;
            @(posedge i_clk);
            i_rd_en = 0;
        end
    end

    #100;
    $display("DONE test");
    $finish;
end

endmodule