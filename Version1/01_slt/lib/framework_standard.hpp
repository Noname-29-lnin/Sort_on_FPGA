#ifndef FRAMEWROK_STANDARD_H_
#define FRAMEWROK_STANDARD_H_

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <numeric>
#include <atomic>
#include <future>

#include "defines.hpp"

#define DEFINES_H_
using SIZE_TYPE_T   = DATATYPE_VAR;
using SIZE_ARR_T    = DATATPPE_ARR;

typedef enum {
            SIMILAR     = 0,
            ACSENDING   = 1,
            DESCENDING  = 2,
            NORMAL      = 3
        } Status_e;

class C_Func_Cal {
    public:
        SIZE_TYPE_T F_Cal_Mean (
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        void F_Reverse_Array(std::vector<SIZE_ARR_T>& arr, int si, int ei);
};

class C_Sort_Algor {
    private:
        size_t P_count_swap     = 0;
        size_t P_count_compare  = 0;
        int P_QuickSort_Partition(std::vector<SIZE_ARR_T>& arr, int si, int ei);
        void P_MergeSort_Merge(std::vector<SIZE_ARR_T>& arr, int left, int mid, int right);
    public:
        void P_QuickSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        void P_MergeSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        void F_QuickSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        void F_MergeSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        size_t Get_Count_Compare() const { return P_count_compare; }
        size_t Get_Count_Swap() const { return P_count_swap; }
};

class C_Framework_Serial : public C_Func_Cal, public C_Sort_Algor{
    private:
        size_t P_count_swap    = 0;
        size_t P_count_compare = 0;
        Status_e P_status;
        int P_Partition(std::vector<SIZE_ARR_T>& arr, int si, int ei);
        void P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M, int& S_cnt);
        Status_e P_SS_Check(std::vector<SIZE_ARR_T> &arr, int si, int ei);
    public:
        void F_Framework_Serial(
            std::vector<SIZE_ARR_T> &arr, int M
        );
        size_t Get_Count_Compare() { return P_count_compare; }
        size_t Get_Count_Swap() { return P_count_swap; }
};

#endif
