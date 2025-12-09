#ifndef FRAMEWORK_RTL_H_
#define FRAMEWORK_RTL_H_

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <numeric>
#include <atomic>
#include <future>

#include "defines.hpp"
#include "framework_standard.hpp"

#define DEFINES_H_
using SIZE_TYPE_T   = DATATYPE_VAR;
using SIZE_ARR_T    = DATATPPE_ARR;

class C_Framework_RTL : public C_Sort_Algor{
    private:
        SIZE_TYPE_T P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei);
        void P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei);
        void P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei);
    public:
        void F_Framework_Serial_RTL(
            std::vector<SIZE_ARR_T> &arr, int M
        );
};

#endif
