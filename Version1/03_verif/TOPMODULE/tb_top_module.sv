`timescale 1ns/1ps
module tb_top_module();

parameter SIZE_ADDR     = 32;
parameter SIZE_DATA     = 32;
parameter IS_READ       = 1; // READ=1//WRITE=0 
parameter MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter MEM_DUMP_FILE = "./../../03_verif/TOPMODULE/mem_dump.hex";

logic   i_clk;
logic   i_rst_n;
logic   i_start;
logic   [SIZE_ADDR-1:0] i_addr_si;
logic   [SIZE_ADDR-1:0] i_addr_ei;
logic   o_done;

logic                    i_valid_ram;
logic [SIZE_DATA-1:0]    i_data_ram;
logic [SIZE_ADDR-1:0]    o_addr_wr_ram;
logic [SIZE_ADDR-1:0]    o_addr_rd_ram;
logic [SIZE_DATA-1:0]    o_data_ram;
logic                    o_rd_ram;
logic                    o_wr_ram;

top_module #(
    .SIZE_DATA          (SIZE_DATA),
    .SIZE_ADDR          (SIZE_ADDR)
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_addr_si          (i_addr_si),
    .i_addr_ei          (i_addr_ei),
    .i_valid_ram        (i_valid_ram),
    .i_data_ram         (i_data_ram),
    .o_addr_wr_ram      (o_addr_wr_ram),
    .o_addr_rd_ram      (o_addr_rd_ram),
    .o_data_ram         (o_data_ram),
    .o_rd_ram           (o_rd_ram),
    .o_wr_ram           (o_wr_ram),
    .o_done             (o_done) 
);
tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (1), // READ=1//WRITE=0 
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (5),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) RAM_UNIT (
    .clk                (i_clk),
    .rst_n              (i_rst_n), 
    .i_data             (o_data_ram),
    .wr_en              (o_wr_ram),
    .rd_en              (o_rd_ram), 
    .read_addr          (o_addr_rd_ram),
    .write_addr         (o_addr_wr_ram),
    .o_data             (i_data_ram),
    .o_valid            (i_valid_ram) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin 
    $shm_open("tb_top_module.shm");
    $shm_probe("ASM");
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    i_addr_si   = 0;
    i_addr_ei   = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_start = 1;
    i_addr_si   = 0;
    i_addr_ei   = 31;
    @(posedge i_clk);
    i_start = 0;
    
    // @(negedge o_done);
    #10000000;
    #100;
    $display("Dumping memory contents to %s", MEM_DUMP_FILE);
    $writememh(MEM_DUMP_FILE, RAM_UNIT.ram);
    #100;
    $finish;
end

endmodule
