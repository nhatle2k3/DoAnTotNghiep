# Trình Café – MVP (Node.js + React + PostgreSQL)

MVP theo **đề cương đồ án**: quản lý menu, bàn/khu vực, đơn hàng, thanh toán, báo cáo. Không dùng Docker.

## 1) Yêu cầu môi trường
- Node.js 18+
- PostgreSQL 14+
- Yarn hoặc NPM

## 2) Cài đặt Database
Tạo DB `trinh_cafe`:
```bash
createdb trinh_cafe
# hoặc psql -c 'CREATE DATABASE trinh_cafe;'
```

Cấu hình `server/.env` từ `.env.example`:
```
PORT=4000
JWT_SECRET=supersecret_change_me
DATABASE_URL=postgres://postgres:postgres@localhost:5432/trinh_cafe
ALLOW_ORIGIN=http://localhost:5173
QR_OUTPUT_DIR=./qr_codes
```

## 3) Cài đặt & Seed dữ liệu
```bash
cd server
npm install
npm run seed   # tạo bảng, dữ liệu mẫu, user admin, QR code bàn
npm run dev    # chạy API tại http://localhost:4000
```

Tài khoản quản trị:
- Email: `admin@trinhcafe.vn`
- Mật khẩu: `admin123`

## 4) Client (React + Vite + Tailwind)
```bash
cd ../client
npm install
npm run dev   # http://localhost:5173
```

Mặc định client gọi API `http://localhost:4000/api`. Có thể đổi bằng biến `VITE_API_BASE`.

### Truy cập từ điện thoại (development)

Nếu bạn muốn mở app trên điện thoại để demo, làm theo các bước:

1. Kết nối điện thoại và máy tính vào cùng một mạng Wi‑Fi.
2. Trên máy tính, tìm địa chỉ IP nội bộ (ví dụ 192.168.1.42). Trên Linux chạy:

```bash
hostname -I | awk '{print $1}'
```

3. Chạy server và client với host binding:

```bash
# server
cd server && npm run dev

# client (vite) - vite.config.js đã đặt host: '0.0.0.0'
cd client && npm run dev
```

4. Trên điện thoại mở trình duyệt và truy cập:

 - Client UI (Vite): http://<MACHINE_IP>:5173
 - API endpoints: http://<MACHINE_IP>:4000/api

5. Nếu bạn dùng QR codes để dẫn khách hàng tới trang đặt món, khi sinh QR hãy đặt biến môi trường `QR_HOST` để payload dùng địa chỉ IP của máy chủ dev, ví dụ:

```bash
QR_HOST="http://192.168.1.42:4000" node server/scripts/generate-qr.js
```

6. Nếu client vẫn không truy cập được: kiểm tra firewall trên máy tính, đảm bảo port 5173 (vite) và 4000 (API) mở cho mạng cục bộ.

## 5) Tính năng chính
- **Đăng nhập** (JWT) – tài khoản admin mẫu trong seed
- **Menu**: xem, thêm vào giỏ và tạo đơn (đơn giản)
- **Bàn/Khu vực**: chọn chi nhánh (4 location), tầng (2 tầng), xem QR code mỗi bàn
- **Đơn hàng**: xem đơn mở; cập nhật trạng thái qua API
- **Thanh toán**: tạo thanh toán (API)
- **Báo cáo**: doanh thu theo ngày, top món (yêu cầu vai trò admin)

## 6) API chính (tóm tắt)
- `POST /api/auth/login` -> { token }
- `GET /api/menu` ; `POST/PUT/DELETE /api/menu/:id` (admin)
- `GET /api/tables/locations` ; `GET /api/tables/floors?location_id=...` ; `GET /api/tables?location_id=...&floor_id=...`
- `POST /api/orders` (tạo đơn từ giỏ)
- `PUT /api/orders/:id/status` (đổi trạng thái, cần JWT)
- `POST /api/payments` (thanh toán, cần JWT)
- `GET /api/reports/sales-by-day` (admin)
- `GET /api/reports/top-items` (admin)

## 7) Ghi chú
- Đây là MVP tối giản để **chạy được ngay** và bám sát đề cương. Có thể mở rộng: phân quyền chi tiết, quản lý kho, in bếp/barista, QR deep-link ra trang đặt món Public, upload ảnh món, v.v.
- Nếu cổng, địa chỉ DB khác: sửa `DATABASE_URL` trong `server/.env`.
- Ảnh QR được sinh ở thư mục `server/qr_codes` và phục vụ qua `/qr/*`.

Chúc bạn dựng demo thành công!
# DoAnTotNghiep
