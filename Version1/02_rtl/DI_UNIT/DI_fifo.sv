module DI_fifo #(
  parameter SIZE_ADDR = 32,
  parameter SIZE_DATA = 32,
  parameter SIZE_LEVEL= 8
)(
  input logic                         i_clk       ,
  input logic                         i_rst_n     ,
  input logic                         i_wr_en     ,
  input logic                         i_rd_en     ,

  input logic [SIZE_LEVEL-1:0]        i_level     ,
  input logic [SIZE_ADDR-1:0]         i_addr_si   ,
  input logic [SIZE_ADDR-1:0]         i_addr_ei   ,

  output logic [SIZE_ADDR-1:0]        o_level     ,
  output logic [SIZE_ADDR-1:0]        o_addr_si   ,
  output logic [SIZE_ADDR-1:0]        o_addr_ei   ,

  output logic                        o_done       
);

localparam DEPTH_FIFO = 8;
localparam ADDR_FIFO = $clog2(DEPTH_FIFO);
localparam SIZE_FIFO = SIZE_ADDR + SIZE_ADDR + SIZE_LEVEL;

logic [SIZE_FIFO-1:0] temp_i_mem;
always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    temp_i_mem  <= '0;
  end else if(i_wr_en) begin
    temp_i_mem  <= {i_addr_si, i_addr_ei, i_level};
  end
end
logic w_valid;
logic [SIZE_FIFO-1:0] temp_o_mem;

logic [ADDR_FIFO-1:0] p_rd_ptr, n_rd_ptr;
logic [ADDR_FIFO-1:0] p_wr_ptr, n_wr_ptr;
logic update_wr_ptr, update_rd_ptr;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    update_wr_ptr   <= '0;
    update_rd_ptr   <= '0;    
  end else begin
    update_wr_ptr   <= i_wr_en;
    update_rd_ptr   <= i_rd_en;
  end
end

always_ff @(posedge i_clk, negedge i_rst_n) begin
  if(~i_rst_n) begin
    p_rd_ptr <= '0;
  end else if(update_rd_ptr) begin
    p_rd_ptr <= n_rd_ptr;
  end
end
always_ff @(posedge i_clk, negedge i_rst_n) begin
  if(~i_rst_n) begin
    p_wr_ptr <= '0;
  end else if(update_wr_ptr) begin
    p_wr_ptr <= n_wr_ptr;
  end
end
// assign n_rd_ptr = update_rd_ptr ? (p_rd_ptr + 1'b1) : p_rd_ptr;
assign n_rd_ptr = p_rd_ptr + 1'b1;
// assign n_wr_ptr = update_wr_ptr ? (p_wr_ptr + 1'b1) : p_wr_ptr;
assign n_wr_ptr = p_wr_ptr + 1'b1;

DIFIFO_dual_mem #(
  .DATA_WIDTH   (SIZE_FIFO),
  .ADDR_WIDTH   (ADDR_FIFO)
) FIFO_MAM (
  .i_clk        (i_clk),
  .i_wr_en      (update_wr_ptr),
  .i_rd_en      (update_rd_ptr),
  .i_addr_wr    (p_wr_ptr),
  .i_addr_rd    (p_rd_ptr),
  .i_data_wr    (temp_i_mem),
  .o_data_rd    (temp_o_mem),
  .o_valid_rd   (w_valid)
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n) begin
    o_addr_si     <= '0;
    o_addr_ei     <= '0;
    o_level       <= '0;
  end else if(w_valid) begin
    o_addr_si     <= temp_o_mem[SIZE_FIFO-1:SIZE_ADDR+SIZE_LEVEL];
    o_addr_ei     <= temp_o_mem[SIZE_FIFO-SIZE_ADDR-SIZE_LEVEL-1:SIZE_LEVEL];
    o_level       <= temp_o_mem[SIZE_LEVEL-1:0];
  end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
  if(~i_rst_n)
    o_done        <= '0;
  else 
    o_done        <= w_valid;
end

endmodule
