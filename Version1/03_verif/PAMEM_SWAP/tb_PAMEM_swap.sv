`timescale 1ns/1ps
module tb_PAMEM_swap();

parameter SIZE_ADDR     = 5;
parameter SIZE_DATA     = 32;
parameter IS_READ       = 1; // READ=1//WRITE=0 
parameter MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter MEM_DUMP_FILE = "./../../03_verif/PAMEM_SWAP/mem_dump.hex";

logic                   i_clk;
logic                   i_rst_n;
logic                   i_start;
logic [SIZE_DATA-1:0]   i_mean_value;

logic                   w_rd_ram;
logic [SIZE_ADDR-1:0]   w_addr_rd;
logic [SIZE_DATA-1:0]   w_data_rd;
logic                   w_rd_valid;

logic [SIZE_ADDR-1:0]   i_addr_a;
logic [SIZE_ADDR-1:0]   i_addr_b;
logic [SIZE_DATA-1:0]   i_data_a;
logic [SIZE_DATA-1:0]   i_data_b;
logic                   o_wr_ram;
logic [SIZE_ADDR-1:0]   o_addr_ram;
logic [SIZE_DATA-1:0]   o_data_ram;
logic                   o_update_pi;
logic                   o_done;

logic [SIZE_DATA-1:0]   w_mean_value;
logic [SIZE_DATA-1:0]   w_temp_a;
logic [SIZE_DATA-1:0]   w_temp_b;
logic [SIZE_ADDR-1:0]   w_temp_i;
logic [SIZE_ADDR-1:0]   w_temp_pi;

tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (IS_READ), // READ=1//WRITE=0 
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (SIZE_ADDR),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) RAM_UNIT (
    .clk                (i_clk),
    .rst_n              (i_rst_n), 
    .i_data             (o_data_ram),
    .wr_en              (o_wr_ram),
    .rd_en              (w_rd_ram), 
    .read_addr          (w_addr_rd),
    .write_addr         (o_addr_ram),
    .o_data             (w_data_rd),
    .o_valid            (w_rd_valid) 
);

PAMEM_swap #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA)
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_mean_value       (i_mean_value),
    .i_addr_a           (i_addr_a),
    .i_addr_b           (i_addr_b),
    .i_data_a           (i_data_a),
    .i_data_b           (i_data_b),
    .o_wr_ram           (o_wr_ram),
    .o_addr_ram         (o_addr_ram),
    .o_data_ram         (o_data_ram),
    .o_update_pi        (o_update_pi),
    .o_done             (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin 
    $shm_open("tb_PAMEM_swap.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    w_mean_value = 0;
    #100;
    i_rst_n = 1;
    i_mean_value = 0;
    
    w_temp_i = 0;
    w_temp_pi = 0;
    repeat (2**SIZE_ADDR) begin
        @(posedge i_clk);
        w_addr_rd = w_temp_i;
        w_rd_ram = 1;
        @(posedge i_clk);
        w_rd_ram = 0;
        @(negedge w_rd_valid);
        w_temp_a = w_data_rd;

        @(posedge i_clk);
        w_addr_rd = w_temp_pi;
        w_rd_ram = 1;
        @(posedge i_clk);
        w_rd_ram = 0;
        @(negedge w_rd_valid);
        w_temp_b = w_data_rd;

        @(posedge i_clk);
        i_start = 1;
        i_addr_a = w_temp_i;
        i_addr_b = w_temp_pi;
        i_data_a = w_temp_a;
        i_data_b = w_temp_b;
        @(posedge i_clk);
        i_start = 0;
        @(posedge o_done);
        w_temp_i = w_temp_i + 1;
        if(o_update_pi) w_temp_pi = w_temp_pi + 1;
    end

    #100;
    $display("w_temp_pi = %d (%h)", w_temp_pi, w_temp_pi);
    #100;
    $display("Dumping memory contents to %s", MEM_DUMP_FILE);
    $writememh(MEM_DUMP_FILE, RAM_UNIT.ram);
    #100;
    $finish;
end

endmodule
