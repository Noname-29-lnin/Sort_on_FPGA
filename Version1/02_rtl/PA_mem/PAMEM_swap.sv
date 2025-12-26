module PAMEM_swap #(
    parameter SIZE_ADDR = 32,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_DATA-1:0]     i_mean_value,
    input logic [SIZE_DATA-1:0]     i_data_i    ,

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
logic w_COMP_less_data, w_pre_COMP_less_data;
logic w_PAMEM_WRITE_done;
logic [SIZE_DATA-1:0] w_data_i;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_start     <= '0;
    else
        w_start     <= i_start;
end
SS_detect_start SSDS_EN_ZONE (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (o_done),
    .o_w_start      (w_start_range) 
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_data_i     <= '0;
    else if(i_start)
        w_data_i     <= i_data_i;
end

assign w_COMP_less_data = w_data_i < i_mean_value;
// always_ff @( posedge i_clk or negedge i_rst_n ) begin
//     if(~i_rst_n)
//         w_COMP_less_data     <= '0;
//     else
//         w_COMP_less_data     <= w_pre_COMP_less_data;
// end

PAMEM_writedata #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) PAMEM_WRITEDATA_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_COMP_less_data & w_start_range),
    .i_addr_a       (i_addr_a),
    .i_addr_b       (i_addr_b),
    .i_data_a       (i_data_b),
    .i_data_b       (i_data_a),
    .o_wr_ram       (o_wr_ram),
    .o_addr_ram     (o_addr_ram),
    .o_data_ram     (o_data_ram),
    .o_done         (w_PAMEM_WRITE_done) 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_update_pi     <= '0;
    else 
        o_update_pi     <= (w_start_range &  w_PAMEM_WRITE_done);
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_done     <= '0;
    else 
        o_done     <= (w_start_range & ~w_COMP_less_data) | w_PAMEM_WRITE_done;
end

endmodule
