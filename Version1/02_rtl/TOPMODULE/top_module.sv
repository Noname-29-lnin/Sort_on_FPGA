module top_module #(
    parameter SIZE_DATA     = 32    ,
    parameter SIZE_ADDR     = 32    ,
    parameter PATH_DATA     = "."
)(
    input logic                 i_clk       ,
    input logic                 i_rst_n     ,
    input logic                 i_start     ,

    output logic                o_done       
);

PA_Cal_Mean #(
    .SIZE_ADDR          (),
    .SIZE_DATA          ()
)(
    .i_clk              (),
    .i_rst_n            (),
    .i_start            (),
    .i_addr_si          (),
    .i_addr_ei          (),
    .i_valid_ram        (),
    .i_data_ram         (),
    .o_en_ram           (),
    .o_addr_ram         (),
    .o_mean_value       (),
    .o_done             () 
);

PA_mem #(
    .SIZE_ADDR          (),
    .SIZE_DATA          ()
)(
    .i_clk              (),
    .i_rst_n            (),
    .i_start            (),
    .i_addr_si          (),
    .i_addr_ei          (),
    .i_mean_value       (),
    .i_valid_rd         (),
    .i_data_ram         (),
    .o_rd_ram           (),
    .o_wr_ram           (),
    .o_addr_rd_ram      (),
    .o_addr_wr_ram      (),
    .o_data_ram         (),
    .o_pi_ram           (),
    .o_done             () 
);

DI_unit #(
    .SIZE_ADDR          (),
    .SIZE_DATA          ()
)(
    .i_clk              (),
    .i_rst_n            (),
    .i_start            (),
    .i_addr_si          (),
    .i_addr_ei          (),
    .i_done_PAMEM       (),
    .i_addr_pi          (),
    .o_addr_si          (),
    .o_addr_ei          (),
    .o_done             () 
);

endmodule
