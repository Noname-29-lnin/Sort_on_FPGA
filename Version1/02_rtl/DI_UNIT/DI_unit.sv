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
logic [SIZE_ADDR-1:0] w_i_addr_si;
logic [SIZE_ADDR-1:0] w_i_addr_ei;
logic [SIZE_ADDR-1:0] w_i_addr_pi;
logic [SIZE_LEVEL-1:0] w_i_level;
logic [SIZE_LEVEL-1:0] w_n_level;

logic [SIZE_LEVEL-1:0]  w_DIFIFO_level;
logic [SIZE_ADDR-1:0]   w_DIFIFO_addr_si;
logic [SIZE_ADDR-1:0]   w_DIFIFO_addr_ei;
logic                   w_DIFIFO_done;

logic w_done;

/////////////////////////////////////////////////////////////
// Submodules
/////////////////////////////////////////////////////////////

SS_detect_edge #(
    .POS_EDGE       (0)   // 1: posedge, 0: negedge
) SSDE_START_UNIT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);


DI_fifo #(
  .SIZE_ADDR        (SIZE_ADDR),
  .SIZE_DATA        (SIZE_DATA),
  .SIZE_LEVEL       (SIZE_LEVEL)
) DIFIFO_UNIT (
  .i_clk            (i_clk),
  .i_rst_n          (i_rst_n),
  .i_wr_en          (),
  .i_rd_en          (),
  .i_level          (w_i_level),
  .i_addr_si        (w_i_addr_si),
  .i_addr_ei        (w_i_addr_ei),

  .o_level          (w_DIFIFO_level),
  .o_addr_si        (w_DIFIFO_addr_si),
  .o_addr_ei        (w_DIFIFO_addr_ei),  
  .o_done           (w_DIFIFO_done) 
);

endmodule
