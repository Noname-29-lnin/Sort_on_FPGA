module SS_read_data #(
    parameter SIZE_ADDR = 6 ,
    parameter SIZE_DATA = 8
)(
    input logic                     i_clk               ,
    input logic                     i_rst_n             ,
    
    input logic                     i_start_read_data   ,
    input logic                     i_en_read_data      ,

    input logic [SIZE_ADDR-1:0]     i_si_ram            ,
    input logic [SIZE_ADDR-1:0]     i_ei_ram            ,

    input logic [SIZE_DATA-1:0]     i_data_ram          ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram          ,
    output logic [SIZE_DATA-1:0]    o_data_ram          ,

    output logic                    o_data_valid        ,
    output logic                    o_done_read_data    
);

//=======================
// Declare signal 
//=======================

wire w_SSDT_start;
wire w_SSDE_start;

logic w_pre_update_en;
logic w_update_en;

logic w_pre_done;

logic w_compare_ei;

logic [SIZE_ADDR-1:0] w_save_addr_si, w_save_addr_ei;
logic [SIZE_ADDR-1:0] w_save_addr_si_next , w_save_addr_ei_next;

logic [SIZE_ADDR-1:0] w_plus_addr_ram;
logic [SIZE_ADDR-1:0] w_pre_addr_ram;

//=======================
// Declare module 
//=======================

SS_detect_start SS_detect_start_for_SS_read_data_unit (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_start     (i_start_read_data),
    .i_done      (w_compare_ei),
    .o_w_start   (w_SSDT_start) 
);

SS_detect_edge SS_detect_edge_start (
    .i_clk       (i_clk),
    .i_rst_n     (i_rst_n),
    .i_pos_edge  (1'b1),
    .i_signal    (i_start_read_data),
    .o_signal    (w_SSDE_start) 
);

//=======================
// Processing 
//=======================

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_save_i_addr
    if(~i_rst_n) begin 
        w_save_addr_si_next <= '0;
        w_save_addr_ei_next <= '0;
    end else begin 
        w_save_addr_si_next <= w_save_addr_si;
        w_save_addr_ei_next <= w_save_addr_ei;
    end 
end
assign w_save_addr_si = (w_SSDE_start) ? i_si_ram : w_save_addr_si_next;
assign w_save_addr_ei = (w_SSDE_start) ? i_ei_ram : w_save_addr_ei_next;

assign w_plus_addr_ram = o_addr_ram + 1'b1;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        w_pre_update_en <= 1'b0;
    else
        w_pre_update_en <=i_en_read_data & w_SSDT_start;
end 
assign w_update_en = w_pre_update_en & (~o_done_read_data) & (~w_pre_done);

always_ff @( posedge i_clk or negedge i_rst_n ) begin : prc_w_nexr_addr_ram
    if(~i_rst_n)
        w_pre_addr_ram <= '0;
    else 
        w_pre_addr_ram <= (w_update_en) ? w_plus_addr_ram : o_addr_ram;
end
assign o_addr_ram = (w_SSDE_start) ? w_save_addr_si : w_pre_addr_ram;

assign w_compare_ei = (o_addr_ram == w_save_addr_ei) & (i_en_read_data & w_SSDT_start);
always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_output_done
    if(~i_rst_n) begin 
        w_pre_done          <= 1'b0;
        o_done_read_data    <= 1'b0;
    end else begin 
        w_pre_done          <= w_compare_ei;
        o_done_read_data    <= w_pre_done;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_output_valid
    if(~i_rst_n)
        o_data_valid <= 1'b0;
    else
        o_data_valid <= w_update_en;
end
assign o_data_ram = (o_data_valid) ? i_data_ram : '0;

endmodule

