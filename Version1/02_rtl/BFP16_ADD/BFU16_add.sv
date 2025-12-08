module BFU16_add #(
    parameter SIZE_DATA     = 16
)(
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_bfu_add    
);

logic w_sign_a, w_sign_b;
logic [7:0] w_exp_a, w_exp_b;
logic [7:0] w_man_a, w_man_b;
assign w_sign_a = i_data_a[15];
assign w_sign_b = i_data_b[15];
assign w_exp_a  = i_data_a[14:7];
assign w_exp_b  = i_data_b[14:7];
assign w_man_a  = {1'b1, i_data_a[6:0]};
assign w_man_b  = {1'b1, i_data_b[6:0]};



endmodule
