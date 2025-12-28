#include <iostream>
#include <vector>
#include <numeric> // cho std::accumulate
#include <algorithm> // cho std::swap

// --- ĐỊNH NGHĨA KIỂU DỮ LIỆU ---
using DataType = float;      // Dữ liệu cần sắp xếp (Float)
using SumType  = double;     // Dữ liệu lớn hơn để chứa tổng tính Mean
using IndexType = int;       // Kiểu dữ liệu cho chỉ số (Index)

// Cấu trúc mô phỏng thanh ghi chứa thông tin tác vụ
struct PartitionTask {
    IndexType si;    // Start Index
    IndexType ei;    // End Index
    int level;       // Độ sâu hiện tại
};

class C_Framework_Iterative {
public:
    // Hàm Partition cho QuickSort (Chuẩn)
    IndexType P_QuickSort_Partition(std::vector<DataType>& arr, IndexType si, IndexType ei) {
        DataType pivot = arr[ei];
        IndexType pi_pos = si - 1;
        for (IndexType j = si; j < ei; ++j) {
            // So sánh float trực tiếp
            if (arr[j] < pivot) {
                ++pi_pos;
                std::swap(arr[pi_pos], arr[j]);
            }
        }
        std::swap(arr[pi_pos + 1], arr[ei]);
        return pi_pos + 1;
    }

    // Hàm QuickSort đệ quy (Core Sort)
    void P_QuickSort(std::vector<DataType> &arr, IndexType si, IndexType ei){
        if (si < ei) {
            IndexType pi = P_QuickSort_Partition(arr, si, ei);
            P_QuickSort(arr, si, pi - 1);
            P_QuickSort(arr, pi + 1, ei);
        }
    }

    // Hàm tính Mean
    DataType P_Cal_Mean(std::vector<DataType>& arr, IndexType si, IndexType ei) {
        if (si > ei) return 0;
        SumType sum = 0;
        for (IndexType k = si; k <= ei; ++k) {
            sum += arr[k];
        }
        return static_cast<DataType>(sum / (ei - si + 1));
    }

    // Hàm Partition dựa trên Mean (Framework)
    IndexType P_Partition(std::vector<DataType>& arr, IndexType si, IndexType ei, DataType mean_value) {
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

    // --- HÀM DIVISION PHIÊN BẢN ITERATIVE (DÙNG STACK) ---
    void P_Division_Iterative(std::vector<DataType>& arr, int M) {
        // 1. Khởi tạo Stack
        std::vector<PartitionTask> stack_registers;
        
        // 2. Nạp giá trị ban đầu
        if (!arr.empty()) {
            stack_registers.push_back({0, static_cast<IndexType>(arr.size()) - 1, 0});
        }

        // 3. Vòng lặp chính
        while (!stack_registers.empty()) {
            // A. Pop thanh ghi trên cùng
            PartitionTask task = stack_registers.back();
            stack_registers.pop_back();

            IndexType si = task.si;
            IndexType ei = task.ei;
            int current_level = task.level;

            // Kiểm tra điều kiện dừng
            if (si >= ei) continue;

            // B. Kiểm tra độ sâu
            if (current_level < M) {
                // --- BƯỚC 1: Tính Mean ---
                DataType mean_val = P_Cal_Mean(arr, si, ei);

                // --- BƯỚC 2: Partition ---
                IndexType bi = P_Partition(arr, si, ei, mean_val);
                
                // Debug: In ra quá trình chia nếu cần
                std::cout << "Level " << current_level << ": [" << si << ", " << ei 
                          << "] Mean=" << mean_val << " Split@" << bi << "\n";

                // --- BƯỚC 3: Push Task mới vào Stack ---
                // Push nhánh PHẢI trước, TRÁI sau (để xử lý trái trước)
                stack_registers.push_back({bi + 1, ei, current_level + 1});
                stack_registers.push_back({si, bi, current_level + 1});

            } else {
                // C. Core-Sort (QuickSort)
                std::cout << "SORT: si="<< si << " ei=" << ei << std::endl;
                P_QuickSort(arr, si, ei);
            }
        }
    }
};

int main() {
    // Test với dữ liệu số thực (float)
    std::vector<DataType> data = {
        12.5f, 7.2f, 14.1f, 9.9f, 10.0f, 11.5f, 
        2.1f, 5.5f, 8.8f, 1.0f, 3.3f, 15.2f, 
        6.6f, 4.4f, 13.7f, 0.0f, 12.5f, 7.2f, 14.1f, 9.9f, 10.0f, 11.5f, 
        2.1f, 5.5f, 8.8f, 1.0f, 1103.3f, 15.2f, 
        6.6f, 4.4f, 13.7f, 0.0f
    };
    
    std::cout << "Before: ";
    for(const auto& v : data) std::cout << v << " ";
    std::cout << "\n";

    C_Framework_Iterative framework;
    
    // M = 3 -> Chia thành 8 mảng con rồi sort
    framework.P_Division_Iterative(data, 4);
    
    std::cout << "After : ";
    for(const auto& v : data) std::cout << v << " ";
    std::cout << "\n";

    return 0;
}