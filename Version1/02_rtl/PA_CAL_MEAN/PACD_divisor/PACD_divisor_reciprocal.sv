module PACD_divisor_reciprocal #(
    parameter SIZE_DATA = 32
)(
    input  logic                    i_clk   ,
    input  logic                    i_rst_n ,
    input  logic                    i_start ,
    input  logic [SIZE_DATA-1:0]    i_divisor,
    output logic [SIZE_DATA-1:0]    o_divisor_reciprocal,
    output logic                    o_done
);
endmodule