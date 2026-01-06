module FPPA2_adder #(
    parameter WIDTH = 9,
    parameter FANIN = 4
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire             C_in,
    output wire [WIDTH:0]   Sum,      // A+B (or A+B+C_in)
    output wire [WIDTH:0]   Sum_p1,   // A+B+1
    output wire [WIDTH:0]   Sum_p2,   // A+B+2
    output wire             C_out
);

    // =========================================================================
    // Step 1: Generate P and G
    // =========================================================================
    wire [WIDTH-1:0] P, G;
    wire [WIDTH:0]   C;
    
    assign P = A ^ B;
    assign G = A & B;

    // =========================================================================
    // Step 2: CLA Tree to compute carries
    // =========================================================================
    cla_logic_tree_level #(
        .WIDTH(WIDTH),
        .FANIN(FANIN)
    ) cla_tree (
        .C_in(C_in),
        .P_in(P),
        .G_in(G),
        .C_out(C)
    );

    // =========================================================================
    // Step 3: Compute Sum = P ^ C
    // =========================================================================
    assign Sum[WIDTH-1:0] = P ^ C[WIDTH-1:0];
    assign C_out = C[WIDTH];
    assign Sum[WIDTH] = C_out;

    // =========================================================================
    // Step 4: Generate flag1 for Sum+1 (fully flattened)
    // flag1[0] = 1
    // flag1[i] = P[i-1] & P[i-2] & ... & P[0]  (for i >= 1)
    // =========================================================================
    wire [WIDTH-1:0] flag1;
    
    genvar i;
    generate
        assign flag1[0] = 1'b1;
        
        for (i = 1; i < WIDTH; i++) begin : GEN_FLAG1
            // flag1[i] = AND of P[i-1:0]
            assign flag1[i] = &P[i-1:0];
        end
    endgenerate
    
    // Sum+1 = Sum ^ flag1
    assign Sum_p1[WIDTH-1:0] = Sum[WIDTH-1:0] ^ flag1;
    
    // Carry out for Sum+1: occurs when all P bits are 1 and original C_out is 1
    wire all_p;
    assign all_p = &P;
    assign Sum_p1[WIDTH] = C_out ^ all_p;

    // =========================================================================
    // Step 5: Generate flag2 for Sum+2 (optimized and flattened)
    // According to paper:
    // f0 = 0
    // f1 = 1
    // f2 = p1 ^ g0
    // fi = (pi-1 ^ gi-2) & fi-1  (for i > 2)
    //
    // Optimization: Expand fi recursively to avoid sequential dependency
    // fi = (pi-1 ^ gi-2) & (pi-2 ^ gi-3) & ... & (p1 ^ g0)
    // =========================================================================
    wire [WIDTH-1:0] flag2;
    
    generate
        assign flag2[0] = 1'b0;
        
        if (WIDTH > 1) begin
            assign flag2[1] = 1'b1;
        end
        
        if (WIDTH > 2) begin
            assign flag2[2] = P[1] ^ G[0];
        end
        
        // For i >= 3: flag2[i] = AND of all (P[j-1] ^ G[j-2]) for j=2..i
        for (i = 3; i < WIDTH; i++) begin : GEN_FLAG2
            wire [i-2:0] flag2_terms;
            
            // Generate all terms in parallel
            genvar k;
            for (k = 0; k <= i-2; k++) begin : GEN_F2_TERMS
                if (k == 0) begin
                    // First term: p1 ^ g0
                    assign flag2_terms[k] = P[1] ^ G[0];
                end else begin
                    // Term k: p[k+1] ^ g[k]
                    assign flag2_terms[k] = P[k+1] ^ G[k];
                end
            end
            
            // flag2[i] = AND of all terms
            assign flag2[i] = &flag2_terms;
        end
    endgenerate
    
    // Sum+2 = Sum ^ flag2
    assign Sum_p2[WIDTH-1:0] = Sum[WIDTH-1:0] ^ flag2;
    
    // =========================================================================
    // Step 6: Compute carry out for Sum+2
    // Detailed analysis of when carry occurs for Sum+2
    // =========================================================================
    wire sum_p2_carry;
    
    generate
        if (WIDTH == 1) begin
            // Special case: 1-bit adder
            assign sum_p2_carry = C_out;
        end else if (WIDTH == 2) begin
            // 2-bit: carry occurs if original carry or flag2[1]=1
            assign sum_p2_carry = C_out | flag2[1];
        end else begin
            // General case: analyze carry propagation
            // Carry occurs when:
            // 1. Original carry out is 1, OR
            // 2. Sum would overflow when adding 2
            wire flag2_carry;
            assign flag2_carry = flag2[WIDTH-1] & Sum[WIDTH-1];
            assign sum_p2_carry = C_out | flag2_carry;
        end
    endgenerate
    
    assign Sum_p2[WIDTH] = sum_p2_carry;

endmodule