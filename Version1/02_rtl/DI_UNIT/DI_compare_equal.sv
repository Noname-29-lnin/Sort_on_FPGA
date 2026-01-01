module DI_compare_equal #(
    parameter SIZE_DATA = 8
)(
    input logic                     i_clk   ,
    input logic                     i_rst_n ,
    input logic [SIZE_DATA-1:0]     i_data_a,
    input logic [SIZE_DATA-1:0]     i_data_b,
    output logic                    o_equal
);

logic w_equal;
assign w_equal = i_data_a == i_data_b;
logic w_o_equal;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_o_equal     <= '0;
    else 
        w_o_equal     <= w_equal;
end
assign o_equal = w_o_equal;

endmodule
