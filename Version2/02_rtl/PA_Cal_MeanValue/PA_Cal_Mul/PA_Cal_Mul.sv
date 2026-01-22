module PA_Cal_Mul #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_valid     ,
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,

    output logic [SIZE_DATA-1:0]    o_data_mul  ,
    output logic                    o_valid      
);

////////////////////////////////////////////////////////////////
// Expact
////////////////////////////////////////////////////////////////

localparam EXP_ZERO = 8'h00;
localparam EXP_INF  = 8'hFF;
localparam MAN_ZERO = 23'h000000;
localparam MAN_NAN  = 23'h400000;

logic [SIZE_DATA-1:0] w_i_data_a, w_i_data_b;

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_data_in
    if(~i_rst_n) begin
        w_i_data_a    <= '0;
        w_i_data_b    <= '0;
    end else if(i_valid) begin
        w_i_data_a    <= i_data_a;
        w_i_data_b    <= i_data_b;
    end
end

logic w_sign_a, w_sign_b;
logic [7:0] w_exponent_a, w_exponent_b;
logic [23:0] w_mantissa_a, w_mantissa_b;
logic w_o_valid;
logic w_o_sign_result;
logic [7:0] w_o_exp_result;
logic [23:0] w_o_man_result;

assign w_sign_a         = w_i_data_a[31];
assign w_exponent_a     = w_i_data_a[30:23];
assign w_mantissa_a     = {1'b1, w_i_data_a[22:0]}; 
assign w_sign_b         = w_i_data_b[31];
assign w_exponent_b     = w_i_data_b[30:23];
assign w_mantissa_b     = {1'b1, w_i_data_b[22:0]};

////////////////////////////////////////////////////////////////
// Begin
// Input: w_sign_a, w_exponent_a, w_mantissa_a;
// Input: w_sign_b, w_exponent_b, w_mantissa_b;
////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////
// End
// Output: w_o_sign_result, w_o_exp_result, w_o_man_result
////////////////////////////////////////////////////////////////

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_valid     <= '0;
    else 
        o_valid     <= w_o_valid;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_output_data
    if(~i_rst_n) begin
        o_data_mul  <= '0;
    end else if(w_o_valid) begin
        o_data_mul  <= {w_o_sign_result, w_o_exp_result, w_o_man_result[22:0]};
    end
end

endmodule
