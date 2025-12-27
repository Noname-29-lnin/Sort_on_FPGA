module COMP_FPU (
    input logic [31:0]      i_fpu_a ,
    input logic [31:0]      i_fpu_b ,
    output logic            o_less   // i_fpu_a < i_fpu_b
);

logic w_sign_a, w_sign_b;
logic [7:0] w_exponent_a, w_exponent_b;
logic [23:0] w_mantissa_a, w_mantissa_b;
assign w_sign_a = i_fpu_a[31];
assign w_sign_b = i_fpu_b[31];
assign w_exponent_a = i_fpu_a[30:23];
assign w_exponent_b = i_fpu_b[30:23]; 
assign w_mantissa_a = {1'b1, i_fpu_a[22:0]};
assign w_mantissa_b = {1'b1, i_fpu_b[22:0]};

logic w_less_sign, w_equal_sign;
logic w_less_exp, w_equal_exp;
logic w_less_man;

COMP_Sign COMP_SIGN_UNIT (
    .i_sign_a           (w_sign_a),
    .i_sign_b           (w_sign_b),
    .o_less_sign        (w_less_sign),
    .o_equal_sign       (w_equal_sign) 
);
COMP_Exponent #(
    .SIZE_EXP   (8)
) COMP_EXP_UNIT (
    .i_exp_a            (w_exponent_a),
    .i_exp_b            (w_exponent_b),
    .o_less_exp         (w_less_exp),
    .o_equal_exp        (w_equal_exp) 
);
COMP_Mantissa #(
    .SIZE_DATA  (24)
) COMP_MAN_UNIT (
    .i_data_a           (w_mantissa_a),
    .i_data_b           (w_mantissa_b),
    .o_less             (w_less_man)
);

assign o_less = w_less_sign | (w_equal_sign & w_less_exp) | (w_equal_sign & w_equal_exp & w_less_man);

endmodule
