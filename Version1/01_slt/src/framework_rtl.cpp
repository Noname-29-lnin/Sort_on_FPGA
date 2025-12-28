#include "../lib/frameworkd_rtl.hpp"

SIZE_TYPE_T C_Framework_RTL::P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    SIZE_TYPE_T t_sum = 0;
    for(int i =si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (SIZE_TYPE_T)(ei - si + 1);
    return t_div;
}

int C_Framework_RTL::P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei){
    SIZE_TYPE_T mean_value = P_Cal_Mean(arr, si, ei);
    // std::cout << "Mean_value = " << mean_value << std::endl;
    SIZE_ARR_T temp_partition = 0;
    SIZE_ARR_T temp_data = 0;
    int i  = si;
    int temp_i = 0;
    int pi = si;
    while (i <= ei){
        // std::cout << "I = " << i << std::endl;
        temp_i = i;
        temp_data = arr[temp_i];
        temp_partition = arr[pi];
        ++i;
        P_count_compare ++;
        if(temp_data < mean_value){
            arr[temp_i] = temp_partition;
            arr[pi] = temp_data;
            // std::cout << "I_next = " << i << std::endl;
            // if(i == ei-1) break; 
            ++pi;
            // std::cout << "PI_STANDARD_PRE = " << pi << std::endl;
        }
    }
    return pi-1;
}

void C_Framework_RTL::P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M, int S_cnt){
    if(si < ei){
        if(S_cnt < (1 << (M-1))){
            std::cout << "SI = " << si << " EI = " << ei << std::endl;
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
}

status_rtl_e C_Framework_RTL::P_SS_Check(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    bool is_Similar     = true;
    bool is_Acsending   = true;
    bool is_Decsending  = true;
    for(int i = si + 1; i <= ei; ++i){
        if(arr[i] != arr[i - 1]){
            is_Similar      = false;
        }
        if(arr[i] < arr[i - 1]){
            is_Acsending    = false;
        }
        if(arr[i] > arr[i - 1]){
            is_Decsending   = false;
        }
    }
    if(is_Similar){
        return RTL_SIMILAR;
    }
    else if(is_Acsending){
        return RTL_ACSENDING;
    }
    else if(is_Decsending){
        return RTL_DESCENDING;
    }
    else{
        return RTL_NORMAL;
    }
};

IndexType C_Framework_RTL::P_Partition_Iterative(std::vector<SIZE_ARR_T>& arr, IndexType si, IndexType ei, SIZE_TYPE_T mean_value) {
    IndexType pi = si;
    for (IndexType i = si; i <= ei; ++i) {
        // QUAN TRỌNG: So sánh trực tiếp với mean_value (float), không ép kiểu về int
        if (arr[i] < mean_value) {
            std::swap(arr[i], arr[pi]);
            pi++;
        }
    }
    // Trả về vị trí biên. Đảm bảo không trả về giá trị nhỏ hơn si
    return (pi > si) ? (pi - 1) : si; 
}
void C_Framework_RTL::P_Division_Iterative(std::vector<SIZE_ARR_T>& arr, int M) {
    std::vector<PartitionTask> stack_registers;
    if (!arr.empty()) {
        stack_registers.push_back({0, static_cast<IndexType>(arr.size()) - 1, 0});
    }
    while (!stack_registers.empty()) {
        PartitionTask task = stack_registers.back();
        stack_registers.pop_back();
        IndexType si = task.si;
        IndexType ei = task.ei;
        int current_level = task.level;
        if (si >= ei) continue;
        // --- CHECKER LOGIC ---
        // RTL_state = P_SS_Check(arr, si, ei);
        // if (RTL_state == RTL_SIMILAR) {
        //     P_count_is_Sim++;
        //     continue; 
        // }
        // else if (RTL_state == RTL_ACSENDING) {
        //     P_count_is_Asc++;
        //     continue;
        // }
        // else if (RTL_state == RTL_DESCENDING) {
        //     P_count_is_Desc++;
        //     std::reverse(arr.begin() + si, arr.begin() + ei + 1);
        //     continue;
        // }

        if (current_level < M) {
            SIZE_TYPE_T mean_val = P_Cal_Mean(arr, si, ei);
            IndexType bi = P_Partition_Iterative(arr, si, ei, mean_val);
            stack_registers.push_back({bi + 1, ei, current_level + 1});
            stack_registers.push_back({si, bi, current_level + 1});
        } else {
            F_QuickSort(arr, si, ei);
            P_count_compare += C_Sort_Algor::Get_Count_Compare();
            P_count_swap    += C_Sort_Algor::Get_Count_Swap();
        }
    }
}

void C_Framework_RTL::F_Framework_Serial_RTL(std::vector<SIZE_ARR_T> &arr, int M){
    // int si = 0;
    // int ei = arr.size() - 1;
    P_count_compare = 0;
    P_count_swap    = 0;
    // int cnt = 0;
    // P_Division(arr, si, ei, M, cnt);
    P_Division_Iterative(arr, M);
}