`timescale 1ns/1ps
`include "./../BFP16/lib/Cal_funs.svh"
`include "./../BFP16/lib/display.svh"
`include "./../BFP16/lib/gen_clock.svh"

module tb_BFP16_add();
localparam ALU_OP       = 1;
localparam SIZE_ADDR    = 10;
localparam SIZE_DATA    = 32;
localparam SIZE_ROM     = 1 << SIZE_ADDR;
localparam FILE_TEST_A  = "./../BFP16/FPU_list_B.txt";
localparam FILE_TEST_B  = "./../BFP16/FPU_list_A.txt";

logic                   i_clk;
logic                   i_rst_n;
logic                   i_add_sub;
logic [SIZE_DATA-1:0]   i_32_a;
logic [SIZE_DATA-1:0]   i_32_b;
logic [SIZE_DATA-1:0]   o_32_s;
logic [SIZE_DATA-1:0]   o_32_e;
logic                   o_ov_flow;
logic                   o_un_flow;

logic [SIZE_ADDR-1:0]   w_i_addr;
logic [SIZE_DATA-1:0]   w_o_data_rom_a;
logic [SIZE_DATA-1:0]   w_o_data_rom_b;
logic [SIZE_DATA-1:0]   rom_A [0:SIZE_ROM-1];
logic [SIZE_DATA-1:0]   rom_B [0:SIZE_ROM-1];
initial begin
    $readmemh(FILE_TEST_A, rom_A);
    $readmemh(FILE_TEST_B, rom_B);
end
assign w_o_data_rom_a = rom_A[w_i_addr];
assign w_o_data_rom_b = rom_B[w_i_addr];

int test_count = 0;
int test_pass  = 0;
shortreal max_errro = 0.0;

BFP16_add #(
    .SIZE_DATA          (SIZE_DATA)
) DUT (
    .i_data_a           (i_32_a),
    .i_data_b           (i_32_b),
    .o_bfu_add          (o_32_s) 
);

initial begin
    i_clk = 1'b0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

// initial begin
//     $dumpfile("tb_BFP16_add.vcd");
//     $dumpvars(0, tb_BFP16_add);
// end
// initial begin 
//     $shm_open("tb_BFP16_add.shm");
//     $shm_probe("ASM");
// end

task automatic Display_result_Error (
    string                      t_type      ,
    input logic [31:0]          t_i_32_a    ,
    input logic [31:0]          t_i_32_b    ,
    input logic [31:0]          t_o_32_s    ,
    output logic [31:0]         t_o_32_e     
);

    shortreal t_sr_32_a, t_sr_32_b, t_sr_32_s, t_sr_32_e, t_sr_rounding_error;
    shortreal t_error;
    logic f_t_check;

    begin
        t_error             = Error_standard();
        t_sr_32_a           = HEX_TO_REAL(t_i_32_a);
        t_sr_32_b           = HEX_TO_REAL(t_i_32_b);
        t_sr_32_s           = HEX_TO_REAL(t_o_32_s);
        t_sr_32_e           = Cal_FPU_expected(1'b0, t_sr_32_a, t_sr_32_b);
        t_o_32_e            = REAL_TO_HEX(t_sr_32_e);
        t_sr_rounding_error = Error_actual(t_sr_32_s, t_sr_32_e);
        f_t_check           = (t_sr_rounding_error <= t_error) ? 1'b1 : 1'b0;

        $display("[%s][%s]i_32_a=%h (%.24f) %s i_32_b=%h (%.24f) \t| o_32_s=%h (%.24f) \t ",
                    t_type, "ADD" , 
                    t_i_32_a, t_sr_32_a, "+", t_i_32_b, t_sr_32_b, t_o_32_s, t_sr_32_s);
        $display("=> %s: expect=%.24f (%h), dut=%.24f (%h), rounding_error=%.8f %% (exp_error = %.8f %%)", 
                    (f_t_check) ? "PASS" : "FAIL", 
                    t_sr_32_e, t_o_32_e, t_sr_32_s, t_o_32_s, t_sr_rounding_error, t_error);
        
        if (f_t_check) test_pass++;
        test_count++;
        if(max_errro < t_sr_rounding_error) max_errro = t_sr_rounding_error;
    end
endtask
task automatic Display_result_Similar (
    string                      t_type      ,
    input logic [31:0]          t_i_32_a    ,
    input logic [31:0]          t_i_32_b    ,
    input logic [31:0]          t_o_32_s    
);
    logic [31:0] t_o_32_e;
    shortreal t_sr_32_a, t_sr_32_b, t_sr_32_s, t_sr_32_e, t_sr_rounding_error;
    shortreal t_error;
    logic f_t_check;

    begin
        t_error             = Error_standard();
        t_sr_32_a           = HEX_TO_REAL(t_i_32_a);
        t_sr_32_b           = HEX_TO_REAL(t_i_32_b);
        t_sr_32_s           = HEX_TO_REAL(t_o_32_s);
        t_sr_32_e           = Cal_FPU_expected(1'b0, t_sr_32_a, t_sr_32_b);
        t_o_32_e            = REAL_TO_HEX(t_sr_32_e);
        t_sr_rounding_error = Error_actual(t_sr_32_s, t_sr_32_e);
        f_t_check           = Is_Similar(t_o_32_s, t_o_32_e) ? 1'b1 : 1'b0;

        $display("[%s][%s]i_32_a=%h (%.24f) %s i_32_b=%h (%.24f) \t| o_32_s=%h (%.24f)",
                    t_type, "ADD", 
                    t_i_32_a, t_sr_32_a, "+", t_i_32_b, t_sr_32_b, t_o_32_s, t_sr_32_s);
        $display("=> %s: expect=%.24f (%h), dut=%.24f (%h), rounding_error=%.8f %% (exp_error = %.8f %%)", 
                    (f_t_check) ? "PASS" : "FAIL", 
                    t_sr_32_e, t_o_32_e, t_sr_32_s, t_o_32_s, t_sr_rounding_error, t_error);
        
        if (f_t_check) test_pass++;
        test_count++;
    end

endtask
task automatic TestCase_Display_result(
    string              t_type,
    string              t_testcase,
    input logic [31:0]  t_i_fpu_a,
    input logic [31:0]  t_i_fpu_b
);
    begin
        $display("==========[ %s ]==========", t_testcase);
        @(posedge i_clk);
        #1;
        i_32_a      = t_i_fpu_a;
        i_32_b      = t_i_fpu_b;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_32_a, i_32_b, o_32_s, o_32_e);
        // @(posedge i_clk);
        // #1;
        // i_32_a      = t_i_fpu_b;
        // i_32_b      = t_i_fpu_a;
        // @(negedge i_clk);
        // #1;
        // Display_result_Error(t_type, i_32_a, i_32_b, o_32_s);
    end
endtask //automatic

logic [31:0] temp_value;
logic [31:0] temp_standard;
initial begin
    i_rst_n = 0;
    i_32_a          = 32'h0;
    i_32_b          = 32'h0;
    temp_value      = 32'h0;
    temp_standard   = 32'h0;
    w_i_addr        = '0;
    #100;
    i_rst_n = 1;
    #100;
    // TestCase_Display_result("ZERO", "(0.0 & 0.0)", 32'h00000000, 32'h00000000);
    // TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h00000000, 32'h80000000);
    // TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h4016A197, 32'hc016A197);
    // TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h40AED834, 32'hc0AED834);
    // TestCase_Display_result("INF", "(inf & inf)", 32'h7f800000, 32'h7f800000);
    // TestCase_Display_result("INF", "(-inf & -inf)", 32'hff800000, 32'hff800000);
    // TestCase_Display_result("INF", "(inf & -inf)", 32'hff800000, 32'h7f800000);
    // TestCase_Display_result("INF", "(inf & 0)", 32'h7f800000, 32'h00000000);
    // TestCase_Display_result("INF", "(-inf & 0)", 32'hff800000, 32'h00000000);
    // TestCase_Display_result("INF", "(inf & Number)", 32'h7f800000, 32'h40533333);
    // TestCase_Display_result("INF", "(-inf & Number)", 32'hff800000, 32'h40533333);
    // TestCase_Display_result("INF", "(inf & -Number)", 32'h7f800000, 32'hc00ccccd);
    // TestCase_Display_result("INF", "(-inf & -Number)", 32'hff800000, 32'hc00ccccd);
    // TestCase_Display_result("NaN", "(NaN & -Number)", 32'h7f800001, 32'hc00ccccd);
    // TestCase_Display_result("NaN", "(-NaN & -Number)", 32'hff800001, 32'hc00ccccd);
    // TestCase_Display_result("NaN", "(NaN &  Number)", 32'hff800001, 32'h40533333);
    // TestCase_Display_result("NaN", "(-NaN &  Number)", 32'h7f800001, 32'h40533333);
    // TestCase_Display_result("APPRO", "APPR INF", 32'h7f21616f, 32'h007fffff);
    // TestCase_Display_result("APPRO", "APPR INF", 32'h7f7fffff, 32'h00ffffff);
    // TestCase_Display_result("APPRO", "APPR INF", 32'h7f7fffff, 32'h007fffff);
    // TestCase_Display_result("APPRO", "APPR ZERO", 32'h00ffffff, 32'h007fffff);
    // TestCase_Display_result("APPRO", "APPR ZERO", 32'h00ffffff, 32'h00ffffff);
    // TestCase_Display_result("SIGN", "(-A + B)", 32'hc00ccccd, 32'h40533333);
    // TestCase_Display_result("SIGN", "TEST SIGN", 32'hc00ccccd, 32'hc0533333);
    // TestCase_Display_result("SIGN", "TEST SIGN", 32'hc00ccccd, 32'hc1b1999a);
    // TestCase_Display_result("PRE_NOR_EXP", "Overflow rouding", 32'h0cffffff, 32'h00f80000);
    // TestCase_Display_result("VALUE", "Value", 32'h5203778f, 32'h5018c9da);
    repeat(2**SIZE_ADDR) begin
    // repeat(10) begin
        TestCase_Display_result("Random", "Read data from ROM", w_o_data_rom_a, temp_value);
        TestCase_Display_result("Random", "Read data from ROM", w_o_data_rom_a, temp_standard);
        @(posedge i_clk);
        #1;
        temp_value = o_32_s;
        temp_standard = o_32_e;
        w_i_addr = w_i_addr + 1;
    end
    
    Display_SummaryResult(test_count, test_pass);
    $display("Temp = %.24f (%h)", HEX_TO_REAL(temp_value), temp_value);
    $display("Exp = %.24f (%h)", HEX_TO_REAL(temp_standard), temp_standard);
    $display("Max_Error = %.4f %%", max_errro);
    #100;
    $finish;
end

endmodule
