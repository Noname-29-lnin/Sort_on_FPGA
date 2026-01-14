- Lĩnh vực nói chung của đồ án đang liên quan đến việc là

  - Processing-In-Memory (PIM)
  - Near-Data-Processing (NDP)

# Kiến trúc Processing-in-DRAM (PIM)

- **Nguyên lý:** Tích hợp các đơn vị tính toán nhỏ (ALU đơn giản) ngay bên trong chip DRAM hoặc tại lớp logic (logic layer) của các bộ nhớ 3D-stacked như HBM (High Bandwidth Memory).

https://developer.nvidia.com/blog/top-5-ai-model-optimization-techniques-for-faster-smarter-inference/?ncid=so-face-272978&fbclid=IwY2xjawO56k1leHRuA2FlbQIxMABicmlkETFWM1QwUGxFYmV0M0V5NUl5c3J0YwZhcHBfaWQQMjIyMDM5MTc4ODIwMDg5MgABHsSCEznPgUZgKK4cQTk90AkE5MiNN6RL0wksmx3v2ID8GUWNvYLR0fD2_RYO_aem_Uu1uIGZJL1joTXFshavyYg

![1766656747842](image/theory_basic/1766656747842.png)

# Tìm hiểu liên quan đến các loại bộ nhớ có thể dùng

## Các công nghệ bộ nhớ hiện nay:

## 1. Công nghệ chính đang thống trị (mainstream)

| Công nghệ                  | Loại                                      | Đặc điểm chính (2026)                                      | Ứng dụng chính                          | Dung lượng phổ biến / Tốc độ nổi bật                  | Tình trạng thị trường 2026                          |
|----------------------------|-------------------------------------------|-------------------------------------------------------------|-----------------------------------------|-------------------------------------------------------|-----------------------------------------------------|
| DRAM (DDR5, LPDDR5X)      | Volatile (mất dữ liệu khi tắt nguồn)     | Tốc độ cao, dùng cho RAM hệ thống                          | PC, laptop, smartphone, server          | DDR5 lên 8000+ MT/s, LPDDR5X cho mobile              | Thiếu hụt nặng, giá tăng mạnh do AI                 |
| HBM (High Bandwidth Memory) | Volatile, stacked                       | Băng thông cực cao (HBM4 lên 11.7 Gbps+)                   | GPU AI (NVIDIA, AMD), data center AI    | HBM4 36-48GB/stack (16-layer), tốc độ kỷ lục         | Bán hết trước khi sản xuất, ưu tiên AI              |
| NAND Flash (3D NAND)      | Non-volatile                              | QLC/TLC cao cấp, 200+ layer (BiCS8, V9)                    | SSD, USB, thẻ nhớ, smartphone           | PCIe Gen5 SSD lên 14GB/s+, QLC cho dung lượng lớn    | Thiếu hụt, giá tăng 2x trong 2025-2026              |
| HDD (ổ cứng cơ)           | Non-volatile                              | HAMR/MAMR, helium-filled, multi-actuator                   | Data center lưu trữ lớn, giá rẻ         | 30-40TB+ phổ biến, hướng tới 100TB+                  | Vẫn chiếm 68% dung lượng shipped toàn cầu           |
| SSD PCIe Gen5             | Dựa trên NAND                             | Tốc độ cực cao                                             | Gaming PC, workstation, server          | Đọc/ghi >14GB/s (Patriot PV593, v.v.)                | Đang phổ biến ở cao cấp, giá cao                    |

## 2. Công nghệ mới nổi (emerging memory) – đang chuyển từ lab sang sản xuất

| Công nghệ | Viết tắt đầy đủ                  | Ưu điểm chính                                      | Nhược điểm hiện tại              | Trạng thái 2026                                              | Ứng dụng tiềm năng chính                  |
|-----------|----------------------------------|----------------------------------------------------|----------------------------------|--------------------------------------------------------------|-------------------------------------------|
| MRAM     | Magnetoresistive RAM (STT-MRAM) | Tốc độ gần SRAM, endurance cao (10^14 cycles), non-volatile | Chi phí cao, dung lượng còn hạn chế | Sản xuất hàng loạt 28nm → 14nm/8nm (Samsung, TSMC, NXP)     | Embedded MCU, automotive, cache thay SRAM |
| ReRAM    | Resistive RAM                    | Scalable dưới 10nm, low power, endurance tốt      | Độ ổn định chưa hoàn hảo        | Đang vào sản xuất embedded (Weebit Nano + TI, GlobalFoundries) | Thay NOR Flash, edge AI, IoT              |
| FeRAM    | Ferroelectric RAM                | Endurance cực cao, low power write                | Dung lượng thấp hơn              | Ít phổ biến hơn, nhưng cải tiến cho automotive              | Smart card, sensor, low-power devices     |
| PCM      | Phase-Change Memory              | Cân bằng tốc độ + non-volatile (giống Optane cũ) | Intel đã dừng Optane 2022        | Nghiên cứu tiếp tục, ít sản phẩm thương mại lớn             | Storage-class memory (SCM), potential comeback |