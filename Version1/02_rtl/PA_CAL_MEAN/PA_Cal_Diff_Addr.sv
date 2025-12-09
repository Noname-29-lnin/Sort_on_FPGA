module PA_Cal_Diff_Addr #(
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

logic [SIZE_ADDR-1:0] w_i_addr_si;
logic [SIZE_ADDR-1:0] w_i_addr_ei;
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_i_addr
    if(~i_rst_n) begin
        w_i_addr_si     <= '0;
        w_i_addr_ei     <= '1;
    end else if(i_start) begin
        w_i_addr_si     <= i_addr_si;
        w_i_addr_ei     <= i_addr_ei;
    end
end



endmodule
