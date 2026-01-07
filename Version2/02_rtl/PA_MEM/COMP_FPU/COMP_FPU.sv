module COMP_FPU (
    input logic [31:0]      i_fpu_a ,
    input logic [31:0]      i_fpu_b ,
    output logic            o_less      // A < B
);

    logic w_sign_a, w_sign_b;
    logic [7:0] w_exponent_a, w_exponent_b;
    logic [23:0] w_mantissa_a, w_mantissa_b;

    assign w_sign_a     = i_fpu_a[31];
    assign w_sign_b     = i_fpu_b[31];
    assign w_exponent_a = i_fpu_a[30:23];
    assign w_exponent_b = i_fpu_b[30:23]; 
    assign w_mantissa_a = {1'b1, i_fpu_a[22:0]};
    assign w_mantissa_b = {1'b1, i_fpu_b[22:0]};

    logic w_less_sign, w_equal_sign, w_neg_sign;
    logic w_less_exp, w_equal_exp;
    logic w_less_man;

    logic [7:0]  w_iso_exp_a, w_iso_exp_b;
    logic [23:0] w_iso_man_a, w_iso_man_b;
    logic        w_en_mantissa;

    COMP_Sign COMP_SIGN_UNIT (
        .i_sign_a           (w_sign_a),
        .i_sign_b           (w_sign_b),
        .o_less_sign        (w_less_sign),
        .o_equal_sign       (w_equal_sign),
        .o_neg_sign         (w_neg_sign)
    );

    assign w_iso_exp_a = w_exponent_a & {8{w_equal_sign}};
    assign w_iso_exp_b = w_exponent_b & {8{w_equal_sign}};

    COMP_Exponent #(
        .SIZE_EXP   (8)
    ) COMP_EXP_UNIT (
        .i_exp_a            (w_iso_exp_a),
        .i_exp_b            (w_iso_exp_b),
        .o_less_exp         (w_less_exp),
        .o_equal_exp        (w_equal_exp) 
    );

    assign w_en_mantissa = w_equal_exp & w_equal_sign;
    assign w_iso_man_a = w_mantissa_a & {24{w_en_mantissa}};
    assign w_iso_man_b = w_mantissa_b & {24{w_en_mantissa}};

    COMP_Mantissa #(
        .SIZE_DATA  (24)
    ) COMP_MAN_UNIT (
        .i_data_a           (w_iso_man_a),
        .i_data_b           (w_iso_man_b),
        .o_less             (w_less_man)
    );

    logic w_o_less_sign, w_o_less_exp, w_o_less_man;
    assign w_o_less_sign    = w_less_sign;
    assign w_o_less_exp     = w_equal_sign  & (w_less_exp ^ w_neg_sign);
    assign w_o_less_man     = w_en_mantissa & (w_less_man^ w_neg_sign);
    assign o_less = w_o_less_sign | w_o_less_exp | w_o_less_man;

endmodule