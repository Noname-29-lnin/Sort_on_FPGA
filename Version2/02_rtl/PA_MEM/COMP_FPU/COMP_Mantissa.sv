module COMP_Mantissa #(
    parameter SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0] i_data_a,
    input  logic [SIZE_DATA-1:0] i_data_b,
    output logic                 o_less   
);

    logic w_less_0_0, w_less_0_1, w_less_0_2, w_less_0_3, w_less_0_4, w_less_0_5;
    logic w_equal_0_0, w_equal_0_1, w_equal_0_2, w_equal_0_3, w_equal_0_4, w_equal_0_5;

    logic w_en_4, w_en_3, w_en_2, w_en_1, w_en_0;

    logic [3:0] w_iso_a_4, w_iso_b_4;
    logic [3:0] w_iso_a_3, w_iso_b_3;
    logic [3:0] w_iso_a_2, w_iso_b_2;
    logic [3:0] w_iso_a_1, w_iso_b_1;
    logic [3:0] w_iso_a_0, w_iso_b_0;

    COMP_LESS_4bit u_i_data_5 (
        .i_data_a (i_data_a[23:20]),
        .i_data_b (i_data_b[23:20]),
        .o_less   (w_less_0_5),
        .o_equal  (w_equal_0_5)
    );

    assign w_en_4    = w_equal_0_5; 
    assign w_iso_a_4 = i_data_a[19:16] & {4{w_en_4}};
    assign w_iso_b_4 = i_data_b[19:16] & {4{w_en_4}};

    COMP_LESS_4bit u_i_data_4 (
        .i_data_a (w_iso_a_4),
        .i_data_b (w_iso_b_4),
        .o_less   (w_less_0_4),
        .o_equal  (w_equal_0_4)
    );

    assign w_en_3    = w_en_4 & w_equal_0_4;
    assign w_iso_a_3 = i_data_a[15:12] & {4{w_en_3}};
    assign w_iso_b_3 = i_data_b[15:12] & {4{w_en_3}};

    COMP_LESS_4bit u_i_data_3 (
        .i_data_a (w_iso_a_3),
        .i_data_b (w_iso_b_3),
        .o_less   (w_less_0_3),
        .o_equal  (w_equal_0_3)
    );

    assign w_en_2    = w_en_3 & w_equal_0_3;
    assign w_iso_a_2 = i_data_a[11:8] & {4{w_en_2}};
    assign w_iso_b_2 = i_data_b[11:8] & {4{w_en_2}};

    COMP_LESS_4bit u_i_data_2 (
        .i_data_a (w_iso_a_2),
        .i_data_b (w_iso_b_2),
        .o_less   (w_less_0_2),
        .o_equal  (w_equal_0_2)
    );

    assign w_en_1    = w_en_2 & w_equal_0_2;
    assign w_iso_a_1 = i_data_a[7:4] & {4{w_en_1}};
    assign w_iso_b_1 = i_data_b[7:4] & {4{w_en_1}};

    COMP_LESS_4bit u_i_data_1 (
        .i_data_a (w_iso_a_1),
        .i_data_b (w_iso_b_1),
        .o_less   (w_less_0_1),
        .o_equal  (w_equal_0_1)
    );

    assign w_en_0    = w_en_1 & w_equal_0_1;
    assign w_iso_a_0 = i_data_a[3:0] & {4{w_en_0}};
    assign w_iso_b_0 = i_data_b[3:0] & {4{w_en_0}};

    COMP_LESS_4bit u_i_data_0 (
        .i_data_a (w_iso_a_0),
        .i_data_b (w_iso_b_0),
        .o_less   (w_less_0_0),
        .o_equal  (w_equal_0_0)
    );
    assign o_less = w_less_0_5 
                    | (w_en_4 & w_less_0_4) 
                    | (w_en_3 & w_less_0_3) 
                    | (w_en_2 & w_less_0_2) 
                    | (w_en_1 & w_less_0_1) 
                    | (w_en_0 & w_less_0_0);

endmodule