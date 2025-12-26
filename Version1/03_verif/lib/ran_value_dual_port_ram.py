import struct

def float_to_hex32(value: float) -> str:
    """
    Chuyển float -> IEEE754 32-bit hex (uppercase, không 0x)
    """
    packed = struct.pack('>f', value)      # big-endian float32
    integer = struct.unpack('>I', packed)[0]
    return f"{integer:08X}"                # 8 hex digits


def convert_file_float_to_hex(path_in: str, path_out: str):
    """
    Đọc file float text (space / newline separated)
    -> ghi file hex IEEE754 (1 value / 1 dòng)
    """
    count = 0

    with open(path_in, 'r') as fin, open(path_out, 'w') as fout:
        for line_num, line in enumerate(fin, 1):
            line = line.strip()

            # bỏ dòng trống hoặc comment
            if not line or line.startswith('#'):
                continue

            # 🔴 tách nhiều số trên cùng 1 dòng
            tokens = line.split()

            for token in tokens:
                try:
                    value = float(token)
                    hex32 = float_to_hex32(value)
                    fout.write(hex32 + '\n')
                    count += 1

                except ValueError:
                    print(f"[WARN] Line {line_num} skip token: {token}")

    print(f"[OK] Converted {count} values")
    print(f"[OK] Output written to: {path_out}")


# ================== PATH ==================
path_original_unsorted = "./../../01_slt/tools/unsorted.txt"
path_hex_unsorted = "./mem_init.hex"

convert_file_float_to_hex(
    path_original_unsorted,
    path_hex_unsorted
)
