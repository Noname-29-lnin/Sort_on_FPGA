module PACS_detect_intit_data (
    input logic         i_clk   ,
    input logic         i_rst_n ,
    input logic         i_start ,
    input logic         i_valid ,
    output logic        o_init_sum  
);

logic w_valid;
logic w_init_valid;

always_ff @( posedge i_clk or negedge i_rst_n ) begin 
    if(~i_rst_n)
        w_valid     <= '0;
    else 
        w_valid     <= i_valid;
end

assign w_init_valid = (i_start) ? 1'b1 : (w_valid ? 1'b0 : o_init_sum);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) 
        o_init_sum  <= '0;
    else 
        o_init_sum  <= w_init_valid;
end

endmodule
