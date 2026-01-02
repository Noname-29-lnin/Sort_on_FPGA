def parse_value(line):
    """
    Tự động nhận dạng datatype
    """
    line = line.strip()

    # int
    if line.isdigit() or (line.startswith('-') and line[1:].isdigit()):
        return int(line)

    # float
    try:
        return float(line)
    except ValueError:
        pass

    # tuple / list
    if line.startswith(('(', '[')):
        return eval(line)   # CHỈ dùng khi file tin cậy

    # mặc định string
    return line


def check_unsorted_lines(filename):
    with open(filename, 'r') as f:
        raw_lines = f.readlines()

    values = [parse_value(line) for line in raw_lines]

    sorted_values = sorted(values)

    print("Các dòng chưa được sort:")
    for i, (orig, sorted_v) in enumerate(zip(values, sorted_values), start=1):
        if orig != sorted_v:
            print(f"{i}: {orig} -> {sorted_v}")


if __name__ == "__main__":
    check_unsorted_lines("./../Reports/COMPILE_REPORT/sorted_RTL.txt")
