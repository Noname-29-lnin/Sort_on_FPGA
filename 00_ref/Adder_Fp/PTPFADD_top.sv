// chưa sửa
module PTPFADD_top (
    input  logic sub,     // 1 = trừ; 0 = cộng
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] C,
    output logic       final_underflow_flag,
    output logic       final_overflow_flag,
    output logic       final_invalid_flag
);
    logic        sign_A_s1;
    logic        sign_B_s1;
    logic [8:0]  exp_A_s1;
    logic [8:0]  exp_B_s1;
    logic [23:0] Ma_s1;
    logic [23:0] Mb_s1; 
           // bypass info
    logic        is_zero_A_s1, is_zero_B_s1;
    logic        is_nan_A_s1,  is_nan_B_s1;
    logic        is_inf_A_s1,  is_inf_B_s1;
    logic        is_snan_A_s1, is_snan_B_s1;

    // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
    logic        is_denormal_A_s1, is_denormal_B_s1;
    logic        both_denormal;
    // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp  
    logic        effective_op_sub_s1_comb;
    logic [8:0]  exp_C_aligned_s2_comb;
    logic [8:0]  shift_right_amount_comb;
    logic        bypass_path_s1_comb;
    logic        large_path_s1_comb;
    logic        close_sub_path_s1_comb;
    // logic        close_add_path_s1_comb;
    // A>= B
    logic        A_exp_ge_B_s1;
    logic        A_exp_qe_B_s1;
    logic [23:0] Ma_s1_unblock;
    logic [23:0] Mb_s1_unblock;
    //--------------------------------//
    PTFADD_decode_control S1 (
	 .A                            (A),
    .B                            (B),
    .sub                          (sub),
    .sign_A_s1                    (sign_A_s1),
    .sign_B_s1                    (sign_B_s1),
    .exp_A_s1                     (exp_A_s1),
    .exp_B_s1                     (exp_B_s1),
    .Ma_s1                        (Ma_s1_unblock),
    .Mb_s1                        (Mb_s1_unblock),
    .is_zero_A_s1                 (is_zero_A_s1),
    .is_zero_B_s1                 (is_zero_B_s1),
    .is_nan_A_s1                  (is_nan_A_s1),
    .is_nan_B_s1                  (is_nan_B_s1),
    .is_snan_A_s1                 (is_snan_A_s1),
    .is_snan_B_s1                 (is_snan_B_s1),
    .is_inf_A_s1                  (is_inf_A_s1),
    .is_inf_B_s1                  (is_inf_B_s1),
    // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
    .is_denormal_A_s1             (is_denormal_A_s1),
    .is_denormal_B_s1             (is_denormal_B_s1),
    .both_denormal                (both_denormal),
    // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp  
    .effective_op_sub_s1_comb     (effective_op_sub_s1_comb),
    .exp_C_aligned_s2_comb        (exp_C_aligned_s2_comb),
    .shift_right_amount_comb      (shift_right_amount_comb),
    .bypass_path_s1_comb          (bypass_path_s1_comb),
    .large_path_s1_comb           (large_path_s1_comb),
    .close_sub_path_s1_comb       (close_sub_path_s1_comb),
    // .close_add_path_s1_comb       (close_add_path_s1_comb), bỏ 
    .A_exp_qe_B_s1                 (A_exp_qe_B_s1),
    .A_exp_ge_B_s1                (A_exp_ge_B_s1)
    );


//-------------------bypass_operation_isolation-------------//
    logic       special_case_detected_comb;
    logic [31:0] special_case_result_comb;
    logic       overflow_flag_comb;        
    logic       underflow_flag_comb;       
    logic       invalid_flag_comb; 

    bypass_logic  u_bypass_logic (
    .bypass_path_s1      (bypass_path_s1_comb),
    .sub                 (sub),

    // ---- special number flags ----
    .is_zero_A_s1        (is_zero_A_s1),
    .is_zero_B_s1        (is_zero_B_s1),
    .is_nan_A_s1         (is_nan_A_s1),
    .is_nan_B_s1         (is_nan_B_s1),
    .is_inf_A_s1         (is_inf_A_s1),
    .is_inf_B_s1         (is_inf_B_s1),
    .is_snan_A_s1        (is_snan_A_s1),   // 
    .is_snan_B_s1        (is_snan_B_s1),

    // ---- basic fields ----
    .sign_A_s1           (sign_A_s1),
    .sign_B_s1           (sign_B_s1),
    .exp_A_field_s1      (A[30:23]),      // bỏ bit mở rộng (bit thứ 8)
    .exp_B_field_s1      (B[30:23]),
    .frac_A_s1           (A[22:0]),
    .frac_B_s1           (B[22:0]),

    // ---- outputs ----
    .special_case_detected_comb (special_case_detected_comb),
    .special_case_result_comb   (special_case_result_comb),
    .overflow_flag_comb         (overflow_flag_comb),
    .underflow_flag_comb        (underflow_flag_comb),
    .invalid_flag_comb          (invalid_flag_comb)
);    
    assign Ma_s1 = bypass_path_s1_comb ? 24'b0 : Ma_s1_unblock;
    assign Mb_s1 = bypass_path_s1_comb ? 24'b0 : Mb_s1_unblock;
    logic [23:0] mantissa_larger_exp; 

    assign mantissa_larger_exp = (A_exp_ge_B_s1) ? Ma_s1 : Mb_s1;

//----------------------------------------------------------//
//-------------------large_path_operation_isolation---------//   
//----------------------------------------------------------//   
    logic [23:0] mantissa_to_shift_s2_large;
    logic [23:0] shifted_large_path;
    logic [23:0] barrel_shifter_in;
    logic                 G_large, R_large,S_large;
 Data_selector  S2_large_path_selector (
     .Ma_s1(Ma_s1),
     .Mb_s1(Mb_s1),
     .A_exp_ge_B_s1(A_exp_ge_B_s1),
     .mantissa_to_shift_s2(mantissa_to_shift_s2_large)              // tính hiệu nào lớn bé hơn
    );


    //điều chỉnh số bit dịch 
    assign barrel_shifter_in = (large_path_s1_comb) ? mantissa_to_shift_s2_large : 24'b0 ;    // shift bao nhiu

logic C_out_GRS;
Pre_aliment   S2_large_path_shifter  (
    .x            (barrel_shifter_in),          //barrel_shifter_in 
    .s            (shift_right_amount_comb),    //  s=shifter_s_port tín hiệu đã điều chỉnh 
    .ARITH        (1'b1),  // 1
    .complementer (effective_op_sub_s1_comb),
    .G(G_large),
    .R(R_large),
    .S(S_large),
    .C_out_GRS(C_out_GRS),
    .y            (shifted_large_path)
);
//-------------------------------------------//
//------------------Stage 3-----------------//
//-------------------------------------------//
    logic [24:0] Result_large;
    logic        Cout_large;
    logic [8:0]  exp_large_s3;
    logic [8:0] exp_final_large_output;
    logic       C_large_flag_output;
    // Adder + rounding logic
    Adder_round_logic u_large_adder_round (
        .Ma                 (mantissa_larger_exp),                  // mantissa lớn
        .Mb                 (shifted_large_path),
        .close_path_s1      (close_sub_path_s1_comb),     // mantissa nhỏ hơn (đã dịch)
        .G                  (G_large),
        .R                  (R_large),
        .S                  (S_large),
        .sub                (effective_op_sub_s1_comb),
        .C_in_GRS           (C_out_GRS),
        .Result             (Result_large),
        .C_out              (Cout_large)    
    );


    Result_Large u_large_exponent_logic (
        .Sum                (Result_large),             // [24:0] từ Adder_round_logic (S3)
        .exp_C              (exp_C_aligned_s2_comb),    // [8:0] từ decode_control (S1)
        .effective_op_sub   (effective_op_sub_s1_comb), // [1] từ decode_control (S1) 
        .exp_final_large    (exp_final_large_output),   // [8:0] Đầu ra (sẽ đi tới MUX cuối)
        .C_large_flag       (C_large_flag_output)       // [1] Đầu ra (sẽ đi tới MUX cuối)
    );

//---------------------------------//
//-------Stage 4: Normalization----//
//---------------------------------//

    logic [23:0] Mantissa_norm_large;

    Normalization_Large u_large_normalization (
        .Sum                  (Result_large),
        .effective_op_sub     (effective_op_sub_s1_comb),
     // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
        .both_denormal      (both_denormal),
     // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
        .Mantissa_norm_Large  (Mantissa_norm_large)
    );


//----------------------------------------------------------//
//-------------------close_path_operation_isolation---------//   
//----------------------------------------------------------//   
    logic close_path_s1;
    logic [23:0] mantissa_to_shift_s2_close;
    logic [23:0] close_shifter_in;
    logic [23:0] shifted_close_path;
    logic  G_close, R_close, S_close;
     Data_selector  S2_close_path_selector (
     .Ma_s1(Ma_s1),
     .Mb_s1(Mb_s1),
     .A_exp_ge_B_s1(A_exp_ge_B_s1),
     .mantissa_to_shift_s2(mantissa_to_shift_s2_close)
    );

    assign close_path_s1 = close_sub_path_s1_comb; 
    assign close_shifter_in = (close_path_s1) ? mantissa_to_shift_s2_close : 24'b0;

    logic        C_out_GRS_close;
    Right_shifter_1bit #( .N(24) )S2_close_path_shifter_1bit (
    .x(close_shifter_in),  
    .shift(shift_right_amount_comb[0]),
    .complementer(effective_op_sub_s1_comb),
    .ARITH(1'b0),
    .G(G_close),
    .R(R_close),
    .S(S_close),
    .C_out_GRS(C_out_GRS_close),
    .y(shifted_close_path)
    
    );

//-------------------------------------------//
//------------------Stage 2-----------------//
//------------------------------------------//
    logic [24:0] Result_close;
    logic [31:0] Result_close_expand; 
    logic        Cout_close;


    Adder_round_logic u_close_adder_round (
        .Ma             (mantissa_larger_exp),              // mantissa lớn hơn
        .Mb             (shifted_close_path), // mantissa nhỏ hơn, đã dịch 1 bit
        .close_path_s1  (close_sub_path_s1_comb),
        .G              (G_close),
        .R              (R_close),
        .S              (S_close),
        .sub            (effective_op_sub_s1_comb),
        .C_in_GRS        (C_out_GRS_close),
        .Result         (Result_close),
        .C_out          (Cout_close)
        
    );
assign Result_close_expand = {Result_close[23:0], 8'b0};
//-------------------------------------------//
//------------------Stage 3-----------------//
//------------------------------------------//

logic [4:0] lzc_shift_val;
logic       lzc_not_all_zero;

LZC_32bit u_lzc32 (
    .i_A            (Result_close_expand),
    .o_Z            (lzc_shift_val),
    .o_not_all_zero (lzc_not_all_zero)
);

logic [8:0] exp_final_Close;       // exponent sau khi trừ leading zeros

Result_Close u_result_close (
    .Sum            (Result_close),  // phần mantissa (25 bit chính)
    .i_Z_count      (lzc_shift_val),              // đầu ra từ LZC
    .exp_C          (exp_C_aligned_s2_comb),                   // exp hiện tại (từ stage 3)
    .exp_final_Close(exp_final_Close)
);

//-------------------------------------------//
//------------------Stage 4-----------------//
//------------------------------------------//
logic [24:0] Mantissa_norm_Close;
logic        shift_overflow_flag;                      // cờ underflow 
    
// === Normalization Stage (Left Shifter) ===
Normalization_Close #(
    .N(24)
) u_normalization_close (
    .Sum                 (Result_close[23:0]),  // đầu vào 
    .s                   (lzc_shift_val),        // số bit cần dịch (từ LZC)
    .Mantissa_norm_Close (Mantissa_norm_Close)
);


//----------------Result_Integration--------------------/


    Result_Integration u_final_mux (
        // --- Tín hiệu điều khiển ---
        .i_bypass_path(bypass_path_s1_comb), 
        .i_large_path (large_path_s1_comb), 
        .i_close_path (close_sub_path_s1_comb), 

        // --- 1. Luồng BYPASS ---
        .i_special_case_result   (special_case_result_comb),
        .i_bypass_overflow_flag  (overflow_flag_comb),
        .i_bypass_underflow_flag (underflow_flag_comb),
        .i_bypass_invalid_flag   (invalid_flag_comb),

        // --- 2. Luồng LARGE ---
        .i_exp_final_large         (exp_final_large_output),
        .i_Mantissa_norm_Large     (Mantissa_norm_large),
        .C_large_flag               (C_large_flag_output),
        .Cout_large                 (Cout_large),
        // --- 3. Luồng CLOSE ---
        .i_exp_final_Close         (exp_final_Close),
        .i_Mantissa_norm_Close     (Mantissa_norm_Close),
        .lzc_not_all_zero           (lzc_not_all_zero),
        .Cout_close                 (Cout_close),

        // --- Tín hiệu từ Decode ---
        .effective_op_sub (effective_op_sub_s1_comb),
        .sub_input               (sub),
        .A_exp_ge_B_s1    (A_exp_ge_B_s1),
        .A_exp_qe_B_s1     (A_exp_qe_B_s1),
        .sign_A           (sign_A_s1), 
        .sign_B           (sign_B_s1),
        
        // --- ĐẦU RA CUỐI CÙNG ---
        .final_result           (C), // Nối vào đầu ra C của top
        .underflow_flag_final   (final_underflow_flag),
        .overflow_flag_final    (final_overflow_flag),
        .invalid_flag_final     (final_invalid_flag)
    );

endmodule 
