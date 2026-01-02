module ADD_SUB_CLA_16bit(
    input  logic        i_carry,
    input  logic [15:0] i_data_a,
    input  logic [15:0] i_data_b,
    output logic [15:0] o_sum,
    output logic        o_carry
);

    logic [3:0] w_P, w_G;
    logic [3:0] w_C;
    assign w_C[0] = i_carry;
    assign w_C[1] = w_G[0] | (w_P[0] & w_C[0]);
    assign w_C[2] = w_G[1] | (w_P[1] & w_G[0]) | (w_P[1] & w_P[0] & w_C[0]);
    assign w_C[3] = w_G[2] | (w_P[2] & w_G[1]) | (w_P[2] & w_P[1] & w_G[0]) | (w_P[2] & w_P[1] & w_P[0] & w_C[0]);
    assign o_carry = w_G[3] | (w_P[3] & w_G[2]) | (w_P[3] & w_P[2] & w_G[1]) | 
                     (w_P[3] & w_P[2] & w_P[1] & w_G[0]) | 
                     (w_P[3] & w_P[2] & w_P[1] & w_P[0] & w_C[0]);

    ADD_SUB_CLA_4bit CLA_UNIT_0 (
        .a      (i_data_a[3:0]),
        .b      (i_data_b[3:0]),
        .cin    (w_C[0]),
        .sum    (o_sum[3:0]),
        .o_p    (w_P[0]),
        .o_g    (w_G[0])
    );
    ADD_SUB_CLA_4bit CLA_UNIT_1 (
        .a      (i_data_a[7:4]),
        .b      (i_data_b[7:4]),
        .cin    (w_C[1]),
        .sum    (o_sum[7:4]),
        .o_p    (w_P[1]),
        .o_g    (w_G[1])
    );
    ADD_SUB_CLA_4bit CLA_UNIT_2 (
        .a      (i_data_a[11:8]),
        .b      (i_data_b[11:8]),
        .cin    (w_C[2]),
        .sum    (o_sum[11:8]),
        .o_p    (w_P[2]),
        .o_g    (w_G[2])
    );
    ADD_SUB_CLA_4bit CLA_UNIT_3 (
        .a      (i_data_a[15:12]),
        .b      (i_data_b[15:12]),
        .cin    (w_C[3]),
        .sum    (o_sum[15:12]),
        .o_p    (w_P[3]),
        .o_g    (w_G[3])
    );

endmodule