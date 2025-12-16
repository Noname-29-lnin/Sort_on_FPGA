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
        size_t P_count_swap    = 0;
        size_t P_count_compare = 0;
        SIZE_ARR_T P_data_check = 0;
        Status_e RTL_state;
        SIZE_ARR_T ReadData(std::vector<SIZE_ARR_T> &arr, int addr, bool is_En, bool &is_valid);
        void WriteData(std::vector<SIZE_ARR_T> &arr, int addr, bool is_En, SIZE_ARR_T data_wr , bool &is_valid);
        // Status_e Check_SS(SIZE_ARR_T data_check, bool &is_Similar, bool &is_Ascending, bool &is_Descending);
        SIZE_TYPE_T P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei);
        void P_SliptSubArr(int N, int si, int ei, std::vector<int> &part_si, std::vector<int> &part_ei);
        void P_SliptCoreSort(int N, int si, int ei, std::vector<int> &coresort_si, std::vector<int> &coresort_ei);
        void P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei);
        void P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M);
    public:
        void F_Framework_Serial_RTL(
            std::vector<SIZE_ARR_T> &arr, int M
        );
        size_t Get_Count_Compare() { return P_count_compare; }
        size_t Get_Count_Swap() { return P_count_swap; }
};

#endif
