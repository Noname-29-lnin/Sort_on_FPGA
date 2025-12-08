module SWAP_unit #(
    parameter SIZE_DATA = 8
)(
    input logic                     i_comp_less , // i_comp_less = i_data_a < i_data_b
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_data_max  ,
    output logic [SIZE_DATA-1:0]    o_data_min   
);

always_comb begin : PROC_MAIN_DATA
    o_data_max = (i_comp_less)  ? i_data_b : i_data_a;
    o_data_min = (i_comp_less)  ? i_data_a : i_data_b;
end

endmodule
