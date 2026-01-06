module TFFE (
	input  logic t, 
	input  logic clk, 
	input  logic clrn, 
	input  logic prn, 
	input  logic ena, 
	output logic q
);

logic w_t;
assign w_t = t ^ q;

always_ff @( posedge clk or negedge clrn or negedge prn ) begin : TFFE_UNIT
    if(~clrn)
        q   <= 1'b0;
    else if(~prn)
        q   <= 1'b1;
    else if(ena)
        q   <= w_t;
end

endmodule
