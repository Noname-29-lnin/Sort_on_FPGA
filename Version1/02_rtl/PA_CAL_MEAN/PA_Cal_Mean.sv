module PA_Cal_Mean #(
    parameter SIZE_ADDR = 32    ,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,

    input logic [SIZE_DATA-1:0]     i_data_ram  ,
    input logic                     i_valid_ram ,
    output logic                    o_en_ram    ,

    output logic [SIZE_DATA-1:0]    o_mean_value,
    output logic                    o_done       
);



endmodule
