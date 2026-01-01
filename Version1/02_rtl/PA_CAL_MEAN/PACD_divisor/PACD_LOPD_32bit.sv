module PACD_LOPD_32bit #(
    parameter SIZE_DATA     = 32,
    parameter SIZE_LOPD     = 5       
)(
    input logic                     i_clk           ,
    input logic                     i_rst_n         ,
    input logic                     i_valid         ,
    input logic [SIZE_DATA-1:0]     i_data          ,
    output logic [SIZE_LOPD-1:0]    o_one_position  ,
    output logic                    o_zero_flag     , 
    output logic                    o_valid         
);

logic [SIZE_DATA-1:0] w_i_data;
logic [15:0] w_data_msb;
logic [15:0] w_data_lsb;
logic [3:0]  w_pos_one_msb;
logic [3:0]  w_pos_one_lsb;
logic        w_zero_flag_msb;
logic        w_zero_flag_lsb;
logic        w_zero_flag;
logic [SIZE_LOPD-1:0] w_o_one_position;

logic w_valid;
logic w_valid_1;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_i_data    <= '0;
    else if(i_valid)
        w_i_data    <= i_data;
end

assign w_data_msb = w_i_data[31:16];
assign w_data_lsb = w_i_data[15:0];

PACD_LOPD_16bit LOPD_16bit_UNIT_MSB (
    .i_data             (w_data_msb),
    .o_pos_one          (w_pos_one_msb),
    .o_zero_flag        (w_zero_flag_msb)
);
PACD_LOPD_16bit LOPD_16bit_UNIT_LSB(
    .i_data             (w_data_lsb),
    .o_pos_one          (w_pos_one_lsb),
    .o_zero_flag        (w_zero_flag_lsb)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_valid    <= '0;
    else 
        w_valid    <= i_valid;
end

assign w_zero_flag         = w_zero_flag_msb & w_zero_flag_lsb;
assign w_o_one_position[4] = w_zero_flag_msb;
assign w_o_one_position[3] = w_zero_flag_msb ? w_pos_one_lsb[3] : w_pos_one_msb[3];
assign w_o_one_position[2] = w_zero_flag_msb ? w_pos_one_lsb[2] : w_pos_one_msb[2];
assign w_o_one_position[1] = w_zero_flag_msb ? w_pos_one_lsb[1] : w_pos_one_msb[1];
assign w_o_one_position[0] = w_zero_flag_msb ? w_pos_one_lsb[0] : w_pos_one_msb[0];

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_valid_1    <= '0;
    else 
        w_valid_1    <= w_valid;
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        o_valid    <= '0;
    else 
        o_valid    <= w_valid_1;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_one_position  <= '0;
        o_zero_flag     <= '0; 
    end else if(w_valid_1) begin
        o_one_position  <= w_o_one_position;
        o_zero_flag     <= w_zero_flag; 
    end  
end

endmodule
