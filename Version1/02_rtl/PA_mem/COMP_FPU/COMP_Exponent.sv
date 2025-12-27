module COMP_Exponent #(
    parameter SIZE_EXP = 8
)(
    input logic [SIZE_EXP-1:0]      i_exp_a     ,
    input logic [SIZE_EXP-1:0]      i_exp_b     ,
    output logic                    o_less_exp  ,
    output logic                    o_equal_exp  
);

logic w_less_low, w_equal_low;
    logic w_less_high, w_equal_high;

    COMP_4bit u_low (
        .i_data_a (i_exp_a[3:0]),
        .i_data_b (i_exp_b[3:0]),
        .o_less   (w_less_low),
        .o_equal  (w_equal_low)
    );

    COMP_4bit u_high (
        .i_data_a (i_exp_a[7:4]),
        .i_data_b (i_exp_b[7:4]),
        .o_less   (w_less_high),
        .o_equal  (w_equal_high)
    );

    assign o_less_exp = w_less_high | (w_equal_high & w_less_low);
    assign o_equal_exp = w_equal_high & w_equal_low;

endmodule
