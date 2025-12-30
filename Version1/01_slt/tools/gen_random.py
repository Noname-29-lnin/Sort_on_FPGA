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
                
                # Tạo dữ liệu ngẫu nhiên
                if data_type == "int":
                    batch_data = np.random.randint(
                        int(low), int(high) + 1, 
                        size=current_batch_size,
                        dtype=np.int64
                    )
                elif data_type == "float":
                    batch_data = np.random.uniform(
                        low, high, 
                        size=current_batch_size
                    ).astype(np.float32)
                else:
                    print("Invalid type! Choose 'int' or 'float'")
                    return
                
                # Ghi file
                for value in batch_data:
                    f.write(f"{value}\n")
                
                # Update thanh tiến độ
                pbar.update(current_batch_size)
    
    print(f"\n✓ Data saved to: {file_path}")

if __name__ == "__main__":
    generate_large_dataset_optimized()
