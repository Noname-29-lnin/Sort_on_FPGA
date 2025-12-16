#include <iostream>
#include <vector>

/*
 * Chia đoạn [si, ei] thành 2^N đoạn con gần bằng nhau
 */
void P_SliptCoreSort(
    int N,
    int si,
    int ei,
    std::vector<int> &coresort_si,
    std::vector<int> &coresort_ei
){
    coresort_si.clear();
    coresort_ei.clear();

    int num_core = 1 << N;          // số đoạn = 2^N
    int len      = ei - si + 1;     // tổng số phần tử
    int base     = len / num_core;  // kích thước cơ bản
    int rem      = len % num_core;  // phần dư

    int cur = si;

    for(int i = 0; i < num_core; ++i){
        int size = base + (i < rem ? 1 : 0);

        coresort_si.push_back(cur);
        coresort_ei.push_back(cur + size - 1);

        cur += size;
    }
}

int main(){
    int N  = 2;     // chia thành 2^2 = 4 đoạn
    int si = 0;     // chỉ số bắt đầu
    int ei = 15;    // chỉ số kết thúc

    std::vector<int> coresort_si;
    std::vector<int> coresort_ei;

    P_SliptCoreSort(N, si, ei, coresort_si, coresort_ei);

    std::cout << "Chia doan [" << si << ", " << ei << "] thanh "
              << (1 << N) << " doan:\n";

    for(size_t i = 0; i < coresort_si.size(); ++i){
        std::cout << "Core " << i
                  << ": [" << coresort_si[i]
                  << ", " << coresort_ei[i] << "]\n";
    }

    return 0;
}
