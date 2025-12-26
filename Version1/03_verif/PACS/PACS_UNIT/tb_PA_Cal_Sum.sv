module tb_PA_Cal_Sum(); 

parameter   SIZE_ADDR = 11;
localparam  ADDR_END  = (1 << SIZE_ADDR) - 1;
parameter   SIZE_DATA = 32;
parameter   MEM_INIT_FILE = "./../../03_verif/lib/mem_init.hex";
parameter   MEM_DUMP_FILE = "./../../03_verif/PACS/PACS_UNIT/mem_out.hex";

logic                     i_clk       ;
logic                     i_rst_n     ;
logic                     i_start     ;
logic [SIZE_ADDR-1:0]     i_addr_si   ;
logic [SIZE_ADDR-1:0]     i_addr_ei   ;
logic                     i_valid_ram ;
logic [SIZE_DATA-1:0]     i_data_ram  ;
logic [SIZE_DATA-1:0]    o_sum        ;
logic [SIZE_DATA-1:0]    o_sum_expect ;
logic                    o_rd_ram     ;
logic [SIZE_ADDR-1:0]    o_addr_ram   ;
logic                    o_done       ;

logic [SIZE_DATA-1:0] ram_test [0:(2**SIZE_ADDR)-1];
initial begin
    $readmemh(MEM_INIT_FILE, ram_test);
end

function automatic logic [SIZE_DATA-1:0] cal_sum (
    input logic t_start
);
    shortreal sum_real;
    shortreal temp_real;
    int  i;

    begin
        sum_real = 0.0;
        if (t_start) begin
            for (i = 0; i <= ADDR_END; i++) begin
                temp_real = $bitstoshortreal(ram_test[i]);
                sum_real  = sum_real + temp_real;
            end
        end
        cal_sum = $shortrealtobits(sum_real);
    end
endfunction


tb_simple_dual_port_ram_single_clock#(
    .IS_READ            (1),
    .DATA_WIDTH         (SIZE_DATA),
    .ADDR_WIDTH         (SIZE_ADDR),
    .MEM_INIT_FILE      (MEM_INIT_FILE),
    .MEM_DUMP_FILE      (MEM_DUMP_FILE)
) RAM_UNIT (
    .clk                (i_clk),
    .rst_n              (i_rst_n), 
    .i_data             (),
    .wr_en              (),
    .rd_en              (o_rd_ram), 
    .read_addr          (o_addr_ram),
    .write_addr         (),
    .o_data             (i_data_ram),
    .o_valid            (i_valid_ram)
);

PA_Cal_Sum #(
    .SIZE_ADDR      (SIZE_ADDR),
    .SIZE_DATA      (SIZE_DATA)
) DUT (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_start        (i_start),
    .i_addr_si      (i_addr_si),
    .i_addr_ei      (i_addr_ei),
    .i_valid_ram    (i_valid_ram),
    .i_data_ram     (i_data_ram),
    .o_sum          (o_sum),
    .o_rd_ram       (o_rd_ram),
    .o_addr_ram     (o_addr_ram),
    .o_done         (o_done) 
);

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

// initial begin 
//     $shm_open("tb_PA_Cal_Sum.shm");
//     $shm_probe("ASM");
// end


initial begin
    i_rst_n = 0;
    i_start = 0;
    i_addr_si = 0;
    i_addr_ei = 0;
    #100;
    i_rst_n = 1;
    @(posedge i_clk);
    i_addr_ei = ADDR_END;
    i_start = 1;
    o_sum_expect = cal_sum(i_start);
    @(posedge i_clk);
    i_start = 0;
    @(posedge i_clk);
    @(posedge o_done);
    $display("o_sum = %h (float = %.24f)", o_sum, $bitstoshortreal(o_sum));
    $display("o_sum = %h (float = %.24f)", o_sum_expect, $bitstoshortreal(o_sum_expect));
    $display("error = %.5f", ($bitstoshortreal(o_sum_expect) - $bitstoshortreal(o_sum))/$bitstoshortreal(o_sum_expect));
    #100;
    $finish;
end


endmodule
