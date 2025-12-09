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

// Internal Signals
logic w_comp_exp_less;
logic [7:0] w_swap_exp_max;
logic [7:0] w_swap_exp_min;
logic [7:0] w_sub_exp_result;

logic [7:0] w_swap_man0_max;
logic [7:0] w_swap_man0_min;
logic w_comp_man_less;
logic [7:0] w_swap_man1_max;
logic [7:0] w_swap_man1_min;
logic [15:0] w_shf_right_man1_min;
logic w_shf_right_over;

logic [7:0] w_alu_man_result;
logic w_alu_man_overflow;

logic [2:0] w_lopd_one_pos;
logic w_lopd_zero_flag;

logic [7:0] w_nor_man;
logic [7:0] w_exp_adjust;

logic w_sel_exp;
logic [1:0] w_sel_man;

logic w_sign_result;
logic [7:0] w_exp_result;
logic [7:0] w_man_result;

// Submodules
COMP_8bit #(
    .SIZE_DATA      (8)
) COMP_EXP_UNIT (
    .i_data_a       (w_exp_a),
    .i_data_b       (w_exp_b),
    .o_less         (w_comp_exp_less)
);
SWAP_unit #(
    .SIZE_DATA      (8)
) SWAP_EXP_UNIT (
    .i_comp_less    (w_comp_exp_less), // i_comp_less = i_data_a < i_data_b
    .i_data_a       (w_exp_a),
    .i_data_b       (w_exp_b),
    .o_data_max     (w_swap_exp_max),
    .o_data_min     (w_swap_exp_min) 
);
CLA_8bit SUB_EXP_UNIT (
    .i_carry        (1'b1),
    .i_data_a       (w_swap_exp_max),
    .i_data_b       (~(w_swap_exp_min)),
    .o_sum          (w_sub_exp_result),
    .o_carry        (w_exp_adjust)
);
EXP_adjust #(
    .SIZE_EXP       (8),
    .SIZE_LOPD      (8)
) EXP_ADJUSTION_UNIT (
    .i_overflow     (w_alu_man_overflow),
    .i_underflow    (w_alu_man_result[7]),
    .i_zero_flag    (w_lopd_zero_flag),
    .i_lopd_value   (w_lopd_one_pos),
    .i_exp_value    (w_swap_exp_max),
    .o_exp_result   ()
);
SWAP_unit #(
    .SIZE_DATA      (8)
) SWAP_MAN0_UNIT (
    .i_comp_less    (w_comp_exp_less), // i_comp_less = i_data_a < i_data_b
    .i_data_a       (w_man_a),
    .i_data_b       (w_man_b),
    .o_data_max     (w_swap_man0_max),
    .o_data_min     (w_swap_man0_min) 
);
SHF_right #(
    .SIZE_DATA      (16),
    .SIZE_SHIFT     (4 ) 
) SHF_RIGHT_MAN_UNIT (
    .i_shift_number (w_sub_exp_result[2:0]),
    .i_data         ({w_swap_man0_min, 8'b0}), 
    .o_data         (w_shf_right_man1_min)
);
assign w_shf_right_over = w_shf_right_man1_min[7];

COMP_8bit #(
    .SIZE_DATA      (8)
) COMP_MAN_UNIT (
    .i_data_a       (w_swap_man0_max),
    .i_data_b       (w_shf_right_man1_min[15:8]),
    .o_less         (w_comp_man_less)
);
SWAP_unit #(
    .SIZE_DATA      (8)
) SWAP_MAN1_UNIT (
    .i_comp_less    (w_comp_exp_less), // i_comp_less = i_data_a < i_data_b
    .i_data_a       (w_swap_man0_max),
    .i_data_b       (w_shf_right_man1_min[15:8]),
    .o_data_max     (w_swap_man1_max),
    .o_data_min     (w_swap_man1_min) 
);
MAN_ALU #(
    .SIZE_MAN       (8)
) MAN_ALU_UNIT (
    .i_sign_a       (w_sign_a),
    .i_sign_b       (w_sign_b),
    .i_carry        (w_shf_right_over),
    .i_man_max      (w_swap_man1_max),
    .i_man_min      (w_swap_man1_min),
    .o_man_alu      (w_alu_man_result),
    .o_overflow     (w_alu_man_overflow) 
);
LOPD_8bit LOPD_UNIT (
    .i_data         (w_alu_man_result),
    .o_pos_one      (w_lopd_one_pos),
    .o_zero_flag    (w_lopd_zero_flag)
);
NOR_unit #(
    .SIZE_LOPD      (3) ,
    .SIZE_DATA      (8)
) NOR_UNIT (
    .i_overflow     (w_alu_man_overflow),
    .i_zero_flag    (w_lopd_zero_flag),
    .i_one_position (w_lopd_one_pos),
    .i_mantissa     (w_alu_man_result),
    .o_mantissa     (w_nor_man) 
);

SIGN_unit SIGN_UNIT (
    .i_comp_man     (w_comp_exp_less | w_comp_man_less),
    .i_sign_man_a   (w_sign_a),
    .i_sign_man_b   (w_sign_b),
    .o_sign_s       (w_sign_result) 
);

PSC_unit PSC_UNIT (
    .i_sign_a       (w_sign_a),
    .i_exp_a        (w_exp_a),
    .i_man_a        (w_man_a),
    .i_sign_b       (w_sign_b),
    .i_exp_b        (w_exp_b),
    .i_man_b        (w_man_b),
    .o_sel_exp      (w_sel_exp),
    .o_sel_man      (w_sel_man) 
);

assign w_exp_result = w_sel_exp ? 8'hFF : w_exp_adjust;
assign w_man_result = w_sel_man[1] ? (w_sel_man[0] ? '0 : 8'b1000_0000) : w_nor_man;

assign o_bfu_add = {w_sign_result, w_exp_result, w_man_result[6:0]};

endmodule
