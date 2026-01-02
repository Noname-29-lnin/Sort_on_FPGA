#ifndef FRAMEWORK_CUSTOM_H_
#define FRAMEWORK_CUSTOM_H_

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <numeric>
#include <atomic>
#include <future>

#include "defines.hpp"

using SIZE_TYPE_T   = DATATYPE_VAR;
using SIZE_ARR_T    = DATATPPE_ARR;

class C_RTL_Func{
    private:
        SIZE_TYPE_T F_Cal_Sum(bool start, std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei);
        SIZE_TYPE_T F_Cal_Div(bool start, SIZE_ARR_T i_dividend, SIZE_ARR_T i_divisor);
        SIZE_TYPE_T F_Cal_divisor(bool start, int addr_si, int addr_ei);
    public:
        SIZE_TYPE_T F_Cal_Mean( std::vector<SIZE_ARR_T> &arr, int si, int ei);
};

class C_RTL_Framework_Serial {
    private:
        size_t P_count_swap     = 0;
        size_t P_count_compare  = 0;
        void RTL_Stack(bool i_pop, SIZE_ARR_T i_data, bool i_push, SIZE_ARR_T &o_data);
        SIZE_TYPE_T RTL_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei);
        SIZE_ARR_T RTL_partition(std::vector<SIZE_ARR_T> &arr, int addr_si, int addr_ei);
    public:

};
#endif
