module FP32_div(
    input  logic             i_clk,
    input  logic             i_rst_n,
    input  logic             i_start,
    input  logic [31:0]      a_value_i,
    input  logic [31:0]      b_value_i,
    output logic [31:0]      z_value_o,
    output logic             o_done
);

    logic [31:0] w_a_value, w_b_value, w_z_value;
    logic        w_start, w_valid;

    SS_detect_edge #(.POS_EDGE(0)) SSDE_START (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_signal(i_start),
        .o_signal(w_start)
    );

    // 1-cycle valid pulse after edge detect
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) w_valid <= 1'b0;
        else         w_valid <= w_start;
    end

    // latch inputs on start pulse
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            w_a_value <= '0;
            w_b_value <= '0;
        end else if(w_start) begin
            w_a_value <= a_value_i;
            w_b_value <= b_value_i;
        end
    end

    typedef enum logic [3:0] {
        IDLE, UNPACK, SPECIAL_CASES, NORMALIZE_A, NORMALIZE_B,
        DIVIDE_0, DIVIDE_1, DIVIDE_2, DIVIDE_3,
        NORMALIZE_0, NORMALIZE_1, ROUND, PACK, DONE
    } state_t;

    state_t state, n_state;

    integer i; // (không dùng for nữa, giữ nếu bạn cần debug)

    logic        [23:0] a_m, b_m, z_m;
    logic signed [9:0]  a_e, b_e, z_e;
    logic               a_s, b_s, z_s;

    logic [50:0] quotient, divisor, dividend, remainder;
    logic [5:0]  count;

    logic guard, round_bit, sticky;

    // Next-state logic (COMB)
    always_comb begin
        n_state = state;

        unique case (state)
            IDLE: begin
                if (w_valid) n_state = UNPACK;
            end

            UNPACK:         n_state = SPECIAL_CASES;

            SPECIAL_CASES: begin
                // nếu rơi vào case đặc biệt thì DONE, nếu không thì NORMALIZE_A
                // điều kiện cụ thể xử lý ở datapath always_ff
                // Ở đây chỉ quyết định nhánh theo “đã special-case hay không”
                // Mình dựa vào cùng điều kiện như bên datapath để chọn n_state.
                if ( ((a_e == 10'sd128) && (a_m != 0)) || ((b_e == 10'sd128) && (b_m != 0)) )       n_state = DONE; // NaN
                else if ( (a_e == 10'sd128) && (b_e == 10'sd128) )                                    n_state = DONE; // inf/inf
                else if ( (a_e == 10'sd128) )                                                          n_state = DONE; // inf/x
                else if ( (b_e == 10'sd128) )                                                          n_state = DONE; // x/inf
                else if ( (a_e == -10'sd127) && (a_m == 0) )                                           n_state = DONE; // 0/x
                else if ( (b_e == -10'sd127) && (b_m == 0) )                                           n_state = DONE; // x/0
                else                                                                                   n_state = NORMALIZE_A;
            end

            NORMALIZE_A: begin
                if (a_m[23]) n_state = NORMALIZE_B;
                else         n_state = NORMALIZE_A;
            end

            NORMALIZE_B: begin
                if (b_m[23]) n_state = DIVIDE_0;
                else         n_state = NORMALIZE_B;
            end

            DIVIDE_0:       n_state = DIVIDE_1;
            DIVIDE_1:       n_state = DIVIDE_2;

            DIVIDE_2: begin
                if (count == 6'd49) n_state = DIVIDE_3;
                else                n_state = DIVIDE_1;
            end

            DIVIDE_3:       n_state = NORMALIZE_0;

            NORMALIZE_0: begin
                if ((z_m[23] == 1'b0) && (z_e > -10'sd126)) n_state = NORMALIZE_0;
                else                                        n_state = NORMALIZE_1;
            end

            NORMALIZE_1: begin
                if (z_e < -10'sd126) n_state = NORMALIZE_1;
                else                 n_state = ROUND;
            end

            ROUND:          n_state = PACK;
            PACK:           n_state = DONE;
            DONE:           n_state = IDLE;

            default:        n_state = IDLE;
        endcase
    end

    // State register + datapath (SEQ)
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state      <= IDLE;

            a_m        <= '0;  b_m <= '0;  z_m <= '0;
            a_e        <= '0;  b_e <= '0;  z_e <= '0;
            a_s        <= '0;  b_s <= '0;  z_s <= '0;

            quotient   <= '0;  divisor <= '0; dividend <= '0; remainder <= '0;
            count      <= '0;

            guard      <= 1'b0;
            round_bit  <= 1'b0;
            sticky     <= 1'b0;

            w_z_value  <= '0;
            z_value_o  <= '0;
            o_done     <= 1'b0;
        end else begin
            state  <= n_state;

            // default outputs
            o_done <= 1'b0;

            unique case (state)
                IDLE: begin
                    // optional: clear intermediates mỗi lần rảnh
                    guard     <= 1'b0;
                    round_bit <= 1'b0;
                    sticky    <= 1'b0;
                    quotient  <= '0;
                    divisor   <= '0;
                    dividend  <= '0;
                    remainder <= '0;
                    count     <= '0;
                end

                UNPACK: begin
                    a_m <= {1'b0, w_a_value[22:0]};
                    b_m <= {1'b0, w_b_value[22:0]};
                    a_e <= $signed({2'd0, w_a_value[30:23]}) - 10'sd127;
                    b_e <= $signed({2'd0, w_b_value[30:23]}) - 10'sd127;
                    a_s <= w_a_value[31];
                    b_s <= w_b_value[31];
                end

                SPECIAL_CASES: begin
                    // NaN
                    if ((a_e == 10'sd128 && a_m != 0) || (b_e == 10'sd128 && b_m != 0)) begin
                        w_z_value <= {1'b1, 8'hFF, 1'b1, 22'd0};
                    end
                    // inf/inf => NaN
                    else if (a_e == 10'sd128 && b_e == 10'sd128) begin
                        w_z_value <= {1'b1, 8'hFF, 1'b1, 22'd0};
                    end
                    // a=inf
                    else if (a_e == 10'sd128) begin
                        w_z_value <= {a_s ^ b_s, 8'hFF, 23'd0};
                        // inf/0 => NaN
                        if ((b_e == -10'sd127) && (b_m == 0)) begin
                            w_z_value <= {1'b1, 8'hFF, 1'b1, 22'd0};
                        end
                    end
                    // b=inf => 0
                    else if (b_e == 10'sd128) begin
                        w_z_value <= {a_s ^ b_s, 8'd0, 23'd0};
                    end
                    // a=0
                    else if (a_e == -10'sd127 && a_m == 0) begin
                        w_z_value <= {a_s ^ b_s, 8'd0, 23'd0};
                        // 0/0 => NaN
                        if (b_e == -10'sd127 && b_m == 0) begin
                            w_z_value <= {1'b1, 8'hFF, 1'b1, 22'd0};
                        end
                    end
                    // b=0 => inf
                    else if (b_e == -10'sd127 && b_m == 0) begin
                        w_z_value <= {a_s ^ b_s, 8'hFF, 23'd0};
                    end
                    else begin
                        // denorm handling
                        if (a_e == -10'sd127) a_e <= -10'sd126;
                        else                  a_m[23] <= 1'b1;

                        if (b_e == -10'sd127) b_e <= -10'sd126;
                        else                  b_m[23] <= 1'b1;
                    end
                end

                NORMALIZE_A: begin
                    if (!a_m[23]) begin
                        a_m <= a_m << 1;
                        a_e <= a_e - 10'sd1;
                    end
                end

                NORMALIZE_B: begin
                    if (!b_m[23]) begin
                        b_m <= b_m << 1;
                        b_e <= b_e - 10'sd1;
                    end
                end

                DIVIDE_0: begin
                    z_s      <= a_s ^ b_s;
                    z_e      <= a_e - b_e;

                    quotient  <= '0;
                    remainder <= '0;
                    count     <= '0;

                    dividend <= {a_m, 27'd0};
                    divisor  <= {27'd0, b_m};
                end

                DIVIDE_1: begin
                    quotient        <= quotient << 1;
                    remainder       <= remainder << 1;
                    remainder[0]    <= dividend[50];
                    dividend        <= dividend << 1;
                end

                DIVIDE_2: begin
                    if (remainder >= divisor) begin
                        quotient[0] <= 1'b1;
                        remainder   <= remainder - divisor;
                    end
                    if (count != 6'd49) count <= count + 6'd1;
                end

                DIVIDE_3: begin
                    z_m       <= quotient[26:3];
                    guard     <= quotient[2];
                    round_bit <= quotient[1];
                    sticky    <= quotient[0] | (remainder != 0);
                end

                NORMALIZE_0: begin
                    if ((z_m[23] == 1'b0) && (z_e > -10'sd126)) begin
                        z_e       <= z_e - 10'sd1;
                        z_m       <= z_m << 1;
                        z_m[0]    <= guard;
                        guard     <= round_bit;
                        round_bit <= 1'b0;
                    end
                end

                NORMALIZE_1: begin
                    if (z_e < -10'sd126) begin
                        z_e       <= z_e + 10'sd1;
                        z_m       <= z_m >> 1;
                        guard     <= z_m[0];
                        round_bit <= guard;
                        sticky    <= sticky | round_bit;
                    end
                end

                ROUND: begin
                    if (guard && (round_bit | sticky | z_m[0])) begin
                        z_m <= z_m + 24'd1;
                        if (z_m == 24'hFFFFFF) z_e <= z_e + 10'sd1;
                    end
                end

                PACK: begin
                    w_z_value[22:0]  <= z_m[22:0];
                    w_z_value[30:23] <= $unsigned(z_e + 10'sd127);
                    w_z_value[31]    <= z_s;

                    if (z_e == -10'sd126 && z_m[23] == 1'b0)
                        w_z_value[30:23] <= 8'd0;

                    if (z_e > 10'sd127)
                        w_z_value <= {z_s, 8'hFF, 23'd0};
                end

                DONE: begin
                    o_done    <= 1'b1;        // pulse 1 cycle
                    z_value_o <= w_z_value;   // latch output
                end

                default: ;
            endcase
        end
    end

endmodule
