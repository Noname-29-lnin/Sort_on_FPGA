/**
 * Module: LZC_16bit
 *
 * Implements a 16-bit LZC based on Dimitrakopoulos et al. (2008),
 * 
 */
module LZC_16bit (

    input  logic [15:0] i_A,
    output logic [3:0]  o_Z, 
    output logic        o_not_all_zero 
);

    // --- 1. Cây OR Nhị phân (Sử dụng Generate) ---
    // Cây OR này có 4 tầng (log2(16) = 4)
    // or_tree_0 = tóm tắt 2-bit (8 logics)
    // or_tree_1 = tóm tắt 4-bit (4 logics)
    // or_tree_2 = tóm tắt 8-bit (2 logics)
    // or_tree_3 = tóm tắt 16-bit (1 logic)
    
    logic [7:0] or_tree_0; 
    logic [3:0] or_tree_1; 
    logic [1:0] or_tree_2; 
    logic       or_tree_3; 

    genvar i;

    // Tầng 0: 16 bits -> 8 Tóm tắt (nhóm 2-bit)
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_or_2bit
            assign or_tree_0[i] = i_A[2*i + 1] | i_A[2*i];
        end
    endgenerate

    // Tầng 1: 8 Tóm tắt -> 4 Tóm tắt (nhóm 4-bit)
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_or_4bit
            assign or_tree_1[i] = or_tree_0[2*i + 1] | or_tree_0[2*i];
        end
    endgenerate

    // Tầng 2: 4 Tóm tắt -> 2 Tóm tắt (nhóm 8-bit)
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_or_8bit
            assign or_tree_2[i] = or_tree_1[2*i + 1] | or_tree_1[2*i];
        end
    endgenerate

    // Tầng 3: 2 Tóm tắt -> 1 Kết quả (cờ o_not_all_zero)
    assign or_tree_3 = or_tree_2[1] | or_tree_2[0];
    assign o_not_all_zero = or_tree_3; // [cite: 202]


    // --- 2. Bốn (4) Cây Logic F() sử dụng CLA
    
    logic [3:0] z_n; 

    // Cây ~Z3 (MSB): F() áp dụng cho 2 bit tóm tắt (or_tree_2)
    assign z_n[3] = or_tree_2[1]; // F(X1, X0) = X1

    // Cây ~Z2: F() áp dụng cho 4 bit tóm tắt (or_tree_1)
    assign z_n[2] = or_tree_1[3] | (~or_tree_1[2] & or_tree_1[1]); // F(X3,X2,X1,X0)

    // Cây ~Z1: F() áp dụng cho 8 bit tóm tắt (or_tree_0)
    assign z_n[1] = or_tree_0[7] |
                    (~or_tree_0[6] & or_tree_0[5]) |
                    (~or_tree_0[6] & ~or_tree_0[4] & or_tree_0[3]) |
                    (~or_tree_0[6] & ~or_tree_0[4] & ~or_tree_0[2] & or_tree_0[1]);

    // Cây ~Z0 (LSB): F() áp dụng cho 16 bit gốc 
    assign z_n[0] = i_A[15] |
                    (~i_A[14] & i_A[13]) |
                    (~i_A[14] & ~i_A[12] & i_A[11]) |
                    (~i_A[14] & ~i_A[12] & ~i_A[10] & i_A[9]) |
                    (~i_A[14] & ~i_A[12] & ~i_A[10] & ~i_A[8] & i_A[7]) |
                    (~i_A[14] & ~i_A[12] & ~i_A[10] & ~i_A[8] & ~i_A[6] & i_A[5]) |
                    (~i_A[14] & ~i_A[12] & ~i_A[10] & ~i_A[8] & ~i_A[6] & ~i_A[4] & i_A[3]) |
                    (~i_A[14] & ~i_A[12] & ~i_A[10] & ~i_A[8] & ~i_A[6] & ~i_A[4] & ~i_A[2] & i_A[1]);

    assign o_Z = ~z_n;

endmodule
