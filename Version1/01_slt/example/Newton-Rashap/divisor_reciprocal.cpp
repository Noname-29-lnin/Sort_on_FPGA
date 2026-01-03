// // // #include <iostream>
// // // #include <cmath>
// // // #include <cstdint>

// // // // Phiên bản 1: Newton-Raphson với số lần lặp cố định
// // // float Newton_Raphson_Fixed_Iterations(float a) {
// // //     // Kiểm tra trường hợp đặc biệt
// // //     if (a == 0.0f) return INFINITY;  // Chia cho 0
// // //     if (std::isnan(a)) return NAN;   // NaN
// // //     if (std::isinf(a)) return 0.0f;  // 1/inf = 0
    
// // //     // Ước lượng ban đầu (initial guess) quan trọng!
// // //     // Dùng bit manipulation để có ước lượng tốt
// // //     uint32_t a_bits = *reinterpret_cast<uint32_t*>(&a);
    
// // //     // Magic number cho ước lượng nghịch đảo
// // //     uint32_t magic = 0x7EF4A7C3;  // ≈ 1.0 trong floating point trick
    
// // //     // Tính xấp xỉ ban đầu
// // //     uint32_t guess_bits = magic - (a_bits >> 1);
// // //     float x = *reinterpret_cast<float*>(&guess_bits);
    
// // //     // Số lần lặp Newton-Raphson
// // //     const int iterations = 3;
    
// // //     // Công thức Newton-Raphson: x_{n+1} = x_n * (2 - a * x_n)
// // //     for (int i = 0; i < iterations; i++) {
// // //         x = x * (2.0f - a * x);
// // //     }
    
// // //     return x;
// // // }

// // // // Phiên bản 2: Newton-Raphson với kiểm tra hội tụ
// // // float Newton_Raphson_With_Convergence(float a, float tolerance = 1e-6f, int max_iterations = 10) {
// // //     if (a == 0.0f) return INFINITY;
// // //     if (std::isnan(a)) return NAN;
// // //     if (std::isinf(a)) return 0.0f;
    
// // //     // Ước lượng ban đầu tốt hơn cho phạm vi rộng
// // //     float x;
// // //     if (std::abs(a) < 1e-10f) {
// // //         x = 1e10f;  // Xử lý số rất nhỏ
// // //     } else {
// // //         // Ước lượng dựa trên exponent
// // //         int exponent;
// // //         float mantissa = std::frexp(a, &exponent);
// // //         x = std::ldexp(1.0f / mantissa, -exponent);
        
// // //         // Hoặc đơn giản hơn:
// // //         // x = 1.0f / a;  // Dùng 1 lần chia để khởi tạo (không tối ưu)
// // //     }
    
// // //     for (int i = 0; i < max_iterations; i++) {
// // //         float prev_x = x;
// // //         x = x * (2.0f - a * x);
        
// // //         // Kiểm tra hội tụ
// // //         if (std::abs(x - prev_x) < tolerance * std::abs(x)) {
// // //             std::cout << "Hoi tu sau " << i + 1 << " lan lap\n";
// // //             break;
// // //         }
// // //     }
    
// // //     return x;
// // // }

// // // // Phiên bản 3: Fast inverse sử dụng bit manipulation (gần đúng)
// // // float Fast_Inverse_Approx(float a) {
// // //     if (a == 0.0f) return INFINITY;
    
// // //     // Chuyển float sang int để thao tác bit
// // //     uint32_t i = *reinterpret_cast<uint32_t*>(&a);
    
// // //     // Hằng số magic (điều chỉnh cho nghịch đảo, không phải nghịch đảo căn bậc 2)
// // //     // Magic = 0x7F000000 - (i >> 1);
// // //     uint32_t magic = 0x7EF4A7C3;  // Tối ưu cho phạm vi [1, 100]
    
// // //     i = magic - (i >> 1);
    
// // //     // Chuyển ngược lại float
// // //     float result = *reinterpret_cast<float*>(&i);
    
// // //     // Một bước Newton-Raphson để tăng độ chính xác
// // //     result = result * (2.0f - a * result);
    
// // //     return result;
// // // }

// // // int main() {
// // //     float a;
// // //     std::cout << "Input data (Float): ";
// // //     std::cin >> a;
    
// // //     std::cout << std::fixed;
// // //     std::cout.precision(10);
    
// // //     std::cout << "\n[Expected] 1/a = " << (float)1/a << std::endl;
// // //     std::cout << "[Fixed Iterations] 1/a = " << Newton_Raphson_Fixed_Iterations(a) << std::endl;
// // //     std::cout << "[With Convergence] 1/a = " << Newton_Raphson_With_Convergence(a) << std::endl;
// // //     std::cout << "[Fast Approx] 1/a = " << Fast_Inverse_Approx(a) << std::endl;
    
// // //     // Tính sai số
// // //     float expected = 1.0f / a;
// // //     float computed = Newton_Raphson_Fixed_Iterations(a);
// // //     float error = std::abs(computed - expected) / expected;
    
// // //     std::cout << "\nSai so tuong doi: " << error * 100 << "%\n";
    
// // //     return 0;
// // // }
// // #include <iostream>
// // #include <cmath>

// // float reciprocal_using_newton(float a) {
// //     // Bước 1: Ước lượng ban đầu
// //     // Có thể dùng 1.0 cho a ~ 1, nhưng không tốt cho mọi giá trị
// //     // Ta dùng ước lượng: x0 = 1.0 / a (tính xấp xỉ)
    
// //     float x;
// //     if (a >= 0.5f && a <= 2.0f) {
// //         x = 1.0f;  // Nếu a gần 1
// //     } else if (a > 2.0f) {
// //         x = 1.0f / (a * 0.5f);  // Ước lượng thô
// //     } else {
// //         x = 2.0f;  // Cho a nhỏ
// //     }
    
// //     std::cout << "Uoc luong ban dau: " << x << std::endl;
    
// //     // Bước 2: Lặp Newton-Raphson
// //     for (int i = 0; i < 5; i++) {
// //         float ax = a * x;           // a * x_n
// //         float two_minus_ax = 2.0f - ax;  // 2 - a*x_n
// //         x = x * two_minus_ax;       // x_{n+1} = x_n * (2 - a*x_n)
        
// //         std::cout << "Lan lap " << i+1 << ": x = " << x 
// //                   << ", a*x = " << ax << std::endl;
// //     }
    
// //     return x;
// // }

// // int main() {
// //     std::cout << "=== TINH NGHICH DAO KHONG DUNG PHEP CHIA ===\n";
    
// //     float a;
// //     std::cout << "Nhap so a: ";
// //     std::cin >> a;
    
// //     if (a == 0) {
// //         std::cout << "Khong the chia cho 0!\n";
// //         return 1;
// //     }
    
// //     // Tính bằng phép chia thông thường
// //     float exact_result = 1.0f / a;
    
// //     // Tính bằng Newton-Raphson
// //     float newton_result = reciprocal_using_newton(a);
    
// //     std::cout << "\nKET QUA:\n";
// //     std::cout << "Chia truc tiep: 1/" << a << " = " << exact_result << std::endl;
// //     std::cout << "Newton-Raphson: 1/" << a << " = " << newton_result << std::endl;
    
// //     // Tính sai số
// //     float error = std::abs(newton_result - exact_result) / exact_result * 100;
// //     std::cout << "Sai so: " << error << "%\n";
    
// //     // Kiểm tra bằng nhân lại
// //     float check = a * newton_result;
// //     std::cout << "Kiem tra: " << a << " * " << newton_result 
// //               << " = " << check << " (gan bang 1)\n";
    
// //     return 0;
// // }
// #include <iostream>
// #include <cmath>
// #include <cstdint>
// #include <bitset>
// #include <iomanip>

// // Cấu trúc để phân tích IEEE 754 32-bit
// struct IEEE754_Float {
//     union {
//         float value;
//         uint32_t bits;
//         struct {
//             uint32_t mantissa : 23;  // 23 bit phần mantissa
//             uint32_t exponent : 8;   // 8 bit exponent
//             uint32_t sign : 1;       // 1 bit dấu
//         } parts;
//     };
    
//     IEEE754_Float(float val) : value(val) {}
    
//     void print_analysis() {
//         std::cout << "\n╔════════════════════════════════════════════════════════╗\n";
//         std::cout << "║        PHÂN TÍCH IEEE 754 FLOATING POINT 32-BIT       ║\n";
//         std::cout << "╚════════════════════════════════════════════════════════╝\n";
        
//         std::cout << "\nGiá trị: " << value << std::endl;
        
//         // Hiển thị dạng bit
//         std::cout << "\n┌─ Biểu diễn nhị phân (32 bit) ─┐\n";
//         std::bitset<32> bit_repr(bits);
//         std::cout << "│ " << bit_repr << " │\n";
//         std::cout << "└────────────────────────────────┘\n";
        
//         // Phân tích từng thành phần
//         std::cout << "\n┌─ Phân tích các trường ─────────────────────────┐\n";
//         std::cout << "│ [Bit 31]     Sign:     " << parts.sign 
//                   << " (" << (parts.sign ? "âm" : "dương") << ")\n";
//         std::cout << "│ [Bit 30-23]  Exponent: " << std::bitset<8>(parts.exponent) 
//                   << " = " << parts.exponent << " (decimal)\n";
//         std::cout << "│ [Bit 22-0]   Mantissa: " << std::bitset<23>(parts.mantissa) << "\n";
//         std::cout << "└────────────────────────────────────────────────┘\n";
        
//         // Tính toán giá trị thực
//         if (parts.exponent == 0) {
//             if (parts.mantissa == 0) {
//                 std::cout << "\n➤ Số 0 (Zero)\n";
//             } else {
//                 std::cout << "\n➤ Số denormalized (subnormal)\n";
//             }
//         } else if (parts.exponent == 255) {
//             if (parts.mantissa == 0) {
//                 std::cout << "\n➤ Infinity (" << (parts.sign ? "-∞" : "+∞") << ")\n";
//             } else {
//                 std::cout << "\n➤ NaN (Not a Number)\n";
//             }
//         } else {
//             // Số chuẩn hóa
//             int exp_unbiased = parts.exponent - 127;
//             float mantissa_value = 1.0f + (float)parts.mantissa / (1 << 23);
            
//             std::cout << "\n┌─ Tính toán giá trị ───────────────────────────┐\n";
//             std::cout << "│ Exponent bias:     127\n";
//             std::cout << "│ Exponent unbiased: " << parts.exponent << " - 127 = " 
//                       << exp_unbiased << "\n";
//             std::cout << "│ Mantissa (1.f):    1." << std::fixed << std::setprecision(6)
//                       << (mantissa_value - 1.0f) << " ≈ " << mantissa_value << "\n";
//             std::cout << "│\n";
//             std::cout << "│ Công thức: (-1)^sign × mantissa × 2^exponent\n";
//             std::cout << "│          = (-1)^" << parts.sign 
//                       << " × " << mantissa_value 
//                       << " × 2^" << exp_unbiased << "\n";
//             std::cout << "│          = " << value << "\n";
//             std::cout << "└────────────────────────────────────────────────┘\n";
//         }
//     }
// };

// // Newton-Raphson để tính nghịch đảo
// float reciprocal_newton_raphson(float a, int iterations = 5) {
//     // Ước lượng ban đầu thông minh
//     float x;
//     if (std::abs(a) >= 0.5f && std::abs(a) <= 2.0f) {
//         x = 1.0f;
//     } else if (std::abs(a) > 2.0f) {
//         x = 0.5f / a;
//     } else {
//         x = 2.0f;
//     }
    
//     std::cout << "\n┌─ Quá trình Newton-Raphson ────────────────────┐\n";
//     std::cout << "│ Ước lượng ban đầu x₀ = " << x << "\n│\n";
    
//     // Lặp Newton-Raphson: x_{n+1} = x_n * (2 - a*x_n)
//     for (int i = 0; i < iterations; i++) {
//         float ax = a * x;
//         float correction = 2.0f - ax;
//         x = x * correction;
        
//         std::cout << "│ Bước " << (i+1) << ": x = " << std::setw(12) << x 
//                   << ", a×x = " << std::setw(12) << ax 
//                   << ", error = " << std::setw(12) << (1.0f - ax) << "\n";
//     }
//     std::cout << "└────────────────────────────────────────────────┘\n";
    
//     return x;
// }

// // Fast inverse sử dụng bit magic (Quake III algorithm - adapted)
// float fast_inverse_approx(float a) {
//     IEEE754_Float num(a);
    
//     // Magic constant cho nghịch đảo
//     const uint32_t magic = 0x7EF311C3;
    
//     uint32_t i = num.bits;
//     i = magic - (i >> 1);  // Bit hack cho ước lượng
    
//     float x = *reinterpret_cast<float*>(&i);
    
//     std::cout << "\n┌─ Fast Inverse với Bit Magic ─────────────────┐\n";
//     std::cout << "│ Magic constant: 0x" << std::hex << magic << std::dec << "\n";
//     std::cout << "│ Ước lượng ban đầu: " << x << "\n";
    
//     // Một bước Newton-Raphson để cải thiện
//     x = x * (2.0f - a * x);
//     std::cout << "│ Sau 1 bước NR: " << x << "\n";
//     std::cout << "└────────────────────────────────────────────────┘\n";
    
//     return x;
// }

// int main() {
//     std::cout << "╔═══════════════════════════════════════════════════════════╗\n";
//     std::cout << "║  TÍNH NGHỊCH ĐẢO & PHÂN TÍCH IEEE 754 FLOATING POINT     ║\n";
//     std::cout << "╚═══════════════════════════════════════════════════════════╝\n";
    
//     float a;
//     std::cout << "\n➤ Nhập số a: ";
//     std::cin >> a;
    
//     if (a == 0.0f) {
//         std::cout << "\n⚠ Không thể tính nghịch đảo của 0!\n";
//         return 1;
//     }
    
//     // Phân tích số nhập vào
//     IEEE754_Float input(a);
//     input.print_analysis();
    
//     // Tính nghịch đảo bằng nhiều phương pháp
//     std::cout << "\n\n╔═══════════════════════════════════════════════════════════╗\n";
//     std::cout << "║                   TÍNH NGHỊCH ĐẢO 1/a                     ║\n";
//     std::cout << "╚═══════════════════════════════════════════════════════════╝\n";
    
//     float exact = 1.0f / a;
//     float newton = reciprocal_newton_raphson(a, 5);
//     float fast = fast_inverse_approx(a);
    
//     // So sánh kết quả
//     std::cout << "\n\n┌─ KẾT QUẢ SO SÁNH ───────────────────────────────────┐\n";
//     std::cout << std::fixed << std::setprecision(10);
//     std::cout << "│ Phép chia trực tiếp:  " << std::setw(20) << exact << " │\n";
//     std::cout << "│ Newton-Raphson:       " << std::setw(20) << newton << " │\n";
//     std::cout << "│ Fast Approx + NR:     " << std::setw(20) << fast << " │\n";
//     std::cout << "├──────────────────────────────────────────────────────────┤\n";
    
//     float error_newton = std::abs(newton - exact) / std::abs(exact) * 100;
//     float error_fast = std::abs(fast - exact) / std::abs(exact) * 100;
    
//     std::cout << "│ Sai số Newton-Raphson: " << std::setw(18) << error_newton << " % │\n";
//     std::cout << "│ Sai số Fast Approx:    " << std::setw(18) << error_fast << " % │\n";
//     std::cout << "└──────────────────────────────────────────────────────────┘\n";
    
//     // Phân tích kết quả nghịch đảo
//     std::cout << "\n\n";
//     IEEE754_Float result(newton);
//     result.print_analysis();
    
//     // Kiểm tra tính đúng đắn
//     std::cout << "\n\n┌─ KIỂM TRA ───────────────────────────────────────────┐\n";
//     float check = a * newton;
//     std::cout << "│ a × (1/a) = " << a << " × " << newton << " = " << check << "\n";
//     std::cout << "│ (Kết quả phải xấp xỉ 1.0)\n";
//     std::cout << "└──────────────────────────────────────────────────────┘\n";
    
//     return 0;
// }

#include <iostream>
#include <cmath>
#include <cstdint>
#include <limits>

// Phiên bản FIXED: Tránh overflow và cải thiện ước lượng ban đầu
float reciprocal_newton_fixed(float a) {
    if (a == 0.0f) return std::numeric_limits<float>::infinity();
    if (std::isnan(a)) return std::nanf("");
    if (std::isinf(a)) return 0.0f;
    
    // Xử lý dấu
    bool negative = false;
    if (a < 0) {
        negative = true;
        a = -a;
    }
    
    // QUAN TRỌNG: Scale a về khoảng [0.5, 1) để tính toán ổn định
    int exponent;
    float mantissa = std::frexp(a, &exponent);  // a = mantissa * 2^exponent, mantissa ∈ [0.5, 1)
    
    // Ước lượng ban đầu CHO mantissa (trong [0.5, 1))
    // Với mantissa ∈ [0.5, 1), 1/mantissa ∈ [1, 2)
    float x;
    if (mantissa >= 0.5f && mantissa < 0.625f) {
        x = 1.8f;  // ~1/0.56
    } else if (mantissa >= 0.625f && mantissa < 0.75f) {
        x = 1.6f;  // ~1/0.625
    } else if (mantissa >= 0.75f && mantissa < 0.875f) {
        x = 1.4f;  // ~1/0.75
    } else {
        x = 1.2f;  // ~1/0.875
    }
    
    // Newton-Raphson CHO mantissa
    for (int i = 0; i < 4; i++) {
        float product = mantissa * x;
        // TRÁNH OVERFLOW: kiểm tra product
        if (product >= 2.0f) {
            x *= 0.5f;  // Giảm x nếu product quá lớn
        } else {
            x = x * (2.0f - product);
        }
    }
    
    // Kết quả cho mantissa: x ≈ 1/mantissa
    // Điều chỉnh cho exponent: 1/a = 1/(mantissa * 2^exponent) = x * 2^(-exponent)
    float result = std::ldexp(x, -exponent);
    
    if (negative) result = -result;
    return result;
}

// Phiên bản dùng bit manipulation (ổn định hơn)
float reciprocal_bit_manipulation(float a) {
    union {
        float f;
        uint32_t i;
    } u;
    
    u.f = a;
    
    // Xử lý trường hợp đặc biệt
    if (u.i == 0) return std::numeric_limits<float>::infinity();  // a = 0
    if ((u.i & 0x7FFFFFFF) > 0x7F800000) return std::nanf("");   // NaN
    if ((u.i & 0x7FFFFFFF) == 0x7F800000) {  // Inf
        if (u.i & 0x80000000) return -0.0f;  // -Inf
        return 0.0f;                         // +Inf
    }
    
    // Tách sign, exponent, mantissa
    uint32_t sign = u.i & 0x80000000;
    int32_t exponent = ((u.i >> 23) & 0xFF) - 127;
    uint32_t mantissa = u.i & 0x007FFFFF;
    
    // Ước lượng: 1/a = 2^{-exponent-1} * (1/ mantissa_norm)
    // với mantissa_norm = 1.mantissa (trong [1, 2))
    
    // Tính nghịch đảo mantissa dùng Newton-Raphson
    float m_norm = 1.0f + (float)mantissa / (float)(1 << 23);
    float x_m = 1.0f;  // Ước lượng ban đầu cho 1/m_norm
    
    for (int i = 0; i < 3; i++) {
        x_m = x_m * (2.0f - m_norm * x_m);
    }
    
    // Tính exponent mới: exp_result = -exponent - 1 (vì 1/(2^exponent * m_norm))
    int32_t new_exponent = -exponent - 1;
    
    // Chuyển x_m về dạng mantissa của float
    union {
        float f;
        uint32_t i;
    } x_conv;
    x_conv.f = x_m;
    
    uint32_t new_mantissa = (x_conv.i & 0x007FFFFF);
    
    // Ghép kết quả
    uint32_t result_i = sign | ((new_exponent + 127) << 23) | new_mantissa;
    u.i = result_i;
    
    return u.f;
}

// Phiên bản đơn giản nhưng ổn định (dùng cho giá trị nhỏ)
float reciprocal_simple_stable(float a) {
    if (a == 0.0f) return std::numeric_limits<float>::infinity();
    
    // Scale a về khoảng [0.5, 2) để tính toán ổn định
    float scale = 1.0f;
    int scale_count = 0;
    
    while (a > 2.0f) {
        a *= 0.5f;
        scale_count++;
    }
    while (a < 0.5f) {
        a *= 2.0f;
        scale_count--;
    }
    
    // Bây giờ a ∈ [0.5, 2)
    // Ước lượng ban đầu: sử dụng đa thức xấp xỉ
    float x;
    if (a < 1.0f) {
        // 1/a với a ∈ [0.5, 1) ≈ 2 - a
        x = 2.0f - a;
    } else {
        // 1/a với a ∈ [1, 2) ≈ (3 - a)/2
        x = (3.0f - a) * 0.5f;
    }
    
    // 3 lần lặp Newton-Raphson
    for (int i = 0; i < 3; i++) {
        float ax = a * x;
        // KIỂM TRA TRÁNH OVERFLOW
        if (ax > 1.8f) {
            x *= 0.9f;  // Giảm x nếu ax gần 2
            ax = a * x;
        }
        x = x * (2.0f - ax);
    }
    
    // Điều chỉnh scale
    while (scale_count > 0) {
        x *= 0.5f;
        scale_count--;
    }
    while (scale_count < 0) {
        x *= 2.0f;
        scale_count++;
    }
    
    return x;
}

// Test với nhiều giá trị
void test_reciprocal() {
    float test_cases[] = {
        0.5f, 1.0f, 2.0f, 4.0f, 8.0f, 16.0f, 32.0f, 64.0f, 128.0f, 256.0f, 512.0f, 1024.0f,
        2048.0f, 4096.0f, 8192.0f, 16384.0f, 32768.0f, 65536.0f,
        0.1f, 0.01f, 0.001f, 0.0001f,
        3.14159f, 2.71828f, 100.0f, 1000.0f, 10000.0f,
        1.0e-6f, 1.0e-9f, 1.0e-12f
    };
    
    std::cout << std::fixed;
    std::cout.precision(10);
    
    std::cout << "\n=== TEST NGHICH DAO ===\n";
    std::cout << "a\t\tExpected\t\tNewton\t\t\tBitManip\t\tSimple\t\t\tError(%)\n";
    std::cout << "----------------------------------------------------------------------------------------------------------------\n";
    
    for (float a : test_cases) {
        float expected = 1.0f / a;
        float newton = reciprocal_newton_fixed(a);
        float bitman = reciprocal_bit_manipulation(a);
        float simple = reciprocal_simple_stable(a);
        
        float error_newton = std::abs((newton - expected) / expected) * 100;
        
        std::cout << a << "\t\t" << expected << "\t\t" 
                  << newton << "\t\t" << bitman << "\t\t" << simple 
                  << "\t\t" << error_newton << "%\n";
    }
}

int main() {
    std::cout << "=== TINH NGHICH DAO KHONG DUNG PHEP CHIA ===\n";
    
    float a;
    std::cout << "Nhap so a: ";
    std::cin >> a;
    
    std::cout << std::fixed;
    std::cout.precision(15);
    
    float expected = 1.0f / a;
    float result1 = reciprocal_newton_fixed(a);
    float result2 = reciprocal_bit_manipulation(a);
    float result3 = reciprocal_simple_stable(a);
    
    std::cout << "\nKET QUA:\n";
    std::cout << "Chia truc tiep: 1/" << a << " = " << expected << std::endl;
    std::cout << "Newton-Raphson: 1/" << a << " = " << result1 << std::endl;
    std::cout << "Bit Manip:      1/" << a << " = " << result2 << std::endl;
    std::cout << "Simple Stable:  1/" << a << " = " << result3 << std::endl;
    
    // Tính sai số
    float error1 = std::abs((result1 - expected) / expected) * 100;
    float error2 = std::abs((result2 - expected) / expected) * 100;
    float error3 = std::abs((result3 - expected) / expected) * 100;
    
    std::cout << "\nSAI SO:\n";
    std::cout << "Newton:    " << error1 << "%\n";
    std::cout << "Bit Manip: " << error2 << "%\n";
    std::cout << "Simple:    " << error3 << "%\n";
    
    // Test tự động
    test_reciprocal();
    
    return 0;
}