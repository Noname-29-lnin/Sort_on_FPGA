module Update_I #(
    parameter SIZE_ADDR = 8
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic [SIZE_ADDR-1:0]     i_num_elems ,
    input logic [SIZE_ADDR-1:0]     i_start_val ,

    input logic                     i_start     ,
    input logic                     i_en        ,

    output logic                    o_en        ,
    output logic [SIZE_ADDR-1:0]    o_value_i   ,
    output logic                    o_done       
);

logic w_start;
logic [SIZE_ADDR-1:0]   w_pre_value_i;
logic [SIZE_ADDR-1:0]   w_next_value_i;
logic w_pre_done;
logic w_enable;
logic [SIZE_ADDR-1:0] w_num_elems;
logic [SIZE_ADDR-1:0] w_num_elems_next;

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);

assign w_enable         = w_start | (i_en);
assign w_next_value_i   = o_value_i + 1'b1; 
assign w_pre_value_i    = w_start ? (i_start_val) : (w_next_value_i);

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_output_value_i
    if(~i_rst_n) begin
        o_value_i       <= '0;
    end else if(w_enable) begin 
        o_value_i       <= w_pre_value_i;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_num_elems_next       <= '1;
    end else begin 
        w_num_elems_next       <= w_num_elems;
    end
end
assign w_num_elems = w_start ? i_num_elems : w_num_elems_next;
assign w_pre_done       = (o_value_i == (w_num_elems));

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_done
    if(~i_rst_n) begin
        o_done          <= '0;
    end else begin 
        o_done          <= w_pre_done & ~w_start;
    end
end
assign o_en = w_enable;

endmodule
