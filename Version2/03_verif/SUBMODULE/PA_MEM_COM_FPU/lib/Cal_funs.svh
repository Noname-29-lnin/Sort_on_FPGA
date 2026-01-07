function automatic shortreal HEX_TO_REAL(
    input logic [31:0]  f_i_data
);
    int temp;
    begin
        temp = int'(f_i_data);
        return $bitstoshortreal(temp);
    end  
endfunction

function automatic logic [31:0] REAL_TO_HEX(
    input shortreal f_i_data
);
    begin
        return $shortrealtobits(f_i_data);
    end
endfunction

function automatic logic COMP_FPU_expected(
    input shortreal     f_i_32_a    ,
    input shortreal     f_i_32_b            
);
    begin
        return (f_i_32_a < f_i_32_b) ? 1'b1 : 1'b0;
    end
endfunction
