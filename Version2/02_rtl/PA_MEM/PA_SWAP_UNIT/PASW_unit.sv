module PASW_unit #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_valid     ,
    input logic [SIZE_DATA-1:0]     i_data_mean ,
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_data_a    ,
    output logic [SIZE_DATA-1:0]    o_data_b    ,
    output logic                    o_valid     ,
    output logic                    o_comp_less  
);

logic                   w_comp_less;
logic [SIZE_DATA-1:0]   w_data_a;
logic [SIZE_DATA-1:0]   w_data_b;
logic                   w_i_valid     ;
logic                   w_o_valid     ;
logic [SIZE_DATA-1:0]   w_i_data_mean ;
logic [SIZE_DATA-1:0]   w_i_data_a    ;
logic [SIZE_DATA-1:0]   w_i_data_b    ;

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        w_i_valid       <= '0;
    end else begin
        w_i_valid       <= i_valid;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        w_i_data_mean   <= '0;
        w_i_data_a      <= '0;
        w_i_data_b      <= '0;
    end else if(i_valid) begin
        w_i_data_mean   <= i_data_mean;
        w_i_data_a      <= i_data_a;
        w_i_data_b      <= i_data_b;
    end
end

COMP_FPU COMP_FPU_UNIT (
    .i_fpu_a        (w_i_data_a),
    .i_fpu_b        (w_i_data_mean),
    .o_less         (w_comp_less) // i_fpu_a < i_fpu_b
);
always_comb begin : PROC_MAIN_DATA
    w_data_a = (w_comp_less)  ? w_i_data_b : w_i_data_a;
    w_data_b = (w_comp_less)  ? w_i_data_a : w_i_data_b;
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        w_o_valid         <= '0;
    end else begin
        w_o_valid         <= w_i_valid;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        o_data_a        <= '0;
        o_data_b        <= '0;
    end else if(w_o_valid) begin
        o_data_a        <= w_data_a;
        o_data_b        <= w_data_b;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        o_valid         <= '0;
    end else begin
        o_valid         <= w_o_valid;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n) begin
        o_comp_less         <= '0;
    end else begin
        o_comp_less         <= w_comp_less & w_o_valid;
    end
end
endmodule
