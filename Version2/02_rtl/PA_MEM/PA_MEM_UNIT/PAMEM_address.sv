module PAMEM_address #(
    parameter SIZE_ADDR     = 32
)(    
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic                     i_start     ,
    input logic                     i_rd_ram    ,
    input logic [SIZE_ADDR-1:0]     i_addr_si   ,
    input logic [SIZE_ADDR-1:0]     i_addr_ei   ,

    output logic                    o_rd_ram    ,
    output logic [SIZE_ADDR-1:0]    o_addr_ram  ,
    output logic                    o_done       
);

    localparam IS_COUNT_UP = 1;
    logic w_start;
    logic w_start_1;
    logic w_active;
    logic w_done;
    logic w_en;
    logic [SIZE_ADDR-1:0] w_t_i;

    logic [SIZE_ADDR-1:0] w_addr_si;
    logic [SIZE_ADDR-1:0] w_addr_ei;
    SS_detect_edge #(
        .POS_EDGE   (1)   // 1: posedge, 0: negedge
    ) SSDE_start (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_signal   (i_start),
        .o_signal   (w_start_1)
    );
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin 
            w_addr_si   <= '0;
            w_addr_ei   <= '1;
        end else begin
            if(i_start) begin
                w_addr_si   <= i_addr_si;
                w_addr_ei   <= i_addr_ei;
            end
        end
    end
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin 
            w_start     <= '0;
        end else begin
            w_start     <= w_start_1;
        end
    end
    
    SS_detect_start u_detect (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_start   (i_start),
        .i_done    (w_done),
        .o_w_start (w_active)
    );

    assign w_en = w_active & i_rd_ram & ~o_done & ~w_done;
    assign w_done = (o_addr_ram == w_addr_ei);

    assign w_t_i[0] = 1'b1;

    genvar i;
    generate
        if (IS_COUNT_UP) begin : GEN_T_UP
            for (i = 1; i < SIZE_ADDR; i++) begin : GEN_T_UP_LOOP
                assign w_t_i[i] = &o_addr_ram[i-1:0];
            end
        end else begin : GEN_T_DOWN
            for (i = 1; i < SIZE_ADDR; i++) begin : GEN_T_DOWN_LOOP
                assign w_t_i[i] = &(~o_addr_ram[i-1:0]);
            end
        end
    endgenerate

    genvar j;
    generate
        if(IS_COUNT_UP) begin
            for ( j = 0; j < SIZE_ADDR; j++) begin : GEN_TFF_COUNT_UP
                TFFE u_tff (
                    .t      (w_t_i[j]),
                    .clk    (i_clk),
                    .clrn   (~((w_start | o_done) & ~w_addr_si[j]) & (i_rst_n)),
                    .prn    (~((w_start | o_done) &  w_addr_si[j])),
                    .ena    (w_en),
                    .q      (o_addr_ram[j])
                );
            end
        end else begin
            for ( j = 0; j < SIZE_ADDR; j++) begin : GEN_TFF_COUNT_DOWN
                TFFE u_tff (
                    .t      (w_t_i[j]),
                    .clk    (i_clk),
                    .clrn   (~((w_start | o_done) & ~w_addr_si[j])),
                    .prn    (~((w_start | o_done) &  w_addr_si[j]) & (i_rst_n)),
                    .ena    (w_en),
                    .q      (o_addr_ram[j])
                );
            end
        end
    endgenerate
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n)
            o_rd_ram <= 1'b0;
        else
            o_rd_ram <= w_en | w_start;
    end
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n)
            o_done <= 1'b0;
        else 
            o_done <= w_done;
    end

endmodule
