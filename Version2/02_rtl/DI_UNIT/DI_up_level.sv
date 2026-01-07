module DI_up_level #(
    parameter SIZE_DATA = 8
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic                     i_update    ,
    input logic [SIZE_DATA-1:0]     i_data      ,
    output logic [SIZE_DATA-1:0]    o_data       
);

logic [SIZE_DATA-1:0] w_n_data;
logic [SIZE_DATA-1:0] w_o_data;
assign w_n_data = i_data + 1'b1;
assign w_o_data = i_start ? '0 : w_n_data;
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_data      <= '0;
    end else if(i_start | i_update) begin
        o_data      <= w_o_data;
    end
end

endmodule
