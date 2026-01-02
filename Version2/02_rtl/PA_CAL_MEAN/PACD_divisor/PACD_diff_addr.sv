module PACD_diff_addr #(
    parameter SIZE_ADDR = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_valid     ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,
    output logic [SIZE_ADDR-1:0]    o_diff_addr ,
    output logic                    o_over_flag ,
    output logic                    o_valid     
);

logic w_start;
logic [SIZE_ADDR-1:0] w_addr_si, w_addr_ei;
logic w_valid, w_valid_1;
logic [SIZE_ADDR-1:0] w_diff_addr;
logic w_over_flag;

SS_detect_edge #(
    .POS_EDGE   (1)   // 1: posedge, 0: negedge
) SS_DETECT_EDGE_START (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_signal   (i_valid),
    .o_signal   (w_start)
);

// Stage 0
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_addr_input
    if(~i_rst_n) begin
        w_addr_si   <= '0;
        w_addr_ei   <= '0;
    end else if(w_start) begin
        w_addr_si   <= i_addr_si;
        w_addr_ei   <= i_addr_ei;
    end
end

// Stage 1
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_valid     <= '0;
    else 
        w_valid     <= i_valid;
end
assign {w_over_flag, w_diff_addr} = {1'b0, w_addr_ei} - {1'b0, w_addr_si} + 1'b1; 

// Stage 2
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        w_valid_1   <= '0;
    else 
        w_valid_1   <= w_valid;
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_diff_addr   <= '0;
        o_over_flag   <= '0;
    end else if(w_valid_1) begin
        o_diff_addr   <= w_diff_addr;
        o_over_flag   <= w_over_flag;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n)
        o_valid   <= '0;
    else 
        o_valid   <= w_valid_1;
end
endmodule
