// if i_start is high while i_done is high, w_start is held low.
// once i_done goes low, w_start follows i_start on the next clock edge
module SS_detect_start(
    input logic                         i_clk       ,
    input logic                         i_rst_n     ,
    input logic                         i_start     ,
    input logic                         i_done      ,
    output logic                        o_w_start   
);

logic w_start;
SS_detect_edge #(
    .POS_EDGE (1'b1)
) SS_detect_edge_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_signal    (i_start),
    .o_signal    (w_start)
);

logic w_done;
SS_detect_edge #(
    .POS_EDGE (1'b1)
) SS_detect_edge_unit_2 (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_signal    (i_done),
    .o_signal    (w_done)
);
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        o_w_start   <= 1'b0;
    else
        o_w_start   <= (w_done) ? 1'b0 : ((w_start) ? 1'b1 : o_w_start);
end 
endmodule
