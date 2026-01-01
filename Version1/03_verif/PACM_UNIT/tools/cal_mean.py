import struct

def hex_to_float(hex_string):
    """
    Chuyển đổi chuỗi HEX 32-bit sang số floating point theo chuẩn IEEE754
    
    Args:
        hex_string: Chuỗi HEX (ví dụ: 'CE8E066E')
    
    Returns:
        float: Giá trị floating point
    """
    # Chuyển chuỗi HEX thành bytes
    hex_bytes = bytes.fromhex(hex_string)
    
    # Giải mã bytes thành float theo chuẩn IEEE754 (big-endian)
    float_value = struct.unpack('>f', hex_bytes)[0]
    
    return float_value

def read_hex_file(filename):
    """
    Đọc file chứa các giá trị HEX và chuyển đổi sang float
    
    Args:
        filename: Đường dẫn đến file
    
    Returns:
        list: Danh sách các giá trị float
    """
    float_values = []
    
    try:
        with open(filename, 'r') as file:
            for line_num, line in enumerate(file, 1):
                # Loại bỏ khoảng trắng và ký tự xuống dòng
                hex_string = line.strip()
                
                # Bỏ qua dòng trống
                if not hex_string:
                    continue
                
                try:
                    # Chuyển đổi HEX sang float
                    float_value = hex_to_float(hex_string)
                    float_values.append(float_value)
                    print(f"Dòng {line_num}: {hex_string} = {float_value}")
                except Exception as e:
                    print(f"Lỗi tại dòng {line_num} ({hex_string}): {e}")
        
        return float_values
    
    except FileNotFoundError:
        print(f"Không tìm thấy file: {filename}")
        return []
    except Exception as e:
        print(f"Lỗi khi đọc file: {e}")
        return []

def main():
    # Tên file input (thay đổi theo file của bạn)
    input_file = "./../../lib/mem_init.hex"
    
    print("=" * 50)
    print("Đọc và chuyển đổi dữ liệu HEX sang Float")
    print("=" * 50)
    
    # Đọc và chuyển đổi dữ liệu
    float_values = read_hex_file(input_file)
    
    # Hiển thị thống kê
    print("\n" + "=" * 50)
    print(f"Tổng số giá trị: {len(float_values)}")
    if float_values:
        print(f"Giá trị nhỏ nhất: {min(float_values)}")
        print(f"Giá trị lớn nhất: {max(float_values)}")
        print(f"Tổng cuẩ mảng: {sum(float_values)}")
        print(f"Giá trị trung bình: {sum(float_values) / len(float_values)}")
    print("=" * 50)
    
    # Lưu kết quả vào file (tùy chọn)
    output_file = "output.txt"
    try:
        with open(output_file, 'w') as file:
            for value in float_values:
                file.write(f"{value}\n")
        print(f"\nĐã lưu kết quả vào: {output_file}")
    except Exception as e:
        print(f"Lỗi khi lưu file: {e}")

if __name__ == "__main__":
    main()
