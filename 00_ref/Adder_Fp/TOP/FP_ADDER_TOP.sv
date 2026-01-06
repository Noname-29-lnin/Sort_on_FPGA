module FP_ADDER_TOP (
    // Inputs theo bảng mô tả
    input  logic [31:0] i_32_a,      // 32-bit floating-point number A
    input  logic [31:0] i_32_b,      // 32-bit floating-point number B
    input  logic        i_add_sub,   // Operation: 0 = add, 1 = sub

    // Outputs theo bảng mô tả
    output logic [31:0] o_32_s,      // 32-bit floating-point output
    output logic        o_ov_flag,   // Overflow Flag
    output logic        o_un_flag,   // Underflow Flag

    // Tín hiệu thêm theo yêu cầu
    output logic        o_invalid    // Invalid Operation Flag
);

    // Gọi module xử lý chính (PTPFADD_top)
    // Ánh xạ (Mapping): .tên_port_con(tên_dây_nối_ngoài)
    PTPFADD_top u_core_adder (
        .sub                  (i_add_sub), // Nối input i_add_sub vào port sub
        .A                    (i_32_a),    // Nối input i_32_a vào port A
        .B                    (i_32_b),    // Nối input i_32_b vào port B
        .C                    (o_32_s),    // Nối port C ra output o_32_s
        
        .final_underflow_flag (o_un_flag), // Nối flag underflow ra ngoài
        .final_overflow_flag  (o_ov_flag), // Nối flag overflow ra ngoài
        .final_invalid_flag   (o_invalid)  // Nối flag invalid ra ngoài
    );

endmodule