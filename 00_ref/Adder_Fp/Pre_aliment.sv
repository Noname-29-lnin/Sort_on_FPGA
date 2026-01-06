/**
 * Module: Pre_aliment (Right_shifter)
 * ĐÃ SỬA LỖI: Đảm bảo CẢ HAI luồng (Main và GRS) 
 * đều thực hiện DỊCH PHẢI (Right Shift) chính xác.
 */
module Pre_aliment  // Right_shifter
(
  input  logic [23:0] x,             // mantissa_to_shift_s2 (Dữ liệu GỐC)
  input  logic [8:0]  s,             // shift_right_amount_comb
  input  logic        ARITH,
  input  logic        complementer, 
  output logic        G,
  output logic        R,
  output logic        S,
  output logic        C_out_GRS,
  output logic [23:0] y
);

  localparam int L = $clog2(24);

  // --- 1. Luồng Shifter chính (DỊCH DỮ LIỆU GỐC) ---
  logic [23:0] st       [0:L];
  assign st[0] = x;

  // --- 2. Luồng GRS ---
  logic [23:0] grs_st   [0:L];
  logic [23:0] st_align [0:L];
  assign grs_st[0]  = x;
  assign st_align[0] = '0;

  // --- 3. BÙ 2 (Twos Complement) logic ---
  logic [23:0] y_shifted;
  logic [23:0] y_complement_one;
  logic [23:0] y_twos_complement;
  logic C_out_incr;

  genvar k, i;
  generate
    for (k = 0; k < L; k++) begin : LEVEL
      localparam int shamt = (1 << k);

      // --- Shifter chính (Right Shift Logic) ---
      for (i = 0; i < 24; i++) begin : MAIN_SHIFT
        logic keep, fill, shift;
        assign keep  = st[k][i];
        assign fill  = 1'b0;
  //      assign shift = (i >= shamt) ? st[k][i - shamt] : fill;
	assign shift = ((i + (1<<k) < 24)  ? st[k][i + (1<<k)] : fill);
        assign st[k+1][i] = s[k] ? shift : keep;
      end

      // --- Shifter GRS (Right Shift Logic) ---
      for (i = 0; i < 24; i++) begin : GRS_SHIFT
        logic keep, shift;
        assign keep  = grs_st[k][i];
	      assign shift = ((i + shamt < 24)  ? st[k][i + shamt] : 1'b0);
        
        // assign shift = (i >= shamt) ? grs_st[k][i - shamt] : 1'b0;
        assign grs_st[k+1][i] = s[k] ? shift : keep;
      end

      // --- Collect dropped bits cho GRS ---
      if (shamt > 0) begin
        logic [shamt-1:0] dropped_bits;
        assign dropped_bits = s[k] ? grs_st[k][shamt-1:0] : '0;
        assign st_align[k+1] = s[k] ? { dropped_bits, st_align[k][23:shamt] } : st_align[k];
      end
      else begin
        assign st_align[k+1] = st_align[k];
      end
    end
endgenerate 

  logic over;
  logic [23:0] result_y_shifted;

  assign over = !(s[8] | s[7] | s[6] |s[5] | (s[4] & s[3] & (s[2] | s[1] | s[0])));
  assign result_y_shifted = st[L] & {24{over}};
  // --- 4. BÙ 2 sau khi dịch ---
  assign y_shifted        = result_y_shifted;

  assign y_complement_one = ~y_shifted;

 //  Incrementer #(.N(24)) u_incrementer_for_complement (
 //    .A    (y_complement_one),
 //    .S    (y_twos_complement),
 //    .C_out(C_out_incr)
 //  );

  // --- 5. CHỌN KẾT QUẢ ĐẦU RA ---
  assign y =  complementer ? y_complement_one : y_shifted;// y_twos_complement : y_shifted;

  // --- 6. OUTPUT GRS ---
  logic [23:0] st_align_final;
  logic [2:0] GRS_complement_one, GRS ,GRS_neg ;
  logic G_ref, R_ref ,S_ref;
  assign st_align_final = st_align[L] & {24{over}};

  
  assign G_ref = y_shifted[0];
  assign R_ref = st_align_final[23];
  assign S_ref = |st_align_final[22:0];

  assign GRS = {G_ref,R_ref,S_ref};
  assign GRS_complement_one = ~GRS & over ;

  //  Incrementer #(.N(3)) GRS_complement (
  //   .A    (GRS_complement_one),
  //   .S    (GRS_neg),
  //   .C_out(C_out_GRS)
  // );

    assign G = complementer ? (GRS_complement_one[2]) : G_ref;
    assign R = complementer ? (GRS_complement_one[1]) : R_ref;
    assign S = complementer ? (GRS_complement_one[0]) : S_ref;


endmodule
