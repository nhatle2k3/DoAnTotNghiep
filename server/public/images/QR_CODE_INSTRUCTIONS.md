# Hướng dẫn thêm mã QR Code cố định

## Vị trí file
Đặt file QR code của bạn vào thư mục này với tên: `qr-code.png`

Đường dẫn đầy đủ: `/server/public/images/qr-code.png`

## Yêu cầu file
- **Tên file**: `qr-code.png` (hoặc `qr-code.jpg`)
- **Kích thước khuyến nghị**: 250x250 pixels hoặc lớn hơn (tỷ lệ 1:1)
- **Định dạng**: PNG hoặc JPG
- **Nội dung**: Mã QR code chứa thông tin chuyển khoản ngân hàng

## Cách tạo mã QR code

### Cách 1: Dùng ứng dụng online
1. Truy cập: https://www.qr-code-generator.com/ hoặc https://qr-generator.com/
2. Chọn loại QR code: "Text" hoặc "Bank Transfer"
3. Nhập thông tin:
   - Số tài khoản: 1040337283
   - Ngân hàng: Vietcombank
   - Chủ tài khoản: LE VAN NHAT
4. Tải xuống file PNG
5. Đổi tên thành `qr-code.png` và đặt vào thư mục này

### Cách 2: Dùng ứng dụng điện thoại
1. Tải ứng dụng tạo QR code (ví dụ: QR Code Generator)
2. Tạo QR code với thông tin ngân hàng
3. Chụp màn hình hoặc xuất file
4. Đổi tên thành `qr-code.png` và đặt vào thư mục này

### Cách 3: Dùng Python (nếu có)
```python
import qrcode

qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data("1040337283|Vietcombank|LE VAN NHAT")
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
img.save("qr-code.png")
```

## Kiểm tra
Sau khi đặt file, truy cập: `http://localhost:3000/images/qr-code.png`
Nếu thấy hình ảnh QR code thì đã thành công!

## Lưu ý
- File QR code này sẽ được hiển thị cho tất cả các đơn hàng
- Nếu muốn thay đổi, chỉ cần thay thế file `qr-code.png` mới
- Đảm bảo file có kích thước phù hợp (không quá lớn để tải nhanh)

