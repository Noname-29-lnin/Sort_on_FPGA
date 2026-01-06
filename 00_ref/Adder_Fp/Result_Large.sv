/**
 * Module: Result_Large (Exponent Adjustment Logic)
 * Chức năng: Điều chỉnh Exponent dựa trên trạng thái Mantissa (Sum[24:23]).
 * Ghi chú: Tín hiệu effective_op_sub không ảnh hưởng đến logic điều chỉnh số mũ.
 */
/*
module Result_Large(                                             
    input  logic [24:0] Sum,                // Mantissa sau cộng/trừ
    input  logic [8:0]  exp_C,              // Exponent đã căn chỉnh
    input  logic        effective_op_sub,   // KHÔNG dùng trong logic này
    output logic [8:0]  exp_final_large,    // Exponent sau điều chỉnh
    output logic        C_large_flag        // Cờ báo tràn số mũ
);

    // --- Tín hiệu điều chỉnh ---
    logic exp_adj_incr; // Yêu cầu +1 nếu Mantissa tràn
    logic exp_adj_decr; // Yêu cầu -1 nếu Mantissa thiếu

    logic Sum_align;
    
    // assign Sum_align = (Sum[24]) ?  ~Sum[23:0] : ~Sum[23:0]

    assign exp_adj_incr = (effective_op_sub)  ? Sum[24] & !Sum[23] : Sum[24] ;          // Tràn: bit cao nhất bật
    assign exp_adj_decr = ~Sum[24] & ~Sum[23];   // Thiếu: hai bit cao nhất đều tắt

    // --- Tính toán song song Exp+1 và Exp−1 ---
    logic [8:0] exp_plus_1, exp_minus_1;
    logic       C_out_plus_1;

    // Tăng số mũ
    Incre_decr #(.N(9)) u_incr (
        .A      (exp_C),
        .decr   (1'b0),
        .S      (exp_plus_1),
        .C_out  (C_out_plus_1)
    );

    // Giảm số mũ
    Incre_decr #(.N(9)) u_decr (
        .A      (exp_C),
        .decr   (1'b1),
        .S      (exp_minus_1),
        .C_out  () // Không cần dùng
    );

    // --- Chọn số mũ cuối cùng ---
    always_comb begin
        if (exp_adj_incr)
            exp_final_large = exp_plus_1;
        else if (exp_adj_decr)
            exp_final_large = exp_minus_1;
        else
            exp_final_large = exp_C;
    end

    // --- Cờ tràn số mũ ---
    assign C_large_flag = (exp_final_large >= 9'd255);

endmodule
*/

/**
 * Module: Result_Large (Exponent Adjustment Logic)
 * SỬA LỖI: Logic điều chỉnh Exponent (exp_adj_incr/decr) 
 * để xử lý đúng phép trừ (Effective Subtraction).
 */

module Result_Large(                                             
    input  logic [24:0] Sum,                // Mantissa sau cộng/trừ
    input  logic [8:0]  exp_C,              // Exponent đã căn chỉnh
    input  logic        effective_op_sub,   
    output logic [8:0]  exp_final_large,    // Exponent sau điều chỉnh
    output logic        C_large_flag        // Cờ báo tràn số mũ
);

    // --- Tín hiệu điều chỉnh ---
    logic exp_adj_incr; // Yêu cầu +1 
    logic exp_adj_decr; // Yêu cầu -1



    // 1. TĂNG (Incr): Chỉ khi là Phép cộng (ADD) VÀ Sum[24] = 1 (Overflow).
    assign exp_adj_incr = Sum[24] & !effective_op_sub;

    // 2. GIẢM (Decr): Khi Mantissa bị "thiếu" (Sum[23] = 0),
    //    cho cả hai trường hợp:
    //    a) (Sub) Sum[24]=1, Sum[23]=0 
    //    b) (Add) Sum[24]=0, Sum[23]=0 (Underflow chuẩn)
    assign exp_adj_decr = ~Sum[23] & ( (effective_op_sub & Sum[24]) | (~Sum[24]) );
    // (Logic đơn giản hơn: assign exp_adj_decr = ~Sum[23];)
    
    // --- Tính toán song song Exp+1 và Exp−1 ---
    logic [8:0] exp_plus_1, exp_minus_1;
    logic       C_out_plus_1;

    // Tăng số mũ
    Incre_decr #(.N(9)) u_incr (
        .A      (exp_C),
        .decr   (1'b0),
        .S      (exp_plus_1),
        .C_out  (C_out_plus_1)
    );

    // Giảm số mũ
    Incre_decr #(.N(9)) u_decr (
        .A      (exp_C),
        .decr   (1'b1),
        .S      (exp_minus_1),
        .C_out  () // Không cần dùng
    );

    // --- Chọn số mũ cuối cùng ---
    always_comb begin
        if (exp_adj_incr)
            exp_final_large = exp_plus_1; // Logic Tăng (cho Add)
        else if (exp_adj_decr)
            exp_final_large = exp_minus_1; // Logic Giảm (cho Sub)
        else
            exp_final_large = exp_C; // Giữ nguyên
    end

    // --- Cờ tràn số mũ ---
    assign C_large_flag = (exp_final_large >= 9'd255);

endmodule