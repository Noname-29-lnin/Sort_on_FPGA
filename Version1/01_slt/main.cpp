#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <thread>

#include "./lib/defines.hpp"
#include "./lib/framework_custom.hpp"
#include "./lib/framework_standard.hpp"
#include "./lib/verif.hpp"

/////////////////////////////////////////////////////////////////
// Function
/////////////////////////////////////////////////////////////////

#define PATH_UNSORTED_FILE      "./tools/unsorted.txt"
#define PATH_SORTED_FILE        "./Reports/COMPILE_REPORT/sorted.txt"

C_Framework_Serial C_framwork_standard;
C_Sort_Algor C_RTL_sort;

/////////////////////////////////////////////////////////////////
// MAIN
/////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
    std::vector<DATATPPE_ARR> arr;
    ReadDataToFile_DEC<DATATPPE_ARR>(PATH_UNSORTED_FILE, arr);

    std::cout << "Size of array: " << arr.size() << std::endl;
    
    std::vector<SortResult<size_t>> results;

    results.push_back({"Data Set", CheckSortedString<DATATPPE_ARR>(arr), 0, 0, 0, 0});

    C_Sort_Algor C_QuickSort;
    std::vector<DATATPPE_ARR> Data_QuickSort = arr;
    size_t Time_QuickSort =  V_CAL_MeasureTime([&]() {
                C_QuickSort.F_QuickSort(Data_QuickSort, 0, Data_QuickSort.size() - 1);
            });
    results.push_back({"QuickSort", CheckSortedString(Data_QuickSort), Time_QuickSort, C_QuickSort.Get_Count_Compare(), C_QuickSort.Get_Count_Swap(), 0});

    C_Framework_Serial C_Framework_QuickSort;
    std::vector<DATATPPE_ARR> Data_Framework_QuickSort = arr;
    int M_Framework_Serial = std::stoi(argv[1]);
    size_t Time_Framework_QuickSort =  V_CAL_MeasureTime([&]() {
                C_Framework_QuickSort.F_Framework_Serial(Data_Framework_QuickSort, M_Framework_Serial);
            });
    results.push_back({"Framework_QuickSort", CheckSortedString(Data_Framework_QuickSort), Time_Framework_QuickSort, C_Framework_QuickSort.Get_Count_Compare(), C_Framework_QuickSort.Get_Count_Swap(), 0});

    Print_Table_Result(results);

    WriteDataToFile_Dec<DATATPPE_ARR>(arr, PATH_SORTED_FILE);
    return 0;
}
