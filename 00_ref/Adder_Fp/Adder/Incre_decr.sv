module Incre_decr #(
    parameter N = 8
)(
    input  logic [N-1:0] A,
    input  logic         decr,    // 0 = +1, 1 = -1
    output logic [N-1:0] S,
    output logic         C_out
);

    logic [N:0] carry;
    assign carry[0] = 1'b1;  // bắt đầu cộng/trừ 1

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen
            assign S[i] = A[i] ^ carry[i];
            assign carry[i+1] = decr ? (~A[i] & carry[i]) : (A[i] & carry[i]);
        end
    endgenerate

    assign C_out = carry[N];
endmodule
