module PA_Cal_Sum #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic                     i_done_cal  ,
    input logic [SIZE_DATA-1:0]     i_data      ,
    output logic [SIZE_DATA-1:0]    o_sum       ,
    output logic                    o_en_next   ,
    output logic                    o_done       
);

endmodule
