module PA_Cal_Mean #(
    parameter SIZE_ADDR = 32    ,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,
    input logic                     i_valid_ram ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,
    output logic                    o_en_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic [SIZE_DATA-1:0]    o_mean_value,
    output logic                    o_done       
);

logic w_active;
logic w_PACS_done;
logic w_BFP16_DIV_done;
logic [SIZE_DATA-1:0] w_sum;
logic [SIZE_DATA-1:0] w_divisor;

SS_detect_start SSDS_ACTIVE_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (o_done),
    .o_w_start      (w_active) 
);

PA_Cal_Sum #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) PACS_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .i_valid_ram    (i_valid_ram & w_active),
    .i_data_ram     (i_data_ram),
    .o_sum          (w_sum),
    .o_rd_ram       (o_en_ram),
    .o_addr_ram     (o_addr_ram),
    .o_done         (w_PACS_done) 
);

PACD_divisor #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) PACD_DIVISOR (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_diff_addr    (w_divisor),
    .o_done         (w_BFP16_DIV_done) 
);

FP32_div FPU32_DIV_UNIT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (w_PACS_done),
    .a_value_i          (w_sum),
    .b_value_i          (w_divisor),
	.z_value_o          (o_mean_value),
    .o_done             (o_done) 
);

endmodule
