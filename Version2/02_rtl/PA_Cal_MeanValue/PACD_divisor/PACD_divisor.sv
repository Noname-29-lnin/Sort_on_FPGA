module PACD_divisor #(
    parameter SIZE_ADDR = 32,
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,
    output logic [SIZE_DATA-1:0]    o_diff_addr ,
    output logic                    o_done       
);

localparam SIZE_LOPD = $clog2(SIZE_DATA);

logic [SIZE_ADDR-1:0] w_diff_addr;
logic w_over_flag;
logic w_valid;

logic [SIZE_DATA-1:0] w_lopd_data;
logic [SIZE_LOPD-1:0] w_lopd_one_pos;
logic                 w_lopd_zero_flag;
logic                 w_lopd_valid;

logic w_valid_1;
logic [SIZE_DATA-1:0] w_shf_data;
logic [SIZE_DATA-1:0] w_shf_left;

logic w_valid_2;
logic w_sign_fpu;
logic [7:0] w_exp_fpu;
logic [23:0] w_man_fpu;
logic w_valid_3;

// Stage 0
PACD_diff_addr #(
    .SIZE_ADDR      (SIZE_ADDR)
) PACD_DIFF_ADDR_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_valid        (i_start),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .o_diff_addr    (w_diff_addr),
    .o_over_flag    (w_over_flag),
    .o_valid        (w_valid) 
);

// Stage 1
assign w_lopd_data = w_over_flag ? {w_over_flag, w_diff_addr[SIZE_ADDR-1:1]} : w_diff_addr[SIZE_ADDR-1:0];
// assign w_lopd_data = w_over_flag ? 32'hffffffff : w_diff_addr[SIZE_ADDR-1:0];
PACD_LOPD_32bit #(
    .SIZE_DATA     (SIZE_DATA),
    .SIZE_LOPD     (SIZE_LOPD)       
) PACD_LOPD_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_valid        (w_valid),
    .i_data         (w_lopd_data),
    .o_one_position (w_lopd_one_pos),
    .o_zero_flag    (w_lopd_zero_flag), 
    .o_valid        (w_lopd_valid)
);

// Stage 2
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_valid_1    <= '0; 
    else 
        w_valid_1    <= w_valid;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_shf_data    <= '0;
    else if(w_valid)
        w_shf_data    <= w_lopd_data;
end
SHF_left #(
    .SIZE_DATA      (SIZE_DATA),
    .SIZE_SHIFT     (SIZE_LOPD) 
) SHF_LEFT_UNIT (
    .i_shift_number (w_lopd_one_pos),
    .i_data         (w_shf_data), 
    .o_data         (w_shf_left)
);

// Stage 3
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_valid_2    <= '0;
    else 
        w_valid_2    <= w_valid_1;
end
assign w_sign_fpu = 1'b0;
assign w_exp_fpu = 8'd158 - {3'b0, w_lopd_one_pos} + {7'b0, w_over_flag};
assign w_man_fpu = w_shf_left[SIZE_DATA-1:8];

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        w_valid_3    <= '0;
    else 
        w_valid_3    <= w_lopd_valid;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_diff_addr     <= '0;
    end else if(w_valid_3) begin
        o_diff_addr     <= {w_sign_fpu, w_exp_fpu, w_man_fpu[22:0]};
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        o_done    <= '0;
    else 
        o_done    <= w_valid_3;
end

endmodule
