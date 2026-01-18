-- Basic seed
INSERT INTO categories (name) VALUES
  ('Coffee'), ('Tea'), ('Juice'), ('Dessert')
ON CONFLICT DO NOTHING;

-- Sample items with images
INSERT INTO items (name, price, category_id, image_url) VALUES
-- ===== COFFEE =====
('Cà Phê An', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/ca-phe-an.jpg'),
('Cà Phê Máy Đen Đá', 30000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cf-may-den.jpg'),
('Cà Phê Máy Sữa Đá', 32000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cf-may-sua.jpg'),
('Espresso', 40000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/espresso.jpg'),
('Cappuccino', 40000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cappuccino.jpg'),
('Latte', 40000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/latte.jpg'),
('Americano', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/americano.jpg'),
('Americano Cam', 45000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/americano-cam.jpg'),
('Americano Quýt', 45000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/americano-quyt.jpg'),

('Cà Phê Phin Truyền Thống', 35000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/phin-truyen-thong.jpg'),
('Phin Đen Đá', 30000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/phin-den.jpg'),
('Phin Sữa Đá', 32000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/phin-sua.jpg'),
('Cà Phê Đen Sài Gòn', 35000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/den-sg.jpg'),
('Cà Phê Sữa Sài Gòn', 37000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/sua-sg.jpg'),
('Cà Phê Muối', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cf-muoi.jpg'),
('Bạc Xỉu', 38000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/bac-xiu.jpg'),

('Cà Phê Bơ', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/ca-phe-bo.jpg'),
('Cà Phê Bơ Lắc', 45000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/ca-phe-bo-lac.jpg'),
('Cốt Dừa Cà Phê', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cot-dua-ca-phe.jpg'),

('Cold Brew Chanh Đào Mật Ong', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cb-chanh-dao.jpg'),
('Cold Brew Ổi Hồng', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cb-oi-hong.jpg'),
('Cold Brew Quýt', 42000, (SELECT id FROM categories WHERE name='Coffee'), '/images/menu/cb-quyt.jpg'),


-- ===== TEA =====
('Trà Đào Cam Sả', 40000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/tra-dao-cam-sa.jpg'),
('Trà Ổi Hồng', 40000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/tra-oi-hong.jpg'),
('Trà Lài Vải', 40000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/tra-lai-vai.jpg'),
('Trà Sả Chanh Mật Ong', 40000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/tra-sa-chanh-mat-ong.jpg'),

('Latte Matcha Nóng / Đá', 45000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/matcha-latte.jpg'),
('Matcha Muối', 45000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/matcha-muoi.jpg'),
('Matcha Latte Bơ', 48000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/matcha-bo.jpg'),

('Ôlong Sữa', 38000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/olong-sua.jpg'),
('Ôlong Sữa Bơ', 42000, (SELECT id FROM categories WHERE name='Tea'), '/images/menu/olong-sua-bo.jpg'),


-- ===== JUICE / SINH TỐ / NƯỚC TRÁI CÂY =====
('Nước Cam', 40000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/nuoc-cam.jpg'),
('Nước Chanh', 35000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/nuoc-chanh.jpg'),

('Sinh Tố Xoài', 40000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/sinh-to-xoai.jpg'),
('Sữa Chua Xoài', 38000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/sua-chua-xoai.jpg'),
('Sữa Chua Phô Mai Xoài', 40000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/sua-chua-pho-mai-xoai.jpg'),
('Bơ Dẻo Xoài Mọng', 40000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/bo-deo-xoai.jpg'),

('Sinh Tố Bơ', 40000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/sinh-to-bo.jpg'),
('Bơ Dừa Nước Hội An', 45000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/bo-dua-hoian.jpg'),

('Nước Dừa Trân Châu Đá', 38000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/dua-tran-chau.jpg'),
('Nước Dừa Matcha', 45000, (SELECT id FROM categories WHERE name='Juice'), '/images/menu/dua-matcha.jpg'),


-- ===== DESSERT: KEM / SNACK / BÁNH =====
('Kem Bơ Dừa Lòng', 42000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-bo-dua.jpg'),
('Kem Xoài Dừa Lòng', 40000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-xoai-dua.jpg'),

('Kem Matcha', 45000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-matcha.jpg'),
('Kem Xoài', 45000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-xoai.jpg'),
('Kem Bơ', 45000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-bo.jpg'),
('Kem Sầu Riêng', 45000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-sau-rieng.jpg'),
('Kem Dừa', 45000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/kem-dua.jpg'),

('Xoài Sấy', 35000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/xoai-say.jpg'),
('Xoài Sấy Muối Ớt', 35000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/xoai-say-muoi-ot.jpg'),
('Bánh Tráng Trộn Lớn', 20000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/banh-trang-tron.jpg'),

('Croissant Trứng Muối', 38000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/croissant-muoi.jpg'),
('Bánh Mì Bơ Tỏi', 35000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/banh-mi-bo-toi.jpg'),
('Bánh Red Velvet', 50000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/red-velvet.jpg'),
('Brown Chocolate', 35000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/brown-choco.jpg'),
('Tiramisu Truyền Thống', 38000, (SELECT id FROM categories WHERE name='Dessert'), '/images/menu/tiramisu.jpg');

-- Locations (4 branches in Da Nang)
INSERT INTO locations (code, name, address) VALUES
  ('PHT', 'Trình Cafe - 25 Phạm Hồng Thái', 'Quận Hải Châu, Đà Nẵng'),
  ('LDD', 'Trình Cafe - 22/4 Lê Đình Dương', 'Quận Hải Châu, Đà Nẵng'),
  ('NHT', 'Trình Cafe - 34/4 Nguyễn Hữu Thọ', 'Quận Thanh Khê, Đà Nẵng'),
  ('PNX', 'Trình Cafe - 100/19 Phạm Như Xương', 'Quận Liên Chiểu, Đà Nẵng')
ON CONFLICT DO NOTHING;
