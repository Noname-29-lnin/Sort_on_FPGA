#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <chrono>
#include <thread>

#include "./lib/defines.hpp"
#include "./lib/framework_custom.hpp"
#include "./lib/framework_standard.hpp"
#include "./lib/frameworkd_rtl.hpp"
#include "./lib/verif.hpp"

/////////////////////////////////////////////////////////////////
// Function
/////////////////////////////////////////////////////////////////

#define PATH_UNSORTED_FILE      "./tools/unsorted.txt"
#define PATH_UNSORTED_READ      "./Reports/COMPILE_REPORT/unsorted.txt"
#define PATH_SORTED_FILE        "./Reports/COMPILE_REPORT/sorted.txt"
#define PATH_SORTED_FILE_1      "./Reports/COMPILE_REPORT/sorted_RTL.txt"

C_Framework_Serial C_framwork_standard;
C_Sort_Algor C_RTL_sort;
C_Framework_RTL c_test;

/////////////////////////////////////////////////////////////////
// MAIN
/////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
    std::vector<DATATPPE_ARR> arr;
    ReadDataToFile_DEC<DATATPPE_ARR>(PATH_UNSORTED_FILE, arr);
    WriteDataToFile_Dec<DATATPPE_ARR>(arr, PATH_UNSORTED_READ);
    std::cout << "Size of array: " << arr.size() << std::endl;
    std::vector<SortResult<size_t>> results;
    results.push_back({"Data Set", CheckSortedString<DATATPPE_ARR>(arr), 0, 0, 0});

    // std::vector<DATATPPE_ARR> data_set = arr;
    // size_t Time_Standard =  V_CAL_MeasureTime([&]() {
    //     std::sort(data_set.begin(), data_set.end());
    // });
    // results.push_back({"Sort Standard", CheckSortedString<DATATPPE_ARR>(data_set), Time_Standard, 0, 0});
    // WriteDataToFile_Dec<DATATPPE_ARR>(data_set, PATH_SORTED_FILE);

    // C_Sort_Algor C_QuickSort;
    // std::vector<DATATPPE_ARR> Data_QuickSort = arr;
    // size_t Time_QuickSort =  V_CAL_MeasureTime([&]() {
    //             C_QuickSort.F_QuickSort(Data_QuickSort, 0, Data_QuickSort.size() - 1);
    //         });
    // results.push_back({"QuickSort", CheckSortedString(Data_QuickSort), Time_QuickSort, C_QuickSort.Get_Count_Compare(), C_QuickSort.Get_Count_Swap()});
    int M_Framework_Serial = std::stoi(argv[1]);
    C_Framework_Serial C_Framework_QuickSort;
    std::vector<DATATPPE_ARR> Data_Framework_QuickSort = arr;
    std::cout << "Number subarry M = " << M_Framework_Serial << std::endl;
    size_t Time_Framework_QuickSort =  V_CAL_MeasureTime([&]() {
        C_Framework_QuickSort.F_Frameworkd_Serial_Quick(Data_Framework_QuickSort, M_Framework_Serial);
    });
    results.push_back({"Framework_QuickSort", CheckSortedString(Data_Framework_QuickSort), Time_Framework_QuickSort, C_Framework_QuickSort.Get_Count_Compare(), C_Framework_QuickSort.Get_Count_Swap()});
    std::cout << "[FrameworkStandard_Quick] Number of Similar = " << C_Framework_QuickSort.Get_Count_Similar() << std::endl;
    std::cout << "[FrameworkStandard_Quick] Number of Ascending = " << C_Framework_QuickSort.Get_Count_Ascending() << std::endl;
    std::cout << "[FrameworkStandard_Quick] Number of Descending = " << C_Framework_QuickSort.Get_Count_Descending() << std::endl;
    //
    // C_Sort_Algor C_Merge;
    // std::vector<DATATPPE_ARR> Data_MergeSort = arr;
    // size_t Time_Merge =  V_CAL_MeasureTime([&]() {
    //             C_Merge.F_QuickSort(Data_MergeSort, 0, Data_MergeSort.size() - 1);
    //         });
    // results.push_back({"MergeSort", CheckSortedString(Data_MergeSort), Time_Merge, C_Merge.Get_Count_Compare(), C_Merge.Get_Count_Swap()});
    // std::vector<DATATPPE_ARR> Data_Framework_Merge = arr;
    // size_t Time_Framework_Merge =  V_CAL_MeasureTime([&]() {
    //     C_Framework_QuickSort.F_Frameworkd_Serial_Merge(Data_Framework_Merge, M_Framework_Serial);
    // });
    // results.push_back({"Framework_Merge", CheckSortedString(Data_Framework_Merge), Time_Framework_Merge, C_Framework_QuickSort.Get_Count_Compare(), C_Framework_QuickSort.Get_Count_Swap()});
    // std::cout << "[FrameworkStandard_Merge] Number of Similar = " << C_Framework_QuickSort.Get_Count_Similar() << std::endl;
    // std::cout << "[FrameworkStandard_Merge] Number of Ascending = " << C_Framework_QuickSort.Get_Count_Ascending() << std::endl;
    // std::cout << "[FrameworkStandard_Merge] Number of Descending = " << C_Framework_QuickSort.Get_Count_Descending() << std::endl;

    // std::vector<DATATPPE_ARR> Data_test = arr;
    // size_t Time_Framework_test =  V_CAL_MeasureTime([&]() {
    //             c_test.F_Framework_Serial_RTL(Data_test, M_Framework_Serial);
    //         });
    // results.push_back({"Data Test", CheckSortedString<DATATPPE_ARR>(Data_test), Time_Framework_test, c_test.Get_Count_Compare(), c_test.Get_Count_Swap()});
    // WriteDataToFile_Dec<DATATPPE_ARR>(Data_test, PATH_SORTED_FILE_1);
    
    Print_Table_Result(results);

    return 0;
}
