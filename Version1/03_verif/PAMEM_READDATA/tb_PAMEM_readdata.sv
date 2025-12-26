`timescale 1ns/1ps
module tb_PAMEM_readdata();

parameter SIZE_ADDR     = 11;
parameter SIZE_DATA     = 32;
parameter IS_READ       = 1; // READ=1//WRITE=0 
parameter MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter MEM_DUMP_FILE = "./../../03_verif/PAMEM_READDATA/mem_dump.hex";

logic                   i_clk;
logic                   i_rst_n;
logic                   i_start;
logic [SIZE_ADDR-1:0]   i_addr_a;
logic [SIZE_ADDR-1:0]   i_addr_b;
logic [SIZE_DATA-1:0]   o_data_a;
logic [SIZE_DATA-1:0]   o_data_b;
logic                   i_valid_rd;
logic [SIZE_DATA-1:0]   i_data_ram;
logic                   o_rd_ram;
logic [SIZE_ADDR-1:0]   o_addr_ram;
logic                   o_done;

tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (IS_READ), // READ=1//WRITE=0 
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (SIZE_ADDR),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) RAM_UNIT (
    .clk                (i_clk),
    .rst_n              (i_rst_n), 
    .i_data             (),
    .wr_en              (),
    .rd_en              (o_rd_ram), 
    .read_addr          (o_addr_ram),
    .write_addr         (),
    .o_data             (i_data_ram),
    .o_valid            (i_valid_rd) 
);

PAMEM_readdata #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA) 
) DUT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_addr_a       (i_addr_a),
    .i_addr_b       (i_addr_b),
    .o_data_a       (o_data_a),
    .o_data_b       (o_data_b),
    .i_valid_rd     (i_valid_rd),
    .i_data_ram     (i_data_ram),
    .o_rd_ram       (o_rd_ram),
    .o_addr_ram     (o_addr_ram),
    .o_done         (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin 
    $shm_open("tb_PAMEM_readdata.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_addr_a = 0;
    i_addr_b = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_addr_a = 10;
    i_addr_b = 15;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;
    @(negedge o_done);
    $display("o_data_a = %h", o_data_a);
    $display("o_data_b = %h", o_data_b);

    @(posedge i_clk);
    i_addr_a = 0;
    i_addr_b = 1;
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;
    @(negedge o_done);
    $display("o_data_a = %h", o_data_a);
    $display("o_data_b = %h", o_data_b);

    #1000;
    $finish;
end

endmodule
