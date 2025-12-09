module BFU16_add_top  #(
    parameter SIZE_DATA    = 16
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
        w_i_add_sub         <= '0;
        w_i_32_a            <= '0;
        w_i_32_b            <= '0;
        o_32_s              <= '0;
        o_ov_flag           <= '0;
        o_un_flag           <= '0;
    end else begin
        w_i_add_sub         <= i_add_sub;
        w_i_32_a            <= i_32_a;
        w_i_32_b            <= i_32_b;
        o_32_s              <= w_o_32_s;
        o_ov_flag           <= w_o_ov_flag;
        o_un_flag           <= w_o_un_flag;
    end
end

BFU16_add #(
    .SIZE_DATA      (SIZE_DATA)
) DUT (
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_bfu_add    
);

endmodule
