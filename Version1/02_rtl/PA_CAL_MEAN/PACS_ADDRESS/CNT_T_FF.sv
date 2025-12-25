module CNT_T_FF (
    input logic                 i_clk   ,
    // input logic                 i_rst_n ,
    input logic                 i_set   ,
    input logic                 i_rst   ,
    input logic                 i_en    ,
    input logic                 i_t     ,
    output logic                o_q     ,
    output logic                o_q_n    
);

always_ff @( posedge i_clk or negedge i_rst or negedge i_set ) begin : similar_T_flipflop_q_posedge
    if(~i_rst) begin
        o_q     <= 1'b0;
    end else if(~i_set) begin
        o_q     <= 1'b1;
    end else if(i_en) begin
        o_q     <= i_t ^ o_q;
    end
end

always_comb begin
    o_q_n = ~o_q;
end

endmodule
