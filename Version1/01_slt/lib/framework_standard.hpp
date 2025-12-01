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

#include "./defines.hpp"

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
        void F_Reverse_Array(std::vector<SIZE_ARR_T>& arr, SIZE_ARR_T si, SIZE_ARR_T ei);
};

class C_Sort_Algor {
    private:
        int P_QuickSort_Partition(std::vector<SIZE_ARR_T>& arr, SIZE_ARR_T si, SIZE_ARR_T ei);
        void P_MergeSort_Merge(std::vector<SIZE_ARR_T>& arr, int left, int mid, int right);
    public:
        void F_QuickSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
        void F_MergeSort(
            std::vector<SIZE_ARR_T> &arr, int si, int ei
        );
};

class C_Framework_Serial : public C_Func_Cal, public C_Sort_Algor{
    private:
        SIZE_TYPE_T P_count_swap    = 0;
        SIZE_TYPE_T P_count_compare = 0;
        Status_e P_status;
        int P_Partition(std::vector<SIZE_ARR_T>& arr, int si, int ei);
        void P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M, int& S_cnt);
        Status_e P_SS_Check(std::vector<SIZE_ARR_T> &arr, int si, int ei);
    public:
        void F_Framework_Serial(
            std::vector<SIZE_ARR_T> &arr, int M
        );
};

#endif
