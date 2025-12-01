#include "../lib/framework_custom.hpp"

/*
    C_RTL_Func
*/
SIZE_TYPE_T C_RTL_Func::F_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    SIZE_TYPE_T t_sum = 0;
    for(int i =si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (ei - si + 1);
    return t_div;
}

