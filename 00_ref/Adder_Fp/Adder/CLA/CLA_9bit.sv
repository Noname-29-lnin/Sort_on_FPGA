module CLA_9bit(
    input  logic         i_carry,
    input  logic [8:0]   i_data_a, // Mở rộng thành 9 bit
    input  logic [8:0]   i_data_b, // Mở rộng thành 9 bit
    output logic [9:0]   o_sum,    // Chỉ cần 9 bit tổng
    output logic         o_carry   // Carry-out cuối cùng
);logic w_carry_8; // Carry-in cho bit 8

    // 1. Sử dụng CLA_8bit cho 8 bit thấp (0 đến 7)
    CLA_8bit CLA_8BIT_UNIT (
        .i_carry  (i_carry),
        .i_data_a (i_data_a[7:0]), // 8 bit thấp
        .i_data_b (i_data_b[7:0]), // 8 bit thấp
        .o_sum    ({w_carry_8, o_sum[7:0]}), // o_sum[8] (carry-out) của CLA_8bit chính là carry-in cho bit 8
        .o_carry  () // Bỏ qua o_carry vì nó đã được gán cho w_carry_8
    );
    // Lưu ý: Module CLA_8bit của bạn có o_sum[8] = o_carry. Ta dùng nó để lấy w_carry_8

    // 2. Tính toán bit tổng thứ 8 (S8) và Carry-out cuối cùng (C9)

    // Bit Propagate (P8) và Generate (G8) cho bit 8
    logic p8, g8;

    assign g8 = i_data_a[8] & i_data_b[8];
    assign p8 = i_data_a[8] ^ i_data_b[8];

    // Tổng bit 8 (S8)
    assign o_sum[8] = p8 ^ w_carry_8;

    // Carry-out cuối cùng (C9)
    assign o_carry = g8 | (p8 & w_carry_8);
    assign o_sum[9] = o_carry;

endmodule