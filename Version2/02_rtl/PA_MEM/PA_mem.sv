module PA_mem #(
    parameter SIZE_ADDR = 32  ,
    parameter SIZE_DATA = 32    
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,
    input logic [SIZE_DATA-1:0]     i_mean_value,

    input logic                     i_valid_rd  ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,
    output logic                    o_rd_ram    ,
    output logic                    o_wr_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_rd_ram,
    output logic [SIZE_ADDR-1:0]    o_addr_wr_ram,
    output logic [SIZE_DATA-1:0]    o_data_ram  ,
    output logic [SIZE_ADDR-1:0]    o_pi_ram    ,
    output logic                    o_done       
);

/////////////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////////////

logic w_active;
logic w_start;
logic [SIZE_ADDR-1:0] i_value;
logic w_done_i;
logic w_en_update_pi;
logic [SIZE_ADDR-1:0] pi_value;
logic w_done_pi;
logic [SIZE_DATA-1:0] mean_value;

logic w_PAMEM_READ_start;
logic [SIZE_DATA-1:0] w_PAMEM_READ_data_a;
logic [SIZE_DATA-1:0] w_PAMEM_READ_data_b;
logic w_PAMEM_READ_done;
logic w_PAMEM_WRITE_done;
logic w_PAMEM_WRITE_update_pi;

/////////////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////////////
SS_detect_edge #(
    .POS_EDGE       (0)   // 1: posedge, 0: negedge
) SSDE_start (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        mean_value  <= '0;
    else if(i_start)
        mean_value  <= i_mean_value;
end
SS_detect_start SSDS_ACTIVE_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (o_done),
    .o_w_start      (w_active) 
);
SS_detect_start SSDS_UPDATE_PI (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (w_done_i),
    .o_w_start      (w_en_update_pi) 
);
PAMEM_address #(
    .SIZE_ADDR      (SIZE_ADDR)
) PACS_I_VALUE_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_start & w_active),
    .i_rd_ram       (w_PAMEM_WRITE_done),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_rd_ram       (w_PAMEM_READ_start),
    .o_addr_ram     (i_value),
    .o_done         (w_done_i) 
);
PAMEM_address #(
    .SIZE_ADDR      (SIZE_ADDR)
) PACS_PI_VALUE_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_start & w_active),
    .i_rd_ram       (w_PAMEM_WRITE_update_pi & w_en_update_pi),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_rd_ram       (),
    .o_addr_ram     (pi_value),
    .o_done         (w_done_pi) 
);
// always_ff @( posedge i_clk or negedge i_rst_n ) begin
//     if(~i_rst_n)
//         w_PAMEM_READ_start  <= '0;
//     else 
//         w_PAMEM_READ_start  <= i_start;
// end
PAMEM_readdata #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA) 
) PAMEM_READDATA_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_PAMEM_READ_start),
    .i_addr_a       (i_value),
    .i_addr_b       (pi_value),
    .i_valid_rd     (i_valid_rd & w_active),
    .i_data_ram     (i_data_ram),
    .o_data_a       (w_PAMEM_READ_data_a),
    .o_data_b       (w_PAMEM_READ_data_b),
    .o_rd_ram       (o_rd_ram),
    .o_addr_ram     (o_addr_rd_ram),
    .o_done         (w_PAMEM_READ_done) 
);
PAMEM_swap #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) PAMEM_SWAP (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_PAMEM_READ_done & w_active),
    .i_mean_value   (mean_value),
    .i_addr_a       (i_value),
    .i_addr_b       (pi_value),
    .i_data_a       (w_PAMEM_READ_data_a),
    .i_data_b       (w_PAMEM_READ_data_b),
    .o_wr_ram       (o_wr_ram),
    .o_addr_ram     (o_addr_wr_ram),
    .o_data_ram     (o_data_ram),
    .o_update_pi    (w_PAMEM_WRITE_update_pi),
    .o_done         (w_PAMEM_WRITE_done) 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_done  <= '0;
    else 
        o_done  <= w_done_i;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_pi_ram  <= '0;
    else if(w_done_i)
        o_pi_ram  <= pi_value;
end

endmodule
