module DI_unit #(
    parameter SIZE_ADDR = 32    ,
    parameter SIZE_DATA = 32     
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,

    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,

    input logic                     i_done_PAMEM,
    input logic [SIZE_ADDR-1:0]     i_addr_pi   ,

    output logic [SIZE_ADDR-1:0]    o_addr_si   ,
    output logic [SIZE_ADDR-1:0]    o_addr_ei   ,
    output logic                    o_done       
);

/////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////

logic w_start;
logic [SIZE_ADDR-1:0] w_i_addr_si;
logic [SIZE_ADDR-1:0] w_i_addr_ei;

/////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_i_addr_si   <= '0;
        w_i_addr_ei   <= '0;
    end else if(w_start) begin
        w_i_addr_si   <= i_addr_si;
        w_i_addr_ei   <= i_addr_ei;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_done      <= '0; 
    end else begin
        o_done      <= '0; 
    end
end

endmodule
