module Data_selector (
    input  logic [23:0] Ma_s1,
    input  logic [23:0] Mb_s1,
    input  logic  A_exp_ge_B_s1,
    output logic [23:0] mantissa_to_shift_s2
);

assign mantissa_to_shift_s2 =  A_exp_ge_B_s1 ? Mb_s1 : Ma_s1;

endmodule 