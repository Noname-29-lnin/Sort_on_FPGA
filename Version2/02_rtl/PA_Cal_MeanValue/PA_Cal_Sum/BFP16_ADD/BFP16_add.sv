module BFP16_add #(
    parameter SIZE_DATA     = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,

    input logic                     i_valid     ,
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_bfu_add   ,
    output logic                    o_valid      
);

logic [SIZE_DATA-1:0] w_data_a, w_data_b;

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_data_in
    if(~i_rst_n) begin
        w_data_a    <= '0;
        w_data_b    <= '0;
    end else if(i_valid) begin
        w_data_a    <= i_data_a;
        w_data_b    <= i_data_b;
    end
end

logic w_sign_a, w_sign_b;
logic [7:0] w_exp_a, w_exp_b;
logic [7:0] w_man_a, w_man_b;
assign w_sign_a = w_data_a[31];
assign w_sign_b = w_data_b[31];
assign w_exp_a  = w_data_a[30:23];
assign w_exp_b  = w_data_b[30:23];
assign w_man_a  = {1'b1, w_data_a[22:16]};
assign w_man_b  = {1'b1, w_data_b[22:16]};
logic is_b_zero;
assign is_b_zero = ~|(w_data_b);

endmodule
