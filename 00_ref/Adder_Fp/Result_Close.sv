module Result_Close(                                           
    input  logic [24:0] Sum,
    input  logic [4:0]  i_Z_count,   
    input  logic [8:0]  exp_C,
    output logic [8:0] exp_final_Close
);
logic [8:0] z_count_expanded;
logic [9:0] exp_sub_result;
logic C_out;                // not use
assign  z_count_expanded = {4'b0,i_Z_count};


// todo ...................................
  CLA_adder_top #(
      .WIDTH(9)
  ) exp_subtractor (
      .A(exp_C),
      .B(~z_count_expanded),        // Bù 1 của B
      .C_in(1'b1),        
      .Sum(exp_sub_result), 
      .C_out(C_out)              // bỏ qua
  );
//todo............................
// CLA_8bit exp(
//     .i_carry(1'b1),
//     .i_data_a(exp_C[7:0]),
//     .i_data_b(~z_count_expanded[7:0]),
//     .o_sum(exp_sub_result),
//     .o_carry(C_out)
// );
//todo............................
assign exp_final_Close = exp_sub_result[8:0] ; 

endmodule