module PAMEM_readdata #(
    parameter SIZE_ADDR     = 32    ,
    parameter SIZE_DATA     = 32     
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_a    ,
    input logic [SIZE_ADDR-1:0]     i_addr_b    ,
    output logic [SIZE_DATA-1:0]    o_data_a    ,
    output logic [SIZE_DATA-1:0]    o_data_b    ,

    input logic                     i_valid_rd  ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,
    output logic                    o_rd_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,

    output logic                    o_done       
);

/////////////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////////////
logic w_start;
logic w_valid_rd;
logic w_en_rank;
logic [SIZE_ADDR-1:0] w_addr_b;

logic w_sel_en;
logic w_sel_addr_ram;
logic w_sel_data_rd;

/////////////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////////////
SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);
SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_VALID_RD_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_valid_rd),
    .o_signal       (w_valid_rd)
);
SS_detect_start SSDS_EN_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_done         (i_valid_rd),
    .o_w_start      (w_en_rank) 
);
assign w_sel_en = w_start | (i_valid_rd & w_en_rank);
CNT_T_FF T_FF_UNIT (
    .i_clk          (i_clk),
    .i_set          (1'b1),
    .i_rst          (i_rst_n),
    .i_en           (1'b1),
    .i_t            (w_sel_en),
    .o_q            (w_sel_addr_ram),
    .o_q_n          () 
);
CNT_T_FF T_FF_UNIT_1 (
    .i_clk          (i_clk),
    .i_set          (1'b1),
    .i_rst          (i_rst_n),
    .i_en           (1'b1),
    .i_t            (i_valid_rd),
    .o_q            (w_sel_data_rd),
    .o_q_n          () 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_addr_b        <= '0;
    end else if(i_start) begin
        w_addr_b        <= i_addr_b;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_rd_ram        <= '0;
    end else begin
        o_rd_ram        <= w_sel_en;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_addr_ram        <= '0;
    end else begin
        o_addr_ram        <= w_sel_addr_ram ? i_addr_a : w_addr_b;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_data_a        <= '0;
    end else if( (w_sel_data_rd) & (i_valid_rd) ) begin
        o_data_a        <= i_data_ram;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_data_b        <= '0;
    end else if( (~w_sel_data_rd) & (i_valid_rd) ) begin
        o_data_b        <= i_data_ram;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_done        <= '0;
    end else begin
        o_done        <= (w_sel_data_rd) & (i_valid_rd);
    end
end

endmodule
