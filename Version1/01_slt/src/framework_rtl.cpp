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

// Status_e C_Framework_RTL::Check_SS(SIZE_ARR_T data_check, bool &is_Similar, bool &is_Ascending, bool &is_Descending){
//     if(P_data_check != data_check){
//         is_Similar      = false;
//         is_Ascending    = true;
//         is_Descending   = true;
//     } else if (P_data_check > data_check){
//         is_Similar      = true;
//         is_Ascending    = true;
//         is_Descending   = false;
//     } else {
//         is_Similar      = true;
//         is_Ascending    = false;
//         is_Descending   = true;
//     }
// }

SIZE_TYPE_T C_Framework_RTL::P_Cal_Mean(std::vector<SIZE_ARR_T> &arr, int si, int ei){
    // SIZE_TYPE_T temp_sum = 0;
    // SIZE_ARR_T  temp_read_data = 0;
    // // int         temp_count = 0;
    // bool        is_valid = false;
    // for(int i = si; i <= ei; i++){
    //     while (!is_valid){
    //         temp_read_data = ReadData(arr, i, true, is_valid);
    //     }
    //     temp_sum += temp_read_data;
    //     // temp_count ++;
    // }
    // // return temp_sum / temp_count;
    // return temp_sum / (ei-si+1);

    SIZE_TYPE_T t_sum = 0;
    for(int i =si; i <= ei; i++){
        t_sum += arr[i];
    }
    SIZE_TYPE_T t_div = 1;
    t_div = t_sum / (ei - si + 1);
    return t_div;
}

void C_Framework_RTL::P_Partition(std::vector<SIZE_TYPE_T> &arr, int si, int ei){
    SIZE_TYPE_T mean_value = P_Cal_Mean(arr, si, ei);
    mean_value = mean_value + mean_value*0.1;
    bool is_check;
    SIZE_ARR_T temp_partition = 0;
    SIZE_ARR_T temp_data = 0;
    int pi = si;
    // while(!is_check){
    //     temp_partition = ReadData(arr, pi, true, is_check);
    // }
    for(int i = si; i <= ei; i++){
        // while(!is_check){
        //     temp_data = ReadData(arr, i, true, is_check);
        // }
        P_count_compare ++;
        if(arr[i] < mean_value){
            std::swap(arr[i], arr[pi]);
            P_count_swap++;
            // while(!is_check){
            //     WriteData(arr, i, true , temp_partition, is_check);
            // }
            // while(!is_check){
            //     WriteData(arr, pi, true , temp_data, is_check);
            // }
            pi++;
            // while(!is_check){
            //     temp_partition = ReadData(arr, pi, true, is_check);
            // }
        }
    }
    std::cout <<"Addr_si = " << si << " Addr_ei = " << ei << " Addr_mean = " << pi - 1 << std::endl;
    std::cout << "Mean Value = " << mean_value << std::endl; 
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

void C_Framework_RTL::P_SliptSubArr(int N, int si, int ei, std::vector<int> &part_si, std::vector<int> &part_ei){
    part_si.clear();
    part_ei.clear();

    // root
    part_si.push_back(si);
    part_ei.push_back(ei);

    // tổng số node trong cây nhị phân đầy
    const int total_nodes = (1 << (N + 1)) - 1;

    for (int i = 0; i < total_nodes; ++i) {
        // nếu chưa đủ node thì mới sinh con
        if ((int)part_si.size() >= total_nodes)
            break;

        int l = part_si[i];
        int r = part_ei[i];

        if (l >= r) {
            // đoạn không thể chia nữa
            part_si.push_back(l);
            part_ei.push_back(r);
            part_si.push_back(l);
            part_ei.push_back(r);
            continue;
        }

        int mid = (l + r) / 2;

        // left child
        part_si.push_back(l);
        part_ei.push_back(mid);

        // right child
        part_si.push_back(mid + 1);
        part_ei.push_back(r);
    }
}


void C_Framework_RTL::P_Division(std::vector<SIZE_ARR_T>& arr, int si, int ei, int M)
{
    // int pi_0 = (si + ei) / 2;
    // int pi_1 = (si + pi_0) / 2;
    // int pi_2 = (pi_0 + 1 + ei) / 2;
    std::vector<int> part_si;
    std::vector<int> part_ei;
    P_SliptSubArr(M, si, ei, part_si, part_ei);
    for(auto index_si : part_si){
        std::cout <<" Part_si = " << index_si << " ";
    }
    std::cout << std::endl;
    for(auto index_ei : part_ei){
        std::cout <<" Part_ei = " << index_ei << " ";
    }
    std::cout << std::endl;

    // partition
    std::cout <<"Size_Part = " << part_si.size() << std::endl;
    for (size_t i = 0; i < part_si.size(); ++i) {
        if (part_si[i] <= part_ei[i]) {
            P_Partition(arr, part_si[i], part_ei[i]);
        }
    }

    // sort by subarrays
    // std::vector<int> coresort_si;
    // std::vector<int> coresort_ei;
    // P_SliptCoreSort((M+1), si, ei, coresort_si, coresort_ei);
    // for(auto index_si : coresort_si){
    //     std::cout <<" coresort_si = " << index_si << " ";
    // }
    // std::cout << std::endl;
    // for(auto index_ei : coresort_ei){
    //     std::cout <<" coresort_ei = " << index_ei << " ";
    // }
    // std::cout << std::endl;
    // for (size_t i = 0; i < coresort_si.size(); ++i) {
    //     if (coresort_si[i] <= coresort_ei[i]) {
    //         P_QuickSort(arr, coresort_si[i], coresort_ei[i]);
    //         // F_SelectionSort(arr, coresort_si[i], coresort_ei[i]);
    //         // std::sort(arr.begin() + coresort_si[i], arr.begin() + coresort_ei[i] + 1);
    //         P_count_compare += C_Sort_Algor::Get_Count_Compare();
    //         P_count_swap    += C_Sort_Algor::Get_Count_Swap();
    //     }
    // }
}

void C_Framework_RTL::F_Framework_Serial_RTL(std::vector<SIZE_ARR_T> &arr, int M){
    int si = 0;
    int ei = arr.size() - 1;
    P_count_compare = 0;
    P_count_swap    = 0;
    P_Division(arr, si, ei, M);
}