module DI_unit #(
    parameter SIZE_ADDR = 32    ,
    parameter SIZE_DATA = 32    ,
    parameter SIZE_LEVEL = 8     
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
    output logic                    o_valid     ,

    output logic                    o_done       
);

/////////////////////////////////////////////////////////////
// Internal Signals
/////////////////////////////////////////////////////////////

logic w_start;
logic w_start_pos;
logic w_start_1;
logic w_i_done_PAMEM;
logic w_done_PAMEM_1;
logic w_done_PAMEM_2;
logic [SIZE_ADDR-1:0] w_i_addr_si;
logic [SIZE_ADDR-1:0] w_i_addr_ei;
always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    w_i_addr_si   <= '0;
    w_i_addr_ei   <= '1;
  end else if(i_start) begin
    w_i_addr_si   <= i_addr_si;
    w_i_addr_ei   <= i_addr_ei;
  end
end

logic [SIZE_LEVEL-1:0]  w_i_level;
logic [SIZE_ADDR-1:0]   w_DIFIFO_i_addr_si;
logic [SIZE_ADDR-1:0]   w_DIFIFO_i_addr_ei;

logic [SIZE_LEVEL-1:0]  w_DIFIFO_level;
logic [SIZE_LEVEL-1:0]  w_LEVEL_out;
logic [SIZE_ADDR-1:0]   w_DIFIFO_addr_si;
logic [SIZE_ADDR-1:0]   w_DIFIFO_addr_ei;
logic                   w_DIFIFO_done;

logic w_done;

/////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////

SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_START_UNIT_POS (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start_pos)
);
SS_detect_edge #(
    .POS_EDGE       (0)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);
SS_detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) SSDE_DONE_PAMEM_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_done_PAMEM),
    .o_signal       (w_i_done_PAMEM)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    w_start_1         <= '0;
    w_done_PAMEM_1    <= '0;
    w_done_PAMEM_2    <= '0;
  end else begin
    w_start_1         <= w_start;
    w_done_PAMEM_1    <= w_i_done_PAMEM;
    w_done_PAMEM_2    <= w_done_PAMEM_1;
  end
end

DI_up_level #(
  .SIZE_DATA    (SIZE_LEVEL)
) DI_UPDATA_LEVEL (
    .i_clk      (i_clk),
    .i_rst_n    (i_rst_n),
    .i_start    (w_start),
    .i_update   (w_i_done_PAMEM),
    .i_data     (w_DIFIFO_level),
    .o_data     (w_i_level) 
);

// always_ff @( posedge i_clk or negedge i_rst_n ) begin
//   if(~i_rst_n) begin
//     w_DIFIFO_i_addr_si    <= '0;
//     w_DIFIFO_i_addr_ei    <= '0;
//   end else begin
//     w_DIFIFO_i_addr_si    <= w_i_done_PAMEM ? (w_DIFIFO_addr_si ) : (w_done_PAMEM_1 ? i_addr_pi         : o_addr_si);
//     w_DIFIFO_i_addr_ei    <= w_i_done_PAMEM ? (i_addr_pi        ) : (w_done_PAMEM_1 ? w_DIFIFO_addr_ei  : o_addr_ei);
//   end
// end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    w_DIFIFO_i_addr_si    <= '0;
    w_DIFIFO_i_addr_ei    <= '0;
  end else begin
    w_DIFIFO_i_addr_si    <= w_start_pos ? (w_i_addr_si) : (w_i_done_PAMEM ? (w_DIFIFO_addr_si ) : (w_done_PAMEM_1 ? i_addr_pi         : o_addr_si));
    w_DIFIFO_i_addr_ei    <= w_start_pos ? (w_i_addr_ei) : (w_i_done_PAMEM ? (i_addr_pi        ) : (w_done_PAMEM_1 ? w_DIFIFO_addr_ei  : o_addr_ei));
  end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  w_LEVEL_out <= 3;
end

DI_fifo #(
  .SIZE_ADDR        (SIZE_ADDR),
  .SIZE_DATA        (SIZE_DATA),
  .SIZE_LEVEL       (SIZE_LEVEL)
) DIFIFO_UNIT (
  .i_clk            (i_clk),
  .i_rst_n          (i_rst_n),
  .i_wr_en          (w_start | w_done_PAMEM_1 | w_done_PAMEM_2),
  .i_rd_en          (w_start_1 | w_done_PAMEM_2 | o_done),
  .i_level          (w_i_level),
  .i_addr_si        (w_DIFIFO_i_addr_si),
  .i_addr_ei        (w_DIFIFO_i_addr_ei),

  .o_level          (w_DIFIFO_level),
  .o_addr_si        (w_DIFIFO_addr_si),
  .o_addr_ei        (w_DIFIFO_addr_ei),  
  .o_done           (w_DIFIFO_done) 
);

DI_compare_equal #(
    .SIZE_DATA      (SIZE_LEVEL)
) DI_COMP_EQUAL_LEVEL (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_data_a       (w_DIFIFO_level),
    .i_data_b       (w_LEVEL_out),
    .o_equal        (w_done)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    o_done        <= '0;
    o_valid       <= '0;
  end else begin 
    o_done        <= w_done & w_DIFIFO_done;
    o_valid       <= w_DIFIFO_done & (~w_done);
  end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    o_addr_si     <= '0;
    o_addr_ei     <= '0;
  end else if(w_DIFIFO_done) begin 
    // o_addr_si     <= (w_start) ? w_i_addr_si : w_DIFIFO_addr_si;
    o_addr_si     <= w_DIFIFO_addr_si;
    // o_addr_ei     <= (w_start) ? w_i_addr_ei : w_DIFIFO_addr_ei;
    o_addr_ei     <= w_DIFIFO_addr_ei;
  end
end

endmodule
