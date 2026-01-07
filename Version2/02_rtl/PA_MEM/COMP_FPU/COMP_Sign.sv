module COMP_Sign(
    input logic         i_sign_a    ,
    input logic         i_sign_b    ,
    output logic        o_less_sign ,
    output logic        o_equal_sign,
    output logic        o_neg_sign   
);

assign o_less_sign  = i_sign_a & ~i_sign_b; // - < +
assign o_equal_sign = ~(i_sign_a ^ i_sign_b); 
assign o_neg_sign   = (i_sign_a & i_sign_b); 

endmodule
