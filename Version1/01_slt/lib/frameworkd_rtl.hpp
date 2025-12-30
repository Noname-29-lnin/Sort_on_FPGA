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
#include <stack>

#include "defines.hpp"
#include "framework_standard.hpp"

#define DEFINES_H_
using SIZE_TYPE_T   = DATATYPE_VAR;
using SIZE_ARR_T    = DATATPPE_ARR;
using IndexType     = int;
typedef enum {
            RTL_SIMILAR     = 0,
            RTL_ACSENDING   = 1,
            RTL_DESCENDING  = 2,
            RTL_NORMAL      = 3
        } status_rtl_e;
class C_Framework_RTL : public C_Sort_Algor{
    private:
        struct TaskState {
            IndexType si;
            IndexType ei;
            IndexType S_cnt;
        };
        struct PartitionTask {
            IndexType si;    //
            IndexType ei;    //
            IndexType level; //
        };
        size_t P_count_swap    = 0;
        size_t P_count_compare = 0;
        SIZE_ARR_T P_data_check = 0;
        size_t P_count_is_Sim   = 0;
        size_t P_count_is_Asc   = 0;
        size_t P_count_is_Desc  = 0;
        size_t P_count_subarrays = 0;
        status_rtl_e RTL_state;
        SIZE_TYPE_T P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, IndexType si, IndexType ei);
        IndexType P_Partition(std::vector<SIZE_TYPE_T> &arr, IndexType si, IndexType ei);
        void P_Division(std::vector<SIZE_ARR_T>& arr, IndexType si, IndexType ei, int M, int S_cnt);
        IndexType P_Partition_Iterative(std::vector<SIZE_ARR_T>& arr, IndexType si, IndexType ei, SIZE_TYPE_T mean_value);
        void P_Division_Iterative(std::vector<SIZE_ARR_T>& arr, int M);
        status_rtl_e P_SS_Check(std::vector<SIZE_ARR_T> &arr, IndexType si, IndexType ei, SIZE_TYPE_T &mean);
    public:
        void F_Framework_Serial_RTL(
            std::vector<SIZE_ARR_T> &arr, int M
        );
        size_t Get_Count_Compare() { return P_count_compare; }
        size_t Get_Count_Swap() { return P_count_swap; }
        size_t Get_Count_Similar() { return P_count_is_Sim; }
        size_t Get_Count_Ascending() { return P_count_is_Asc; }
        size_t Get_Count_Descending() { return P_count_is_Desc; }
        size_t Get_Count_Subarrays() { return P_count_subarrays; }
};

#endif
