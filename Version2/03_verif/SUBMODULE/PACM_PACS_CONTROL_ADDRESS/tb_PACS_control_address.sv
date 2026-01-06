`timescale 1ns/1ps
module tb_PACS_control_address();

parameter SIZE_ADDR = 32;

logic                     i_clk       ;
logic                     i_rst_n     ;
logic                     i_start     ;
logic                     i_rd_ram    ;
logic [SIZE_ADDR-1:0]     i_addr_si   ;
logic [SIZE_ADDR-1:0]     i_addr_ei   ;
logic                    o_rd_ram     ;
logic [SIZE_ADDR-1:0]    o_addr_ram   ;
logic                    o_done       ;

PACS_control_address #(
    .SIZE_ADDR      (SIZE_ADDR)
) DUT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_rd_ram       (i_rd_ram),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_rd_ram       (o_rd_ram),
    .o_addr_ram     (o_addr_ram),
    .o_done         (o_done) 
);

initial begin
    i_clk       = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin
    $shm_open("tb_PACS_control_address.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_rd_ram = 0;
    i_addr_si = 0;
    i_addr_ei = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_start = 1;
    i_addr_si = 0;
    i_addr_ei = 32'h00000015;
    @(posedge i_clk);
    i_start = 0;
    repeat (20) begin
        @(posedge i_clk);
        i_rd_ram = 1'b1;
        @(posedge i_clk);
        i_rd_ram = 1'b0;
        #1;
        $display("o_addr_ram = %h", o_addr_ram);
    end
    #100;
    @(posedge i_clk);
    i_rd_ram = 1'b1;
    @(posedge i_clk);
    i_rd_ram = 1'b0;
    #1;
    $display("o_addr_ram = %h", o_addr_ram);
    repeat (20) begin
        @(posedge i_clk);
        i_rd_ram = 1'b1;
        @(posedge i_clk);
        i_rd_ram = 1'b0;
    end
    @(posedge i_clk);
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;
    repeat (20) begin
        @(posedge i_clk);
        i_rd_ram = 1'b1;
        @(posedge i_clk);
        i_rd_ram = 1'b0;
        #1;
        $display("o_addr_ram = %h", o_addr_ram);
    end
    
    #100;
    @(posedge i_clk);
    i_rd_ram = 1'b1;
    @(posedge i_clk);
    i_rd_ram = 1'b0;
    #1;
    $display("o_addr_ram = %h", o_addr_ram);
    #100;
    $finish;
end

endmodule
