module PACS_detect_done(
    input  logic            i_clk       ,
    input  logic            i_rst_n     ,
    input  logic            i_start     ,
    input  logic            i_done      ,
    output logic            o_done       
);

logic w_start;
SS_detect_edge #(
    .POS_EDGE   (1)   // 1: posedge, 0: negedge
) SS_DETECT_EDGE_START (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_signal   (i_start),
    .o_signal   (w_start)
);
logic w_done;
SS_detect_edge #(
    .POS_EDGE   (1)   // 1: posedge, 0: negedge
) SS_DETECT_EDGE_DONE (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_signal   (i_done),
    .o_signal   (w_done)
);

logic w_o_tff;
logic w_en_tff;
assign w_en_tff = w_start & (~w_o_tff);
TFFE T_FF_UNIT (
	.t          (w_start), 
	.clk        (i_clk), 
	.clrn       (i_rst_n & (~o_done)), 
	.prn        (1'b1),
	.ena        (w_en_tff), 
	.q          (w_o_tff)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        o_done  <= '0;
    else 
        o_done  <= w_o_tff & w_done;
end

endmodule
