module PAMEM_writedata #(
    parameter SIZE_ADDR = 32,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_a    ,
    input logic [SIZE_ADDR-1:0]     i_addr_b    ,
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,

    output logic                    o_wr_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic [SIZE_DATA-1:0]    o_data_ram  ,
    output logic                    o_done       
);

logic [SIZE_ADDR-1:0]     w_addr_a;
logic [SIZE_ADDR-1:0]     w_addr_b;
logic [SIZE_DATA-1:0]     w_data_a;
logic [SIZE_DATA-1:0]     w_data_b;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_addr_a    <= '0;
        w_addr_b    <= '0;
        w_data_a    <= '0;
        w_data_b    <= '0;
    end else if(i_start) begin
        w_addr_a    <= i_addr_a;
        w_addr_b    <= i_addr_b;
        w_data_a    <= i_data_a;
        w_data_b    <= i_data_b;
    end
end

logic w_valid_0, w_valid_1, w_valid_2, w_valid_3;

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_valid_0)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_valid_1    <= '0;
        w_valid_2    <= '0;
        w_valid_3    <= '0;
    end else begin
        w_valid_1    <= w_valid_0;
        w_valid_2    <= w_valid_1;
        w_valid_3    <= w_valid_2;
    end
end

assign o_wr_ram = w_valid_1 | w_valid_3;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_addr_ram  <= '0;
    end else begin
        o_addr_ram  <= w_valid_2 ? w_addr_b : w_addr_a;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_data_ram  <= '0;
    end else begin
        o_data_ram  <= w_valid_2 ? w_data_b : w_data_a;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_done  <= '0;
    end else begin
        o_done  <= w_valid_3;
    end
end

endmodule
