import random

data_type = str(input("Type of data (int/float): ")).strip().lower()
bit = int(input("Input Size data (bit): "))
size_bit = 2 ** bit
number = int(input("Input Number of Elements: "))

low = -(size_bit - 1) / 2
high = (size_bit - 1) / 2

if data_type == "int":
    large_dataset = [
        str(random.randint(int(low), int(high)))
        for _ in range(number)
    ]

elif data_type == "float":
    large_dataset = [str(random.uniform(low, high)) for _ in range(number)]

else:
    print("Invalid type! Choose 'int' or 'float'")
    exit(1)

file_path = "./unsorted.txt"
with open(file_path, "w") as f:
    f.write(" ".join(large_dataset))

print(f"Data saved to: {file_path}")
