/**
 * Module: Right_shifter_1bit
 */
module Right_shifter_1bit #(
    parameter int N = 24 // (Nên set N=24 cho TPFADD_top)
)(
    input  logic [N-1:0]       x,              // Dữ liệu GỐC (chưa bù)
    input  logic               shift,          // Tín hiệu (s[0])
    input  logic               complementer,   // Từ effective_op_sub
    input  logic               ARITH,          // (Không dùng trong logic này)
    output logic               G, 
    output logic               R, 
    output logic               S,
    output logic               C_out_GRS,
    output logic [N-1:0]       y               // Dữ liệu đã dịch VÀ bù (nếu cần)
);

    // --- Tín hiệu trung gian ---
    logic [N-1:0] y_shifted;
    logic [N-1:0] y_complement_one;
 //   logic [N-1:0] y_twos_complement;
    logic         C_out_incr;
    
    // --- 1. Logic Dịch Phải 1 bit (Right Shift Logic) ---
    // Dịch logic (không dùng ARITH), vì ta bù 2 ở cuối
    assign y_shifted = shift ? {1'b0, x[N-1:1]} : x;

    // --- 2. Tính G, R, S ---
    // Khi dịch 1 bit: G = bit rơi ra (x[0]), R và S = 0
    logic [2:0] GRS_complement_one, GRS ,GRS_neg ;
    logic G_ref, R_ref ,S_ref;
    assign G_ref = y_shifted[0];
    assign R_ref = shift ? x[0] : 1'b0;
    assign S_ref = 1'b0;



    assign GRS = {G_ref,R_ref,S_ref};
    assign GRS_complement_one = ~GRS & !shift;


    assign G = complementer ? GRS_complement_one[2] : G_ref;
    assign R = complementer ? GRS_complement_one[1] : R_ref;
    assign S = complementer ? GRS_complement_one[0] : S_ref;


    // --- 3. BÙ 2 (Twos Complement) sau khi dịch ---
    assign y_complement_one = ~y_shifted;

    // Module cộng thêm 1 (giả sử Incre_decr đã có trong flist)
    // Incre_decr #(.N(N)) u_incrementer_for_complement (
    //     .A     (y_complement_one),
    //     .decr  (1'b0), // Hoạt động như FA_Incrementer (+1)
    //     .S     (y_twos_complement),
    //     .C_out (C_out_incr)
    // );

    // Nếu complementer=1 (trừ), chọn bù 2. Nếu 0 (cộng), chọn dịch gốc.
    assign y = complementer ? y_complement_one : y_shifted;

endmodule
