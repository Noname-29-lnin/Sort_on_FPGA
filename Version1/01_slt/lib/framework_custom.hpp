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
    public:
        SIZE_TYPE_T F_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei);
};

// class C_RTL_Framework_Serial {
//     private:
//         Status_e P_status;
//     public:

// };
#endif
