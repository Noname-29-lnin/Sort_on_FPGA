/*
 * Module: Adder_round_logic
 * SỬA LỖI:
 * 1. Thêm cổng input 'close_path_s1' để biết khi nào cần "Xử lý Âm".
 * 2. Thêm Bước 4: Lấy Bù Hai (Magnitude) của kết quả NẾU
 * (close_path_s1 == 1) VÀ (Kết quả Âm (C_out_raw == 0)).
 * 3. SỬA LỖI 5: Đảm bảo 'C_out' (đầu ra) luôn là 'C_out_raw' (Carry-out gốc).
 */
module Adder_round_logic (
    input  logic   [23:0] Ma,
    input  logic   [23:0] Mb,
    input  logic         close_path_s1, // THÊM CỔNG NÀY (Từ PTPFADD_top)
    input  logic         G,
    input  logic         R,
    input  logic         S,
    input  logic         sub,
    input  logic         C_in_GRS,
    output logic  [24:0] Result, // 25-bit (Đã lấy Bù Hai nếu cần)
    output logic         C_out   // Carry-out GỐC của bộ cộng
);



    logic LSB_unrounded;
    logic carry_bit0_unused;
    
  //  // --- 1. Tính LSB (cho làm tròn Ties-to-Even) ---
  //  FA_1bit fa_lsb (
  //      .A   (Ma[0]),
  //      .B   (Mb[0]),
  //      .C   (1'b0),
  //      .S   (LSB_unrounded),
  //      .C_o (carry_bit0_unused)
  //  );

    // --- 2. Logic làm tròn (Rounding) ---
    logic round_normal;
    logic round_tie_even;
    logic round_up;
    logic not_round;

    assign round_normal    = (R & S);
    assign round_tie_even  = (G & R & ~S);
    assign round_up        = round_normal | round_tie_even; // | C_in_GRS;

    // --- 3. Bộ cộng chính (CLA Adder) ---
    logic [24:0] Result_raw; // Tên mới: Kết quả thô (có thể âm)
    logic        C_out_raw;  // Tên mới: Carry-out thô
    logic [24:0] Result_one;
    logic [24:0] Result_two;
    logic [24:0] Result_neg_one;
    logic [24:0] Result_neg;




    // TODO  thay thế code của  vào đây 
     // CLA_adder_top #(
     //     .WIDTH(24),
     //     .FANIN(4)
     // ) cla_final (
     //     .C_in  (round_up),
     //     .A     (Ma),
     //     .B     (Mb),
     //     .Sum   (Result_raw), // 25-bit (Result_raw[24] là Carry-out)
     //     .C_out (C_out_raw)   // (C_out_raw == Result_raw[24])
     // );
    // TODO .................................................
      FPPA2_adder #(
          .WIDTH(24),
          .FANIN(4)
) adder_and_round (
    .A(Ma),
    .B(Mb),
    .C_in(1'b0),
    .Sum(Result_raw),      // A+B (or A+B+C_in)
    .Sum_p1(Result_one),   // A+B+1
    .Sum_p2(Result_two),   // A+B+2
    .C_out(C_out_raw)
);
 
assign Result_neg = ~Result_raw;

logic C_out_neg;   //not use
Incrementer #(.N(3)) Neg_result_add_one (
      .A    (Result_neg),
      .S    (Result_neg_one),
      .C_out(C_out_neg)
    );
// CLA_24bit adder(
//     .i_carry(round_up),
//     .i_data_a(Ma),
//     .i_data_b(Mb),
//     .o_sum(Result_raw),
//     .o_carry(C_out_raw)
// );
    // TODO ...................................................
    // --- 4. Bước "Xử lý Âm" (và kết quả làm tròn) ---

    always_comb begin 
        if(close_path_s1) begin 
            if(C_out_raw) begin    //trừ gần và là kết quả man_A - man_B dương.
                if(round_up) begin
                    Result = Result_two;
                end else begin 
                   // Result =Result_raw;
                    Result = Result_one;
                end 
            end else begin         //trừ gần và là kết quả man_A - man_B âm.
                if(round_up) begin
                 //   Result = Result_neg_one;
                    Result = Result_neg_one;
                end else begin 
                    Result = Result_neg;
                end
            end
        end else begin //large_path 
            if (sub) begin        // trừ 
                 if(round_up) begin
                    Result = Result_two;
                end else begin 
                    Result =Result_one;
                end 
            end else begin      // cộng 
                if(round_up) begin
                    Result = Result_one;
                end else begin 
                    Result =Result_raw;
                end
            end 
        end 
    end 
assign C_out = C_out_raw;

endmodule