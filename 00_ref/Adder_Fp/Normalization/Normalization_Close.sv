module Normalization_Close #(
  parameter int N = 32
)(
  input  logic [N-1:0]         Sum,  
  input  logic [4:0]           s,      // shift count từ LZC
  output logic [N-1:0]         Mantissa_norm_Close,
  output logic                 shift_overflow_flag 
);

  // Phát hiện s > 25
  assign shift_overflow_flag  = s[4] & s[3] & (s[1] | s[2]);

  // Clamp logic
  logic [4:0] s_clamped;
 assign s_clamped  = shift_overflow_flag  ? 5'd25 : s;

  // =============================
  // Barrel left shifter tổ hợp
  // =============================
  localparam int L = $clog2(N);
  wire [N-1:0] st [0:L];
  assign st[0] = Sum;

  genvar k, i;
  generate
    for (k = 0; k < L; k++) begin : LEVEL
      for (i = 0; i < N; i++) begin : BIT
        wire keep  = st[k][i];
        wire shift = ((i >= (1<<k)) ? st[k][i - (1<<k)] : 1'b0);
        assign st[k+1][i] = s_clamped[k] ? shift : keep;
      end
    end
  endgenerate

  assign Mantissa_norm_Close = st[L];

endmodule
