# QR Code System - Trình Café

## 📱 Tổng quan

Hệ thống QR code cho phép khách hàng quét mã để đặt món trực tuyến tại từng bàn trong các chi nhánh của Trình Café.

## 🏢 Chi nhánh và Bàn

### Chi nhánh hiện có:
- **HC** - Trình Café - Hải Châu
- **ST** - Trình Café - Sơn Trà  
- **TK** - Trình Café - Thanh Khê
- **LC** - Trình Café - Liên Chiểu

### Cấu trúc bàn:
- Mỗi chi nhánh có **2 tầng**
- Mỗi tầng có **10 bàn**
- Tổng cộng: **80 bàn** (4 chi nhánh × 2 tầng × 10 bàn)

## 🔧 Quản lý QR Code

### Scripts có sẵn:

#### 1. Tạo/Tái tạo QR Code
```bash
cd server
npm run generate-qr
```
- Tạo QR code cho tất cả 80 bàn
- Format file: `{CHI_NHANH}-F{TANG}-T{BAN}.png`
- Ví dụ: `HC-F1-T1.png` (Hải Châu, Tầng 1, Bàn 1)

#### 2. Tạo nhãn in QR Code
```bash
cd server
npm run print-labels
```
- Tạo file HTML để in nhãn QR code
- File output: `qr_codes/printable/qr-labels.html`
- Hướng dẫn in có trong console

### Cấu trúc thư mục:
```
server/
├── qr_codes/                    # Thư mục chứa QR code
│   ├── HC-F1-T1.png           # QR code cho từng bàn
│   ├── HC-F1-T2.png
│   ├── ...
│   └── printable/             # Thư mục nhãn in
│       └── qr-labels.html     # File HTML để in
└── public/
    └── order.html              # Trang web đặt món
```

## 🌐 Trang web đặt món

### URL QR Code:
```
http://localhost:4000/order.html?location={CHI_NHANH}&table={SO_BAN}&floor={TANG}
```

### URL QR Code (for local testing with phone):

When testing on a phone, replace `localhost` with your computer's local IP address (e.g. `192.168.1.42`).

```
http://<MACHINE_IP>:4000/order.html?location={CHI_NHANH}&table={SO_BAN}&floor={TANG}
```

You can run the helper script `scripts/show-ip.sh` to quickly display your machine IP and example URLs.
```

### Ví dụ:
# Option A: provide QR_HOST so QR payload points to your machine IP
QR_HOST="http://<MACHINE_IP>:4000" node server/scripts/generate-qr.js

# Option B: edit server/scripts/generate-qr.js to change host, then run
- Bàn 1, Tầng 1, Hải Châu: `http://localhost:4000/order.html?location=HC&table=1&floor=1`
- Bàn 5, Tầng 2, Sơn Trà: `http://localhost:4000/order.html?location=ST&table=5&floor=2`

### Tính năng trang web:
- ✅ Hiển thị thông tin bàn và chi nhánh
- ✅ Xem thực đơn theo danh mục
- ✅ Thêm món vào giỏ hàng
- ✅ Đặt món trực tuyến
- ✅ Responsive design cho mobile
- ✅ Giao diện đẹp với Tailwind CSS

## 🖨️ Hướng dẫn in QR Code

### Bước 1: Tạo file in
```bash
cd server
npm run print-labels
```

### Bước 2: Mở file HTML
- Mở file: `qr_codes/printable/qr-labels.html`
- Hoặc truy cập: `file:///path/to/qr-labels.html`

### Bước 3: In
1. Nhấn `Ctrl+P` (Windows) hoặc `Cmd+P` (Mac)
2. Chọn "More settings" → "Options" → "Background graphics"
3. Chọn khổ giấy A4
4. In và cắt theo đường viền đứt nét

### Kích thước nhãn:
- **8cm × 6cm** mỗi nhãn
- **6 nhãn** mỗi trang A4
- Có đường viền đứt nét để cắt

## 🔄 Cập nhật QR Code

### Khi nào cần tái tạo:
- Thay đổi URL trang web đặt món
- Thêm/bớt bàn mới
- Thay đổi cấu trúc chi nhánh

### Cách tái tạo:
```bash
# 1. Cập nhật URL trong script (nếu cần)
# File: server/scripts/generate-qr.js
# Dòng: const payload = `http://localhost:4000/order.html?...`;

# 2. Chạy script tái tạo
cd server
npm run generate-qr

# 3. Tạo lại nhãn in (nếu cần)
npm run print-labels
```

## 📊 Thống kê QR Code

### Số lượng:
- **80 QR code** cho 80 bàn
- **4 chi nhánh** × **2 tầng** × **10 bàn** = 80 bàn

### Format tên file:
```
{CHI_NHANH}-F{TANG}-T{BAN}.png
```

### Ví dụ:
- `HC-F1-T1.png` - Hải Châu, Tầng 1, Bàn 1
- `ST-F2-T15.png` - Sơn Trà, Tầng 2, Bàn 15
- `TK-F1-T8.png` - Thanh Khê, Tầng 1, Bàn 8
- `LC-F2-T20.png` - Liên Chiểu, Tầng 2, Bàn 20

## 🚀 Triển khai Production

### Cập nhật URL:
1. Sửa file `server/scripts/generate-qr.js`
2. Thay đổi `http://localhost:4000` thành domain thực tế
3. Chạy `npm run generate-qr` để tái tạo QR code

### Ví dụ Production:
```javascript
const payload = `https://trinhcafe.vn/order?location=${location.code}&table=${table.table_number}&floor=${table.floor_id}`;
```

## 🛠️ Troubleshooting

### QR Code không hiển thị:
1. Kiểm tra server có chạy không: `curl http://localhost:4000/api/health`
2. Kiểm tra thư mục QR: `ls server/qr_codes/`
3. Tái tạo QR code: `npm run generate-qr`

### Trang web đặt món không load:
1. Kiểm tra server: `curl http://localhost:4000/order.html`
2. Kiểm tra file: `ls server/public/order.html`
3. Restart server: `pkill -f "node src/index.js" && npm run dev`

### In không đúng:
1. Kiểm tra file HTML: `ls server/qr_codes/printable/`
2. Mở file trong browser để xem trước
3. Đảm bảo bật "Background graphics" khi in

## 📞 Hỗ trợ

Nếu gặp vấn đề, hãy kiểm tra:
1. Server có đang chạy không
2. Database có kết nối không
3. File QR code có tồn tại không
4. URL có đúng format không

---

**Tạo bởi:** Trình Café Development Team  
**Cập nhật:** $(date)  
**Phiên bản:** 1.0.0

npm run generate-qr
npm run print-labels