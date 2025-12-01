#include "../lib/framework_standard.hpp"

/*
    Func_Cal
*/
SIZE_TYPE_T C_Func_Cal::F_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    SIZE_TYPE_T t_sum = 0;
    for(int i =si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (ei - si + 1);
    return t_div;
}

void C_Func_Cal::F_Reverse_Array(std::vector<SIZE_ARR_T>& arr, int si, int ei){
    while(si < ei){ std::swap(arr[si++], arr[ei--]); }
}

/*
    Sort_Algo
*/
int C_Sort_Algor::P_QuickSort_Partition(std::vector<SIZE_ARR_T>& arr, int si, int ei) {
    int pivot   = arr[ei];
    int pi_pos  = si - 1;
    for (int j = si; j <= ei; ++j) {
        P_count_compare ++;
        if (arr[j] < pivot) {
            ++pi_pos;
            std::swap(arr[pi_pos], arr[j]);
            P_count_swap ++;
        }
    }
    std::swap(arr[pi_pos + 1], arr[ei]);
    return pi_pos + 1;
}
void C_Sort_Algor::P_QuickSort(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    if (si < ei) {
        int pi = P_QuickSort_Partition(arr, si, ei);
        P_QuickSort(arr, si, pi - 1);
        P_QuickSort(arr, pi + 1, ei);
    }
};
void C_Sort_Algor::F_QuickSort(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    P_count_compare = 0;
    P_count_swap    = 0;
    P_QuickSort(arr, si, ei);
};

void C_Sort_Algor::P_MergeSort_Merge(std::vector<SIZE_ARR_T>& arr, int left, int mid, int right){
    std::vector<SIZE_ARR_T> L(arr.begin() + left, arr.begin() + mid + 1);
    std::vector<SIZE_ARR_T> R(arr.begin() + mid + 1, arr.begin() + right + 1);
    size_t i = 0, j = 0, k = left;
    while(i < L.size() && j < R.size()){
        P_count_compare ++;
        if(L[i] <= R[j]) {
            arr[k++] = L[i++];
        }
        else {
            arr[k++] = R[j++];
        }
    }
    while(i < L.size()) arr[k++] = L[i++];
    while(j < R.size()) arr[k++] = R[j++];
}
void C_Sort_Algor::P_MergeSort(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    if(si < ei){
        size_t mid = (si + ei) / 2;
        P_MergeSort(arr, si, mid);
        P_MergeSort(arr, mid + 1, ei);
        P_MergeSort_Merge(arr, si, mid, ei);
    }
};
void C_Sort_Algor::F_MergeSort(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    P_count_compare = 0;
    P_count_swap    = 0;
    P_MergeSort(arr, si, ei);
};

/*
    Framework_Serial
*/
Status_e C_Framework_Serial::P_SS_Check(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    bool is_Similar     = true;
    bool is_Acsending   = true;
    bool is_Decsending  = true;
    for(int i = si + 1; i <= ei; ++i){
        if(arr[i] != arr[i - 1])    is_Similar      = false;
        if(arr[i] < arr[i - 1])     is_Acsending    = false;
        if(arr[i] > arr[i - 1])     is_Decsending   = false;
    }
    if(is_Similar){
        return SIMILAR;
    }
    else if(is_Acsending){
        return ACSENDING;
    }
    else if(is_Decsending){
        return DESCENDING;
    }
    else{
        return NORMAL;
    }
};

int C_Framework_Serial::P_Partition(std::vector<SIZE_ARR_T>& arr, int si, int ei){
    int bi = si;
    SIZE_TYPE_T mean = F_Cal_Mean(arr, si, ei);
    for(int i = si; i <= ei; i++){
        P_count_compare++;
        if(arr[i] <= mean){
            std::swap(arr[bi], arr[i]);
            bi = bi + 1;
            P_count_swap++;
        }
    }
    return bi - 1;
}
void C_Framework_Serial::P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M, int& S_cnt){
    if(si < ei){
        P_status = P_SS_Check(arr, si, ei);
        if(P_status == SIMILAR) {
            return;
        }
        else if(P_status == ACSENDING) {
            return;
        }
        else if(P_status == DESCENDING){
            F_Reverse_Array(arr, si, ei);
            return;
        }
        else {
            if(S_cnt < (1 << (M))){
                int bi = P_Partition(arr, si, ei);
                S_cnt++;
                P_Division(arr, si, bi, M, S_cnt);
                if((si == 0) || (ei == static_cast<int>(arr.size()) - 1)) {
                    S_cnt = 1;
                }
                P_Division(arr, bi+1, ei, M, S_cnt);
            } else { // core-sort
                // P_QuickSort(arr, si, ei);
                P_MergeSort(arr, si, ei);
                P_count_compare += C_Sort_Algor::Get_Count_Compare();
                P_count_swap    += C_Sort_Algor::Get_Count_Swap();

            }
        }
    }
};

void C_Framework_Serial::F_Framework_Serial(std::vector<SIZE_ARR_T> &arr, int M){
    int addr_si = 0;
    int addr_ei = arr.size() - 1;
    int cnt     = 0;
    P_count_compare = 0;
    P_count_swap    = 0;
    P_Division(arr, addr_si, addr_ei, M, cnt);
}
