module SS_read_write_ram #(
    parameter SIZE_ADDR     = 32    ,
    parameter SIZE_DATA     = 32     
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_wr_en     ,
    input logic                     i_rd_en     ,
    input logic [SIZE_ADDR-1:0]     i_addr_ram  ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,

    output logic                    o_wr_en     ,
    output logic                    o_rd_ne     ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic [SIZE_DATA-1:0]    o_data_ram  ,

    output logic                    o_valid_wr  ,
    output logic                    o_valid_rd   
);



endmodule
