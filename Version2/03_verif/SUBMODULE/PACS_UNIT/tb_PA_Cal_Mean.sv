`timescale 1ns/1ps

`include "./../../03_verif/SUBMODULE/PACS_UNIT/lib/display.svh"

module tb_PA_Cal_Mean();
parameter SIZE_ADDR = 32;
parameter SIZE_DATA = 32;
logic                   i_clk;
logic                   i_rst_n;
logic                   i_start;
logic [SIZE_ADDR-1:0]   i_addr_si;
logic [SIZE_ADDR-1:0]   i_addr_ei;
logic                   i_valid_ram;
logic [SIZE_DATA-1:0]   i_data_ram;
logic                   o_en_ram;
logic [SIZE_ADDR-1:0]   o_addr_ram;
logic [SIZE_DATA-1:0]   o_mean_value;
logic                   o_done;
localparam SIZE_ROM     = 1 << SIZE_ADDR;
parameter MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter MEM_DUMP_FILE = "./../../03_verif/SUBMODULE/PACS_UNIT/mem_dump.hex";
int                     t_test_count = 0.0;
int                     t_test_pass = 0.0;
int                     t_max_error = 0.0;

tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (1), // READ=1//WRITE=0 
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (SIZE_ADDR),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) ROM_UNIT (
    .clk                (i_clk),
    .rst_n              (i_rst_n), 
    .i_data             (),
    .wr_en              (),
    .rd_en              (o_en_ram), 
    .read_addr          (o_addr_ram),
    .write_addr         (),
    .o_data             (i_data_ram),
    .o_valid            (i_valid_ram) 
);

PA_Cal_Mean #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA)
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_addr_si          (i_addr_si),
    .i_addr_ei          (i_addr_ei),
    .i_valid_ram        (i_valid_ram),
    .i_data_ram         (i_data_ram),
    .o_en_ram           (o_en_ram),
    .o_addr_ram         (o_addr_ram),
    .o_mean_value       (o_mean_value),
    .o_done             (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin
    $shm_open("tb_PA_Cal_Mean.shm");
    $shm_probe("ASM");
end

initial begin

    
    
    #100;
    Display_SummaryResult(t_test_count, t_test_pass, t_max_error);
    #100;
    $display("Finished test...");
    $finish;
end

endmodule
