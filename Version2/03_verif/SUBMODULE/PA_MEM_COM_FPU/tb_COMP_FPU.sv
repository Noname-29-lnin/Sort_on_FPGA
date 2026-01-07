`timescale 1ns/1ps
`include "./../../03_verif/SUBMODULE/PA_MEM_COM_FPU/lib/Cal_funs.svh"
`include "./../../03_verif/SUBMODULE/PA_MEM_COM_FPU/lib/display.svh"

module tb_COMP_FPU();

localparam SIZE_DATA = 32;
localparam SIZE_ADDR = 11;
logic                   i_clk;
logic                   i_rst_n;
logic [SIZE_DATA-1:0]   i_fpu_a;
shortreal               f_fpu_a;
logic [SIZE_DATA-1:0]   i_fpu_b;
shortreal               f_fpu_b;
logic                   o_less;

int number_count = 0;
int number_pass = 0;
localparam PATH_DATA_A  = "./../../03_verif/SUBMODULE/PA_MEM_COM_FPU/FPU_list_A.txt";
localparam PATH_DATA_B  = "./../../03_verif/SUBMODULE/PA_MEM_COM_FPU/FPU_list_B.txt";
logic [SIZE_DATA-1:0] mem_test_A [2**SIZE_ADDR-1:0];
logic [SIZE_DATA-1:0] mem_test_B [2**SIZE_ADDR-1:0];
initial begin
    $readmemh(PATH_DATA_A, mem_test_A);
end
initial begin
    $readmemh(PATH_DATA_B, mem_test_B);
end
logic [SIZE_ADDR-1:0] w_addr_test;

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

COMP_FPU DUT(
    .i_fpu_a    (i_fpu_a),
    .i_fpu_b    (i_fpu_b),
    .o_less     (o_less)  // A < B
);

initial begin
    $shm_open("tb_COMP_FPU.shm");
    $shm_probe("ASM");
end

task automatic display_result();
    begin
        @(posedge i_clk);
        i_fpu_a = mem_test_A[w_addr_test];
        f_fpu_a = HEX_TO_REAL(i_fpu_a);
        i_fpu_b = mem_test_B[w_addr_test];
        f_fpu_b = HEX_TO_REAL(i_fpu_b);
        @(negedge i_clk);
        $display("[%s] i_fpu_a = %.4f (%h) < i_fpu_b = %.4f (%h) = o_comp_less (%b) | Expected (%b)", o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b) ? "PASS" : "FAIL", f_fpu_a, i_fpu_a, f_fpu_b, i_fpu_b, o_less, COMP_FPU_expected(f_fpu_a, f_fpu_b));
        if(o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b)) begin
            number_pass ++;
        end
        number_count ++;
        @(posedge i_clk);
        w_addr_test ++;
    end
endtask //automatic

initial begin
    i_rst_n = 0;
    i_fpu_a = 32'h0;
    i_fpu_b = 32'h0;
    w_addr_test = '0;
    #100;
    i_rst_n = 1;

    repeat (2) begin
        @(posedge i_clk);
        i_fpu_a = 32'h4bddcd42;
        f_fpu_a = HEX_TO_REAL(i_fpu_a);
        i_fpu_b = 32'h4bddcd42;
        f_fpu_b = HEX_TO_REAL(i_fpu_b);
        @(negedge i_clk);
        $display("[%s] i_fpu_a = %.4f (%h) < i_fpu_b = %.4f (%h) = o_comp_less (%b) | Expected (%b)", o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b) ? "PASS" : "FAIL", f_fpu_a, i_fpu_a, f_fpu_b, i_fpu_b, o_less, COMP_FPU_expected(f_fpu_a, f_fpu_b));
        if(o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b)) begin
            number_pass ++;
        end
        number_count ++;
    end
    repeat (1) begin
        @(posedge i_clk);
        i_fpu_a = 32'hcec6a04a;
        f_fpu_a = HEX_TO_REAL(i_fpu_a);
        i_fpu_b = 32'hd02dca4a;
        f_fpu_b = HEX_TO_REAL(i_fpu_b);
        @(negedge i_clk);
        $display("[%s] i_fpu_a = %.4f (%h) < i_fpu_b = %.4f (%h) = o_comp_less (%b) | Expected (%b)", o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b) ? "PASS" : "FAIL", f_fpu_a, i_fpu_a, f_fpu_b, i_fpu_b, o_less, COMP_FPU_expected(f_fpu_a, f_fpu_b));
        if(o_less == COMP_FPU_expected(f_fpu_a, f_fpu_b)) begin
            number_pass ++;
        end
        number_count ++;
    end
    repeat (2**SIZE_ADDR) begin
        display_result();
    end
    Display_SummaryResult(number_count, number_pass);
    #100;
    $display("End Simulation");
    $finish;
end
endmodule
