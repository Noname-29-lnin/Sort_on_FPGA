module wallace_tree #(
    parameter SIZE_DATA = 8
)(
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [2*SIZE_DATA-1:0]    o_product       
);

logic [SIZE_DATA-1:0][SIZE_DATA-1:0] w_propagation;

generate
    for(genvar i = 0; i < SIZE_DATA; i++) begin
        for(genvar j = 0; j < SIZE_DATA; j++) begin
            assign w_propagation[i][j] = i_data_a[j] & i_data_b[i];
        end
    end
endgenerate



endmodule

module WTM_full_adder(
    input logic         i_carry ,
    input logic         i_data_a,
    input logic         i_data_b,
    output logic        o_sum   ,
    output logic        o_carry  
);

assign o_sum    = i_carry ^ i_data_a ^ i_data_b;
assign o_carry  = ((i_data_a^i_data_b)&i_carry) | (i_data_a&i_data_b);

endmodule

module WTM_half_adder(
    input logic         i_data_a    ,
    input logic         i_data_b    ,
    output logic        o_sum       ,
    output logic        o_carry      
);

assign o_sum    = i_data_a ^ i_data_b;
assign o_carry  = i_data_a & i_data_b;

endmodule
