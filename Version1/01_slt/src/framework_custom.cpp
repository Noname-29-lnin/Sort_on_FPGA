#include "../lib/framework_custom.hpp"

/*
    C_RTL_Func
*/

SIZE_TYPE_T C_RTL_Func::F_Cal_Sum(bool start, std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei){
    SIZE_TYPE_T temp_sum = 0;
    if(!start){
        return temp_sum;
    } else {
        for(int i = addr_si; i <= addr_ei; i++){
            temp_sum += arr[i];
        }
        return temp_sum;
    }
}
SIZE_TYPE_T C_RTL_Func::F_Cal_Div(bool start, SIZE_ARR_T i_dividend, SIZE_ARR_T i_divisor){
    if(!start){
        return 1;
    } else {
        return i_dividend/i_divisor;
    }
}
SIZE_TYPE_T C_RTL_Func::F_Cal_divisor(bool start, int addr_si, int addr_ei){
    if(!start){
        return 1;
    } else {
        return (SIZE_ARR_T) (addr_ei - addr_si + 1);
    }
}

SIZE_TYPE_T C_RTL_Func::F_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei)
{
    SIZE_TYPE_T t_sum = 0;
    for (int i = si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (ei - si + 1);
    return t_div;
}

// Hirecture
// |- Stack
// |- CheckData

void C_RTL_Framework_Serial::RTL_Stack(bool i_pop, SIZE_ARR_T i_data, bool i_push, SIZE_ARR_T &o_data)
{
    static std::vector<SIZE_ARR_T> stack_mem;
    if (i_push)
    {
        stack_mem.push_back(i_data);
    }
    else if (i_pop && !stack_mem.empty())
    {
        o_data = stack_mem.back();
        stack_mem.pop_back();
    }
}

SIZE_TYPE_T C_RTL_Framework_Serial::RTL_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei)
{
    SIZE_TYPE_T temp_sum = 0;
    SIZE_TYPE_T temp_div = 1;
    for (int i = addr_si; i <= addr_ei; i++)
    {
        temp_sum += arr[i];
    }
    temp_div = temp_sum / (addr_ei - addr_si + 1);
    return temp_div;
}
SIZE_ARR_T C_RTL_Framework_Serial::RTL_partition(std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei)
{
    SIZE_TYPE_T bi = addr_si;
    SIZE_TYPE_T mean = RTL_Cal_Mean(arr, addr_si, addr_ei);
    for (int i = addr_si; i <= addr_ei; i++)
    {
        if (arr[i] < mean)
        {
            std::swap(arr[i], arr[bi]);
            bi++;
        }
    }

    return bi - 1;
}
