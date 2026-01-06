/**
 * Module: lzc32_hier
 *
 * Implements a 32-bit LZC by hierarchically instantiating two 16-bit
 * LZC modules (lzc16_gen).
 */
module LZC_32bit (
    input  logic [31:0] i_A,
    output logic [4:0]  o_Z,
    output logic        o_not_all_zero
);
    logic [3:0]  z_hi; 
    logic        v_hi; 
    logic [3:0]  z_lo; 
    logic        v_lo; 

// hign
    LZC_16bit lzc_hi (
        .i_A            (i_A[31:16]),
        .o_Z            (z_hi),
        .o_not_all_zero (v_hi)
    );

//low
    LZC_16bit lzc_lo (
        .i_A            (i_A[15:0]),
        .o_Z            (z_lo),
        .o_not_all_zero (v_lo)
    );

    assign o_not_all_zero = v_hi | v_lo;
    assign o_Z[4] = ~v_hi;               // Z[4] (bit "16"): Chỉ bật '1' NẾU khối cao (v_hi) toàn 0.

    // Z[3:0] (4 bit thấp):
    // NẾU v_hi là '1' (khối cao có '1'), CHỌN z_hi.
    // NGƯỢC LẠI (khối cao toàn 0), CHỌN z_lo.
    assign o_Z[3:0] = v_hi ? z_hi : z_lo;
endmodule