-- PostgreSQL schema for Trình Café MVP

CREATE TABLE IF NOT EXISTS users (
id SERIAL PRIMARY KEY,
full_name TEXT NOT NULL,
email TEXT UNIQUE NOT NULL,
password_hash TEXT NOT NULL,
role TEXT NOT NULL DEFAULT 'customer', -- 'admin', 'staff', or 'customer'
created_at TIMESTAMP DEFAULT NOW()
);

-- Extra profile data for customers (1-1 with users where role = 'customer')
CREATE TABLE IF NOT EXISTS customers (
id SERIAL PRIMARY KEY,
user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
phone TEXT,
address TEXT,
note TEXT,
created_at TIMESTAMP DEFAULT NOW()
);

-- Extra profile data for staff (1-1 with users where role = 'staff')
CREATE TABLE IF NOT EXISTS staff (
id SERIAL PRIMARY KEY,
user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
phone TEXT,
position TEXT, -- chức vụ
salary NUMERIC(12,2), -- lương cơ bản (nếu cần)
work_schedule TEXT, -- thời gian / ca làm việc
status TEXT NOT NULL DEFAULT 'working', -- working, on_leave, resigned
started_at TIMESTAMP, -- ngày bắt đầu làm
created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS locations (
id SERIAL PRIMARY KEY,
code TEXT UNIQUE NOT NULL,
name TEXT NOT NULL,
address TEXT
);

CREATE TABLE IF NOT EXISTS floors (
id SERIAL PRIMARY KEY,
location_id INT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
name TEXT NOT NULL,
level INT NOT NULL
);

CREATE TABLE IF NOT EXISTS cafe_tables (
id SERIAL PRIMARY KEY,
location_id INT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
floor_id INT NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
table_number INT NOT NULL,
qr_code TEXT, -- path or content
status TEXT NOT NULL DEFAULT 'available' -- available, occupied, reserved
);

CREATE TABLE IF NOT EXISTS categories (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS items (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
price NUMERIC(12,2) NOT NULL,
category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
available BOOLEAN DEFAULT TRUE,
image_url TEXT
);

CREATE TABLE IF NOT EXISTS orders (
id SERIAL PRIMARY KEY,
table_id INT NOT NULL REFERENCES cafe_tables(id) ON DELETE RESTRICT,
status TEXT NOT NULL DEFAULT 'pending', -- pending, preparing, served, paid, cancelled
total NUMERIC(12,2) DEFAULT 0,
created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
id SERIAL PRIMARY KEY,
order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
item_id INT NOT NULL REFERENCES items(id) ON DELETE RESTRICT,
quantity INT NOT NULL,
price NUMERIC(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
id SERIAL PRIMARY KEY,
order_id INT NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
amount NUMERIC(12,2) NOT NULL,
method TEXT NOT NULL, -- cash, card, ewallet
status TEXT NOT NULL DEFAULT 'completed',
created_at TIMESTAMP DEFAULT NOW()
);