module PTFADD_decode_control (
    input  logic sub,     // 1 = trừ, 0 = cộng
    input  logic [31:0] A,
    input  logic [31:0] B,
//-----------------------------------------------------
//  TÍN HIỆU TỔ HỢP TẦNG 1 (Combinational Logic)
//-----------------------------------------------------
       // decode outputs
    output logic        sign_A_s1,
    output logic        sign_B_s1,
    output logic [8:0]  exp_A_s1,
    output logic [8:0]  exp_B_s1,
    output logic [23:0] Ma_s1,
    output logic [23:0] Mb_s1,

    // bypass info
    output logic        is_zero_A_s1, is_zero_B_s1,
    output logic        is_nan_A_s1,  is_nan_B_s1,
    output logic        is_inf_A_s1,  is_inf_B_s1,
    output logic        is_snan_A_s1, is_snan_B_s1,
   // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
    output logic        is_denormal_A_s1, is_denormal_B_s1,
    output logic        both_denormal,
    // TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
    
    // control 
    output logic        effective_op_sub_s1_comb,
    output logic [8:0]  exp_C_aligned_s2_comb,
    output logic [8:0]  shift_right_amount_comb,
    output logic        bypass_path_s1_comb,
    output logic        large_path_s1_comb,
    output logic        close_sub_path_s1_comb,
//    output logic        close_add_path_s1_comb,
    output logic       A_exp_qe_B_s1,
    // A>= B
    output logic       A_exp_ge_B_s1
);

// logic so sánh 
logic [9:0] diff_result_s1;
logic [8:0] diff_A_minus_B_s1;
logic [8:0] abs_diff_s1;
//TODO :thay thế 
// --- 1. Decode Inputs ---
// assign is_zero_A_s1 = (A[30:0] == 31'b0);
// assign is_zero_B_s1 = (B[30:0] == 31'b0);
// assign is_nan_A_s1  = (A[30:23] == 8'hFF) && (A[22:0] != 0);
// assign is_nan_B_s1  = (B[30:23] == 8'hFF) && (B[22:0] != 0);
// assign is_snan_A_s1 = (A[30:23] == 8'hFF) && (A[22] == 1'b0) && (A[21:0] != 0);
// assign is_snan_B_s1 = (B[30:23] == 8'hFF) && (B[22] == 1'b0) && (B[21:0] != 0);
// assign is_inf_A_s1  = (A[30:23] == 8'hFF) && (A[22:0] == 0);
// assign is_inf_B_s1  = (B[30:23] == 8'hFF) && (B[22:0] == 0);
// 
// // thêm vào để xử lý + 2 số dưới chuẩn nhưng ko làm exp tăng.
//    
// assign is_denormal_A_s1 = (A[30:23] == 8'h00) && (A[22:0] != 23'b0);
// assign is_denormal_B_s1 = (B[30:23] == 8'h00) && (B[22:0] != 23'b0);
// assign both_denormal = is_denormal_A_s1 & is_denormal_B_s1;
// //-------------------------------------------------------------//
// assign sign_A_s1 = A[31];
// assign sign_B_s1 = B[31];
// assign exp_A_s1  = (A[30:23] == 8'h00 && !is_zero_A_s1) ? 9'd1 : {1'b0, A[30:23]};
// assign exp_B_s1  = (B[30:23] == 8'h00 && !is_zero_B_s1) ? 9'd1 : {1'b0, B[30:23]};
// assign Ma_s1     = (A[30:23] == 8'h00) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
// assign Mb_s1     = (B[30:23] == 8'h00) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};

//TODO :thay thế 


// --- Định nghĩa các tín hiệu phụ trợ để code gọn hơn (Intermediate Signals) ---
// Kiểm tra Exponent toàn 1 (dùng cho NaN và Inf)
wire exp_A_ones = &A[30:23];
wire exp_B_ones = &B[30:23];

// Kiểm tra Exponent toàn 0 (dùng cho Denormal và Zero)
wire exp_A_zeros = ~|A[30:23];
wire exp_B_zeros = ~|B[30:23];

// Kiểm tra Mantissa khác 0
wire mant_A_nzero = |A[22:0];
wire mant_B_nzero = |B[22:0];

// --- Phân loại số (Classification) ---

// Zero: Toàn bộ 31 bit (Exp + Mant) đều bằng 0
// (Lưu ý: A[30:0] tương đương check cả Exp và Mantissa)
assign is_zero_A_s1 = ~|A[30:0]; 
assign is_zero_B_s1 = ~|B[30:0];

// NaN: Exp toàn 1 VÀ Mantissa khác 0
assign is_nan_A_s1  = exp_A_ones & mant_A_nzero;
assign is_nan_B_s1  = exp_B_ones & mant_B_nzero;

// Signaling NaN (SNaN): Exp toàn 1 VÀ bit MSB của Mantissa bằng 0 VÀ phần còn lại khác 0
assign is_snan_A_s1 = exp_A_ones & ~A[22] & (|A[21:0]);
assign is_snan_B_s1 = exp_B_ones & ~B[22] & (|B[21:0]);

// Infinity: Exp toàn 1 VÀ Mantissa toàn 0
assign is_inf_A_s1  = exp_A_ones & ~mant_A_nzero;
assign is_inf_B_s1  = exp_B_ones & ~mant_B_nzero;

// Denormal: Exp toàn 0 VÀ Mantissa khác 0
assign is_denormal_A_s1 = exp_A_zeros & mant_A_nzero;
assign is_denormal_B_s1 = exp_B_zeros & mant_B_nzero;

// Both Denormal
assign both_denormal = is_denormal_A_s1 & is_denormal_B_s1;

// --- Tách các thành phần (Extraction) ---

assign sign_A_s1 = A[31];
assign sign_B_s1 = B[31];

// Exponent: Nếu là Denormal (Exp=0, Mant!=0) thì gán Exp = 1 (theo chuẩn tính toán nội bộ), ngược lại giữ nguyên
assign exp_A_s1  = is_denormal_A_s1 ? 9'd1 : {1'b0, A[30:23]};
assign exp_B_s1  = is_denormal_B_s1 ? 9'd1 : {1'b0, B[30:23]};

// Mantissa: Nếu Exp toàn 0 (Zero hoặc Denormal) thì bit ẩn là 0, ngược lại là 1
assign Ma_s1     = exp_A_zeros ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
assign Mb_s1     = exp_B_zeros ? {1'b0, B[22:0]} : {1'b1, B[22:0]};
assign effective_op_sub_s1_comb = sign_A_s1 ^ sign_B_s1 ^ sub;



//------------------------------------------------//
logic exp_subtractor_C_out;

//todo ....................
 // CLA_adder_top #(
 //     .WIDTH(9)
 // ) exp_subtractor_ip (
 //     .A(exp_A_s1),
 //     .B(~exp_B_s1),        // Bù 1 của B
 //     .C_in(1'b1),        
 //     .Sum(diff_result_s1), // Lấy Sum[9:0] (10 bit)
 //     .C_out(exp_subtractor_C_out)              // bỏ qua
 // );
// todo.......................
 CLA_9bit exp(
     .i_carry(1'b1),
     .i_data_a(exp_A_s1),
     .i_data_b(~exp_B_s1),
     .o_sum(diff_result_s1),
     .o_carry(exp_subtractor_C_out)
 );
//todo.......................



assign diff_A_minus_B_s1 = diff_result_s1[8:0]; // 9-bit kết quả
assign A_exp_ge_B_s1 = diff_result_s1[9];
assign A_exp_qe_B_s1 = !(| diff_A_minus_B_s1);
assign abs_diff_s1 = A_exp_ge_B_s1 ? diff_A_minus_B_s1 
                                 : (~diff_A_minus_B_s1 + 9'd1);    // tín hiệu shift cuối cùng 
//
// --- 2. Control Logic ---
assign    shift_right_amount_comb = abs_diff_s1;
//-------- shift_right_amount_comb > 1 -----------//
logic  not_shift_right_amount_gt_1;
assign not_shift_right_amount_gt_1 = !(|shift_right_amount_comb[8:1]);
//---------------------------------------------//
always_comb begin
    //    mặc định  //
    bypass_path_s1_comb    = 1'b0;
    large_path_s1_comb     = 1'b0;
    close_sub_path_s1_comb = 1'b0;
    // close_add_path_s1_comb = 1'b0;
    //

    if (A_exp_ge_B_s1) exp_C_aligned_s2_comb = exp_A_s1;
    else               exp_C_aligned_s2_comb = exp_B_s1;

    if (is_nan_A_s1 || is_nan_B_s1 || is_inf_A_s1 || is_inf_B_s1 ||
        is_zero_A_s1 || is_zero_B_s1) begin
        bypass_path_s1_comb = 1'b1;
    end else begin
        if (effective_op_sub_s1_comb & not_shift_right_amount_gt_1)
            close_sub_path_s1_comb = 1'b1;
        else large_path_s1_comb = 1'b1;
    end
end

endmodule 

