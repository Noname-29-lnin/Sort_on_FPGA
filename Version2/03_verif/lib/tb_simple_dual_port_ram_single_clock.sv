module tb_simple_dual_port_ram_single_clock#(
    parameter IS_READ       = 1, // READ=1//WRITE=0 
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 6,
    parameter MEM_INIT_FILE = "./mem_init.hex",
    parameter MEM_DUMP_FILE = "./mem_dump.hex"
)(
    // input  logic                     i_mode     , // 0: read, 1: write
    input  logic                     clk        ,
    input  logic                     rst_n      , 
    input  logic [DATA_WIDTH-1:0]    i_data     ,
    input  logic                     wr_en      ,
    input  logic                     rd_en      , 
    input  logic [ADDR_WIDTH-1:0]    read_addr  ,
    input  logic [ADDR_WIDTH-1:0]    write_addr ,
    output logic [DATA_WIDTH-1:0]    o_data     ,
    output logic                     o_valid     
);

    logic [DATA_WIDTH-1:0] ram [0:(2**ADDR_WIDTH)-1];

    initial begin
        if (IS_READ == 1'b1) begin
            if (MEM_INIT_FILE != "") begin
                $display("Initial load memory contents from %s", MEM_INIT_FILE);
                $readmemh(MEM_INIT_FILE, ram);
            end
        end
    end

    always_ff @(posedge clk) begin
        if (wr_en)
            ram[write_addr] <= i_data;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            o_data      <= '0;
        else if(rd_en)
            o_data      <= ram[read_addr];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            o_valid      <= '0;
        else
            o_valid      <= rd_en;
    end

    final begin
        if (MEM_DUMP_FILE != "")begin
        // if (MEM_DUMP_FILE != "" && (i_mode == 1) )begin
            $display("Dumping memory contents to %s", MEM_DUMP_FILE);
            $writememh(MEM_DUMP_FILE, ram);
        end
    end

endmodule
