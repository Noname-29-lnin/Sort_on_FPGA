module top_module #(
    // parameter MEM_INIT_FILE = "./mem_init.hex",
    // parameter MEM_DUMP_FILE = "./mem_dump.hex",
    parameter SIZE_DATA     = 32    ,
    parameter SIZE_ADDR     = 32     
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic[SIZE_ADDR-1:0]      i_addr_si   ,
    input logic[SIZE_ADDR-1:0]      i_addr_ei   ,

    input logic                     i_valid_ram ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,
    output logic [SIZE_ADDR-1:0]    o_addr_wr_ram,
    output logic [SIZE_ADDR-1:0]    o_addr_rd_ram,
    output logic [SIZE_DATA-1:0]    o_data_ram  ,
    output logic                    o_rd_ram    ,
    output logic                    o_wr_ram    ,

    output logic                    o_done       
);

///////////////////////////////////////////////////////////
// Internal Signal
///////////////////////////////////////////////////////////
logic [SIZE_ADDR-1:0]   DI_addr_si;
logic [SIZE_ADDR-1:0]   DI_addr_ei;
logic                   DI_valid;
logic                   DI_done;

logic                   PACM_active;
logic                   PACM_en_ram;
logic [SIZE_ADDR-1:0]   PACM_addr_ram;
logic [SIZE_DATA-1:0]   PACM_mean_value;
logic                   PACM_done;

logic                   PAMEM_rd_ram;
logic                   PAMEM_wr_ram;
logic [SIZE_ADDR-1:0]   PAMEM_addr_rd_ram;
logic [SIZE_ADDR-1:0]   PAMEM_addr_wr_ram;
logic [SIZE_DATA-1:0]   PAMEM_data_ram;
logic [SIZE_ADDR-1:0]   PAMEM_pi_ram;
// logic                   PAMEM_done;

logic                   RAM_rd_ram;
logic [SIZE_ADDR-1:0]   RAM_addr_rd;
logic [SIZE_DATA-1:0]   RAM_data_rd;
logic                   RAM_rd_valid;

///////////////////////////////////////////////////////////
// Submodules
///////////////////////////////////////////////////////////

DI_unit #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA),
    .SIZE_LEVEL         (8) 
) DI_UNIT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .i_addr_si          (i_addr_si),
    .i_addr_ei          (i_addr_ei),
    .i_done_PAMEM       (PAMEM_done),
    .i_addr_pi          (PAMEM_pi_ram),
    .o_addr_si          (DI_addr_si),
    .o_addr_ei          (DI_addr_ei),
    .o_valid            (DI_valid),
    .o_done             (o_done) 
);

PA_Cal_Mean #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA)
) PA_CAL_MEAN_UNIT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (DI_valid),
    .i_addr_si          (DI_addr_si),
    .i_addr_ei          (DI_addr_ei),
    .i_valid_ram        (i_valid_ram),
    .i_data_ram         (i_data_ram),
    .o_en_ram           (PACM_en_ram),
    .o_addr_ram         (PACM_addr_ram),
    .o_mean_value       (PACM_mean_value),
    .o_done             (PACM_done) 
);

PA_mem #(
    .SIZE_ADDR          (SIZE_ADDR),
    .SIZE_DATA          (SIZE_DATA)  
) PA_MEM_UNIT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (PACM_done),
    .i_addr_si          (DI_addr_si),
    .i_addr_ei          (DI_addr_ei),
    .i_mean_value       (PACM_mean_value),
    .i_valid_rd         (i_valid_ram),
    .i_data_ram         (i_data_ram),
    .o_rd_ram           (PAMEM_rd_ram),
    .o_wr_ram           (o_wr_ram),
    .o_addr_rd_ram      (PAMEM_addr_rd_ram),
    .o_addr_wr_ram      (o_addr_wr_ram),
    .o_data_ram         (o_data_ram),
    .o_pi_ram           (PAMEM_pi_ram),
    .o_done             (PAMEM_done) 
);

SS_detect_start SSDS_ACTIVE_PACM_UNIT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (PACM_done),
    .i_done             (PAMEM_done),
    .o_w_start          (PACM_active) 
);

assign o_rd_ram     = PACM_active ? PAMEM_rd_ram : PACM_en_ram;
assign o_addr_rd_ram = PACM_active ? PAMEM_addr_rd_ram : PACM_addr_ram;

// tb_simple_dual_port_ram_single_clock#(
//     .IS_READ            (1), // READ=1//WRITE=0 
//     .DATA_WIDTH         (SIZE_DATA),
//     .ADDR_WIDTH         (SIZE_ADDR),
//     .MEM_INIT_FILE      (MEM_INIT_FILE),
//     .MEM_DUMP_FILE      (MEM_DUMP_FILE)
// ) MEM_UNIT (
//     // input  logic                     i_mode     , // 0: read, 1: write
//     .clk                (i_clk),
//     .rst_n              (i_rst_n), 
//     .i_data             (PAMEM_data_ram),
//     .wr_en              (PAMEM_wr_ram),
//     .rd_en              (RAM_rd_ram), 
//     .read_addr          (RAM_addr_rd),
//     .write_addr         (PAMEM_addr_wr_ram),
//     .o_data             (RAM_data_rd),
//     .o_valid            (RAM_rd_valid) 
// );

// assign i_valid_ram = RAM_rd_valid;
// assign i_data_ram = RAM_data_rd;
// assign o_addr_wr_ram = PAMEM_addr_wr_ram;
// assign o_addr_rd_ram = RAM_addr_rd;
// assign o_data_ram = PAMEM_data_ram;
// assign o_rd_ram = RAM_rd_ram;
// assign o_wr_ram = PAMEM_wr_ram;

endmodule
