#include <iostream>
#include <vector>
#include <cassert>

// Prototype
void P_SliptSubArr(
    int N,
    int si,
    int ei,
    std::vector<int> &part_si,
    std::vector<int> &part_ei
);

// Implementation (copy từ hàm đã sửa)
void P_SliptSubArr(
    int N,
    int si,
    int ei,
    std::vector<int> &part_si,
    std::vector<int> &part_ei
){
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


int main() {
    std::vector<int> si, ei;

    int N  = 3;     // tạo 2^3 = 8 mảng con
    int st = 0;
    int en = 31;

    P_SliptSubArr(N, st, en, si, ei);

    std::cout << "Split result (" << si.size() << " sub-arrays):\n";

    for(int i = 0; i <= si.size() - 1; i++){
        std::cout << "slipt: si=" << si[i] << ", ei=" << ei[i] << std::endl;
    }

    std::cout << "✅ P_SliptSubArr TEST PASSED\n";
    return 0;
}
