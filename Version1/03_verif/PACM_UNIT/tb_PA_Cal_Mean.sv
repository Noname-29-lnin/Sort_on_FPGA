`timescale 1ns/1ps

module tb_PA_Cal_Mean();

parameter SIZE_ADDR     = 32;
parameter SIZE_DATA     = 32;
parameter IS_READ       = 1; // READ=1//WRITE=0 
parameter MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter MEM_DUMP_FILE = "./../../03_verif/PACM_UNIT/mem_dump.hex";

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
tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (IS_READ), // READ=1//WRITE=0 
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (6),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) RAM_UNIT (
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
    i_rst_n = 0;
    i_start = 0;
    i_addr_si = 0;
    i_addr_ei = 0;
    #100;
    i_rst_n = 1;
    #100;
    @(posedge i_clk);
    i_start = 1;
    i_addr_si = 0;
    i_addr_ei = 63;
    @(posedge i_clk);
    i_start = 0;

    @(posedge DUT.w_BFP16_DIV_done);
    $display("o_total_sum = %h (%.4f)", DUT.w_divisor, $bitstoshortreal(DUT.w_divisor));

    @(posedge DUT.w_PACS_done);
    $display("o_total_sum = %h (%.4f)", DUT.w_sum, $bitstoshortreal(DUT.w_sum));

    @(posedge o_done);
    $display("o_mean_value = %h (%.4f)", o_mean_value, $bitstoshortreal(o_mean_value));
    $display("End Simulation");
    #100;
    $finish;
end

endmodule
