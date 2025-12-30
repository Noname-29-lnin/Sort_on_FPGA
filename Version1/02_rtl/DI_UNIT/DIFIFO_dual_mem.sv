module DIFIFO_dual_mem #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 3
)(
  input  logic                      i_clk     ,
  input  logic                      i_wr_en   ,
  input  logic                      i_rd_en   ,
  input  logic [ADDR_WIDTH - 1:0]   i_addr_wr ,
  input  logic [ADDR_WIDTH - 1:0]   i_addr_rd ,
  input  logic [DATA_WIDTH - 1:0]   i_data_wr ,
  output logic [DATA_WIDTH - 1:0]   o_data_rd ,
  output logic                      o_valid_rd 
);

  reg [DATA_WIDTH - 1:0] ram [2**ADDR_WIDTH - 1:0];
  initial for(int i = 0; i < 2**ADDR_WIDTH; i++) ram[i] = '0;

  always_ff @(posedge i_clk) begin
    if(i_wr_en) begin
      ram[i_addr_wr] <= i_data_wr;
    end 
  end

  always_ff @(posedge i_clk) begin
    if(i_rd_en) begin
      o_data_rd      <= ram[i_addr_rd];
    end
  end

  always_ff @(posedge i_clk) begin
    o_valid_rd      <= i_rd_en;
  end

endmodule
