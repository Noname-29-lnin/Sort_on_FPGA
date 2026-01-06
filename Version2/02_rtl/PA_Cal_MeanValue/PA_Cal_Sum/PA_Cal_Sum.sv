module PA_Cal_Sum #(
    parameter SIZE_ADDR = 32,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,

    input logic                     i_valid_ram ,
    input logic [SIZE_DATA-1:0]     i_data_ram  ,

    output logic [SIZE_DATA-1:0]    o_sum       ,
    output logic                    o_rd_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic                    o_done          
);

/////////////////////////////////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////////////////////////////////
logic w_start;
logic w_valid_ram;
logic w_init_sum;
logic [SIZE_DATA-1:0] w_data_save;

logic [SIZE_DATA-1:0] w_sum_value;
logic w_value_sum;

logic w_controladdress_done;
logic w_output_sum;

/////////////////////////////////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////////////////////////////////
SS_detect_edge #(
    .POS_EDGE   (1)   // 1: posedge, 0: negedge
) SS_DETECT_EDGE_START (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_signal   (i_start),
    .o_signal   (w_start)
);

PACS_detect_intit_data PACS_DETECT_INIT (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_start    (w_start),
    .i_valid    (i_valid_ram),
    .o_init_sum (w_init_sum) 
);
assign w_data_save = w_init_sum ? 32'b0 : w_sum_value;

BFP16_add #(
    .SIZE_DATA     (SIZE_DATA)
) BFP16_ADD_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_valid        (i_valid_ram),
    .i_data_a       (i_data_ram),
    .i_data_b       (w_data_save),
    .o_bfu_add      (w_sum_value),
    .o_valid        (w_value_sum) 
);

PACS_control_address #(
    .SIZE_ADDR      (SIZE_ADDR)
) PACS_CONTROL_ADDRESS_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_start),
    .i_rd_ram       (w_value_sum),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_rd_ram       (o_rd_ram),
    .o_addr_ram     (o_addr_ram),
    .o_done         (w_controladdress_done) 
);

PACS_detect_done PACS_DETECT_DONE (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (w_controladdress_done),
    .i_done         (w_value_sum),
    .o_done         (w_output_sum) 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) 
        o_sum       <= '0;
    else if(w_output_sum)
        o_sum       <= w_sum_value;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) 
        o_done       <= '0;
    else 
        o_done       <= w_output_sum;
end

endmodule
