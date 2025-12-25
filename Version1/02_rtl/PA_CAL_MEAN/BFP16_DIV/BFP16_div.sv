module BFP16_div #(
    parameter SIZE_DATA     = 32
)(
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_bfu_div    
);

logic w_sign_a, w_sign_b;
logic [7:0] w_exp_a, w_exp_b;
logic [7:0] w_man_a, w_man_b;
assign w_sign_a = i_data_a[31];
assign w_sign_b = i_data_b[31];
assign w_exp_a  = i_data_a[30:23];
assign w_exp_b  = i_data_b[30:23];
assign w_man_a  = {1'b1, i_data_a[22:16]};
assign w_man_b  = {1'b1, i_data_b[22:16]};

endmodule
