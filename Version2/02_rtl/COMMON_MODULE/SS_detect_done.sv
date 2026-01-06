module SS_detect_done (
    input  logic        i_clk       ,
    input  logic        i_rst_n     ,
    input  logic        i_done_a    ,
    input  logic        i_done_b    ,
    output logic        o_done       
);
logic w_done_a, w_done_b;

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_DONE_A (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_done_a),
    .o_signal       (w_done_a)
);
SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_DONE_B (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_done_b),
    .o_signal       (w_done_b)
);

logic w_active_done_a, w_active_done_b;
logic w_detect_done_a, w_detect_done_b;

assign w_active_done_a = w_done_a;
assign w_active_done_b = w_done_b;
TFFE TFFE_UNIT_A (
	.t              (w_active_done_a), 
	.clk            (i_clk), 
	.clrn           (i_rst_n & (~o_done)), 
	.prn            (1'b1), 
	.ena            (1'b1), 
	.q              (w_detect_done_a)
);
TFFE TFFE_UNIT_B (
	.t              (w_active_done_b), 
	.clk            (i_clk), 
	.clrn           (i_rst_n & (~o_done)), 
	.prn            (1'b1), 
	.ena            (1'b1), 
	.q              (w_detect_done_b)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_done      <= '0;
    else 
        o_done      <= w_detect_done_a & w_detect_done_b;
end
endmodule
