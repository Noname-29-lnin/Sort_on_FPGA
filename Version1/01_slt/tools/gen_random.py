import numpy as np
from tqdm import tqdm

def generate_large_dataset_optimized():
    data_type = input("Type of data (int/float): ").strip().lower()
    bit = int(input("Input Size data (bit): "))
    number = int(input("Input Number of Elements: "))
    
    size_bit = 2 ** bit
    low = -(size_bit - 1) / 2
    high = (size_bit - 1) / 2
    
    file_path = "./unsorted.txt"
    
    # Xử lý theo batch để tránh tràn RAM
    batch_size = 10_000_000  # 10 triệu phần tử mỗi batch
    
    with open(file_path, "w") as f:
        # Tính số batch cần thiết
        num_batches = (number + batch_size - 1) // batch_size
        
        with tqdm(total=number, desc="Generating data", unit="elements") as pbar:
            for i in range(num_batches):
                # Tính số phần tử cho batch hiện tại
                current_batch_size = min(batch_size, number - i * batch_size)
                
                # Tạo dữ liệu ngẫu nhiên với phân bố rộng hơn
                if data_type == "int":
                    # Sử dụng phân bố logarit để tạo giá trị rải đều từ nhỏ đến lớn
                    # Tạo các số mũ ngẫu nhiên
                    log_low = np.log10(max(abs(low), 1))
                    log_high = np.log10(max(abs(high), 1))
                    
                    # Random dấu (âm/dương)
                    signs = np.random.choice([-1, 1], size=current_batch_size)
                    
                    # Random độ lớn theo log scale
                    log_values = np.random.uniform(
                        1,  # Từ hàng chục (10^1)
                        log_high,  # Đến giá trị max
                        size=current_batch_size
                    )
                    
                    # Chuyển về giá trị thực
                    batch_data = (signs * (10 ** log_values)).astype(np.int64)
                    
                    # Clip trong phạm vi cho phép
                    batch_data = np.clip(batch_data, int(low), int(high))
                    
                elif data_type == "float":
                    # Tương tự cho float
                    log_low = np.log10(max(abs(low), 1))
                    log_high = np.log10(max(abs(high), 1))
                    
                    signs = np.random.choice([-1, 1], size=current_batch_size)
                    
                    log_values = np.random.uniform(
                        1,  # Từ hàng chục
                        log_high,
                        size=current_batch_size
                    )
                    
                    batch_data = (signs * (10 ** log_values)).astype(np.float32)
                    batch_data = np.clip(batch_data, low, high)
                    
                else:
                    print("Invalid type! Choose 'int' or 'float'")
                    return
                
                # Ghi file
                for value in batch_data:
                    if data_type == "int":
                        f.write(f"{value}\n")
                    else:
                        f.write(f"{value:.6f}\n")
                
                # Update thanh tiến độ
                pbar.update(current_batch_size)
    
    print(f"\n✓ Data saved to: {file_path}")
    print(f"✓ Range: {low:.2e} to {high:.2e}")
    print(f"✓ Distribution: Logarithmic (spread from tens to billions)")

if __name__ == "__main__":
    generate_large_dataset_optimized()