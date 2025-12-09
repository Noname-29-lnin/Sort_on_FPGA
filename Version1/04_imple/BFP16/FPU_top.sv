module FPU_top  #(
    parameter SIZE_DATA    = 32
)(
    input logic                         i_clk           ,
    input logic                         i_rst_n         ,
    input logic [SIZE_DATA-1:0]          i_32_a          ,
    input logic [SIZE_DATA-1:0]          i_32_b          ,
    output logic [SIZE_DATA-1:0]         o_32_s           
);

logic [SIZE_DATA-1:0]          w_i_32_a;
logic [SIZE_DATA-1:0]          w_i_32_b;
logic [SIZE_DATA-1:0]          w_o_32_s;    

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_est_time
    if(~i_rst_n) begin
        w_i_32_a            <= '0;
        w_i_32_b            <= '0;
        o_32_s              <= '0;
    end else begin
        w_i_32_a            <= i_32_a;
        w_i_32_b            <= i_32_b;
        o_32_s              <= w_o_32_s;
    end
end

BFP16_add #(
    .SIZE_DATA      (SIZE_DATA)
) DUT (
    .i_data_a       (w_i_32_a),
    .i_data_b       (w_i_32_b),
    .o_bfu_add      (w_o_32_s) 
);

endmodule
