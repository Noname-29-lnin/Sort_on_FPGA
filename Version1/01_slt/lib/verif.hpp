#ifndef VERIF_H
#define VERIF_H

#include <iostream>
#include <vector>
#include <chrono>
#include <functional>
#include <algorithm>
#include <iomanip>
#include <fstream>
#include <string>
#include <cstdint>
#include <cstring>

class Verfi_CalTime_c {
    protected:
        template <typename Func>
        long long MeasureTime(Func func) {
            auto start = std::chrono::high_resolution_clock::now();
            func();
            auto end = std::chrono::high_resolution_clock::now();
            return std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
        }
};

template<typename Func>
size_t V_CAL_MeasureTime(Func func) {
    auto start = std::chrono::high_resolution_clock::now();
    func();
    auto end = std::chrono::high_resolution_clock::now();
    return std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
}

template <typename SIZE_ARR_T>
std::string CheckSortedString(const std::vector<SIZE_ARR_T>& arr){
    // return std::is_sorted(arr.begin(), arr.end()) ? "PASS" : "FAIL";
    for(size_t i = 1; i < arr.size(); ++i){
        if(arr[i] + 0.000000001 < arr[i-1]) // cho phép chênh nhỏ
            return "FAIL";
    }
    return "PASS";
}

template <typename SIZE_TYPE_T>
struct SortResult {
    std::string algorithm_name;
    std::string check_sorted;
    SIZE_TYPE_T time_run;
    SIZE_TYPE_T count_swap;
    SIZE_TYPE_T count_compare;
    SIZE_TYPE_T count_auxiliary_space;
};

template <typename SIZE_TYPE_T>
void Print_Table_Result(const std::vector<SortResult<SIZE_TYPE_T>>& results) {
    std::cout << std::endl;
    std::cout << std::left << std::setw(30) << "Sort algorithm "
              << std::setw(15) << "Check sorted"
              << std::setw(20) << "Time (ns)"
              << std::setw(20) << "Number Swap" 
              << std::setw(20) << "Number Compare"
              << std::setw(20) << "Auxiliary Space (Bytes)"  << std::endl; 

    std::cout << std::string(125, '-') << std::endl;

    for (const auto& res : results) {
        std::cout << std::left << std::setw(30) << res.algorithm_name
                  << std::setw(15) << res.check_sorted
                  << std::setw(20) << res.time_run
                  << std::setw(20) << res.count_swap 
                  << std::setw(20) << res.count_compare 
                  << std::setw(20) << res.count_auxiliary_space 
                  << std::endl;
        std::cout << std::string(125, '-') << std::endl;
    }
}

inline float Convert_FP(const uint32_t data) {
    float result;
    std::memcpy(&result, &data, sizeof(float));
    return result;
}

template <typename SIZE_ARR_T>
void WriteDataToFile_Dec(const std::vector<SIZE_ARR_T>& vec, const std::string& filename) {
    std::ofstream outFile(filename); // Mở file để ghi

    if (!outFile.is_open()) {
        std::cerr << "Error: Can't open file '" << filename << std::endl;
        return;
    }

    for (const auto& val : vec) {
        outFile << val << "\n"; // Mỗi phần tử ghi trên một dòng
    }

    outFile.close();
    std::cout << "Finish write file '" << filename << "'.\n";
}

template <typename SIZE_ARR_T>
void WriteDataToFile_Hex(const std::vector<SIZE_ARR_T>& vec, const std::string& filename) {
    std::ofstream outFile(filename);

    if (!outFile.is_open()) {
        std::cerr << "Error: Can't open file '" << filename << "'\n";
        return;
    }

    for (const auto& val : vec) {
        std::ios oldState(nullptr);
        oldState.copyfmt(outFile);

        outFile << "0x"
                << std::uppercase
                << std::setfill('0')
                << std::setw(8)
                << std::hex
                << static_cast<uint32_t>(val);
        outFile.copyfmt(oldState);
        outFile << "  =>  "
                << std::fixed << std::setprecision(6)
                << Convert_FP(static_cast<uint32_t>(val))
                << "\n";
    }

    outFile.close();
    std::cout << "Finish write HEX file: '" << filename << "'\n";
}

template <typename SIZE_TYPE_T>
void ReadDataToFile_HEX(const std::string& filename, std::vector<SIZE_TYPE_T> &arr) {
    std::ifstream file(filename);
    SIZE_TYPE_T number;
    if (file.is_open()) {
        while (file >> std::hex >> number) {
            arr.push_back(number);
        }
        file.close();
    } else {
        std::cerr << "Cannot open file: " << filename << std::endl;
        return;
    }
    printf("Finished read file: %s\n", filename.c_str());
}

template <typename SIZE_TYPE_T>
void ReadDataToFile_DEC(const std::string& filename, std::vector<SIZE_TYPE_T> &arr) {
    std::ifstream file(filename);
    SIZE_TYPE_T number;

    if (file.is_open()) {
        while (file >> number) {
            arr.push_back(number);
        }
        file.close();
    } else {
        std::cerr << "Cannot open file: " << filename << std::endl;
        return;
    }

    printf("Finished reading file: %s\n", filename.c_str());
}

#endif // VERIF_H
