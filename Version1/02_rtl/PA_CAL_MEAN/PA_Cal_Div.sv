module PA_Cal_Div #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_DATA-1:0]     i_dividend  ,
    input logic [SIZE_DATA-1:0]     i_divisor   ,

    output logic [SIZE_DATA-1:0]    o_quotient  ,
    output logic [SIZE_DATA-1:0]    o_remainder ,
    output logic                    o_done       
);

logic [SIZE_DATA-1:0] w_dividend;
logic [SIZE_DATA-1:0] w_divisor;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_data
    if(~i_rst_n) begin
        w_dividend  <= '0;
        w_divisor   <= '1;
    end else if(i_start) begin
        w_dividend  <= i_dividend;
        w_divisor   <= i_divisor;
    end
end

endmodule
