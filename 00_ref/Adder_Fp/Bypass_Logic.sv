/*
 * Module: bypass_logic (Tổ hợp)
 * Xử lý tất cả các trường hợp đặc biệt (NaN, Inf, Zero).
 */
 
module bypass_logic (
    // --- Đầu vào (TỪ Thanh ghi Tầng 1) ---
    input  logic       bypass_path_s1, 
    input  logic       sub,            
    input  logic       is_zero_A_s1,
    input  logic       is_zero_B_s1,
    input  logic       is_nan_A_s1,
    input  logic       is_nan_B_s1,
    input  logic       is_inf_A_s1,
    input  logic       is_inf_B_s1,
    input  logic       is_snan_A_s1,   
    input  logic       is_snan_B_s1,   
    input  logic       sign_A_s1,      
    input  logic       sign_B_s1,      
    input  logic [7:0] exp_A_field_s1, 
    input  logic [7:0] exp_B_field_s1, 
    input  logic [22:0] frac_A_s1,     
    input  logic [22:0] frac_B_s1,     

    output logic       special_case_detected_comb,
    output logic [31:0] special_case_result_comb, 
    output logic       overflow_flag_comb,        
    output logic       underflow_flag_comb,             
    output logic       invalid_flag_comb            
);

    logic [31:0] A_rec;
    logic [31:0] B_rec;
    logic        eff_sign_B; // Dấu hiệu quả của B

    // hợp lại
    assign A_rec = { sign_A_s1, exp_A_field_s1, frac_A_s1 };
    assign B_rec = { sign_B_s1, exp_B_field_s1, frac_B_s1 };

    // TÍNH TOÁN DẤU HIỆU QUẢ CỦA B:
    // eff_sign_B = sign_B_s1 (nếu cộng)
    // eff_sign_B = ~sign_B_s1 (nếu trừ)
    assign eff_sign_B = sign_B_s1 ^ sub;

   
    always_comb begin
        // Default
        special_case_detected_comb = 1'b0;
        special_case_result_comb   = 32'b0;
        overflow_flag_comb         = 1'b0;
        underflow_flag_comb        = 1'b0;
        invalid_flag_comb          = 1'b0;

        if (bypass_path_s1 && (
            is_nan_A_s1 || is_nan_B_s1 ||
            is_inf_A_s1 || is_inf_B_s1 ||
            is_zero_A_s1 || is_zero_B_s1)) begin

            special_case_detected_comb = 1'b1;

            // ===== 1. NaN priority =====
            if (is_nan_A_s1 || is_nan_B_s1) begin
                special_case_result_comb = (is_nan_A_s1) ? A_rec : B_rec;
                if (is_snan_A_s1 || is_snan_B_s1)
                    invalid_flag_comb = 1'b1; // chỉ khi có signaling NaN
            end

            // ===== 2. Infinity cases =====
            else if (is_inf_A_s1 && is_inf_B_s1) begin
                if (sign_A_s1 != eff_sign_B) begin
                    special_case_result_comb = 32'h7FC00000; // NaN (∞ - ∞)
                    invalid_flag_comb        = 1'b1;
                end else begin
                    special_case_result_comb = A_rec; // ∞ + ∞ = ∞
                end
            end
            else if (is_inf_A_s1) begin
                special_case_result_comb = A_rec; // ∞ ± finite = ∞
            end
            else if (is_inf_B_s1) begin
                special_case_result_comb = {eff_sign_B, B_rec[30:0]};
            end

            // ===== 3. Zero cases =====
            else if (is_zero_A_s1 && is_zero_B_s1) begin
                special_case_result_comb = {sign_A_s1 & eff_sign_B, 31'b0};
            end
            else if (is_zero_A_s1) begin
                special_case_result_comb = {eff_sign_B, B_rec[30:0]};
            end
            else if (is_zero_B_s1) begin
                special_case_result_comb = A_rec;
            end
        end
    end

endmodule