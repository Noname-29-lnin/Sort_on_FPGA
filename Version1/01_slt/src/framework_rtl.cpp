#include "../lib/frameworkd_rtl.hpp"

SIZE_ARR_T C_Framework_RTL::ReadData(std::vector<SIZE_ARR_T> &arr, int addr, bool is_En, bool &is_valid){
    is_valid = false;
    while(!is_En){}
    is_valid = true;
    return arr[addr];
}

void C_Framework_RTL::WriteData(std::vector<SIZE_ARR_T> &arr, int addr, bool is_En, SIZE_ARR_T data_wr , bool &is_valid){
    is_valid = false;
    while(!is_En){}
    arr[addr] = data_wr;
    is_valid = true;
}

SIZE_TYPE_T C_Framework_RTL::P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    SIZE_TYPE_T t_sum = 0;
    for(int i =si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (ei - si + 1);
    return t_div;
}


int C_Framework_RTL::P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei){
    SIZE_TYPE_T mean_value = P_Cal_Mean(arr, si, ei);
    std::cout << "Mean_value = " << mean_value << std::endl;
    // bool is_check;
    SIZE_ARR_T temp_partition = 0;
    SIZE_ARR_T temp_data = 0;
    int i  = si;
    int pi = si;
    while (i <= ei){
        // while(!is_check){
        //     temp_data = ReadData(arr, i, true, is_check);
        // }
        // while(!is_check){
        //     temp_partition = ReadData(arr, pi, true, is_check);
        // }
        temp_data = arr[i];
        temp_partition = arr[pi];
        P_count_compare ++;
        if(temp_data < mean_value){
            // while(!is_check){
            //     WriteData(arr, i, true , temp_partition, is_check);
            // }
            // while(!is_check){
            //     WriteData(arr, pi, true , temp_data, is_check);
            // }
            arr[i] = temp_partition;
            arr[pi] = temp_data;
            pi++;
        }
        i++;
    }
    return pi - 1;
}

void C_Framework_RTL::P_SliptCoreSort(int N, int si, int ei, std::vector<int> &coresort_si, std::vector<int> &coresort_ei){
    coresort_si.clear();
    coresort_ei.clear();

    int num_core = 1 << N;
    int len      = ei - si + 1;
    int base     = len / num_core;
    int rem      = len % num_core;

    int cur = si;

    for(int i = 0; i < num_core; ++i){
        int size = base + (i < rem ? 1 : 0);

        coresort_si.push_back(cur);
        coresort_ei.push_back(cur + size - 1);

        cur += size;
    }
}
void C_Framework_RTL::P_SliptSubArr(int N, int size_arr, int si, int ei, std::vector<int> &part_si, std::vector<int> &part_ei){
    part_si.clear();
    part_ei.clear();
    // root
    int num_core = 1 << N;
    int len      = ei - si + 1;
    int base     = len / num_core;

    int cur = si;

    for(int i = 0; i < num_core; ++i){
        part_si.push_back(cur);
        part_ei.push_back(size_arr);
        cur += base;
    }
}

void C_Framework_RTL::P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M, int S_cnt){
    if(S_cnt < (1 << (M-1))){
        int bi = P_Partition(arr, si, ei);
        std::cout << "PI_STANDARD = " << bi << std::endl;
        S_cnt++;
        P_Division(arr, si, bi, M, S_cnt);
        if((si == 0) || (ei == static_cast<int>(arr.size()) - 1)) {
            S_cnt = 1;
        }
        P_Division(arr, bi+1, ei, M, S_cnt);
    } else { // core-sort
        P_QuickSort(arr, si, ei);
        P_count_compare += C_Sort_Algor::Get_Count_Compare();
        P_count_swap    += C_Sort_Algor::Get_Count_Swap();
    }
}

void C_Framework_RTL::F_Framework_Serial_RTL(std::vector<SIZE_ARR_T> &arr, int M){
    int si = 0;
    int ei = arr.size() - 1;
    P_count_compare = 0;
    P_count_swap    = 0;
    int cnt = 0;
    P_Division(arr, si, ei, M, cnt);
}