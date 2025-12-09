#include "../lib/frameworkd_rtl.hpp"

SIZE_TYPE_T C_Framework_RTL::P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    SIZE_TYPE_T temp_sum = 0;
    SIZE_TYPE_T temp_count = 0;
    for(int i = si; i <= ei; i++){
        temp_sum += arr[i];
        temp_count ++;
    }
    SIZE_TYPE_T temp_div = 1;
    return temp_div = temp_sum/temp_count;
}

void C_Framework_RTL::P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei){
    SIZE_TYPE_T mean_value = P_Cal_Mean(arr, si, ei);
    int pi = si;
    for(int i = si; i <= ei; i++){
        if(arr[i] < mean_value){
            std::swap(arr[i], arr[pi]);
            pi++;
        }
    }
}

void C_Framework_RTL::P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei)
{
    int pi_0 = (si + ei) / 2;
    int pi_1 = (si + pi_0) / 2;
    int pi_2 = (pi_0 + 1 + ei) / 2;

    const std::vector<int> part_si = {
        si,
        si,
        pi_0 + 1,
        si,
        pi_1 + 1,
        pi_0 + 1,
        pi_2 + 1
    };

    const std::vector<int> part_ei = {
        ei,
        pi_0,
        ei,
        pi_1,
        pi_0,
        pi_2,
        ei
    };

    for (size_t i = 0; i < part_si.size(); ++i) {
        if (part_si[i] <= part_ei[i]) {   // tránh vùng invalid
            P_Partition(arr, part_si[i], part_ei[i]);
        }
    }

    for (size_t i = 0; i < part_si.size(); ++i) {
        if (part_si[i] <= part_ei[i]) {   // tránh vùng invalid
            P_QuickSort(arr, si, ei);
        }
    }
}

void C_Framework_RTL::F_Framework_Serial_RTL(std::vector<SIZE_ARR_T> &arr, int M){
    int si = 0;
    int ei = arr.size() - 1;
    P_Division(arr, si, ei);
}