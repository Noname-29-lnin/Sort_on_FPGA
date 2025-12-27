module PAMEM_swap #(
    parameter SIZE_ADDR = 32,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_DATA-1:0]     i_mean_value,
    input logic [SIZE_ADDR-1:0]     i_addr_a    ,
    input logic [SIZE_ADDR-1:0]     i_addr_b    ,
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic                    o_wr_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic [SIZE_DATA-1:0]    o_data_ram  ,
    output logic                    o_update_pi ,
    output logic                    o_done       
);

logic w_start;
logic w_start_range;
logic w_PASW_done;
logic w_PASW_comp_less;
logic w_PAMEM_WRITE_done;
logic w_o_update_pi;
logic w_update_pi;
logic [SIZE_DATA-1:0] w_data_i;
logic [SIZE_DATA-1:0] w_data_a;
logic [SIZE_DATA-1:0] w_data_b;

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);

PASW_unit #(
    .SIZE_DATA      (SIZE_DATA)
) PASW_SWAP_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_valid        (w_start),
    .i_data_mean    (i_mean_value),
    .i_data_a       (i_data_a),
    .i_data_b       (i_data_b),
    .o_data_a       (w_data_a),
    .o_data_b       (w_data_b),
    .o_valid        (w_PASW_done),
    .o_comp_less    (w_PASW_comp_less)
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_o_update_pi     <= '0;
    else if(w_PASW_done)
        w_o_update_pi     <= w_PASW_comp_less;
end
PAMEM_writedata #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) PAMEM_WRITEDATA_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_PASW_done),
    .i_addr_a       (i_addr_a),
    .i_addr_b       (i_addr_b),
    .i_data_a       (w_data_a),
    .i_data_b       (w_data_b),
    .o_wr_ram       (o_wr_ram),
    .o_addr_ram     (o_addr_ram),
    .o_data_ram     (o_data_ram),
    .o_done         (w_PAMEM_WRITE_done)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_update_pi     <= '0;
    else 
        o_update_pi     <= w_o_update_pi & w_PAMEM_WRITE_done;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_done     <= '0;
    else 
        o_done     <= w_PAMEM_WRITE_done;
end

endmodule
