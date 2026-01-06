/**
 * Module: Result_Integration (Tổ hợp)
 * ĐÃ SỬA: Thêm 'assign' cho large_overflow_calc
 */


module Result_Integration (
    // --- Tín hiệu điều khiển (Từ Tầng 1, đã pipeline) ---
    input  logic         i_bypass_path,
    input  logic         i_large_path,
    input  logic         i_close_path,

    // --- 1. Đầu vào từ Luồng BYPASS ---
    input  logic [31:0]  i_special_case_result,
    input  logic         i_bypass_overflow_flag,
    input  logic         i_bypass_underflow_flag,
    input  logic         i_bypass_invalid_flag,

    // --- 2. Đầu vào từ Luồng LARGE ---
    input  logic [8:0]   i_exp_final_large,      // 9-bit (Dùng để tính Overflow)
    input  logic [23:0]  i_Mantissa_norm_Large,  // 24-bit (đã làm tròn)
    input  logic         C_large_flag,
    input  logic         Cout_large,
    // --- 3. Đầu vào từ Luồng CLOSE ---
    input  logic [8:0]   i_exp_final_Close,      // 9-bit (Dùng để tính Underflow)
    input  logic [23:0]  i_Mantissa_norm_Close,  // 24-bit (đã làm tròn)
    input  logic         lzc_not_all_zero,
    input  logic         Cout_close,

    // --- ĐẦU RA CUỐI CÙNG ---
    output logic [31:0]  final_result,
    output logic         underflow_flag_final,
    output logic         overflow_flag_final,
    output logic         invalid_flag_final,

    // --- Tín hiệu từ Decode_Control (đã pipeline) ---
    input  logic         effective_op_sub,
    input  logic         sub_input,
    input  logic         A_exp_ge_B_s1,
    input  logic         A_exp_qe_B_s1, 
    input  logic         sign_A, 
    input  logic         sign_B
);

    // ===== Internal Logic =====
    logic final_sign_comb;
    logic sign_not_eff_sub;
    logic sign_eff_sub;

    logic sign_of_larger_exp;
    logic large_overflow_calc;   // Cờ Overflow tính toán của Luồng Large
    logic close_underflow_calc;  // Cờ Underflow tính toán của Luồng Close
    logic sign_of_larger_exp_close;
    // --- Tính dấu của số có mũ lớn hơn ---
    // 
    //  assign control_sign = (sub_input) ? effective_op_sub : (sign_of_larger_exp ^effective_op_sub)   ;
    //  assign sign_of_larger_exp = (A_exp_ge_B_s1) ? sign_A : sign_B;
    // 
    // // assign final_sign_comb = (effective_op_sub) ? (sign_of_larger_exp ^ ~Cout_close) : sign_A;  // ( thử)
    //  assign sign_of_larger_exp_close = (effective_op_sub & A_exp_qe_B_s1 & !Cout_close) ?  !sign_of_larger_exp : sign_of_larger_exp;
    //  assign sign_1 =    (A_exp_ge_B_s1) ?  sign_of_larger_exp_close : ((sign_of_larger_exp ^effective_op_sub) ? !sign_of_larger_exp: sign_A);
    //  assign sign_2 =    (A_exp_ge_B_s1) ?  sign_of_larger_exp_close : ((effective_op_sub) ? sign_of_larger_exp : sign_A);
    //  assign sign_eff_sub = sub_input ? sign_1 : sign_2;
    // 
    //  assign sign_not_eff_sub =    (A_exp_ge_B_s1) ?  sign_of_larger_exp_close : ((control_sign) ? sign_of_larger_exp : sign_A);
    //  assign final_sign_comb = (effective_op_sub) ? sign_eff_sub : sign_not_eff_sub;
    logic sign_y_0;
    logic sign_y_1;

    assign sign_of_larger_exp = (A_exp_ge_B_s1) ? sign_A : sign_B;

    always_comb begin
        if (effective_op_sub) begin
            if(A_exp_qe_B_s1 & !Cout_close) begin 
                final_sign_comb = ~sign_A;
            end else if(sub_input) begin 
                if(sign_A | 0) begin 
                    if(A_exp_ge_B_s1) begin 
                    final_sign_comb = sign_A;
                    end else begin 
                    final_sign_comb = 1'b0;
                    end 
                end else begin
                    if(A_exp_ge_B_s1) begin 
                    final_sign_comb = sign_A;
                    end else begin 
                    final_sign_comb = 1'b1;
                    end
                end
            end else begin 
                final_sign_comb = A_exp_ge_B_s1 ? sign_A : sign_B; 
            end 
        end else begin 
             if(sub_input) begin 
             final_sign_comb = sign_A;
            end else begin
            final_sign_comb = A_exp_ge_B_s1 ? sign_A : sign_B; 
            end 
        end
    end

    

    
    // --- Tính dấu cuối cùng của kết quả ---
    // assign final_sign_comb = sign_of_larger_exp;

    // ===  LOGIC TÍNH CỜ ===
    // 1. Overflow (Luồng Large): Exponent >= 255
    assign large_overflow_calc = C_large_flag;
    // assign large_overflow_calc = i_exp_final_large[8] |
    //                     (i_exp_final_large[7] & i_exp_final_large[6] & i_exp_final_large[5] &
    //                      i_exp_final_large[4] & i_exp_final_large[3] & i_exp_final_large[2] &
    //                      i_exp_final_large[1] & i_exp_final_large[0]);

    // 2. Underflow (Luồng Close): Exponent <= 0
    assign close_underflow_calc = i_exp_final_Close[8] | ~( | i_exp_final_Close[7:0] );

    // ===========================

    // --- MUX kết quả cuối cùng ---
    always_comb begin
        // Mặc định (Fail-safe)
        final_result          = 32'h7FC00000; // NaN
        overflow_flag_final   = 1'b0;
        underflow_flag_final  = 1'b0;
        invalid_flag_final    = 1'b1; // Default an toàn

        if (i_bypass_path) begin
            final_result          = i_special_case_result;
            overflow_flag_final   = i_bypass_overflow_flag;
            underflow_flag_final  = i_bypass_underflow_flag;
            invalid_flag_final    = i_bypass_invalid_flag;
        end 
        else if (i_large_path) begin
          
            if (large_overflow_calc) begin
                final_result = {final_sign_comb, 8'hFF, 23'b0}; // Ép về Vô cực
            end else begin
                final_result = {final_sign_comb, i_exp_final_large[7:0], i_Mantissa_norm_Large[22:0]};
            end
            overflow_flag_final   = large_overflow_calc;
            underflow_flag_final  = 1'b0; // Luồng Large không thể underflow
            invalid_flag_final    = 1'b0; // Luồng Large luôn valid
        end 
        else if (i_close_path) begin
            if (~lzc_not_all_zero) begin 
                final_result          = {final_sign_comb, 31'b0}; // Ép về Zero tuyệt đối
                underflow_flag_final  = 1'b0;
            end else if (close_underflow_calc) begin
                final_result = {final_sign_comb, 31'b0}; // Ép về Zero
            end else begin
                final_result = {final_sign_comb, i_exp_final_Close[7:0], i_Mantissa_norm_Close[22:0]};
            end
            overflow_flag_final   = 1'b0; // Luồng Close không thể overflow
            underflow_flag_final  = close_underflow_calc;
            invalid_flag_final    = 1'b0; // Luồng Close luôn valid
        end
    end

endmodule




