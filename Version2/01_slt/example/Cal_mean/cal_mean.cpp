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
#define SIZE_TYPE_T   float
#define PATH_UNSORTED_FILE      "./../01_slt/tools/unsorted.txt"
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

int main(){
    std::vector<SIZE_TYPE_T> arr;
    ReadDataToFile_DEC(PATH_UNSORTED_FILE, arr);

    SIZE_TYPE_T temp_sum = 0;
    SIZE_TYPE_T temp_divisor = arr.size();
    SIZE_TYPE_T temp_mean = 0;
    for(int i = 0; i < arr.size(); i++){
        temp_sum += arr[i];
    }
    temp_mean = temp_sum / temp_divisor;
    std::cout << "mean = " << temp_mean << std::endl;

    return 0;
}