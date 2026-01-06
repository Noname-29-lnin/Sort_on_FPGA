/**
 * Module: Normalization_Large
 * ĐÃ SỬA LỖI: Sửa cổng output 'Mantissa_norm_Large' 
 * từ 23 bit ([22:0]) thành 24 bit ([23:0]).
 */
 /*
 module Normalization_Large (
    input  logic [24:0] Sum,                  // Mantissa sau cộng/trừ
    input  logic        effective_op_sub,
// TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp
    input  logic both_denormal, 
// TODO: Xóa xử lý số dưới chuẩn hoặc thêm vào nếu muốn xử lý số dưới chuẩn vì chưa đầy đủ trường hợp               
    output logic [23:0] Mantissa_norm_Large   // <<< SỬA LỖI Ở ĐÂY
);

    logic        shift_left;
    logic        shift_right;

    // --- Xác định hướng dịch ---
    assign shift_right = Sum[24] & !effective_op_sub & !both_denormal;               
    assign shift_left  = (~Sum[24]) & (~Sum[23]) & !both_denormal; 
    logic [1:0] sel;
    assign sel = {shift_right, shift_left};

    // --- Tạo các khả năng (24-bit) ---
    wire [23:0] mant_right = Sum[24:1];           
    wire [23:0] mant_left  = {Sum[22:0], 1'b0};   
    wire [23:0] mant_norm  = Sum[23:0];           

    // --- Mux chọn kết quả cuối ---
    always_comb begin
        case (sel)
            2'b00:   Mantissa_norm_Large = mant_norm;
            2'b01:   Mantissa_norm_Large = mant_left;
            2'b10:   Mantissa_norm_Large = mant_right;
            default: Mantissa_norm_Large = 24'bx;
        endcase
    end 

endmodule
 


 */
module Normalization_Large (
    input  logic [24:0] Sum,                  // Mantissa sau cộng/trừ
    input  logic        effective_op_sub,
    input  logic        both_denormal,
    output logic [23:0] Mantissa_norm_Large
);

    logic        shift_left;
    logic        shift_right;

    // --- Xác định hướng dịch ---
    // shift_right: chỉ khi ADD có carry (Sum[24]==1)
    assign shift_right = Sum[24] & !effective_op_sub & !both_denormal;

    // shift_left: khi MSB thực của trường 24-bit = 0
    // (với SUB, MSB thực là Sum[23]; với ADD, nếu Sum[24]==1 thì shift_right sẽ thắng)
    assign shift_left  = (~Sum[23]) & effective_op_sub & !both_denormal ;

    logic [1:0] sel;
    assign sel = {shift_right, shift_left};

    // --- Tạo các khả năng (24-bit) ---
    wire [23:0] mant_right = Sum[24:1];           // shift right 1
    wire [23:0] mant_left  = {Sum[22:0], 1'b0};   // shift left 1
    wire [23:0] mant_norm  = Sum[23:0];           // no shift

    // --- Mux chọn kết quả cuối ---
    always_comb begin
        case (sel)
            2'b00:   Mantissa_norm_Large = mant_norm;
            2'b01:   Mantissa_norm_Large = mant_left;
            2'b10:   Mantissa_norm_Large = mant_right; // priority khi both = 1
            default: Mantissa_norm_Large = 25'bx;
        endcase
    end 

endmodule


