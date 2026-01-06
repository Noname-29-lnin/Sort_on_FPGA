module Incrementer #(
    parameter N = 8
)
(input logic [N-1:0] A ,
output logic [N-1:0] S ,
output logic C_out
);

logic [N:0] carry ;

assign carry[0] = 1'b1;
genvar i;
generate
    for (i=0;i<N;i=i+1) begin : gen
       assign  S[i] = A[i] ^ carry[i];
       assign  carry[i+1] = A[i] & carry[i];
    end
endgenerate 

assign C_out = carry[N];
endmodule 