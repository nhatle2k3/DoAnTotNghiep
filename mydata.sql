--
-- PostgreSQL database dump
--

\restrict EiSpbr8eEoQuybt6rPNUcCl75HPqjkcON7ajwIuwgz2lWFtUyFI0Znb3zJGowR0

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

-- Started on 2025-12-07 01:05:53 +07

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 233 (class 1255 OID 16755)
-- Name: generate_orders_2025(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_orders_2025() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    month_num INT;
    order_num INT;
    created_at_time TIMESTAMP;
    new_order_id INT;
    item_count INT;
    picked_item INT;
    picked_price NUMERIC;
    qty INT;
    total_price NUMERIC;
BEGIN
    FOR month_num IN 1..11 LOOP
        FOR order_num IN 1..75 LOOP
        
            -- random thời gian trong tháng
            created_at_time :=
                TO_TIMESTAMP(
                    '2025-' || LPAD(month_num::TEXT, 2, '0') || '-' ||
                    LPAD((1 + floor(random() * 28))::TEXT, 2, '0') || ' ' ||
                    LPAD((8 + floor(random() * 12))::TEXT, 2, '0') || ':' ||
                    LPAD(floor(random() * 59)::TEXT, 2, '0') || ':' ||
                    LPAD(floor(random() * 59)::TEXT, 2, '0'),
                    'YYYY-MM-DD HH24:MI:SS'
                );
            
            -- tạo order cho bàn ngẫu nhiên
            INSERT INTO orders (table_id, status, total, created_at)
            VALUES (
                (SELECT id FROM cafe_tables ORDER BY RANDOM() LIMIT 1),
                'paid',
                0,
                created_at_time
            )
            RETURNING id INTO new_order_id;

            -- reset tổng tiền
            total_price := 0;

            -- 7 món cho mỗi hóa đơn
            FOR item_count IN 1..7 LOOP
            
                SELECT id, price
                INTO picked_item, picked_price
                FROM items
                ORDER BY RANDOM()
                LIMIT 1;

                qty := 1 + floor(random() * 3); -- số lượng: 1–3

                INSERT INTO order_items (order_id, item_id, quantity, price)
                VALUES (new_order_id, picked_item, qty, picked_price);

                total_price := total_price + (picked_price * qty);
            END LOOP;

            -- cập nhật tổng tiền
            UPDATE orders
            SET total = total_price
            WHERE id = new_order_id;

            -- tạo payment
            INSERT INTO payments (order_id, amount, method, status, created_at)
            VALUES (
                new_order_id,
                total_price,
                'cash',
                'completed',
                created_at_time
            );

        END LOOP; -- 75 orders per month
    END LOOP; -- tháng 1 → 11

END;
$$;


ALTER FUNCTION public.generate_orders_2025() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16612)
-- Name: cafe_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cafe_tables (
    id integer NOT NULL,
    location_id integer NOT NULL,
    floor_id integer NOT NULL,
    table_number integer NOT NULL,
    qr_code text,
    status text DEFAULT 'available'::text NOT NULL
);


ALTER TABLE public.cafe_tables OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16611)
-- Name: cafe_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cafe_tables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cafe_tables_id_seq OWNER TO postgres;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 221
-- Name: cafe_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cafe_tables_id_seq OWNED BY public.cafe_tables.id;


--
-- TOC entry 224 (class 1259 OID 16632)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16631)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 220 (class 1259 OID 16598)
-- Name: floors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floors (
    id integer NOT NULL,
    location_id integer NOT NULL,
    name text NOT NULL,
    level integer NOT NULL
);


ALTER TABLE public.floors OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16597)
-- Name: floors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.floors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.floors_id_seq OWNER TO postgres;

--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 219
-- Name: floors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.floors_id_seq OWNED BY public.floors.id;


--
-- TOC entry 226 (class 1259 OID 16641)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    name text NOT NULL,
    price numeric(12,2) NOT NULL,
    category_id integer NOT NULL,
    available boolean DEFAULT true,
    image_url text
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16640)
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO postgres;

--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 225
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- TOC entry 218 (class 1259 OID 16587)
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    address text
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16586)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_id_seq OWNER TO postgres;

--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 217
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- TOC entry 230 (class 1259 OID 16673)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(12,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16672)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 228 (class 1259 OID 16656)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    table_id integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    total numeric(12,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16655)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 227
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 232 (class 1259 OID 16690)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    order_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    method text NOT NULL,
    status text DEFAULT 'completed'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16689)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 231
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- TOC entry 216 (class 1259 OID 16574)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    role text DEFAULT 'staff'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16573)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3329 (class 2604 OID 16615)
-- Name: cafe_tables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cafe_tables ALTER COLUMN id SET DEFAULT nextval('public.cafe_tables_id_seq'::regclass);


--
-- TOC entry 3331 (class 2604 OID 16635)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 3328 (class 2604 OID 16601)
-- Name: floors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors ALTER COLUMN id SET DEFAULT nextval('public.floors_id_seq'::regclass);


--
-- TOC entry 3332 (class 2604 OID 16644)
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- TOC entry 3327 (class 2604 OID 16590)
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- TOC entry 3338 (class 2604 OID 16676)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 3334 (class 2604 OID 16659)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3339 (class 2604 OID 16693)
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- TOC entry 3324 (class 2604 OID 16577)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3522 (class 0 OID 16612)
-- Dependencies: 222
-- Data for Name: cafe_tables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cafe_tables (id, location_id, floor_id, table_number, qr_code, status) FROM stdin;
12	1	1	12	/qr/PHT-T12.png	available
13	1	1	13	/qr/PHT-T13.png	available
14	1	1	14	/qr/PHT-T14.png	available
15	1	1	15	/qr/PHT-T15.png	available
16	1	1	16	/qr/PHT-T16.png	available
17	1	1	17	/qr/PHT-T17.png	available
18	1	1	18	/qr/PHT-T18.png	available
19	1	1	19	/qr/PHT-T19.png	available
20	1	1	20	/qr/PHT-T20.png	available
21	1	1	21	/qr/PHT-T21.png	available
22	1	1	22	/qr/PHT-T22.png	available
23	1	1	23	/qr/PHT-T23.png	available
24	1	1	24	/qr/PHT-T24.png	available
25	1	1	25	/qr/PHT-T25.png	available
26	1	1	26	/qr/PHT-T26.png	available
27	1	1	27	/qr/PHT-T27.png	available
28	1	1	28	/qr/PHT-T28.png	available
29	1	1	29	/qr/PHT-T29.png	available
31	2	2	1	/qr/LDD-T1.png	available
32	2	2	2	/qr/LDD-T2.png	available
33	2	2	3	/qr/LDD-T3.png	available
34	2	2	4	/qr/LDD-T4.png	available
35	2	2	5	/qr/LDD-T5.png	available
36	2	2	6	/qr/LDD-T6.png	available
37	2	2	7	/qr/LDD-T7.png	available
38	2	2	8	/qr/LDD-T8.png	available
39	2	2	9	/qr/LDD-T9.png	available
40	2	2	10	/qr/LDD-T10.png	available
41	2	2	11	/qr/LDD-T11.png	available
42	2	2	12	/qr/LDD-T12.png	available
43	2	2	13	/qr/LDD-T13.png	available
44	2	2	14	/qr/LDD-T14.png	available
45	2	2	15	/qr/LDD-T15.png	available
46	2	2	16	/qr/LDD-T16.png	available
47	2	2	17	/qr/LDD-T17.png	available
48	2	2	18	/qr/LDD-T18.png	available
50	2	2	20	/qr/LDD-T20.png	available
51	2	2	21	/qr/LDD-T21.png	occupied
52	2	2	22	/qr/LDD-T22.png	available
53	2	2	23	/qr/LDD-T23.png	available
54	2	2	24	/qr/LDD-T24.png	available
5	1	1	5	/qr/PHT-T5.png	occupied
56	2	2	26	/qr/LDD-T26.png	available
57	2	2	27	/qr/LDD-T27.png	available
58	2	2	28	/qr/LDD-T28.png	available
59	2	2	29	/qr/LDD-T29.png	available
60	2	2	30	/qr/LDD-T30.png	available
61	3	3	1	/qr/NHT-T1.png	available
62	3	3	2	/qr/NHT-T2.png	available
63	3	3	3	/qr/NHT-T3.png	available
64	3	3	4	/qr/NHT-T4.png	available
65	3	3	5	/qr/NHT-T5.png	available
66	3	3	6	/qr/NHT-T6.png	available
67	3	3	7	/qr/NHT-T7.png	available
69	3	3	9	/qr/NHT-T9.png	available
70	3	3	10	/qr/NHT-T10.png	available
71	3	3	11	/qr/NHT-T11.png	available
72	3	3	12	/qr/NHT-T12.png	available
73	3	3	13	/qr/NHT-T13.png	available
74	3	3	14	/qr/NHT-T14.png	available
75	3	3	15	/qr/NHT-T15.png	available
76	3	3	16	/qr/NHT-T16.png	available
77	3	3	17	/qr/NHT-T17.png	available
78	3	3	18	/qr/NHT-T18.png	available
79	3	3	19	/qr/NHT-T19.png	available
80	3	3	20	/qr/NHT-T20.png	available
81	3	3	21	/qr/NHT-T21.png	available
82	3	3	22	/qr/NHT-T22.png	available
83	3	3	23	/qr/NHT-T23.png	available
84	3	3	24	/qr/NHT-T24.png	available
85	3	3	25	/qr/NHT-T25.png	available
86	3	3	26	/qr/NHT-T26.png	available
88	3	3	28	/qr/NHT-T28.png	available
89	3	3	29	/qr/NHT-T29.png	available
90	3	3	30	/qr/NHT-T30.png	available
91	4	4	1	/qr/PNX-T1.png	available
92	4	4	2	/qr/PNX-T2.png	available
93	4	4	3	/qr/PNX-T3.png	available
94	4	4	4	/qr/PNX-T4.png	available
95	4	4	5	/qr/PNX-T5.png	available
96	4	4	6	/qr/PNX-T6.png	available
97	4	4	7	/qr/PNX-T7.png	available
98	4	4	8	/qr/PNX-T8.png	available
99	4	4	9	/qr/PNX-T9.png	available
100	4	4	10	/qr/PNX-T10.png	available
101	4	4	11	/qr/PNX-T11.png	available
102	4	4	12	/qr/PNX-T12.png	available
103	4	4	13	/qr/PNX-T13.png	available
104	4	4	14	/qr/PNX-T14.png	available
105	4	4	15	/qr/PNX-T15.png	available
107	4	4	17	/qr/PNX-T17.png	available
2	1	1	2	/qr/PHT-T2.png	available
3	1	1	3	/qr/PHT-T3.png	available
8	1	1	8	/qr/PHT-T8.png	available
55	2	2	25	/qr/LDD-T25.png	available
6	1	1	6	/qr/PHT-T6.png	available
7	1	1	7	/qr/PHT-T7.png	available
4	1	1	4	/qr/PHT-T4.png	available
9	1	1	9	/qr/PHT-T9.png	available
10	1	1	10	/qr/PHT-T10.png	available
1	1	1	1	/qr/PHT-T1.png	available
11	1	1	11	/qr/PHT-T11.png	available
30	1	1	30	/qr/PHT-T30.png	available
49	2	2	19	/qr/LDD-T19.png	available
68	3	3	8	/qr/NHT-T8.png	available
87	3	3	27	/qr/NHT-T27.png	available
106	4	4	16	/qr/PNX-T16.png	available
108	4	4	18	/qr/PNX-T18.png	available
109	4	4	19	/qr/PNX-T19.png	available
110	4	4	20	/qr/PNX-T20.png	available
111	4	4	21	/qr/PNX-T21.png	available
112	4	4	22	/qr/PNX-T22.png	available
113	4	4	23	/qr/PNX-T23.png	available
114	4	4	24	/qr/PNX-T24.png	available
115	4	4	25	/qr/PNX-T25.png	available
116	4	4	26	/qr/PNX-T26.png	available
117	4	4	27	/qr/PNX-T27.png	available
118	4	4	28	/qr/PNX-T28.png	available
119	4	4	29	/qr/PNX-T29.png	available
120	4	4	30	/qr/PNX-T30.png	available
\.


--
-- TOC entry 3524 (class 0 OID 16632)
-- Dependencies: 224
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name) FROM stdin;
1	Coffee
2	Tea
3	Juice
4	Dessert
\.


--
-- TOC entry 3520 (class 0 OID 16598)
-- Dependencies: 220
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floors (id, location_id, name, level) FROM stdin;
1	1	Tầng 1	1
2	2	Tầng 1	1
3	3	Tầng 1	1
4	4	Tầng 1	1
\.


--
-- TOC entry 3526 (class 0 OID 16641)
-- Dependencies: 226
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, name, price, category_id, available, image_url) FROM stdin;
8	Americano Cam	45000.00	1	t	data:image/jpeg;base64,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
16	Bạc Xỉu	38000.00	1	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxITEhUQEhIQEg8QEBAQFRUVEBAVFRAQFRUWFhUVFRUYHSggGBolHRUVITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OFxAQGi0dHR0rLS0tKy0rLS0tKy0tLS0tLS0tLS0tLS0rKy0tLS0tLS0tLS0tLS0tLS0rLS0tLS0tLf/AABEIAOEA4QMBIgACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAADAAECBAUGB//EAEUQAAEDAgIHBQQHBgMJAQAAAAEAAhEDIQQSBRMxQVFhkQZxgaHwIlLB0RQjMkJiseEHcpKiwtKCsvEWMzREU1TT4vIV/8QAGgEBAAMBAQEAAAAAAAAAAAAAAAECAwQFBv/EACQRAQADAAEEAQQDAAAAAAAAAAABAhEDBBIhMUETIlFxM2GR/9oADAMBAAIRAxEAPwDyIpJ4TgKyDBOnAToIpKUJ0EQjUXocJKBaqGU9Fm9V2vR6dRASIUA4yn1iUb1ITkNHY1EdSQBo7Vo0iqrKXRWW1ABCCxO/Yj0XyIVShVlEZINkF5rUzxNgouqDqm1oQVq9IhUFsvcCsyqy5QDCmCotUwEClSBShKEEgU6gnzICpIcp0HNJwlCdAoUoTBSUBkinShSGUVIhNCBkRpQipsQWQE4KWGpl7hTYC97jDWtBc5x4NaLkrY0n2XxmHY2pWw1VjHmAfZdB3BwaSWm2+EGc2EQu6KLcPU9x9vwOt5Lo9Hdi8XWw7sS1jcoaXtpkuFWqwbXMZF+UkE7ptMDnnElNdTNF+5j/AOB3yV7RPZ/F4pxZRovcWgEkwxrQdkufAvGzkVIzXVeCt4R0oektFVsPUNKvSfSqC8OG0cWkWcOYJCWFcBsQaD6dpQXthOXO8EpG9A9J9kKsLqYI8EGu9AMhO0qJKSAoKUoaUoJkqBKbMouKAkpIcpIMeEoUoTgIkwCeE8J4RBgEoUwE+VAIhIhEhLKg63sP2RZiA2vWBqUSXtLGvLS17SAM1wSDI2Om4tw77BdkMOXWo0qAbFzhcPm8H1M7p2Xzb+Nhz/7L8R9SWSbV39C2mdnVelMtsiLCBA4dFXUj6NwdGiIpBhdEF2Zpe4W3jYOQgI1Si54IdGR1suURHq6Ca4LIPIjndOx43Qo1JxodkCC6RBs7LMfuxHhCd2Cc6qH2a1rWgZZDiQZufd2W5lFpu3yUTxPnIUoUMToHDuBL6VE5y4l2RmYF0yQ6JH2jsO8paG0P9HBZTPsA5gIbewkm1yYueUbIi8ynwc6/I/NFbT/Eeh+aCjjMK2s0sqsDmzaRdruIO1p5rJ/2Oo7TUxDrzBqyOhELpjT9R8ymdhwePQKBxGmOyrGtmmylVGwtdTpNfPEGmGl3ls6cnpjshZrmAUXONw+pDQOIDzm8Bm8N/rT2jgeqxO0OEYKdStlANOlUfMX9lpO3buRLwenVtKTnSgtUgVdVMFSQwpSgnKZRlOgZQcU7kNxQElJDlJBShSATwnhAwClCQCkAgYBOAnhPCBoTQpwmhB2f7MsS1tUscYGcO8o+AXrVYMP2Xi/E7vULwbs3ULatt7fyK7/CYxx3lc3Jea2xtSkTGu8o5hP2HSI2olNp4Bc3haruK1MPiCo+qTxtem7kehVumR6CzqNcq/SqStK31Wa4PICk0hRBUgVbVRQAmcmCRUinVbdYfbV2XAYlx/7aq0f4mlv9S28YYXK/tQr5dH1R7xos61GT8VnE/di0x4eGkJ2hMpBbqJAJ4ThOghCRUnKEohEob1NxQ3FApSTSkgFCkApQnAQRDVINUgFKEEYShThKFIYBMWogCRaoBtEvy1QeUfkuywNV3LbbuXDMMEFdDovHOBiVw9XSZmJh18FoyYl19LFvAPP1ZdBgHEgTtAC53AV5AsOgXQYN1ljxUtHuV7zEtbDnYtCgs3CladBddXPZbYiBQYphaKJBOVEJyVKFDSodDcokmo0dwO9cT+2CvGEa3367B0Dnf0rv6wmORleZftlqfV0G8ar3fwtI/rVYj7tWmfDysKYTQpNC2UJSTQkgZyinKjKIRcguRihPQNKSSSAkKWVTypw1SIAKQCnlTgII5UoRA1PlUJChIhEypFqADlo4F3tKhUCsYCqM0bwVhzQ143d6J3eC6TDuAEcvNcxod9gujYbArCPENfcrWB0tTDtXUe1rzETaZ+K6Og61lyVXQrKr2uc0Zm3aZNiF0ujMLq2hoJMcSnFeZnyjkrER4alNyKCq9MooK6IliIXpnLK0vWrNdSdSbnaKoFRsgewQQTfhM24cJWkakhItszH4TNciJM8ryT9sNWauHbvYyuT3PNMD/IV6s9y8c/am6cW0cKDfNz/kpr7Vn04tSASARIWqqEJiETKolqCEKDgjBqiQgrlDcrDmITmohBMp5UkStQpBqcKQClBg1OGqbWqbWokPKnyouVKEAsqWVGYxSFNBUq07HuKqAEOD2+K19Ssmk+D3GD3hY8vw043a9n8TmA4oulcdWbUEEhgAgbuc8d6wsPWcG56f223A4xu8V2ADKrQSLwHCdo5Livs+nVTInZb2gMTrGNdJmbjmF0dJ1lzehC1rYEbT1XQUaoWtfDK/mQMCKzqri931YPstgW7zvW21VKbwjCqFrEspFcolCdXCo6Rx2Wm7KQH5SGkiQHbiQoteKxq0VmfC7UNl412+9rGP/C2m3+WfivTTpEmkHuEHLmPSZC8o01X1mIqv2y8+QDfgrcc7Kt4xjalPqVchQe1bs1Z1NMGK1q7J2MUiqWKGrVx1NO2kgo6pRdSWjqVF1JBn6lJX9Wkgz9YE7a4Wc5ymJWeynw0NeE4xSoSnU7Kche+lpjjOSphqfImyjFwY3kn+mFUshS1ZTZF76eeCrZRJcNri5zhzmbdUMMKlSsR4rPknwvT26bs/XpPhpGV0b9wtfuvtXY4XRxLbW23Xnei8QBJbHA8Z5r0HR+IecNTvFnDwn9Vx29uiHPvxdfCVTcOY50uH4t/cV6BoHH0K7A5lVmaBLS6HNPAgrkquDDnQ+7XeasaL0W2hVlp9l1oVOntafDTmisxvy9BbhLTu6yk2huWfo6oWuEGxIkbir2PrQYGzoujvjHN2zolaixo9pw7rn8liVcTRqkNa8QCQSWuAt3pY/FhoifaIMfE+C4TtGXDVU2OLZJeYMEmbX6rk6jmjuiv+ung4vGum7Y6bpUaL6DDNd1PIAPuAwMxO4wZC8udUKu6dd9Y4kkmwJPhP5Kg1wXb09+6uufmp22xNlQomdKm1qK2m1dGsgiSlJRsoTZQmyYF4qYJ4pGiE2pKaHLioOJUtUVB1Mpph/FJRypJsoYWQTdEI3SqoJJT5yiFgN5qXiqheU7XqcFomE7XoAd3p8/NMFkFSaCgMeOKMwHiiRGMKHXsZ5T+akQVF1zfh5T+qzvHhavtPREHM4b46bvivStGf8NSPDN+a8y0awCYsvQ9BVJwzL7HOC4bT5dUel6o2wPAq+btB3qhTfYbLlXWvGSfdt3rGLdszML5sQvaKrEEBzmlxcABImFf0/insD3NaC5rZAM3gLiqOBpVajQ5m1w68jtC7fSFNrGhskhjQJcSTHMlOLl7q2n8HJxxWY/t5w3SFVk1ap1lSpLWi8AST0GaO4clGhinV3APDQWGAQCLE8yrVZrST3kDuQMG1oqADe4LzuTlm+zPt31pFYYfaRsPMf9QhZtJqt6YrZ6pvEF580Bhj7y97o4mOGryep/lkVgRA0bLqrrSPvBOMWfeC6nPqzqxxKk1iqjSPcfBTbpIckyTYWYS1negf/pDgnbpAcEyTRXVjwKBUqFEGLm0IryFApZj6lJWpHBJNMcqal9gSJPJDzdyfOrIIsPFSYzvUc/MojHd/VBMU+9TbTPAJmk8RbmlmPJNMTg/hCm1rj94KAnki0TzHRQk2pd7yZzct5JsfCCCjl34goVnSNu535KtvSax5Dwr7HvXZ9l8a1+Gi8srPaQeMA+K4Sg6Oi63s8+KFtpqT5LzefIh2cca6jD1JMboBU8fjwBlb3LPw1cG+8BBxL5k7Fx3me2YdFK+WloGtmrsJ2B7Z7yVpdrsfme5gJgHjayw+zjvrmjg9p8/9FZ07SIz8S1w+yZzGbzPwWVbfb2R8tZrHd3T8MDSOlWUxGb2uAurOhgS5jnbbnylZGC0RL9ZUEwZAPHiVu6Pf7RPBjz/KVPLNK17a+/lasTM7LmtIBofebiep/RDFOnvzJ9IEF+0j2R8VBoHE+S93pon6Vf08nn/ksRp0uDihODNzCjwOJ8k0Dieq3Yq9tzClqz7itgN59UoHA9U0xV1bvd8wnAqcArQpt5qJpDj5lNMA+s4BNnqIr2+PiUMnl5lSgs1TiOqSeRwHUpKBz5clKGU11ZA4ITgqunzKMSskpSgBxTglBYUgq8lOHFBZCPQAJVDMVqdn6BqVm0xEuDxu90n4Kto8StWfLNzQV0mg8V9URP3/AILmcSCHOB2hxB5FaGiqnsH94Lg56bV2cM+XW0MTt3SE+uhvVYdKqUfXmF59qy7K429BVorNPAg961NKYyXHvK53QdT6wK9j6lyeZXNaMtjaPRqtWQnwb4FQ8KT/AJKk6qIU8NU9irHuAeGYJ2pYmKvUPcB5KQpjn5qtiGnOTz4pw6OPVfS8UZSv6h4fJO3t+1htP1dEFEcRPiq+f16Km0gf6hXUWNUOPkVLVjj5fqgeI6hEaDyRKep9eilqu714p2gog7h0KgBNLu8vmomiPUfNWc3d0Ki6mTfZ4H5IK30YeoSVjVHj5H5JJpjkC1MGerqVr/opSOXkraogKY9T8k+UegpR6umLfV/kgYgegmt6hIj1f5KBb6ugII9R81Id6rmVKUFkEcVs9lsU2niabzlIaXyCAZGrdbv4c4XNlxW12cwn19J1Q5Waxsx9q/CbA96iZiExEybthRDcVUewRSrHWs4Q65AO+DKp6OqwCOYXfad0e14JaaT6RMPY9zaAJOZwNIXiDn+0BE22lc1W7KVrvpBrqW3/AHlKW8jDiN/HwGxYXp3V8N6ckVnyBSqouuQzoTFMBIpPc0GJGQ3vYQZOw7EE4WuNtGsO+lUH5hcluCXVXmr+W1oCp9aPFWsdVvG+SsbRjqrCXCjWcYi1N3yU3Cu9wY2i/O7NDTDS4jaBO0xdc09LeeTcbxz0ivmVl+Itu6SreAY6q1zRAcS2crdjGkSepb4kKkNCYyJ1JdxaKlMOF4vmMdFqaP0TjtXUpGg7DtqOaGkvByuylxL6jXH2Q0OMbJceC6ePo592c/L1lcyvtjVG3uIs3Z3BNq28HT3hb2l+zeJp5qmrFRm0ljz7JNyMpEwufOJgwWEEbiXBd9LRMeHHasxOyY03bhbvT6p29qkMa33R/E75ogxTfdHV396tsq+AzQPAhEpNIOye+fiE7q7dzfM/3KTKnEADkXH+sILDard4YPAf2Izcu40+g/tVUMHvddYPycnFM/dzTyFb88yhKwG8qfl8kiwfg8A35IUP3MeD+7U+aiHP93yqfNBY1Q/D0Z8kkPM/3D/C9JQOPcSf/r9EM+tnyRBXBP2f5v0Szj3f5v0V9UwKR6/0SLu5HDh7jus/BIuHuu6kJpitI5efzUsvqCj63k7xeU2tPug95d800wE0Xe67oUF9MjcR4FWZ/C3+b5oVVvcrIaHZavSbWisxrmuLftEAWN2ydk/AL0R3ZqlWirQcaVSc7YIcGGSQXU90TuP3RtBXj4dBjjZbuh9KVKbgA9wBDoBdZr4sRz2Bc3LxzvdEujivGdsvS8Y7EasU6mFoYmkz8IA3/cPtMIk/ZeTciQsCqaLHg0qWoqtqio6mKbnOcB9lsuqFwYb22SQdybR3bHEWBIfJAGbedgkumFpO7XDI11XB0nsJc2LSAI94Eb+XxVI5L19wvPFS3oHE6Wa9lRrTVpmASHnEPLXSNgygMHs7jYGLrJZjXARJmTfMYP58V1Gje0uDqWGEa3NAILKW3cD7MbtncrTMdo8/8q25iBQo3Pgb96meomPGEdNvlymG0vkmXsEiLvf/AOPl5LKq1HVap+tBDmkNANUuBNpaRSN4tNt17Lu8TpTRzbagNJ4MIkDhBT4XSWEbIp4cAwCYpsvIkTO3xUT1WfCY6TXHaMwlU5mEY7ENdmbl1j4yHaJLc2/cQCdy6ns5oevSptoupuYxrw8BxBc0xYiZgmd0AdVrDtAS0EMGUtDm/WG4It7IAjbxQX6WruZmbqqeYTZhdYzxPnzWV+ovP9Na9JEZMw2dIYsMBqVCxm3edtiIAuSImBcydm1efdpsa2rNRrA325ED7pMXi1yQtd7/AK0OcTUcATe5Jn2YOzj0XLaZxcAMe1uYiYB+yJBsJkREX2zyVOH7rxi/LWK8c6qCod3+Uqbaj+Z/wlBbim8B0+RTtxQ2+z/N/cvTx5urAqv59D8kta7n/CVWGL7vO3mkMSeI6J2mrgqu9MKjruQ/gHyVTW/iT678SdqNXG4mNw6AfBWm4mbhtvE/0rJ18feHRN9NducfCydqe5ua38Hl/wCqSxvp7/fd1KZOw7nMTG9OK5G9RIQ3jmpVWPpJ9FIVu/qq10kw1Y1nf1Um1eahRI9SjOpgjcOFyo1OI6zmn1irvbBhOHK2IEqAHcJ8ULLwnuTkpQomExK/h8dAAIuDmBEGHDZIO1bOK0vTqNFy0zMEO+1Bm4mRAG/euZaFYm3isrUiWtLzVv4XF0y0Q4A+yeDg5rhBvvt5ytVuPp5Q7Owe0M0PZILhwniB3SuTw+HqOE5THGIWjS0dYFxhYX46/l1057fhrYyrTOU52Z2jM0ZrOMXBIsJBB3bDxVvCaQpioXEtDKpG8Wk2/ILGqUWNA+sOzcRZN9LY3Y8nLIA2wPAws54omMX+vO66rD6RoQ+kXnLS9prg1xBDrhoDRsGzwVbF6YDBkZncy82aLWiHEyAOELmm6R2naT+FoU/pziNoE8gPNW+hHyrbqJzFnF6UqvIyllIZQPZkuiCIzHv3AHms1uCO217k/mUYUgbk37wnFDmOo+a6aUivrw5OS829hjD93QpDDnZb8vzRNQfeHUp9QeI6rXWIX0c8uv6JtUPeHkjak+in1B/F1KkC1HqAomj39AjGlG2Z70wZz8wiAvozufyTfRjz6FXhS9mAL7zmaQe60jbxS+jHn5Jpin9GPA9HJ1b1Hf5JKNMcvW39yrFJJRCZJOmSVlTtUxsTpKJ9pQCikkpDhSakkoIFK0cFu70klnb00q0z8FXxP2fFJJZVbz6ZX3grDEkltLOBW7Ebd4JJKqRCo0/ikktYZSONngjN2JJJKsEdnrgFJvrySSUJI/FC3pJIiV37o/dH5hUynSUQSkkkkpQ//9k=
1	Cà Phê An	42000.00	1	t	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1DUEc3o-t6lC4zVbfKvOgw9OCuyxskjdUHA&s
17	Cà Phê Bơ	42000.00	1	t	data:image/jpeg;base64,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
18	Cà Phê Bơ Lắc	45000.00	1	t	data:image/jpeg;base64,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
13	Cà Phê Đen Sài Gòn	35000.00	1	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxQTEhUTEhMWFhUXFxsYGBUYGRkYGBgbHRUbGhgXGBoYHSggGhslGxcXITEiJSkrLi4uGB8zODMsNygtLisBCgoKDg0OGhAQGy0lHyUtLS0vLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAOEA4QMBIgACEQEDEQH/xAAbAAACAgMBAAAAAAAAAAAAAAADBAIFAAEGB//EAEcQAAECBAMEBwUECAQFBQAAAAECEQADITEEEkEFUWFxEyIygZGh8AZSscHRQpLh8RQVU2JygrLSFiOiwlRzk8PiJDM0Y6P/xAAZAQADAQEBAAAAAAAAAAAAAAAAAQMCBAX/xAAsEQEBAAIBBAEDAgUFAAAAAAAAAQIRIQMSMVFBEyJxMmFSkbHh8BQjgZLR/9oADAMBAAIRAxEAPwBaRJlpCe0pklA/dGuj8Hg0oBCQlKFZRavfc84AkKUbTLb8otBUyG+wTbtLewp84893IzUpJP8AliockneACPJu6JBmbogzAEEhiBYd0AXh2+wj7zxuXJqQMmupNG+EAWCJmuVFGDnQaNyic2cQzqSH3Al638IRStgwUjuB0FzDKMazB0kNbLWz0MBNrW6e2TX3fJo1PmAmik10yxnTpNQtd7ZaRudMt19KOltLwABSHrlSeILV3c4mpZo+cMGoX5PvgUxQOqDV92lT4wZEogURS9FUeAMTiLdZQ0qI3NXYZg494MDW4gS5Iey/i2sOSJgUMswk2YkMRAC6ZZulKTyLRi0F/t80s0THV7Jpva8AmTiohx3pVC2BlLAB7V9RxtC6C1QpLtqGiaJ5SQ+f4xKfNY9ocHTDCAAbsipqAWsIgsZRZYeparcIyaAagII3u1YgpRAZKX/m13QEgmYXFVNxG6JZiXJcpegZjzfhDMpTAEpLs9GIH1gvSZnBFrQbBCfiVBqOG07XOETPJFDmHgqCzVOr3g7ApuIjNlklVH3kUKQd8MFJhLEdogUH2gdIDs3ChQMycsh3UlOgIDAnUl/jBpkwAOogga2UIq8ZiwV0AUfsqrUHeBcxvG8J52RdysPNmqyy0nKkBJUWAqada71+EPba2diEScmdeWtEVNXAfM1HNTeLH2WxCk4ZSpoZKyXNXozAtwNjW8G9osOqbKCZUwIqEqdOajVavVah7riK4YyWY75s355/lrx/yJj9u44KVPMlICaGilJzVDaml7O0XOA9pZYSkKllwSDkCWW41ckitXevxji/Y+amSVoxGdbuxSMpFczEuX1B4aPHKJlqU6ZIXNJAJEtJUQHDvlBo5FYzrLHx8+v7I92eFdh/idH7GX94RkUP+HVe7P8A+guMin1ep+/8v7F39T/NOyVLrRD6uTERLv1E96o2ZVGKQWFOtv0+MRyN9lA5mOR2iTEh6dHxe/GAhYD9ZHCnxg0tt6He4D0+sCUv9/wRaEE0zKUKXAJonSITFEsxX3AeMY6q1UatQARIy/3VFxUEs1YAihCjbMOZh5UklI6yrcDaF5ACXcAd7wVOKCS1SdwhCg5DwatCmJIR1ewnuU2sSXNYmqQPE8I30birqDPuTDIOYgt2S/BVecazkF3WH0IdqwYSwRQilwkD4mEscJrDowRdy7kcxuZzAa4kKzIJUQQ25mipn4XLUZCOBaIbO2moqy9oEgJLMbOX5C/ExaCZLNigl2qwJLtTvh6JWqTSx30V3CIAnQqYUYgH84dxWEG4AnStgd4tCkyTlrUG16GEbCSU3S3EMI3JSn9xn4gwKT1VVUpjyIg01fEEHen4NDJCYliTlpoyolJXSgLVvUwvPlks+U7hUd0TSSkjqgMLjduMAbMlLpJrvIpypyg+19qpkIKQUmjDKATa54VFS0KqWzKNXPaTR+b8o5tIHSrCK51Eia9hV0qGgBpFMeMU+plcZwfxJlKBzFJA1dlPuhCehMrss511A77QtMWSopJoxqKudzwfG4QTJsqWDQA9apIGgCdVfIQpwjbcpeFzhPaFCMPkWkqUFOCCxNDewiezfa1SWVkQwmVBfs1bKQXzAUJLk8nEczjcOUrUlDrSC2YChPyPCEVKOXKXp8WZ20ikz+7unn386Y+plOHZbY9qkJlrTLSpBWlkqCwWOVsxUAlTANcPozVg3s97QYLDYZAS6V9lYCDmUyR1lEUYmor4GON2PjUy5nSFOdSew5Zi73Y3tRjW8FxnSLmrWsBDEqUGygakANu+EGMkxuMmp+3H9D+pl58uz/xxK/Yz/uj6xkCzYLj4Tf7o1Gv9Jf4r/wB8v/V/9z9jwS1cqKb1PElKD3Q5u9a690A6QEXlh761/KJomh6KHcmOVYwhbEEkEM4AT61iKgpqFZuNAOcakTKEZlW0S2sESMwsu+paANIwwYllPxVA5qbkpT3q9boKpND1RW/WjFIYN1AeAffACpUBboxvvBFh3DKI+6PGNtRwacE/WNpljUG47R+UASCi90jkHMFVMrYWZ1FvLWIpJBL+AHzjc1DCjA8amANickgjMCQQGS4qRZ2ap86RX7Lw6zMKiSkgkrDEO4YJrQgRm0F9ZQGsmUpJsykzJqVHnmLxLC7ddWUhxbNY0S6lKG54t1On2yaTwzuW0NoTEdIQQoNlGZOiiXAA8zygmCwgEzOFBSUWAqXFK8aqPMwsEIUsmUsqUylhJFMxoCTw0BhRIVJFMyVqdIdqC6llr98TUeh+wOLVME9SgQykBLhiO048wPGOeJC8ykG6iGNnzVaOg9g8SpeHXMUAHXTeUhIYnjUxyuKSvJLlpBypAqLuzOeQzHmRFep+jGflLH9WQc/qFldXhdJ+kRlCtA2tKg/SEhPmJZKhmKjRCtA7XPrqmLQFKTkcBTUGkRsVRn0F243gJWpiVW3isFyNehYkn7PfASouDxuLHnCJBRCrHRnhBeBK5KghYCQg5UoHay0JVqQWuIYnS+0Wu9U/SKiZtRapPQoDKykEj3Bo/rzimE4qfUsjnP0ggqCdHB3bjBVT1O4fM4q/PvMM/pAObpyqzpKQConjSsIupUxIIBAcPvAq/ONRy6+TSUqNXYXd6eGsOypspMhSSkmYr7ZS+UBQqNeHjFVicSSGFnv8Wh3ZmAm4iZ0MlJKwHclkjfX5a6OYfZtmM2aEyJ3+cGdPNKXYpJZ6lNN4eNbRx6ZpTkdRS4egd6s12Hz4xezvYdWRhiEkt1gUFJSGNSMzgOwq1K7geZ2js1WFUAoJZyyh9oAgE7xcUPnFLhZOVMpnjjqzgvmP7v3RGRH9KRuPgIyBJ6QVm7q5ZeEHw012BKn5NSF0JPunmVxAA7v/ANI5HpLCUhw5K6aEgPAFoylwAK6riSKsWDgB3VaJLTu6MNuD+qwBKRMABKggVob11eGelY1UN9EwtIWCQHHLL6aCJJNHVXUBmgDc5T1BWa0AHqkRUp1Vy/E8vGDMWZlHQkmn5QuC1AUg/uhz4wARBcdpRaoowMbmqN0hiRWjmF14mYEAplhRNxm0ahJ38IclLcAtcO0KhXYhyqUGLqTNRXekpm1/6kJyMEJkpkqIKu0CaEAlwnc5iy2grKEL/Zz5ajymJXLP9CYQwi1ZlS2RlRMVUnrO+ZgO+OrqXfTlRw4zsHwcoSJalzGzGp3U7KRFbicWoywJqcwJcsQFBy6UcS0WE5YUMqg4K7G1IivBy1Er7KnIG7MzAtwjnl9rOx9kzlwU5Tv1piv4WlpGXuyxws/GzXCpqcqUPVNio0T3C8dns3DqTshac3WUiaMzv2lqRm+cclKxqT0aEdZIBzZtEij8yYt1PGP4Tw838tYXapCQtYKwknIosCAzKUeB0iGJSF51y1FSixKDcBX1p3PGpsmTNdVUKADoLAEO6UnTuhJUheUFIzuoqUpOq3ZKS1gPlE21niMT0QTLHWIDqfV7DmT5CBSMUhRYHIo6aHd4xrGYYIQnOc67VIBNKl+AeJYKVIKkTAcqiCQkm+jiEBSkg1DH3hbvEKJw6Q+VIAN1J14EGGsECVKUslKQCog8bDuSH74jIxUs9YjKXIBDlJ5wapOf2thaZmB6x6w0G4juinmKyj5x1u0cOZg0AP2khxweOax2ESlQrnCT1xUKOpaN4ufqYXe4rysOAQAGDbuZ4x1XsbiZ0grXLYJOUMwKVgOxLg2JIal45BMpc5fRS0lRJOUUBA4mgFN8dFh5xCDJnjKpKgKaZXCnId9bUsRF8LMbtjp6l3VxtT2im5FKXLSgv1ygqOYPRTXB5u3g3EbSx/SkmqkswfSujd0XRxGdJQolQalToatFViMIAhWQ0903jG5vUmizzuXkj+in3VeUZEGPvD/V9I1FNMaes5bvk1Nye+IZEuC6NNIYTuLJNL1J38oiBcMVb6ZRTURxPRAWWcOkbwEmGkTnTfgyUd/wiFbuKNRIcwVExTEtltVRhBFCyDdZbgGibg+/3lvIQBaidVHl1RDMlJzg0Fn1PKAMXKr2Qe879RGlEVAJp7tGEOTlM50uYTckEsVAV90H6wBSrTIUp0S5qzuDhPnDu08OtagkS5ikgDsqCQ/z0jFzQsgmQsKcOXYAE3cXpBNoFRmHowQKOsOVGn2QSw5xv5CCsKsYWclSSk9GpYCjmIMpaVprrTNAtnISrETFFIqErSt7BUsUbmFRbbNKR0aCVdZRT1i6jmBSS+lSD4QjsbEOhGdLzAFIJ16swgg0NOz5xXe+kleMzEoMBS5JNIjJlglLgByTq/5wUsbJs9XPzNY30LBJCrAlmFOEQVdQENgAAGoD3Kmg/PzjjsXgkrBGXKVUJA3Fw/COvx8xsJKBYZhLSXo1Mz2OqY5mYhiU57E1uD3jR9TFurOZr0l075/KhxOylgdVlBySadolg43AQ7PniRKSlBDigBsdVEtEyFDKkuLkwviZaFhOYOWNXY8bRPftQpPxMqcE9I6F5e5ifnCv6IVTa9gMXFmHZSO+8ExmBIUqYBmFFAbyaJDbhBJn+RKAutR8VG55CH+AFjNpKz5EModkg/aJ07hEXlqqlWS6Uv2S1yPEh4AJqMlQEKU7LA0+0rg8FXs12ILpAHV1YBwnvMPiAYqXKAYlNRUB0sDUl95Pwiox8sGYpaFEqLkpNKHdvHwpFng5RmJUFkjPQDQHgOEQ/VClFGZIOW40bUXq4qDx0aCXljKWiex2xciTiZoCUucpNOrcqc3AYgcuUWu1ZMpcgrkoQpXVIUAyu11tHuTSG8PNlmUqXNOVGXs1IYOSRoA7CKbaWIlrQUSZiwmvVZnADkqDAszU1Bjot441Zrn3samOLlUEZqqYPelN9oDMAdcvNmD3ZnD08mPfG52GSZoWFPuDEMd4g6VJJIUASNGr4/SJb3XHfbGnf8T/AKj/AGxkG/RV/sJvgr+2Mje+oPu/d3ctNaZRTmfHnEqgv5qO/hCqFGzkadUMPEwWUUuaAE2cv5RyvQFkrBBBOYfu0iSEJdnCXPZJzEwJiDqb7kpjAQ3VoRfKH8zADK5p0SwGqqeUD6VyWLjcBfvjS1UYsNXVU1vSMoXLqbd2RCBuUp0jQ2Id25wnix1S7klwyi3hEZGICXAAr7rmvExDaIDEqCcp94kAvx0gAKcJLCk5ZZcKAPWLA3ce8IljsFMUSQslPuA5fMXhbZ/QlYKJZChVw5T960Em7TWVZUNRypRSWG5IGpjXOzZgQpFgRlWXF1MGKKnRq01J4wyzT5yRZM5RHKYgTB8IZwygT1gON/lXyN7GGJGET0uYDMTlCgWqEoKXFQ5ZtRbSNy/bZ7Ts5lLg0A3AjxjS5h091vxi4xmzkpY5FV063rxbvgWHWhKgAgu4HZJNTvMRt50p8bWPtTSVLT+8PJMcqKF+P0jr/aHDKmdGEgkZusRVhQP8YoJuzClbKWkB2DFyeOUW7yIvnzklhxFVtCay0AVdKgeWV37jT+aB0ANX6kWO3RLQAJQUSbrNzoABomppFVMSet3CMZeWp4bVMNdGSBwjWJlpWSVJzZaAc7xOaXDGgcAQITGPVo6mMZMlisCkqzA0DDI12FEjhC2GzFWUEu+aYRqdEjhFotFKtcnnAlp3+uXDjGthBC9CdfQHGHBiFCnowgbsaetNw4wYTASBeFYDBGdJBszGrU+kJ+0E2UAAGKzQgXAHvbuHfDqfP4wHaOB6SWVBPXIcFqt7p4sGjfTrHU8cOaSctddPrENmY3oJ2dId3BDtTWuloclyFJSJrCimA+NNz/OCYVAlzUrnyiUTHqwIqKml2q4u1Y1jbLtyYyy7Xf64/wDqP/U/8IyH/wDDUj9knzjIt39X+L+jo7svYBSau+7rGnhGSzQtw7I+sSmhi9K6kEnujfRlnqb36ojjXaSR9oFt6i58BBUzWFOsD/KBACk6Na6Q/mYGoVGYJfj1j4CAG0qo4bmmpfnGpq7VD36xqO4QMK0qAC7tlERMypbXUD4kwjMONxy01ZPdEMViBlDIMwA9kM3Al4gkFVgOBNfK0TXihLFbNU00gAGDmrUVE5QACyAC441vC0ozDRZns4+yBrqdBFpJn9JLUSlQOWgo5Bs0CROLhJlzAl0tZhWrkVLxqBaTMMySaupvC8NbKwxXSlC4J9cYcwcjpJYa4enAmkF2bglhZLMIxKPgKbhC5CyAkVSQ4I3vpCkiWVEFBdL7yAfnHQzZYIhDEbOZHVU3EQZb8wY6MzJC1pIUE2cDi1HhZWHSoMtIdrpYEGG8NPU3DfAVzHUQ3fBci05Xb0pikcQOfpopyeDuv4Rfe088ZkBIdnJPFvxjn2Zn0BMalDSSSzPVRPhEpcns5jViWG+I9KRb3T4xEg5f5e+GTJxIYNRuUR6R/DX1QRCbPa4egH4wpOn16opxvDBh61v6v9I2gOo15bvzhLpO/wBb/nB8OoqIA9cBD0S0kpfu1h3DuwbdbjuhHoZjOE2sl2hvBTHAehHkeMGE5LNUL2YQFBYUAbZbPx0/OL7YRV0abEdahob73rSLCS7g6QdCQNPCLzHXKDbn3T/p+sZBH4GNw+DUkyVSlOULmSfd71F/KKw7SmIw6FkgqUrUad0bk7aWFoTMQOszNetjHL210rFaSTZTDf1UxJMtgzX1Tp37oTlbbClLGWiASS92hnA44TUuAQHasKygNUvldqdY95MEVh3uQngov5CBbUx3Q5GSC70tblBcTi0DtqCSfGEY0uUjeSPugQHHTZacoKJa2JJcgNye5iOZBGYEEe87/GEUzELUwmAnkknzEEoPy5udMxQCQXFEqqeD6GBSZmeYCETUsz5iyWA3amBTpIy5cwDlyWA8rRmEkZesVPShc/B2g2HTbDxjMrT8biOkVtgMHDg67489wE8pDO7a/OkWMrEkt1qaivjHPlbLwtMJfLrjtWWQQkPvDwP9bJHVyjk8c1+kZWKWCid9O54LLnpUuwzNf7Ln8aRn6mfsfSxXMza1WA7oh0pVcgNpFIpknMo9a5TuHpodl4ofjWH3X5Fwk8Kf2jm5DSpIJB5mkU5xgsdGD8YN7TSJsyaCgskJrzzH8IQk7FV9tZ3x14Y7xlQyuqLNxLjq72gU3Fks1A/kIa/VcsB1G2pMJ4qdh5X2X7vg8bmDFy0UM99YmiUpQKgkketNYW/WC5hyykJRueLbZuDUgdeYVHcOzGrjopbVBicStL9UjioQqnEKd8xfgW8I7iZLSpOVQBB0MVOL9nUEPLOU7jUH6RvDPH0zljQdme0ak0mDMN4uPrF3IUFDpE5mLqBT2rvbXkY4qfIUhWVQY8flHU7GUeip7jDd9qDPGTmFjlfFXOzMcVDMlJLEgtQvq6XY+L8ItcPMC7Fi9RUHwNYqNjpKZYcMbtQ0PKLOWxuxG4w5kLFjljcI9Gjd5GMhbGnA7SxGdUqSmyQAeevlDeKMoK6XN1kigcNQMKRCV7MaqUSecOS/Z6Xq8TsntTurm5WPAlqAqpZAPACvmYtsDtZEtASMxa7A3i5RsSV7ohqVs2WPsCDKSjdcjPxa5s0KyKKU2G/WGEbOxExSlqSl1Cjuw/KOuTJAsIK0HA5cgn2fn9GUZgHLm9eEZI2BOSoKDAjUWs0dkPlGKg2HIj2aUoutRJJu9YcTsDq5SpRA0cx0MRIpBsOckoyEoFk08KQymZHN43a/RYuclXYKyxvl+oi2w+LSsOlQUOBeObq9Oy7+HR0s5ZpYnEG7PqKOXs9+USmYslg9H8OI5PeEOkiJmRHSu1iJ4JB1rXVjDsibFH04TVRAG8lh5whjvahCQRK66t/2B9e7xjWPSyy8M5Z44+XR4mcHLmKzH4mYCBLTf7Rq3dANizCqQhSi6iVEqN6rUYa6QG3hxjrn28enLfu5VfQTVdsh95q3JNogvZKSO0oq3m3hFmuIKjXfSmEUc1CnyqOVrH8YsMHjSkZV9x398FmsaEPCM+Qw6v3T8oN7NdS54IcGJfpEcycVkq53MX+Mbl45ZvlAg7KXdFxtPFSsv+azab+6NbAmpUkFIp1ksd2aKc/5hcpBA1Pyh3ZC0yxlcitDz3w/jTPm7dXs0JSgAE21qYekTUlTU5xXSVONOcEzMTUNvP1vDmWi0uKb/ONxR5f3z4K/ujUHfD7FkENpA52IQkgKUkE2BIB844jYm11IW8yYcpu6iok6FtOcLbdxQXPUoKzEAClXo9ALw+3k9vRaPGwka+q2jjdm+0ZRK6ySrKksX10DHSI4r2qmZFBOV1DtCmWtq3LDzjPbTdsEiNNHnmD9o58tFVNmI60wuePx8odR7VzAlnSou+cigDWbXnD7KW3cJaIv67oVwGKK0pJDEhJPMiE9rbdTJUlBTmJDmuUAW3RnRrYnnEFnnCMjbMpSAvMEgkiu8acYal4hKkukpUDqDAHl3tR/8uf/ABmKgKYuKHeKHxi19pz/AOrn/wAfyEVJjpx8IXyYRtGaLTV/eJ+MSO0ZpvMX4n5QpGJg7Z6HdfY5USXJJO81PnE0wNAeDzKCAOs2clYkyym2QFudfnBypKmHYVuNu7whnAIyyZQ3S0/0j6QPEyAbxz3ytAwtSaKqGJflGhNBFC/rygIzo/eTuP1gIKVdg5Ve6flC0ex1KgSjGgo1ChbXfEVLhaMKdJSq4fxjEyUiyR4QURvLDJAwJSDcQyJcQnpISSkOd0EBjZ+PUgM9b17L/KLmTtcapPFqjyjj5E1a3GZIOiSLxgQpNCVyidQ+Q90b17J2f66lfveBjI5Do5v/ABCPvRkLtg01jcAqUoJUt3FhoPWnCAT8RLSogpCSNdVD1SkbxKJiCkzUZOqTcF63o+6F5yAtZK0kqajCjczFPyX4LTFElwOo+pt3c4IZScwOWgYE6BV2AjJiEofOoqZVADThThviBcI6hLA5ubCpffzhksJs1KJeZs3Cim41sYHMnvLBKSkvVVMoHIHnCq5q1J7KWaxZ/KsHlyxk6qtPtH4uzwaG1t/iuZLUEoKSgAAFQcqZId2NItpe3JGIYT5Jf3gHApvoWrHL4QrmqCJCRmfrfDM8dpsz2SlpUFrUoqoSH6pIo7N+UZujTx3s2iYEJQvIEUAAoHNaQ3sbZXQJbMVklyTy3chFmEN6740Ph9B9Ynum8l9qv/lz/wCP5CKiLX2mP/qp5/8AtX/U0VDx0TwjfLcbERETTDIRMTJpEEwaUlyBCD0lMpgBuAHy+RgK0w5Mtw9fjC038Y51yUxEIYnDP8jFpMT69cXhaYmCBUKnLRfrDz/GNpxCVAkHTvEOTZe+K+dg3Lih3iNalLdieHnF2uAkfAD4mLCQsKEVCCUnrD+YbnBqO7SLTZaaKLggkV5BvlCyhytYjCLJzIWQdxt4RknGFJyzklP7wqkxYpTBwgHqqD8D6aM7aLr2bLmh6HcofWBfoU2XRhNR7qr93ruhgbKKSVYdZSdUGx7j+MN4bauUhOIQUH3gHSfp5w/wFRlk/wDCr841HWfpsj9rL+8IyDdJ58nBTZqkhAeh7R4h4uR7JzwUqStBIFQdDSzeEXGw9gJkHOuZmJYMeyKgkAG5oN55RT43b04T1hCmSgkZQE1y3d7lx5RvdvDKvm7BnSpqj0fSKPWdiBxaKvEIWlVUdY3rTiwj1XBrKkAqoSA4FnyuW74o/aH2bXPmBaZgToxFbi3p4JkK4SUkqzZE5WLkq6tr0gsiYlSkqdCQzKPC9frzhrH7KVKXkUSs3Ym5c1Y/OL72a2OlShNmykg0y8as5A+PONWhd7IwyRLS0tKCUgkBLam/cBFslOrafL8Y24AHw30J8fGCFQcD6HUCJGE2h9aRtrd319fERIX9cT9P/GNkjyfyb5/iYA8Z9qA2Jnf8xf8AUYpSYvvaxDYmb/zF/wBRiiMdGKN8sRBExBMTSYbIqBDuAS60D94fGE0mLXYMrNOl0frA+BeFWo9BVr69WMAI9eufOG5kvR9482+R+sBy8b/Ow59YeEc6xNaOfr0YDMRw9X+kWPRjj6/IwMSuB9eh4QBWmRwgS5HOLhUngT658B4xA4Z9Ph6u/wCMGwo14eFDhykugkH1eOlVhL+tKeXxhaZg+EPY0r8LtGrTAx36d+6LaUQQ9CG5xXzcHwgCUrll0HmND3b4Vxl8HLp0EtbXDjjfuOkOIWlYyllfuqv50MUeG2klVFdU+R5GHCIxdzy158Hv1VJ/ZK8D9YyEenV76oyDuG77A2/s+fMmhSAFBIAAJDb3NaVP5QLZ/sqM3STyyncy0tkfR33tXfF9+s0O2tqV4Cvhaghgqdw2ha9e1QdzeN4pthSbV9qUSVGXLA6hyqKnA1cDWxH0N4Rw3tXOXMqGzKZMvLo9eteg7uEE9oNhA9aUgZnfPQtyc+mvHPYRE4KSlIJU4ZQDV4nSNSQtibRndNiFZkKUqwCcwsGBItYeUdmjaEqQEImKSksCzEt1yK5Qw8NDWCyknKHyu3CvVq1DqNHjlsXsqbOxBUosgqrewplBrpSnGFxQ7gznAALuNNaDm9+MS6Q3rfuur6eWkVstYCRUmg+Cd9e4vyiS51K1fv8AePr5RnRnjN8fHRPjc7++JfpAfz8yf9or5iKeZiGtSvzDc7ce+E520DcKJp8Aaa7xv7oNBVe1WwFTSZ0kZiScyRU0PDXhyvHCz5eUkKBBFxHoU7FKUrNKJCywXLLDMwYKrwYg6iGlSTOSBOkyV6MtdQ/uqykjuMVxy0lZt5cIImO7xHspJNRLUP4JiSO7OYCn2Xlfsp5I96ZJA/0qeH3wdtcegR3HsnscpIXMDVF9A+vOGdm7MVKUDKw8pLfaWrOR5E+BEdJhJpACFZXUakXJvTUBufMAl83PfBzHSU6VWnI/DXiVV4QDI5pr67/s/jDSZZLXqPMgbr1Ua1ifRajnbmWJ+7YxNsoJHr8uHx0jP0ZvWr/XThrFgUMa6N8fonhexjOiq3c+4s3d2j9IAR6D14EDzTSN/o47vl47gYeyNUehUtU8U7hGui0PofkngOEBq84bh6e3j8I0cMHcD1+Q84sFy+F/j4b1HwjOhpbdT4f7fwgCpn4Oxbd4/m8LTcGCLevTxfGW4IDc/XDMYD0D3HqxHwFOMAcnitn8PXx4b+UKInLlUDkbjbix0+EdkvB+vXeab6whidlvu9evK0MKL9bj9mfH8IyHv1MfdV90/wB0ZC7cRuq6VtJaVEUSQWO9RHMU1i32bjjMqWY2Yh3eyk1qN7eEUeIwgUxsrQ1ruN2qGfSkb2agodK3ILHe1q8q740OXXdJWvnzT4348o1mFKDT4J415b9NYqhnA/y1Ajcp20tuuGoKiJy8US4UkpPEAghgLA1tcF4RLFaqUbWvcrj1uUBXPO8fF6q17uGsKzXY9kguHGvacHfcULa1ga16uBv8VXcc/lD0DBxHHy/h9fKAKnUqo1DeQ+vHkIgpfH049fONSzz9ZfLy4wjamKO/06voPCME1IH2Xp/t39998ZMlvWvrw38O+AKlbvyr3buEABkCUSlM8EpDMtCsq07mJo7AUOgFmjtJGyJEyXmROCiLunKs/ddz64Rxgwps35W+f5xORh1pqkkcvGleX4Rre/LHbzuLfEzZSVFIK76hXxYCIpmhRofHtcbU3UeBIGJP2knm5778D9YZk4OcpnWEgluqOVieZ8IzY1BEywmvCpOnGGcFJznO1BQGlTQUf+MaFyORieG2UlgVHMdMxcOW0sD1tXNBSLZKjWt6+IJ14lF4UmhQsmo4/Mtxsmj8xE2bu47j/wCJ3comz23btA93ZgyBuFbGImWX+Pgx42Kt1oYQSirW08QH1p9rcYkom/B9L34aqG4RKWjff8WLffXalKmJAvYVv3+G9SfC8ABHLjcWFjowISmrC+sbShvHyF2A4AnvDmCEagcvlzLJRvNbxpKaVBPDhqKnckUr2oA0hyBQcx64q3WvBAD69fvCvC8RAO52v3UPM0WfgIJKD9oN6r8V3920ARQCasKfn/aIGscqfk5tpmPGkGSKvQanmfgyjq56thGwhi7Nrbd43ASNTXSAFkoJ3b7a/mUjQUMaMhq6XDDS/wAG+9DShV3et/EHv7R10jJWrsCPKj66hiK+4KQyK/oqd6f9P1jIc6NH7NXir6RuDQefSrK5/wBkBx3bP8SP+3GRkHyY+y/p/WIZxWv8I/pTGRkGH6hfCs2vZHP/AHoiHtL/AO0r+I/OMjI6Z5wTvyd+ynu/qEbRY/x/2xkZHPfKhjUcx/sheV2TyP8AUqMjIz8Gb1Pr7QhgWPIfKMjICMnX+X4LhtHbPf8A0LjcZBAsPtJ/hP8AVEZd5XNPxRG4yGQkmyf4j/QI1O7J5q+EyMjIDAn9qZ/GP+7DC+0f+YPiIyMhAGf9rmPjKg8i5/gT8ExkZASabjl/tiKL/wAqv+5GRkBiKuOS/wCqbAhf+X/ciMjICET/AO3/ACD+hEHw/wBf6Y3GRqApGRkZCD//2Q==
2	Cà Phê Máy Đen Đá	30000.00	1	t	data:image/jpeg;base64,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
3	Cà Phê Máy Sữa Đá	32000.00	1	t	data:image/jpeg;base64,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
15	Cà Phê Muối	42000.00	1	t	data:image/jpeg;base64,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
10	Cà Phê Phin Truyền Thống	35000.00	1	t	data:image/jpeg;base64,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
14	Cà Phê Sữa Sài Gòn	37000.00	1	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUTExMWFRUWFxkXFxgXFxcZGBgXGBcXFxgYFxcYHSggGBolHRUVITEhJSkrLi4uFx8zODMsNygtLisBCgoKDg0OGhAQGi0lHyUtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAOEA4QMBIgACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAAEAQIDBQYAB//EAEkQAAECBAQCBgcFBQYEBwEAAAECEQADITEEEkFRYXEFIjKBkfAGE0KhscHRM1JicuEUkrLS8RVTgqKzwhYjQ1Q0Y3OTw+LyB//EABkBAAMBAQEAAAAAAAAAAAAAAAABAwIEBf/EACgRAQEAAgICAgEDBAMAAAAAAAABAhEhMQMSQVEyEyJxYYGRsQQUYv/aAAwDAQACEQMRAD8AHlzQQ2ZILaDveHDrWzn3CBVHZX7qYnkrUE+0p9DRo853CFS20SBxMRro4Jr+EQ61QlPFzChZIPWHcIAiKQACL7qhzuwYkjYMIaUkUow1Ua84cgue0fh4QBIkMn7p11MQTVJJYoBf71+4ROgpJcEE83jhJA0rC2FXO6PSpIynIxJANiTqYFxfR8ymUOkBgQwDntKIjU+j2HlKxiETU5gpCsgIdOcdZy9CWSRXeCPSjChGKASkJQtCCyQAl8xQWAsWSH5xbHG+vszc9XSmxGCXKwfrEBhQJe5BIAXyJOvOKfEYh1oC0OxYEG5apbYR6X09hvWSZiPvJUOTgt72Mea4bApVLC0qZS0UfR6qaN+Xx44a0x487l2m6NmoSFBK8yiSST4eEDTROHXWy2GUN+K6vCBv2ZWbIXdVCRUJQL13MHpxwJQlHVAcqfRI+sR1zwqFkYtUtJObITXKQaIFKPqYm/bgsELSxyOpWz2HOJDjJayfWoFA7irVo/GB5OD9aFZDZTqegUdB3Q/5JJNmD1QQjrAVXu92biYDVMmpGYAlz3RZmQJEkkh1atuYr8N0kpCTXMHCQFVc6nlBOQPnzAEpzhyQ5bRheHqklhW4oFawOJwmj1h6ujaMC5bnDMbNUtQWllJSKAXhaJNNkgVLg8LRn+lUAKdr7WflvFmjFrBYvuQr3CCErQpwUkEV4PwhzhnPH2mmPmSVleQCtyODP8IEnTQC6PAxbz5vrFHRSXyqAYlt4qsJgVLVdgVZSXtWsWk43XLcPpp/R9CMhWGz5SVNcsSRTfjTSJP2pCiVMUqOjFzwJ1FYEm9GKlLCcOZkwFAzKyvqXS6aaje8B4ueoKqwLDRjTfjQRq57x4bud9ePgFi5C8xCsxQ9BSwsCRWAUrIOVILvRrvanwi5m4ouCLK8mGYRKDOOYhLpuRQkVJzewzPCwvsljN3Su/ZZ393M8DCRpf2mR/3KPEfWOh+2P1f8Oj9HH7axTl+tb7ohZR6wormbRyZpKe0SdkhuMNCfwqPMxyOhKQz0SHu5vtEipgAoSPyiI8+6UgnvMTiUSBUgt5pCCBQ1y96teQgXETCkhQlmZRnFG5CD5iSAPiqBMSmaQ8tTDWle54cCLouXlzL9X6sNYlydXaO/tKZmrLARxUMzcodgMMWXmExRIq5HG20RS5cgKCUycy6avl4k6Qws+j8SpOLlKCwEpUnMlnLKOU10oY1HprJpKmfdUQfFKh8FRkscmcCTKSguA+a4I+Ubb0nPrMGZnBC/3mH++L+L8LP7pZ/lKnxDkGPOujpIISG7OdN7ZVqTbuj0ATHlpO6UnxAPzjDSkMtVKJXMH+cmvjFP+R+Kfh7SypdE5QwcvEOJw6VAgo7VC12hROfI9KmG+tu6m60cbpV87oihyKBq5B1YUESpUJMmt7ltVGHzQWVxUKw2YtgoHdqw9kqZfSS0gucwJYBXDtHlCTimdlAGQlyOWvjBuJwaVjROU15G4hMNg8hWtTPo2iRaNbnYD45CsoloHPgBACAUUsR1lN/lTDiVFRmKBAv3aCH4fFqqVAKqBa6jp3Q5wR0jHkgmYMwFt820ET15EBaQQ51rekMmolqLCmU1a1b98GpCSChVUkeEZtFm4o8ZVQC0lyOqUMDSrF4M9HugCuaXHUSHmPYqugF76uwNuMGfsKOqSSSkg82PuNotuj52VQYs5DkE0GtBeLePLH3n0zMOdiJPScv1hljtJZyAyeQ91qUjDemA9VPUVOymUmgFx/X3xtcWqQAZiHdZ7SXygmhIID6XrU6aYnpf1ZWtIBVWqiokniX1tG8ss9fu55+Kz5sv2gEzc8pkoGYEkE9o0Pu+kPwgZSVTJbsQctCHB9+tIYpHq0AtyGtIsOj+j5s8DKkpQSylE2sWpc2ieMuXEcslt4aL/itP3P8AKP5Y6A/+ET/3K/A/SOi36Pl+v9L+nk+v9L2VMJBYNShNBES3NHKuVBEqZd2JY3KjTwiZcxuqEu2thHE6UKJZIA7LbVpziwBoK1EATJuj11CaxJJmMpiwBHeYQdNBerBtSfgIAx88pUMkxYo7BBIPPhFnNADEgbV+UVk7G5FE5i7UBSSL8IcB2Cm9WY6l1FVLDNygSXOQOrKC1VFQ4Te5OsH4CaJmepIpRQbSrPpD1YSW40OwLe6DYQdIhSj22H3XbxMbroZPrujQij+qXLYFw6cwTXuTHnHSOHzrOSWSx6yjUdwj0H/+fkJkKQzZVZmZu0Nv8MX8HevtPy9bE9F1kSz+ADw6vyjFTltiMQnQTV05pQr/AHRsuj5mRBls5RMmI2tMU1eUYzpKURiJyv7xT8HCEIvq+UHvinl/BPx/kiVNJKNLxD6s9X8zxIJKgU9UsAdDCZezRr3jkdBi3F9VUhC1S9cwhJagAHc1NoZVTfm90Mj5hJzN94QxS78xDkPXir3QwqGguqAHT31YgkACAMRJr1QAUu2z7wVLY79qkIW5X/rDgCyZWVIBvcn5wRKmVr55wirVtDJZPKACwPCJQ4DQHImVeDUGM3g02MxyZUsZkk0oAKd50jGzJmYuwHnU6njG2wiXBJZ9Hs3KMz0zgCmca0X1n0A1Hc0W+OHN5ZdKuckkEscovw2g/oKfPljMkD1RckkdkgCorw5Uh2FwhmLMpKwEvc1qLUi76EwU5IVKmywZdWLg7U3IL68YeO50xhLK7+1T/ej99X1jok/4blfdV4mOjm/63/uq7/pE+UEP4ZvpEsuY4qc2mwERJDF1BxuT8oUkGrE1tYfrGlzgR2XY/h+DwkwhJo3O5MIiZxtoAw8YYhV99ADXxhASmaVvRtn+MV+JnrSohIUpVKMG8dIKTNCbhi+7k84gxXri4QGSdRVR8bQ4DipZlnMEg7PTkTAeFkj1gKlJK1Fw1WAsBE0zDtKy7q/6nmsPwODVLWkPLq5ZKanvhzoxsvEsWKSA7A7trwjS+ic8etUkaofwUPqYxM+UkrJ9VMXWpcgcWjQ+h4yqkkUz5ie9KmHIAD3xvxTWUqfk/HTR41IE2YzdbLMbiUhJ5OZZMZfpJZCy2prXgI0WN/8AEqq2aSg8yFTB8GjNdJjrk7/IRfy3hLxzkEUjYeEPlTijstargEeBEMaGmOaVenzp2YglKQ2yQH+ndA/qQSGo2mh4A6d/jBU7DLSAVJKQqzhniL1cH8krs1gQ1T7o6VLJZ6XMTYlJTMVswPeQfjlfvgYLJKeRgNKkCjcYGzEQ9YIIPCBlYgikBJSsa0hiZsBvWsIZgvGtFtZyZjcXtBsucE/OM/h+k0BTFyNxGhwkyVMDJYjbWFlhZ2cylGYVQILWcxHjujDMIU9rAwsoiWW0aD0KG7P4d0UwkqeamT0csTEq9WGcB07fGL3DyGDBRo+x1iRNBDkK0jetMQvqlfe9wjo5juPCOhNM3m0qD4mJEFql+8/KOlpctb8unMwhQ1PhU+Mcy6RfZrX3QxMzauwAb3w1I8fExKMKQXUQNiS58IRlRL1LAfPiYindIqBCUh1EsK+JO0Fpkp3fio08IFxOPCVlkS9nJD9/CHIQlcwqlgjLmCtTR4hwi1hYBMssSWF3iNU15aVdQqBJAsDyiPCKJXmUlCTU0LqMHwYmbIWVOJqgHfKLRe9EYYy1y27CVUrYF6dznu9+VQFkH/mBAJOlffGrwq2A2OhqDzEbwuryxlBvT81p0pW6FDwUk/7orxhwtXWoONIskYdKikt2Xatnuz+aQSnDpBdlWZv1BJh5fuLHhVyejUTGTY3oHoLjbaLAYRKVDKhIKbFg7nVzV4mlkCyP4/5Y56ux882jEmmu1XjHKihZzoLMk0IoKpIsXfnrAR6FmZ8obLoslksbOd+Ac840EwE+ymmqqnwtEK0Zu0So8TbgAKRrj5L+GY9JwmWJaQaB3P3lFnLaBgGEZteLYnbSNP6XYTP6urMT8ooE9GSxf3w9b5KcK2fib1eGHNokwXicdKl8eQir/aps85UkJHyjcw+2bl9D04JZS7h9vrFXjOj5wDkOOH0i/wCjsEJYqSpWp07oPBEKZ+t4O47nLBJLRNJmqSXSSDwjYz8BLWGUkcxeM90j0OuXVPWTwuOcVx8kqdwsXPo9jlTcwWapAAP1iwnzzLWlISeswoac8sZv0cmdZQ4D3KEaPEJUqaghmvfQfGMWSZHLuLJM1abhx+H6GC5c5D1IBaxp8YEKomlq73hzLcGk3rkfeHiI6IMg2joxs9BGHdtCeq2LAaCM7Km58TQlk8aUDRb4npBKEkkigiNmlkuFxctRUlJrV6N74coVu3xjLYLpHIFqFVKokD4xEZc5YBCVlT1JNI3+mXtGpnsKu3EwHICVk5VgngBFbi8HiJmWlAA4JvzhcJ0RNS7dV6GD9PjseyxxapbBKpgDcRWOlLloS+YVHCBpPo796sHy+hUDug9J9j2VZnyvZD8k3je9HJzS0K3Qk+KQYz0vo1A0i/6FxSQnIqwLA7DTujOfEPHlaSktEiZ0SJw2bsqBHvhDgDeJTd6a4+XHEw9CnDiApslosMBOSE5dtbvGpfsrNTgikxBkrDsTiUpGYkf1pEUzGp74VyxgkrMenWNEr1VCSc7AcMl/GMZMxK19lyeFEjnvGu9KyFrQ7OApuRy/SKNmpF8M/wBvSeWF2pZ3Ri3zEhR2+kROSeqMpHdF9A8/DpVUhjuI1777EmjMHjyOqoViwlzgbGKebKUB94e+IZU5QqD3G8LWzti/M6I52MCQ5LAXijV0oXZKXhZuILMoOTpB61n2h+F6RTMxAAACSCHa/GNMEpORxa3hr4RlZcoJWlbMRt740eCxCT2S/Aw7fotLYTBvEmEmhQNoCNeERZizEt3Q5kNLduIhYp/VHy/1joPaD1UOE6Fm16xD3g+X6Oi6yTF8Ew4JML2PQDC9Fy02T4wchAGkPCGjssLZlywig0SBPKG5YAZCaQ8DlHd8ARvAUnHBE5STQFiDsSBeDaRn+maTjyHwjGc3G8O2sl4pqvxvFrL6bWBViOP1jziRjFoPVUW2uPDSDE9NL1APiI5b47virzWuW0n9OuGygd0Ap6TJU9vO0ZlXTH4ff+kRq6VVoB3mD0t7E1OmsmYgLBG7Od23gXEdIJTR3Owv37Rl5nSC1e03Kn6x0hcamBbH4/FuQVav3WiEAEOkvwhuLnZcvVzCr7iI5ASSCg8xzi+M/ajl+RVDyYgmQ9U4iix3xzA2L8I1pkOYGnyAdn4wWtPdziNQhzgAJGAyv1jXakEIkgWHfEsNMO20pJDFpiNK1DzWJTEGKnhArraHAuMP0ofzb7wWjpWXq/hGTVNUpL5C3A1hJS1kMiY34VfWNesrLW/21K3PgY6Mt6rEfdHuhYXpiOXoSTSFnTQkOogDcxj8R6RLygABJJ7V6cjFX0r0suYAkrcA9UHW12gmJ7eiInghwQQY71guCPGPNTPWAlKioipypt+sSHFLy5KhIL5SYfoNvSEmOasVfQ6iZSHL9UQz0jkTVIAlVALkAsTtzjOjWpTu0cQN4yuDnz5MuYpaSGAypNes9+USdEdOzJkwIPWe9Gal4fqW2iIGhig6dpOHFA+JEaFIYbxQekKWmIP4PmfrGMum8e1e8JHRxNbd8S0rtFMQcwVsIljjDMx2g7HR6RBmGECAwZh4VMTOS4EBrw4vYxYZXEQzERbD8Uc+wJxC00UMw97R0rIogpU1XI1iaaiA52Fe1I1qMj1h4EnU10evCB04mYihGYe+G4jEBfZrQgjUVGndCmNG4mjssAJWQE1bfxgrDzcyQd4dgRoxqHYunmILVhUrFWI0jjJSoVSCN4ZL6OUmslf+E2g4CM9FLTWWruNoR0E5Z0soP3hB+H6TynLOQUncWi5lSZcwOMqh4iDdnYZz9gk/9wY6NH/Ycr7g98dD9oHmktRKmUnvJvyiVEtAWaUdne/ARyJaiMyiEtoBUG1eMMVMUlIZiEl+NbkxZNYzJvq5eZIL939YhTNK5ZOStyp6jugc4kKDBGbj+sSYOX1WBJpZ/dSFwaad0iohKZRVlSkApSS96k7xYYH0gnoZJNDb1ndYxVicQMllkMPlb4RrOgfR4KRmxCQpRLt93y8K61yFv0Vi/XSwpSRUkUsW1HjBqJSRYAeESy5KUgBIAAs230tHKTwt7vLRGtGgDz54RQekw60sjZQ/h+saIJNvPmhii9JU0ln83wEK9NY9qSFCobCEmJLFUI6OhDAZwgvDmA0U/WDMN8YVCwlCnnn84asefPmsS4YU7/lCrRyHn6tFsekMuwS0RApEGEefl8KRCsV1jTIGamAZ+GHfvFqtHCB5kvhDgU6yRfrDfX9YKwU5LAA201iVcmBJuEh9l0tJZguUvh3ih/WKORPWi/WHvizwmKSqxrsbxiyxqWVbywFhiAsbNXw1iJPQ4fNImFCtq/D+sRpg2Viz7QzcbKHfCl0Znqsb95Pgn6R0F/taN5njHQ/Y/wCzzeRhs565ZIJPPiYU5QTUZagE3a0egz/R6StZUQS+mh80jMek3RiJKk5R4iw0EWl2lVKEBIvRqA+aw5JTlBSFAuCQLciI6WkBWYIOna315CCZODWtVJgClFsrU7oYaL0bwcouTKHrBlL3u/hGqkp4eT5EBdB9FJlIZ3JqSd/l2YtZSQKa/T+nGI3mtQwefPcIUD5+fcbeMSE2+pOv6f0hJfHv931PCEDR55+Xii9Jqy0H8XxSY0Cvj5778Yp/ScAyn2WPgfrBejnbKEx0ITDUkEc4lV4cowrQ0BocIRnAA8oLw8AyqDvg2QKwUotMNa2vn5xIsf1898dhR1e/x1+RiQy9/Oh+HC8Vx6Ry7DzZfd3eeMRFI3+HnfwgtSOH6+T8YYJXj57/AP8AUaZBTU7+d/nDDIf5+fNos/Uv588PfDxhyfPnhAFQcJekRLwnDz84uhIt52/SFOEHnS36U5wBnJmDMDTsFtf3xqpuDBFvPloh/ZQRx8+e+HsM7Jxa0UV1h7/GLTDYtC7GuxoYdPwT6e7zX6xXT8E1W8/SFZKJbFxHRRNM3V746F+n/U/dteiUES03NE3vZN/6QRNwqFdoJJvUDhb3xnvSD0g9URKQcrJfNTVgAnwf5RnZvSkyaoLW60pAbR+LfO8bkZXvpdJloQkhPWKmppR3MB+iuESpalZS4ZirQuLA8DwiPG4DEzESylGZhU5rPZ3OgEXeClKw0lcyc2Zny2rZIHMgb3g+Av8ADpYMT9at3+1oYVF+dHpq16cbERQ9AdOqmqUlSUgAPR9N9NLlrRoEhrvehHfbwGsZ0bkg2NHG/L+bjHefGx5dYViVQawHjXUC7fdHhCENpZ/cS1+Q/WDQR5btz8+KaxX+kTGQrgUn3trzEWmWtm500PD8IuxgDppB9Qvu3ftC/wC7r4wqcYVUII6bDQYlVj3jgqEhEIaA91MA8F4ZUCogqQYRr7AodD8bNy+beMES5Q8be4UpxTC9Fy/+WOJLeb3CbQQmR3aP9d7i40i06c97QCWPNtL7dpO1oaZbmnny4r+GCUJHcTcbHatutodLQ9MmtbHfj8D1jtaGQYS3qaDu10/zHX2Yd6t3pp4X07z4QT6umvHetTXWilDW0KEcLX+fKytoAgMvufl3t4ne0ImTw3FKb/r4Wg0yedPP13vDpckfr8/Ftu1AQNMvfv8Af+vhEKpOhDfL6920WYlJ35d7fWp5wqpKWB337r+7eA1QcLTz59/sxFNwL7xcZda+WZ+NRtrCGU9k00em3u8eyYAoP7N4J/eMdF7+y/8Al/H6R0MlF0x0ShSSpMsFZp5rw4xjVYabKWczng1t6A1j0dJvyL7+3cnldjD/AFSKnKLsCwNcygzswvwhyhReimGWJZK3AUaA3soE6M72fSC+nejFTkBCTR3Nxu1h+LURbSqnvrQvcaXI63GGCYaEsKi7NZJobaKpQwjVnQHQicOGupRqoltCA372+sXKXerDfl4cRcGB/WsS5tdnpbS/sGlYQr57OOAULGh7I2gIWlfHyW8L/pCKmpDV2/2/U8YFVNAJo777dYXuPZv4wkxY30py6w10qLvCMXLnB6qsa7+z9TtEOPZUuYjViBzBA8XgOZPAe1j4HMdbCovvCS5wmTUywUpzqCQokgDMSxLdkOobwaDF4lDE6GIBGk6a6NKpqkpUhSwe0hQKF6haSNwxPF7WjOzkFJZQIOxjGWNimOUscDDgYjBhwMYbTogqRASDFr0aNk5lcXCE8SdTwtzhzHZXLTU4CVllgas7e/i1QmpGoiZewps7WqB8UWMRYQKCBVzvZ1OCws1QkMN7RKmWXYfE2tzo8suQYtrSHZEJqXpf61DVos3FMt4kULHhVvEtW3b10tDpUsMSfClBU8hRSxpYRLSxFdfftXRdK3hBAEmx76fFhwWLbVh+XUl+/jzu43pniUjhY30f4O44dqGpQQdnsRqLA7s2XU9kwAiEVo/C/Bjb8tW1MPQBew3tQ215Uf2YUpLObat8xZwCdB2YUS1Xe/xqSBWp7YubiGCTEbh/JfT8wFNqw6aCQ4Na993Zrm+/aEPItVju+tK+OQvTtmORVrNw82tWvZgCEIBqRXh3ux7yNO2IVwNRuPxae8vRj2xEuZuDb6DXVqbOPszHTE70Fzwu+nAtT2RAQb1qP7yZ4J/lhIKy8Zfu+sdDDHoxxTRSO8aXqAbHrGvGCpHSSSSyq0d6HtA6UIZ733inkYpaKKGdObfM1tdPkIk/5EyhoSARUBVEvu6q8WhGujOIa7Uq7igQ+uZNUmziOVMNb14h7LTr1VFwPIioWpcsMl1iopVgKAkHjCy58wrFEgMHdnVWrkFtSbEQ/UbWnrKmzVtRn9Y1Li44Qhmh78rV63Gh7QjPdI4+b/0wCEkZie0kuB2T1kniAQ0cvpqWEE6ilw5Iy0fmnUQ/Sl7RoZeJFL6X/wAG3O9ojmYoM7eWBf8Ay/pFDh+mEqQSU5Rsog2BsH/LbaGS+l0rcmgrUgWdnfWi9YXpkftFlMxVfPAP7v0ivmTFDrJoUsXAsaVr+W8NTOSqoL8X81cmDF4oMpgQDtxyn5q98LVg2tPSnoWZKZcpOeTMaZLmoD5QTVOZJI6ppU2IgNGDWpPXBW1woVfi9oI9D/SxeDmFJWTIW5Uhs6QpTdbISCR2nIIPNmjZYjp7o+b2k5VAOFSVBUs/hJIzJ5FCYtdZRHnGsN/ZMlRA9WxJai1/AC3KEPQSA7ps9c5NUliC3MRqV9MSQvOjCJVLAYJWpKkk/eqFK96eUUGP6QK19ggaITKKUDlXL33iWWOMVmWVQ4bo1B7KEhqkk08VFomSwLaQ2ZPSKkgHQa9yReC8Bg1LLqSQkAkD2iQT2vuh0sxvmFoxGljgpRyuEh2ru78nuJZsbwWEciDtoDQP7Nlp27LwskUASNk0IBsEhgHHsyzpeHJ6x0GljmY1veygbEU8NEYEvUvXSjvUkc6LFCRWHpbjtuCQ92DeyHdu1D3DnuJFOdWcM4VcC8KoaOxdg+bgBrUfZ0fUwAzIH7qGtqAcWpLOtzpEbjZt2+JAFTlKqEez4Tql0NKPwN97Cyk0NepHJBc0rp3dZgk6uFhwdYAhAV+ou7il9TmDuO2KRKiUSNK2NnFK8bIVrrHZhYVqw0NCzsahNUHV21h61i7UIezAhgTUUNFqH+HhARqVDbTjRgafh9oaVSIeUVrrdhQ6Pyfn24hC1O7V4kqqHuHBT1kEC462lodNQw0A0NmHZCqjKS3qjpY2hg5STQjnU68a6kgs/tmmyhApprvsQWHtNl0HZNd+QtxVwTpepBJFq+3v2R3uS9dxSjNc02u407YgBv7EP7v/ADH+eFiRx/en90/zR0GiYuZIBGbgDq/ZB0/KaGA8VhK0ZqigFe0nvZtCLxaEA9wuCXoFp5/GIpii4IqCb0FHfkq4owvWE0z6c6SKnyRUE11FbROrEKAch+Y4Jo4/rBU5BLOG3CmDFhTh2TagiIy2ADOLe5SaHSwuIYD4jEugqAJZwW7aBa+oFavrpFb+yy1IAWjPbKpJAzO5qKVrrXbSD8xCgU0qKUatwG/MaXN4jTIzOp2W/Ze/5S4rS3E8hSXhizlS4uV6tISHBsQq7NYcHeBDNVlKQ1b+duEWqsGCopmFTmmZ38kbv3RBiMIlRdCSEoZnKCDpoXU/N/dFdX4+GeDZMi1qBi47qe6D6nf328qgfDTEqKaFI3ykhxuXoeDOIs1pRLuWawdyeSXcm1wNInnMrqNY6DoQaGjauPdxoYllSy7gl/f473ixw2HBALFiHqCCxZ6GtlGtbRYYaQAnS1uTk8GdKtnfxioqpeFmHXvLEeJsKe+DsP0Ss0KlXelH0qNqg60eLZEgjQ05ngCfabqUuOtBkqX4Gjghq9V/uk1QdNYCC9GdGIR1me5JuXoetcWKgxAtFvRLUdj76CldSgWPtWiGUXZ6vXVxUuL6PMFCRSJ0IIDcKvRyxFVAboFx7UASS6lg5FrVuGqweyL7wyYRrZ9WZiaEPaiwWBHZ3jiml9mKqtZiGNvsyyTD5iWL6XqHpV+L5VkVFMm0ANUpWwCndiCfxC1XdKxc3HIrUh9KgkVAslJZq0KFVHsHvRFLG72tmBc6M+dCnLjt8YWWKa1/M5DM4BIPYVett2hk5BD1bW3VIBdwKuaGZUE9gUBhZzguoudXTQlN6gNdKrt2xCqDnQ7ilS7F6FhmCg5b7S8OysAXvVyCRoHu7fZlgfnAEBIAIBIGhIplAZw5oMqkmh9neJlcufvoQzm8wMQbiG2sLMSAzMKhwGIJGZNj2RCmwYltwXGg1o/YUbWMAKZZIdgQ4rW9OtdrpQq4o/e8odt6ghqkF3G7kZ06h0jvYmYBQgbAA5TY9VLn7omBwo9iFMwChVTiHF01oNyhRJA7R7gFSljVwxvo7irW+6p2FFKreFSoEil3AO4YO1XoNnrL0hhXQZQ/5VGrOMgemi00Psp7n5nB1rV6OxHuqk1FlKgCP1mI2T+4r+SOiPOj7i//AHf/ALx0AZxfaT59oxHjbK/L/JHR0KdnQ6/sxyH+6Fxfs/mT8THR0MKxHaPM/wAIgbE9kch/EqFjocFV0iyvzfNMB+x/imfAR0dHZj+VQvS66N7Mz8g+Iiv6R+0lfn/2wsdGce8jvTXJ+zH5E/6S4sD2lch/GqEjo5fJ+dVx6ifBXT+c/wASYJw325/Kf4JMdHQjJP8AsVf4/wCCfF1K7Y/Mf4kwkdCJBI+zX3f6aYklWRzP/wA0LHQwkl/af4fmiA8R2fP93Njo6AQcO2n8vzlRW4Tsnz/0UwsdABk/7RP50/xzIHnfankf4FwkdAUOn9qZ3f6iYn6P+zl/+mn+COjoY+DR9pM5H/XlxDL+zH5D/pqjo6Ea/jo6OgD/2Q==
5	Cappuccino	40000.00	1	t	data:image/jpeg;base64,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
20	Cold Brew Chanh Đào Mật Ong	42000.00	1	t	data:image/jpeg;base64,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
21	Cold Brew Ổi Hồng	42000.00	1	t	data:image/jpeg;base64,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
22	Cold Brew Quýt	42000.00	1	t	data:image/jpeg;base64,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
19	Cốt Dừa Cà Phê	42000.00	1	t	data:image/jpeg;base64,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
4	Espresso	40000.00	1	t	data:image/jpeg;base64,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
6	Latte	40000.00	1	t	data:image/jpeg;base64,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
11	Phin Đen Đá	30000.00	1	t	data:image/jpeg;base64,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
12	Phin Sữa Đá	32000.00	1	t	data:image/jpeg;base64,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
53	Bánh Mì Bơ Tỏi	35000.00	4	t	data:image/jpeg;base64,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
54	Bánh Red Velvet	50000.00	4	t	data:image/jpeg;base64,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
51	Bánh Tráng Trộn Lớn	20000.00	4	t	https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/cach_lam_banh_trang_tron_tac_2_6efea7dc72.png
55	Brown Chocolate	35000.00	4	t	data:image/jpeg;base64,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
52	Croissant Trứng Muối	38000.00	4	t	data:image/jpeg;base64,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
46	Kem Bơ	45000.00	4	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxMTEhUSEhIWFRUVFRcVFRUYFRUVFxUWFRUWFhcVFRUYHSggGBolHRUVITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OGxAQGy0iICUtKzUvLS4tLS0tLzAtLS0tLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0rLf/AABEIALcBEwMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAAFAAIDBAYBBwj/xABAEAABAwIEAwYDBAcIAwEAAAABAAIDBBEFEiExQVFhBhMicYGRFDKhQrHB8AcVUlNygtEjJDNikqLh8XOy0kP/xAAaAQACAwEBAAAAAAAAAAAAAAABBAACAwUG/8QALhEAAgIBBAEDAgUEAwAAAAAAAAECEQMEEiExQRMiUQVhFDIzgbGhwdHwQnGR/9oADAMBAAIRAxEAPwD2B6gKtOUeRWAQLt1IWpAKWQaE4BODUrKEOWXQuONlwMJ3UIOL+Wq5rzsugck2oeGNLjwF1Sc1BOTLRi5OkOIAFz7lQTVrWgkFpt5feon53w5ycoIvlLblDBhzXWzuc7MPl2t7LjajX5nJRxRq1dscxYIf8mF4cRDmhwIIPC+uikp60PvYG43BCDU+Fdy/O0nLxYdfUFGIMRjI0GvJa4NRkbSySUX/AD9wZMUF+RWTNmBGx8uKpVlSB0RBpJF9Bf3VV0R+0G29TfTjfqncqc40nX3MIVGXJHQVLZLgONxupp6cEeJrXDysUKmZHEQ/M1neHLbYF+4FidyL+ysQVwlYC3UcwpjnOMKycv5JOCbuPRFUYPC7bwnkdkNqcAy/ZBHMI2xx/wC0+F97hpykfZOrT6LWGVSdGbhXJmG4OCbW+iKRUbY8rGjVxAHmeP3lFhEL3IDXcuB/hKBvMnxRc5payNuVt/tSSaXHOzQfdXkwIMvPBu3ytH4qh2lrGU9O579mNu4DQvJNmsHVzrBXaVwAzuNmt5/evM/0jY730zaZh8MZ7yX+O1oov5QS89S1DwHsw1TUzzSPkcfFI7M8jnwaOTQLAdAuModfEdUVpaU+QUwo9VLCDmUwRzBqAPBFlDFSarQYPS5dVamCwR+rpWOOVXR8Xb5tAtCYtVeiiFkKZLRjf1rUM0IvZEsMxgyHK5tvPZEKqkBOyr/DNZrZXSZVyRzGsEbNEbNF7Lw3tBTOilMZ0svomgluF5f+lzCA20zRx18ijJETPMcqS5nSWYT7Lzp2ZQXTwVdlR5KQC5ddBQIdTJJbacUp5gxpceHDiSdAB1JsPVNgYd3bnfz6dFVvwFEkbbandSXTHOAFyhsEz3uJuQL6BKajWLFJQSts3x4XNNhYHkn/AAoNs3nZOijItzU62S3L3FG66I54g5tjt52VdtI1uw215pkxOY3dYDYD8UPjxxoqPh3HUi7Tt1sOeiWeXF6nujz1ZpGE64Cj4gRx+iH1FFGCXEC5uPMHTUcUSfGDuopadhAbb146dVpmwqa4SsGOdPsG4a5sLRG1oDG7AbNB1Nh7lJ+JDvA0NcSTbawHv0SmIjk1+QgDqDxv0XKmUMfbpcG+gHHTmk8WR8xcumMSiu0uwb2gwSGQioe1zsgJsLkgmwzgAcBvos+zHWUr4o2Fxe4EPiDPDYGwsQBqNbW9UeGLWcWP1adA7Y5TxH9Vyehib4mNa5pddpyjc7624nfzV/xkHHdH9wehJOmFcNrBKLhTuh8V1kH4tHTT2uRmFnDhm/aaf6ohVY46MgfvCLA8Ba+6MdZj77A9PJ/Y0brFpa8XafzdCmyFxALi4N8LCdSep5qDGMT7uG7SL2WfwzHLxulcRmDnMaOAsTqfvPkt8erjOewo9NKMd4V7b4x3EIEZ/tHERxA6jvCCc5HHK0E+dl5rS0IZqTckkucdS5xNy49Sbo5hUf6ymmfnOaKMikadBIQbzPPV3hA5BBZZDflzHLomW7Mei4w32ViOJU6QorTx3QXBHyMbGjFCoBSq7RU5WyZQutapYgVPFDordLSo2Ap/DcSoZaO6OSw6KsAimCirBSho0WM/S1F/dCvQWRrzf9LVe0x9yDrxQbIuzxNsCStgpLGy9H1tZOC5ZIBasoOT2puVdAQCDaqTPUxxDaNplf1d8rB6Xv6BFQOCB4K/NUVL738TWj0BBH0Rd7uCTWfjd8s1jCzs0gO+ydGxoF2/nkqWQ5xyPBWsQnDIwTxI90pkyVunPihjb1GPk7Q5xfM4nzOqmjqjnyEeLca2uOaG4NVGRx5BLFJwHh17W4/8pbFqtuCM4t1fn4LSw3NxY3GZ5W+IRhw5X/FAcO7PPfO6slIzvN2NscrQLNH3BbSAh7Q4jcX1TnsTkNHc97k2n4KfiNsdqXPycjJXJX2F03juoqiDOLHiE5k3bPb2YRq+QBjuIR5g0G7iPC0a3N7a+6FdpHFrM+ZwIAv4iLaHLsdOOyv/AKkhilMzpCSGlovoNfos/wBra6OoaIoxnlJyhoI0A+0fpr1XH9JuLb4k/B0YzSarohwcGSPNGWv4uDnWcOdr6XttewRKnxxsbDGHZwy5PO45dLoVh2ER08AdJnDycpDm2Pm2xNwNPdAMWwyfUxggPBNybADqeaWeFxdRYxuUlbBdXjxmqXvOjS8gDm03H3J2J9oZc0DWm/c3vfiNh9LhCGQZbE8y31T2va2S772OgP7PmOS6WyMY0kKxk3I11Tixq2CNmYXGrW3JHrsoMF7LVb4zG5wa1xN9bmxOo6FO7JNLKnKPlc24+nH1Wqrqx1OTOHiRmcNkYLXjvaxHK/HrZY6eccc3fRrm3Tikh2H4S6liY1nzRO7yI8czRd7D0c3N7FDu3mHtD21MQ/s5wJDyDnb/AFHuVtaSobNEJGagjM3np+ShOM0wfQzD934o/J7mPt7xu912HVWjlcp8mEw/VaWhgWewpuq2eG097KjZeieCmur0FLZWIIbK01qumyjQyKFXGMTGBWYgrplWV5wqrIkRnDQLk2WF7U9to4bsiIe/psPMq6ZWgt2kxyOmjJJ1toOZXiHaGvMueRx1cT6K/idfJO7PKbn6DyWWxur1yhSRZcFGySYJgksqYbPrdPYVGAnrRmaJAUimhPBUCZnsg+7qscRUH65keqJCDssxghMNfPEdpW963q5rzcegd9FqZqgA5b6lcpxUcdN00xrFy+rI6up7todlu5Be0mJGVgEVzuSPK3/KK1bLtsUAq6a2o/PnzXF1+ozKTg/yujo6XHC1J9ofgOJCONzjwG3N17WRuipC8h8o1OtuA5LL4HTN73M4GwHhadWjXU25rdMvlu3fTT87Jr6ZiWRcu0ukV1z2Se3tlkck1ya1pOrtOg4+a45y9CjkjXnlyUNbPkjJ4pzn8f67KniZDmFhP/XNY6hv03t7NMSW5WZCqldJILuu0l1h/Dbf3Qvs+5jK6Z9vCC5g4+ItzFo/mv5Ir4A42c243FxcdfNZTsdM7M7ONXkyA9SbH7x7Lk6et/J0sq9vAb7V1RfMzKHODQ65Ojc2hytHS2vmrEOFvqaeQ3DcujTvci2oHqFXqHl2ckOa1jz4ifncWg3YBqBoBzv0WowSmcKR7SQ27XHTcEgnLflt7pt4IOVsW9SSXB41jVKIwGjdp1vvcb3ULYc9hbfdXcVjJc9zzmdYC3UC34KfBae7e8tdo3I4earGcZou4yi+S5hNFJFIxzCNNgRe197LefBGRhDmt1+YZQM2ltbLMMaHttrY6aeav0M88WVveFzQ8bi5tfVt+KXk8cZ+42SnKNoK9kKV0RdGHEsBNsysYu9scFQD8rIXP3+14so/3fRFKgDunPAsSL2tYlYTtdOW0cgLtZZGsA6Ns53pY/RNeq4NY11QpOG5ObFh+M0TmC7cj2gAm1rkAXNxoj+H43TDTvB7hee0+BmIEk3LvF5X1shdZTFdHbwhPcz2uHGYDoJW+4XX9oKZu8zfcLwJ2YHcpMYTugix7jU9t6Rg/wAQE8hqgVd+k1oFoYiTwJ0C8yii6KywBaRRVhnFO1VVUXDpMrT9lunuUEygars9QGoJiGKcir2kAsYhX22QGTxG5UU0xKfGVm2FDDAkpDMFxGyH10GrpXErolRwKdZMATwoQw3bF7oKqKcAkA942w3ytyVEXUujyvA5xuHFG67M7JLEQ4ECxvuNwRw2V/GcNE8RZs7RzHcWvbq1wWZ7N1eQmklGQ5rRg7Mfqe71+ydXM6Xbu0hcn6hg3qv9sZ02TZIviOe+a9v8p1B8lynkdI/IWgHXW+lxwV8TOvlAF72IdpbyU0VCxnjedtd7Adbrjx08Z1V15tnSeWlz+xXfh5ZrZG8NkvGCsPW9p2VEjoYJQxjdM41zHmBfbqtD2elIBb3hkGlybeE2P3p3Qyx4s7hDhGOohOWNORoCVE5ye3zUZZxXccjnUQyO+iH1Ulg51tmkkk2AtbdX5I7E77c0NrKdz2uY37Qt73H0us5SNIxBnZ+ga6J80jQ58ziTcc9rDloEOqKRjPka1txrYcNRpbjf86rXmn7uNkTeA+7khEtO0vP2QALgXJuL63PDVLZZRguTfHcmAWU133ebBhvbm63Lob79EWgxBob3bW/Nmu4m5NmuJv7KtI8OBsPJBX4gI5hHzY7/AFHQfRcx6jJJXfY96MV4M5iFK523Mk8roFBiBgc5hdawy5QdxrbTzK9DbSNIuSgY7KiarDmtsdXHk4N4Hr1UwyS4YZq+Sz2KfI9hDmZQdQQCQfLl9y2MMojLS1o00Ohv1KrskZAAyzgbjTK4jTqNFdimdO7wsysG5cPEevRXVyl7ezOTSX2CcTw9vmvO8fpfiaoQRWytP1Iu93kALLS4/iQpYnZTdztG+e2nP8jkqXYLCrMfVPN3SEhhO5bfxP8A5nDToL8U/GFyUp9iE5WtsejJ4rWSQuLZmn+JDHYhG7YhekY/RMkBD2g9V5ljnY+xLonEdE76iMNlEcjWnimktHELNVVJVRb3IQ+Wql43CumirNdLWsGlwhtXi1tlmzK48SmueVawF2pr3OVJ7inNK7cIWEjaVK1pK7HESdAitJhr3bNQbJQNFMUlqGYC+ySFho+lbrpTA5dutDMc1SAKIFSMcoEfZZvtVgInHeM/xGi29s4BuGk8CDqHcD630YN1yVqpkgpRphTo89pcZ7wfD1NxKDljkcLCQ/u3/syjls7cckCxCMsLm+Lq3X6hbvtHgDKgHQNeQAXW0cBsHgb24HQjgRxzrWTwf2VTH37B8kgGeVrRra+nfNt5PHELh6rRO98O/j5OnptXs9sujDiMB+YR2N+HhP0Ww7O4pUCVoEZEZtmOY3IHpZGBSxzND4o2ys2vGCXA8iN2noQimFsc354CxrRu6wvbgBulIOW9OSqvPI5kyqUeDT5xoLpstQ1oLnHQLNjEg52jst+N+qIwQB7gXuzAagbC/MjmnI695H7Uc+Wn2/mLMcjpSHWytGwO581ejisLqOSUALjasAXJA9U1HLGPEpcmMra4RQxjEBALnW9uWg0Cz9bjbQ0h2gI333F9hqosUqDPK527LgMaftAaXPTdTCha4XcLlcTNqZ5crUHwdTDghjgnNclKkrWllxy8rn/tY+N7Zq2xBdbQ2dbxX59NvRHO0xMUbjE0uOzQ0EkvINttgNyenVA+weEyGZjnDQ3J46jmfzst8auP9DSXFsNzxFsjowHNNtDobX1A47BaXsjhZhjMkvznRo5Dn6oxUwx6Zmi442VYvJOW+nDpyTOPHjxz+RSeSU40gFi8NS2XPnBZckXY05fbXir8dSIIzNM9znO0aOLuTY4xso8b7VwwDILTSk5cgtZpP7x2wHTdZmtqHyEvkdlaRbT5yP2W/u2+XqSbp2GnipbkKTzNraU4qaSvrh32jcxGVpuGBoJcxpG7tCC7hqBrtvZnZAGgWAFgBoABoAAgf6PKfPLLNlDWMaImADQE6m3kAP8AUjWM3zaJbXxcIqd+TTTU3RRqZQRqs9iIsrVYTwQ/xOBBCvpNQ8vtkDPi2coE1DmHeyF1FDE7gFexCmIKCVAI2K6CjQruOSYFEeCrP7PRJktU8cVWfiTwiDgtDs9Epo8EhCEOxSRQSV8h4ok4NOxkLOAUc2Nxs2AWTfK87lR5SjRLNA/tM6+iSAZElKRLPrIJwcllSWxkPDk5rlAu5kCFkOXHu0vy1UTXqRpUaCiNwVWpp2uFnNDvMfnz9E+mfa7b7EgKxlulITWRGidACr7PXd3sD3xy/vGOyuI5P0PeD+IPPkqdTilRGMtTG2Zu2eJzWSfzROdlJ6B1+i1eWybNDHILSsa8dRcjyPBUnhTVIvGTXKMvh0lI539nUBr/AN1MDE8HlZ9r+l0fpoJbjw2/zcLIbiPYqmmFmvez/IT3kflldqPQgqlTdhZYf8Cqli/8chLDr+6kOn+spOWgh4Vf9G34mVUzV1NG5w0eAQNUGODyF4fI8vt5WtxFuVtFS+BxWP5atsn/AJIPxja771WqMTxSO12QP55Yal/3ALDNooyd8/8ApbHnlFcBV1C1riGnQbc7KhVVVnd2NTyvb6hA6/HsRdvQteRxbBOP/ZwVSlqcVc/wUuS5+YQA262e6x4clhH6fPd7WkhmOrjXutm3oMIOVpLbEnc7tH5J+itStZDpCxjQ0a7N0HFZenwvFJmF1ZWuprOsI2BgzNtvmjcLcdDf1Q2akgiBa+pqJhe5Z3pa1x/zBlr+t03LTxxram1/Jiss8jsJ9oO3lPbu2h75NrR//RA08gVkayor5xZ8opYTuGl2dw5Fx8TvIBoVyrxhjRaKNrOo+a38W6z9VXFx3W0MPO6ufl9lW6VN/si9BJDAAIgXH9t+p8wNgonVbnk7knQdSdghrnaa+i0XYjDzNO028MZBPnv+CeguBebPUOzuHinpmR8QMzzze7U/09FRxaoF9UYndobLN4gy9w8aJH6jDJJJR6GNJKC7Bs1S06c1IIwG7IO2N0k1oxoDqtGYSAARwSeDHmxq6GM08cuDMYk0HgstXQLd4lRk7BZ6fDHC911dNKclUkIZlFdGNqIyqckS0tZRW4IZLSpmjEDGJROiRZ1OoHwIBB3dJzYFb7gqVkKKIVPh0kQ7tJEh9LJFMulmWhkOsuZUgU4KEG5VI0Lic1QhQfGRIeR9tlBNXd24X1HPiPPmr078sgvq1wAI8kOxqEWuNRuvOZ3PDOUoPp/z/Y3jyuQlDWtdxGqkcOSyoNttQeB/O6mhxN0epJc36t8+YTGH6kpcTRNoedJZMdVEcVQixeN/GxXaqra0X3Tb1GLbuUlRZE8lceahdisjRo4jVVviGuF7WUMuXmpGSmriy6kTzY9J+2hVVjz/ANs+6iqwzn9UHqGsP2vqtOSWiPEsae77RPqs/PUPdsi0kDLbqhK4N2VKT7JuYOMB+0dE2YgDT3SqqweaF1Ezna7AoepGPCKtj5qq23uvT/0TRf3d0h+0930AH4FeSuYvb+wVL3dDCOLml5/mJP4rTBJymZzfBpS5RTMa4WIXCUx705RnZXhoWMNwFNJZML0xyFIlkVQByQiqgB4ItIqr41ZIBnKqgBQWsw3otlPGh81PdBotZhpqIhU3wELaVFF0Qyeh6Ku0JmXM6JzI0Wlouii+G6IUQqCJJXvhkkdoOT3G6QKYAnBXZQeCpGlRBSMQISAJ7WpgUgcoQgrortuN26oZXi7SQj7BdDK2nsS3nsuR9S0u/wB8TSEq4My53IWvw4KJsnoeXNWpGWJBVOqiuLXsdweIPNcFRcXybIpujs/QacQrkzmBmoJ6XKFUVdneY3Ns9rTm1sDY8kSlN4z5XvwI6FUyQnj5a4CuQRLXgaC/u5U5a6/2j7uUNVe50053H3XuqMp6H2KahOVAJqicH/8AQ+5/oqD2HhJ9VXrzJa0Y1PE20HS/Fcpo3BgEniPG9j6JxSe3c3/kFnJp3N0L/wDcqFXXaaBzvcD34og+Ntx4W6bWCZVHRXWRX8kAclXc5SCPJW4QLDObNGvU9Amy2vew9lCXc0zaa4QKLtJCZpWsG73BoA4cPoF7zTgMa1g2a0NHoLLyr9HtEA81D9m6M8zuV6E2tB0undNCk2zOT8BXvFHI8AEqHNYalCa+v4XSep1koTqA1hwRkvcX6TEWSXDTqNCrLpFif1iI5rRjfdH21wNgTYpjT6tTSUuzPNg2u49BJz7qFz1VM6aJ0+hYnKgkYuOmTDJdSiEL2BVJ4Ar7mhMLFKCBZaZVzTo9JEFA6FSiWCO46JIv3C4pRLN+1PeQAoI3qYgFZZVNr2Ag15OQy5idFMm6BROerRTSpkfZOpGqqHqVj0QFyMplc27b8RqmscpCbhUyR3RcQoz9bHfVDJ4rIw43Dm8jZCXPsSCvOSim9sjYoNkbHKXOgzgts5w+a22g5q0+FoiysByi9vLlolUbXHqmRPu0hK6iEq2PosmZWrjN0PnbbqjdZoTpcoc+yGODC2CJS87WH1+ipwUsmcuc/MLbbfRGJA1Mu0J6CaVEKDmWVaters7gTa6GVbxeyMI+4ngqyKtuQOqlmdYKON2UF/EbeZTuOJWzUUGJZGhgNgBZE6fGDcG6wUFQVeiq7cU6n4KUb2TH3W3Qx+L5nboDFWKdrgUpk0ik7ibxztdh3D3tL8xKFY/ijviA1jtOig+G5OIVeHDXB+Yuujh00oythnlTRr8MrHFozFEWylAaWWwV1lSukuhRhQSp7ZEMFQpBOr2AJiRLvEPZKnmVQhdJTbJkRUgeESDsiScHJI0Dk1bQnNchcbjzU7CeaoQuOnTO+VdxKjaTdAhfbIpGyqowqQBAhcZOpxMqDbJ+dQgFqnyMqHG12Ot6FVKx4vceqf2sp5CzPG4i24CyuHVzyS1zr9CuPq8Edzfk0izRtkuCFUjmsVEyo4bKu6WxXNyo0RHiw8WiCyvRXF5dAVnpZlbEnRGKV6ql6inrBsASmF2mu6ZUWiWdfJqqM5v5qydbqzhWEOmOmgG7jsEY9lvBHgGBvq52xA2G7jyCpdr6HuKl1ODfKd+a9L7MxsiDmRWvbxSn8F5di5Lqycl2ch5Gbn+dk/hiqszvkHkWUsZTnxLrWLZhLET1chkVDNZWYypFqXRGmuwjHMrEUpVCNqt0m+qvKW2NsCW50i829rqSOdWMSH93JCBUbjzWeDP6isvkx7XQfpAXuDRxV+vphENXKhhT8rg5Ve0uJ3fa+gVMuWfqKMXSDCEdtsuw1YVpkyydNX2NwNFanxg3aGt3Oq1hqJXTRSWNVaZroXJ+cBDKWfQaqZ0gtunUYhH4gJIf3oSRshsIFasuJLMBLlum92kkqkEQnA6LqShBzE9JJQgyWO4ssfjODZXZ26JJKmTHGceQoHPluLHccVyCGR7bgj1SSXByJK0ao5XxSZLOa3TiCs1VDmEklIRTCUZHi2gUVnHYfVdSTUcUaAKfwWubnkNlo8Eo80Dp55CyJt/AwG7rcyFxJXhFNgfRmsS7VPfdlP4I9upQ2mhcPXikkm0lHhBRbjpypWU1wkktK4Cuyr3VjZWYjZJJIRm4zpDU4pxtl1gvsnONntCSS31X6bMtMveHcTfekf5LN4Q/mkksdJ0Xz9mihd4Sspjsh7wdUklpl/Wivsyi/TZNQt0VzuDe6SSbhFGMgtSO01VxoXEkwujIkskkkoA//9k=
42	Kem Bơ Dừa Lòng	42000.00	4	t	data:image/jpeg;base64,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
48	Kem Dừa	45000.00	4	t	data:image/jpeg;base64,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
44	Kem Matcha	45000.00	4	t	data:image/jpeg;base64,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
47	Kem Sầu Riêng	45000.00	4	t	data:image/jpeg;base64,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
45	Kem Xoài	45000.00	4	t	data:image/jpeg;base64,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
43	Kem Xoài Dừa Lòng	40000.00	4	t	data:image/jpeg;base64,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
56	Tiramisu Truyền Thống	38000.00	4	t	data:image/jpeg;base64,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
49	Xoài Sấy	35000.00	4	t	data:image/jpeg;base64,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
50	Xoài Sấy Muối Ớt	35000.00	4	t	data:image/jpeg;base64,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
37	Bơ Dẻo Xoài Mọng	40000.00	3	t	https://mgmakegreatness.com/wp-content/uploads/2025/11/Bo-Deo-Xoai-Mong.webp
39	Bơ Dừa Nước Hội An	45000.00	3	t	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlBLqF_ckywdfkrOefnYJCCT9uOo0Quv2PzQ&s
32	Nước Cam	40000.00	3	t	data:image/jpeg;base64,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
33	Nước Chanh	35000.00	3	t	data:image/jpeg;base64,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
41	Nước Dừa Matcha	45000.00	3	t	data:image/jpeg;base64,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
40	Nước Dừa Trân Châu Đá	38000.00	3	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxIREBAPEhAPEBAQDw8QDw8PDw8PDw8PFREWFhURFRUYHSggGBolGxUVITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OFRAQFysdFx0tKy0rKystLS0rLS0tKysrKysrKystLSsrLS0rLjc3LTc3Ky03NysrNys3KysrKysrK//AABEIALoBDwMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAADAAECBAYHBQj/xAA/EAACAQIDBQYDBQYFBQEAAAAAAQIDEQQSIQUGMUFxEyJRYYGxMnKRB6GywfAjQlJigtFTY3OSwhQzQ6PhJP/EABoBAAIDAQEAAAAAAAAAAAAAAAABAgMEBQb/xAAlEQACAgIDAAICAgMAAAAAAAAAAQIRAyEEEjETIjJBBRUzUYH/2gAMAwEAAhEDEQA/AOkxlp6DoBTlogsWWkRYp91gtmPRksc+6C2YymUqmkB6QiM5W4ihK5cA4hCABCQhIAHHTGHQAYr7ZMH2myqsudKVOp6KWvuZP7Ecd+3q0/8AEoQkusG7+6On7zYNVsHiaT1z0Z/W117HC/srxrpY/DJ6XlOjLyvy+4BM+ijw9443lS+Z+x7TqK+W6u+C5nkbw3vSf835FWX8GWY/yQGnhmk7anpYD4F6lahUulyurdStXxDpVsKm7U6rqU35T4xM/H02y7O/qeyMSaBSqd5R8rm0yk2MyGJrKEHJ8lp5sHgpOUFKXGV36CvdAGGHGYxiENcVwAcZiuM2ACYwhmACGY4zGAww4zACvh5d1FiDKODl3UW4MQEdovug9muxHaM9Cu62Sm35HO5ORQyxslFaI7w7VULK/Ox6eyamaCZyzbe1XVxMIJ6KWvU6dsN/s10NOPL2bRA9IQhGgYhCHABCQhAA7V1bxTPmxxeF2pVjw7HGKS6Z0/Zn0ojgP2o4Pstr1WlZVqUJrrazD9iO71sLCvCEndNxUozi7SV1cz+3lXpdnnaq01LRpNVOH0PT3PxnbYHC1PGjBPqlYDvfWjTpQnJ2Uaiv48ynMvqyUFtMqYfFwqxtGWv70JO0o+hW3jpVIYejWUlKnSrU6kr3zxSfFeKK1OU8SllpxpRXCrO7qPpFcPUJi69SOHjSqVY1KFaM6d8nfi14pP7zHCdJks0nVM1+HrRnCNRfDJJ3PPe0qKqTcqsFbu6yXEzFeDlCVN1HGnaGWzcYU421ejvJlqhgY4tRhFKlhaVuS7Ss/wCJ+C9TRHP21H0p7F9V3i6to/8AYpvWX8b8j3ErJLwVkDwuHhTgoQWWK4IIXwjVtkkMJiY1yYxmMOxgAQhDAA4whDAQzEMACYw7IgB5mAl3UXVI8zZsu6WatWxGwBY6pd2B7QX7CXysqVqmaXqWNqytQl8rODzp3losXhyuk/8A9S/1H7s7RsP4EcVwLvio/PJ+52rYi7i6G3j/AOT/AIUw8PTQ4wjpEhCEIAHEMWKeGfPT3B6ACmcj+3DCWq4LEeOek/vkjs/ZQXF/VmU34xWy8sKeNXa2leEITk5xduPdkrEXJL0Vnm/ZFi8+z1B/+KrOHRXuj3NtQVWEoSjKTUk0otRs1wep5GwcBg6VN1cDWmqdZpuEnnSktOD1Tt5nuYPJmu25Nu7uw00H6MtHFOjL95x/ei9ZQ814ojUrQouLklPtXCdObWbK83eivBNGx2vTo1oZXpJcLOzi/ExGL2diYSnTjSlWp/FdRbivNNcGYMsHB2lZCc3SRU2vLPWnhaatKdRSp3k1GnTerk/I6PsbZlJUIxSV7RcpJZc0kuLXh5HONlRm68ajazaqOdd2OV8GjpOyq7ytN3bXHRXHw9262KG2W5YKy49CpJWdvA81bGxlWTzVVSp3dudRxv5I93CbNhSgouU6jS+KT1NkZ36WFJjD1HHM1GSduKTTsMyxAMIQhjGEIQAIYcYAExh2MwARFjjMAM9s6p3SGNxNing61l6FTG17uxROfWNjSL+z3mdyxvNPLh5/KwGylwKe/OItQa8U0edlL5MrZOWkYXd+GbErq/zO27IjaC6HHNzKF613+tDs+zlaCOzxl9mUw8LQ4w1zeNEhDXHQDGp10p2enmyxXxL1suCbv0Akanwy6P2ItAc72pvXWqynHM6cU5RtTdn1bsZna1qtrzcrfxRbfuA2hWtUqfPL3KdTFXVjjzyT7UzO/TdbE2pTcY0opUlGMdNFFvmbHZFCjLWda7T1itI/U4zs7G5ZWvxlH3N/hb1IuUdUuP0K5/yEsLSatFyk2rR0TLhrL/t6eNr/AFKNbauCg2u0heWjUc7v/tTOZ4io1lTutX5aAISWmr0btqy7+yi1pFfyHS8LtjZ7zKn2SlFO96Lg79XFXK+G2nTiruS5XSepzuVZK9m/q7BFjWub0jbmQ/sXHyJHudAx2+ijpGEV5ym/aKZnsdvXUqX78nf92mnTj6y4szNarfXoyCnol+uJU+bOQnNs2m58251Xf4o5reGv3mnaMruOvjfkl96Zq2drj28asvh4QGHYxeSGEIQAMIQmADCYhABETHGYAYCFWxXz3l6gp1CeDV5o5fKlUGWR9NBs+NrdDK7947vRhf8AWhrc2WF/I5hvVWdSvJ30Wi+iORw4XkYsz0e/uPC8m/1wOsYNd1HL/s+otRTf60Oo0PhR3OL7IrS0FuNca41zcBNEkyCZIBkkKXB9H7DId8H6gI4PvDpVrJf4kvc8N1D2d5m1Xr/6k/cz82cqUfsylos06mvqjoW528UIJwnZZpK3h4HNYS9z0cPPh1KpxV3QlJo6dvXCnanKLSvJ8OhkalTRa21ZShjZyUVKUpWeibbsSlHMl8zM0oLtaVIg3bLHax11u+pJ1ONvAoyw3FhaMGm23dKOiIdEFFyM9PSKJRl7/mBmuFv5QlGPLzf4iUY7BI325S0mvKPsjTMzW5Erxn8sTTs9Bi/BGmPgNjE2iLLCREQ9hhgMIcQAMMOPYAIjMlYawAcoqTL+xe9M8epU7p7+61HRy8Tjcx/Rli9Lm8FfJRclyRy6pWzyb8Wjou+8rUJfrxOY4KV5xX8yMnBh9ZSK822jqu5dDLTh0XsbqnwRld2aVoR+Vexq1wOpwfGxvwcQhHQESRIjEkhASQvHoJD/ANgA4VvZS/bVvOc/czTjyNvvXhrzqS/nl7mW/wCn19TlZJVJi6lBR19S9h38PVj1MM78ObCUaPw9StyRVKJZocurLsJWV+OpWw9Lh8w+Hm7yX83AokrIRgWm9GRlH2GnJa2ur8uQdLT+lFbpEnGgWGUk2vHKehQhw6/8gdKGvrEtU1+vUcXbGkbTcpdyXRGmM1uUrQl0RpHJeJ38X4ItQmMyEqyXMFLFxRYMMxminU2hFcyvU2tHxCwo9QY8Se2FyAT2s2K0PqzQuS8URdWPiZertOb4FSePqPmO0HVmvliormClj4+P3mPliZvi2R7RvmwsKZkZyvFG33co5aUfGxi9n0nOUV/MjoeDoZYLojzv8hNqKROG2Zjfmv8As7eP/wBMLsrDZq0LfxI0n2iYppJLx/ueRuXFzqp24NBxU44HIhPczrW79G0I9F7Hvo83ZVO0V0PROxw49cSCXo44yHRqESiSIolcAJIcH2i8SEsRFcwA5xt6F5SXLM/czkcKsy+aPubHHWc5/M/c8ueHT1t/B+JnG5EX3skZ+vStryc5JfUjCjZrqerXoXsvCrMFTgmujMkpUxuNoqOk+7b+MlQoWlPyZ6HY/dIOqGsn5ApEUil/0l2ulwqwvselClw+UNGj+EbjaG4nn08N/wASxSofr1LvZeyFGIQhtEVEvbKxTpppc0izPaU2UcPzCtnZhJpUWxih6mMm+YF15c2Tcgco3J9yXVEZS8wUicqTGUBdiXVA1OxNTTJ9khlQQrY6Q6HVO4y0HUxWwGlRBTp2DZmSWpJSEzN7v0s1VacP7m6taPoYfYu0IQd20tfFHu4jb8Muj9jz/NjKcqSIY4tIw2/ta9VL9cWel9n2E/ffP+7PK22lVqZw+ytoyoK0TVjg/hjAPjfazsWGklFa8icsTHxOYw3irS0ul0LlHHTlxkdaGVKKRF42b6WPiuYGe1ooylOrcLHUt7i6HvT214FSrtqXIoKApUg7C6hKm16j/TAyxs3+8/qwdSkCY7FQWSv+vMFOlp/s/EHh/YdrT/b+I5uaNskeRODvb/Mlr5kexsvDvv35l7smm5f5jsiFGhpq27z5mN42WLwFCjx6lmNPj0Cdho7eIeFLj0COKiNDUaF3blkuFhS/CSgrP+mwXLw6GqOK0JgMn3DumEjpyFJ8S6GGvSJVlOzJwqXBVdSMHYvotj4XEicYleFQOpCZKyTYOSuSGYhgJpkVMK6iXMBVqRJpN/oTa/2EUrkZRK6qj9qyaxsreRBO0sGpzvyKeZsNhq+V3tcbxkXlow6LEJaCjAIqZzZxtGwp1lqNGBalTB9mRhoGPQiezhEeXRiethUaIekJI9GlEsRQGkWYGpMpaJQbJZiNx8wMQmgUoILchJgmDQlH8iVv+P4iUETy/l7lMkRBRhw8FVYNx+H53fpctRhx/wBTUd0vLhJlTiTRXS49boKlqTVPgSjT0XUrUbGxRj7E1Hh0GS/sTjK30sacaIMh2fiCqosup7AavAtIlCs+AO5nt+toyoujldm22/PyI7E3gjVSjJ2kTgkwcmjR5yarsrqVyRb8aI92FliGClVb5j2GsPqhdmDbY1gthrEhEUSQspKNJ6CERTJouPZUsmdNPyXENg9mKS+LqmIVMw1JFmESFBIsxa8DlHUsBKkDdEvojNK12Q/YrKUFZnoYWRUjG70LdGNi6BGR6dMPBlWiwtzQioPmI3BqRK90SQmiVxIEpWJ3AiXKcdF6BVH2/MLCn3Y+aRJUyLIWBhDR/NcK4fF1QTLxJL30M05F0Y2Cya+g6Xw+bYS+n3Eb8PJlUJljiQyq39RCUfcKlp/UQt7myDKJIC4kJINL8mCqMsKzNb3bMhWhFy0cU7MxGyMNSzThKaU4/DK9je7xRcopLg0cw2tsydOTqRb4+OpD5EpUWrHas0+yN4ck3RqSuk7KehsKU1JJppp80cZpVb8Xrz8TQ7F3gnRai25QvwbbaNEZlMkdJyjxiVNm7QhWipRd/FF5xLLKxmkMkJxJU4sAslGJNDZRNWsQYFyFKrBZ1e31DU6MqjU07aapAMPjpRVn3lzTuRqYm0r07xTWqXAAMPTZYgVaZbgjAjpMLFkpIhEKkJxFY1NW4FiDAqIWmicERZagF0AQYRMuRWFkiN7CjIaQ6FZJq+oyYNTsScgEaZ2yQkuDjG/UeCTPPwGIzRtflaxYVTLq+HefRIJ+EEtlyNP2uLs/h82Qw+Ji8uvGFywpLR9Tm5ZbNmNaKjp8PmZDL7lm/wAK82AlLh8zKlIsoSX3MZW09QM6nH57A5114ribMUzNkgGk1b0ZWqzRWq46Oivdu6XVchULy7zVlZO31Rp9KGVtoU7pLyM7jdn3vfgaXEvW3GyKtaCZRkWzViejme2thNXnBemp4kKrTyyVn5nVcVhk+KMrt7YEZJyjoxwyfpiyY72ijsDFTpT7SDvZ6x8UdH2TvJDErJZU5rjGVk/Q5BhsTOhO0vHnzPewdTtHng8k+N0zTGRlkjquGpRbeaViU4RXCTZitlbxyUlSrXT0Sn4mqovMk73vwfIuWyui1Bos0pRlo10ZTytBaT11uRaGgtTAPigFeLiuBalUlHg3r4kJJy4sWyejAU2XaLKNEv0eRjRtZYykooTFTAgFSCQIoePAnETJ2sETIMnEsRBiHuJiQxDNEYu2g6ITGIPSquLTRoculnwy8/NGZj+aNbXXdXyr2Bq0RfpUjglxWncS0Cxp2y6vhYfDvX6exarLRHHyPbN0FpFF3015sBK/d1/fZat7gZcvmZWiwpVIv/2AJYS71b0m5F7k/mCtavoa8CtlGUoUsHGNnbm36ksTUcUkuDVn0QSo9Stj+EfU6HiMi9Ap3IziRiElwK2aEVKkDz8Xhz1ZAJFUkTizH7a2LGabS1MlKNTDz1vbkdQxC1Zkt4Yqz0QQm7oU4JqzzsPjO2nC7S1SuarZ21amDmoVe/ResXxsuT9jneCfe9Ub6lrhNdbZbX15I1JuzI0dB2fiIYiOaE1axZqQjHTNqc/3Bk+1qK7tkenLijcYJXkWJ2QJJX53Yp2XkWLd5hKsV4IYH//Z
38	Sinh Tố Bơ	40000.00	3	t	data:image/jpeg;base64,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
34	Sinh Tố Xoài	40000.00	3	t	data:image/jpeg;base64,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
36	Sữa Chua Phô Mai Xoài	40000.00	3	t	data:image/jpeg;base64,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
35	Sữa Chua Xoài	38000.00	3	t	data:image/jpeg;base64,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
27	Latte Matcha Nóng / Đá	45000.00	2	t	data:image/jpeg;base64,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
29	Matcha Latte Bơ	48000.00	2	t	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSytv0xS0OlxQECnkzyoD2m9NdzDcTfLPCQNg&s
28	Matcha Muối	45000.00	2	t	data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxITEhUSEhAVFRUXFRUVFRUVFRUVFRUVFRUWFhUVFRUYHSggGBolGxUVITEhJSkrLi4uFx8zODMtNygtLisBCgoKDg0OGxAQGislHyUtLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS8tLS0tLS0tLS0tLf/AABEIANIA8AMBIgACEQEDEQH/xAAbAAABBQEBAAAAAAAAAAAAAAADAAECBAUGB//EADgQAAEDAwIEBAMHAwUBAQAAAAEAAhEDBCESMQVBUWEicYGRBhMyQlKhscHR8BQjcmKCwuHxkhX/xAAZAQADAQEBAAAAAAAAAAAAAAAAAQIDBAX/xAAvEQACAgEDAwIEBAcAAAAAAAAAAQIRAxIhMQRBYRMiMlFxgSMzcsEFQkORodHw/9oADAMBAAIRAxEAPwD0+VAuVe8uNDC4CSI/EgLzr4p4fWOu5oXFdtRsvez51Qgt3caWZbAk6doGIiDjLPCM1BvdluE9DyJWkejVBKhpXmnw98Z1ammhcVJJwypgaidmvjc9D79Vv8S45/SMa7BfUexrKZnLNY+Y+OXhkA9SN1DzP1VDT9xw0SwvLq+x1sqTQmS3W5IiJV22owEO3pq0XJiIOCG4IhQnFAESoOKkShuKQ0MUNxUiVAoAg5DJU3ITkMZB7lWqPRKiqVSpGXbJ+CoVnIfDTuiuZJSQDiu4bFI8VI+psqVSnhVP6cuMIk6QItU6tGtg0wfMfuihrKIkUwArdhZhqwfiOsXP0A4G645yctjdRUVZDiV3b1T/AHG6gOUmPzQaNa0Z9Nu31A/VZNW105UWFONpGTab3R0o41AhjA3yClSunvOXFZFJq17CmrVvklm/w9sNJ7LzH4hutdzUPQx7L0y4fooOd0aT+C8fc7U4u6kn3Kz6v4UiVyes1KeppadiIWC6k5jw0jMiOjs49CunDFSFZlSAaFUbZdTLdOJJnttjpzwtup6ZZaadNHRgzvHaq0zxy+vLe3qPba02vIe6K9UCpGTAo0z4QG48ZBJicK98G8IrX10K9VznspuDqlRxJ1ObltMH2kDYeYW/bfAFqHAuF65v3DTa08sOcBPM7R9J7T3HCHMDW0qVtUpMDcB1PQ1u+Dnf33810I8yHTybuXHyLbaCK2lCIEyo6hwnUQUiUAM4qBTlOKRPL3QNASoFWKdKZzkbjmFP+j7n2STTApFQKvmx7n2UHWB5OHrIQBRKE4K3VtXjduOoyq5CTAq1Aqz6S0CxRNJIor2TIKsPapUmQUXRlIBjRwiW9EBWNciE8QuXLkt1E1hGt2QqVQ0SVyd343l0brork6vJVnWoRDFvbCU72McWoco//lHkFtNtoVygzkuhRRk2c421IK2eH0DIwtIWQ3hW6FABNQRNmL8YVC21cBuRHuvPLThVR32CvW721D4BEhRpWLRsAoy4FN7iQ4anhThKF0gRTQk5OgCKUJQnKQDFMSBk7IBraqopDeC5x+60fqSUe94ZrIc2oGgCI0yCBy3WGbJNRfpq2NJdw1Ki6ZGks6ydR/RGfTMO0luqcTONsHMqtb3dINBpuDmtwXBwDRjcyYPRSp3TCS+AASAXmGhxGBBOXeaiM00rfP8A2w6LdGeY9evpyUhPRUaF017j4H+FwALm4nq390SrdtpuaHVPqJgESScQGxtCtZFV9gotKlc3jWOhztLQJJc06TqMCH7AzOO6PUr6ASRUd/tBH4fqs3+qo13adLmVRye1zSYnBPNqzy5UtovfyCRote0gOaZBEggyCDzVZvyapcGkFzTDi3cSMEjmO/Y9EWpS/tEPAEhwIaYkZ2cSOXOVy/DLQWVZ1Q1Gsp6DqaYOJ8P9wu7YnfKmeaUHH5dxpJmtXtSzfbkf5shQtajdsqksDHfQ15keGHk4DhjUInG0hZd5RLHEbjkeoXTGSkrRP1GATPKqvc/kFbtaRO6jJbjsXGr3LVvT5lQrvlXNGEP5QU48WlFSnZR+WkKJWgWBRLVqZlVtFFbTRdKk1qYB6GQjBqDRCskK0SChSASTpgV9KYhFUXIACUyIVCJQAoUYlTapMGR5hAGX8NjW6vW5l+geTf8A0ey2jMDbvG3oFlfDlMsFWm7dtV3mRAg+wla4WEF7UUZrr6lrFNzXAkmNTCGnlgkQd/xUb7i9KkNJguiQ0Rn7oHKeisXlCmCKjxOnacgEncDqq5sw7TqAe0Z8Y1EndpE9JPJc8llVpNf6RWxasbgvYHFuknOknOnqsrit3csqtbSpB4cAR4TG+QXlwA6qd7AmrNQOYZIpTLmgwGlpEEfsi8N4lTqS2lJMlz5OWE7EzyPIDkplLUljcqfjlh5LFox4qn+3DXwXkPOHNAgxzE49Ois8WqtpU3VYDSIl2kuPs3fGPZEY4Tg7HOdsc/RFqOBGwI9IgraONKLimS+TJtLy2aA75kawNi4MJaADpEkAx06HzVltOnXZsCJwWzESdJBIG/QdUuH2mhpa7SRqJDWtAa0HkBGczlXqNIDDRA6DAHkFOPHPbVVd1QOjN4dY/IJhxIMAzAGOekYnui3sOA9xO8R/0FK7rtYSdLjJiGtLnE+nLuh6tTtjhpeZ3BI0tEctz7FXGo+2I3vuVhSCPSASATgLoJJFRJT6lEpAKUgoynlIZOFJoUWKwwKkIlRYiuTBMVQhkkkkAQUU5KG9yAEUlAOJT6CgBnKbDkJgxTotykwFXt/H8wb7OHbqO4/nJEa0ohKiHQoSQyvXmDDoPUiQO5H/AGqllRa3U5tRzhUIcNRkAaQAGf6YbPuVpvbPP05qpWtpwScEERLdjO43GNlm472VYFwDgWnJaftDEwCDGJ/6VWzsxSDm0ywOIccCCTsCROQJGQefJXn+ECQTJAkDmeZzgIXEDTFNxe4tbzLS5rsfdLczjks5wT3fYLLNrH1EAPLROBMDkSJmCTzUmDxE6SOWzc4HimZjlH4INCoHMBZrG0SIJiD9sZB2nvvzRLekXAOcxzHSca9XPqDt2WkXxQiypseoOUP8ffktBDVhmY8UQDAJE9PwRKNrpY4budJcep5DyCnRZHco4RFLkGZMJKREEhOqAjCQYpwkEAMGKQYpBOEAJrUQJgE6Yh0ySSYCSSSQAGEtKdJADJ0kkAMpMdlRAQPmeM9gFMnSAuEqBcoB8qLnLOygmpMax/8AUEuQ3vS1AHfdY2ygsuxHiBnnG09pQHPQnOUt7jotvvjkNby8M9e46eSFY3VfPzRT7Fmr2Or0yq4cisKm23djaL7XzuUdr5VKmrVNXqJLNNFBQGlEc/C0iyWUbkgEkqLHSgcXrNaAX7HH6rMsuKsPhbKwn1EIS0tlJbG4kCs+vWcIM4Vq3qArRZU3QFgFSBQ9SlK1TEycpyVBqdwlMRMFJRCdMB5SUU4QBBJMFJADJFJMUAOVmPqw5x7gewWkVz9w7wvcPvH8Fy9VNxiVE0tfMFCfVcFlcN4mPocc7BajsrDHlU1aY6CUrkHGxUnFVHBIVTzytNbrcAlRyHqQ312qDaoOxWcp7lIOCisKA1yK1GsGWqblapFUWVAERtQnstIyRDLguBsM/opfMlZtavpGN09u9zvLmf2UPqoqWlchpHv2NqENcJGfdIWbGjAAKFcvh7Y2BCNc053MBPHUrbVsCr8xpccyRyTUb8AkOGmEBlOkCXNcC7zR2s1NkgLNTk32sqi61zamQUemyOaBQGkREKw13ddkF3fJJMBSBQW6pycIgK1TJCJFMnVAMnCUJwEARBTFRwExKAHlM1RJSacIAVZ0A+RXLtvBDgeZK6G+qQxx7Lz6+uI1ef5f+rz+tlSKiVuIXAa4lp549CtbhPH9g8zykfrC5y+hx8OxaPfmqbSQvEWRxlsaVZ6fTuQ4SCCk6sOi4Gy4i9hkE+R2XQ2XF9YyF2w6q0LSazqrUEubOCoBzXKpX4eHGdTh5FVLK64HRdfdBu7lE8QA5+5WJeW3yxJrnOwMHbzWPfXYJ3lcc+qndJFUd9b37CMOB9UV3EGjc+i84tL4tONuavi9JMqMnV5UhUjumV2HJIVx9wGtmdlx1ndjBKs3PES/A+kbefVY4uravbcHEuXN2Y1Tn9ZXR1AXN8wuSa4Fpnn+8rrbR2pjT2H5L2f4bJy1WRI5S7+Fnl5c2qQSequ8O4PVZ9VUkLo9KG+lK6pdHjbuv8i1MzL26cwYEjmo2XFGhucK3e+EfTPZVLrh7XsgNE79IKiccincXwuAVGjbXOpXGFZNhauYN1fpNO5K3wym4rUtxOiyHKQKG0IgXSiRwkEk6YFclRLkMvUA/qlYBHOUWOwh1KiHrQAHjVaKRXmnEbnxEeq7n4kr/wBv1XmXEq2ZXndVvKiydKtndWvlk5WFTuc52WjbXJ+ycdF5GTE7tFJnUcKoUjhwE91sBrBs0ei4f+tcMog4w7ulCMktx2da6/aPsqhfce0jAz7rFPGnAbAnuqNfiGvJABj8VT1ILJ3V2+o4ucf2A7IbacoDaquUnBZytDE1kI1Koq9asgUXEuU6NStgdJamUV74yOqzW1oCk2uuVY97CzXt7icdc/ku44W6aYzyXntq7LV23AKnhgHESvY/hsqnQmrNiEpCjlDdg45r3WzImYKpXmoQWb8/JWajCdjjmospx4e26zmnLYZH5hDQcd1apv7KnW1aYDU1tUx4zB81KnplTAvveEWcKvTqgo0LZOySbSnJQ2/gpPKpMDOL0J1TohPMoRqRupbGHc7ugVK6C+ohEoGUfiQk0SRyMrzS+qL1W8p6mOHZeW8ctjTeRy5Lz8/xmjj7EzIc5Tp1yOaE8qIKy02Zmky780VlcdVlgpi9S8KYWaNWp3QhVVE1T1UfmlJYB2a1KqFYFdYjaxU21j1WcunDUaxrSi0qsbLIZUVuk5RLFQ7NZlSVE1jKDSekBOywlFIDZ4fUmO38C9C+HKZDFwPw1alz9p5L06wpBjAOq6ugxfiajXiDfzLAQbyq5oGlmo9kcqMwDK9t7owBVXHTq2gTCxad9Vd4i4aZxH5FbYrNc2RkLFrWOHHTpbJON1x9QpNJxY1RZtrlznDUYPTlCk2nU1u8InkTt7LnqNR9F2um572EfakwfNa1LiNSqQ3Tp5lxG47LmhnT9s7vt5KaL7wSW7zz0q852kYzz81UoTkgjb1lWHAYnJC7sau2iGK1c8mSI81YqPIB6QqlW6DfqwOSgLgOiDgrSDS9t7iZnvqIDnoZemlaDJqQaotCmgZNjVyPxXwguOByMdx1811rSmvaAqMLTvyPQrDPi1rblGmOaWz4Z4ld25achVwV3nGeFzMtnqP+TDyPbYrk7vhpE6fEBviHN/ybuPPZccb4YZMbjxwUCVEuUnNVbVC0RiTeVAFRqPUNSqgLAcpNKC16mHKWgLTDCt0X/gqDCSrLRGSYXPMZfpVJEK7Y0yXRvOwHNA4dZucQGt32JG/kOf8AMrufhzgYadtTuc7N7k/osfSbe/8AY2x4m93wavwpwzSMjxHJ7BdaRCDaUAxvUnc9VMuXr9Ph9OPknLPU6XCG1yg0wdRByIwUQpiR1WtWZipPacDlyULui1wh23RMGjVq7R2Qa51NO7eU/qEnxTEY3FuM29GKRaYjMAwMq7w+8bV+gSImSMAdFzvE7ukH/LptLyAS77RJ3WLQ+I3TpcTTAw4NGCdhIXkzzSjk8Lsi0tj0CpdMZGQCTyzPmrjqzRknl6rhql6HPFMVG6tGoScGenRbvCLlzwBiREQZnkfRPF1zc6aq+BuJttIeCCyR1KlQpgYAwBumYckY7qy2mIiML04K9+5mzlQVJrkNTY1aDCBym1IBOgBSp6kOU4KBlPiFuCJiVzHEuHA5iY2IMOb5ELsKhWZdW8zpwVjkxKW5pDI1scNd8JJyNLj0MMf7jB8yFjXXDHN+yR5tJH/02Z9l2905oMVGlp+8MhANsTllQO9Vg8c15L/Dl4OCdaHlpP8AuaPwJBQTbn7pXcV7N/OkHegKrOsRzt4/2KfsL0o/M5WlZuP2PcgfmrNOwcfuA93g/gyT+C6Nlh92gD5s/daFtw6sdmBvsPySpvhB6Ue7ObteDPOZPmG6R6Of+y1rDhLAQSZd0ALnT2cdvQLo7X4eG9WpjpMD3XQcMt6TcUmDzA/5JrDJ+B3jj5KXB+BuiXDQ3pu8+ZXW2Vq1ghogfzJQ7dnVHL11Y8MYGc8spk6j0GCpjqk13VamQAW7pnUfLl5olNmkZJPfcn2QOJWz6gDWP0iZJ5x0Ct0GaQBMxzKhXqarb5gBrUNUjVj8j1Vau2oC1oYHDOpzjmesK6QBJGOvohvrggROefTulKK7vcDFo8LZ83xafmAagGiABOZXP8e4C0uqHDtUYAyHAzJAXXWlRoJJcCQIJJBPryCBxaoW03ERqcQ0HYZ2XHkhF420Ve551Q4W5zjLfpOIByPPthdJ8NMqUpc9zdIcAMmY5qxwrh1YAufOreMHM7tjksi7t307iQ3UwT8wcvF19V5yjNe9r6FnaUeL03GBJzExvPRaFlgDLvJ264HgtcPLWvBpvB1aTgOydj0Xe2jvCJbAEAEmZC7uj6ieWbU+xMo0jng1EaFMMUwxeoQRCSnpS0noihkEkTQolqQAagVeo3KulqHUpfzukMza1AO3CwuIcCDpLCWO6hdYacjZDfbgpNDs4z+hum/TWJ8xKkH3g+4fMLsP6U9FNlkNyigs5Njr082N7wrljaXNTe4xMHQB+a6pliIyJVq2s2sENaAOwhLTuFmTZcCaMvLnnq4k/gt63oBuwRKbUmuJdGkx97EHsr4JsmSnGPVSxjZQfEzGRnPL1RYggHVNPum+Y2NQODznCTggCY81TuqzTEVC07AgSM/hyUmPAdo0xDcHGx5QhValKmRqIbrgCTHkAFnKVrt5AbjDXmi4MdmN+3PC5e74o6k0Mdv9LgJEB3Mrq69TsRy1RiPJZPFuHFzmkt1gRJLROcQIyuLq4OXvjdpdiomTZUarHOfSBe0xBHiAgbEFWx/UOeJLXMmNJblpGZI6resbZrGQxsSNp588rJbbvZW+ZqbBkGm3xH/S7z3yud9P6eNam9+Sr3Ni3rhzdJ3HhOD/AALH4xZuqO+WGQ0kQ4E/UNp7brctrSGgy7V9rv5hW6lHEctvRd/ovJj0vYi6ZhcJ4EKZ1uc17iTmJweXeF0DM7CAFUpUjT0sYwlp3Mjwj9VeAV9PhjjVJfUTdnONUgnSXSBIJykkkBEJFJJIBghXX0nySSSnwxopcGyx0/eP5q7G6SSww/loYYclIc/JJJbsQahsPNPcH+eqZJL+UC5yRGpJLRcEsA4f3B/if0Q7w5P+B/ROksXwyidv9I8h+Shd/Sf51SSSj+WvoDMLgVRzi0ucSepJPNWS0Orv1CYc2JzGOU7JJLzcXwy/V+xfdFziJimSEXhplpJyZ3O+wSSXo/1vsZkmnxjyKr8IaC+oSMh2DzHkkkscnxr9X7FRNdoUwkku4gQUgmSTA//Z
30	Ôlong Sữa	38000.00	2	t	data:image/jpeg;base64,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
31	Ôlong Sữa Bơ	42000.00	2	t	data:image/jpeg;base64,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
23	Trà Đào Cam Sả	40000.00	2	t	data:image/jpeg;base64,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
25	Trà Lài Vải	40000.00	2	t	data:image/jpeg;base64,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
24	Trà Ổi Hồng	40000.00	2	t	data:image/jpeg;base64,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
26	Trà Sả Chanh Mật Ong	40000.00	2	t	data:image/jpeg;base64,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
7	Americano	42000.00	1	t	data:image/jpeg;base64,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
9	Americano Quýt	45000.00	1	t	data:image/jpeg;base64,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
\.


--
-- TOC entry 3518 (class 0 OID 16587)
-- Dependencies: 218
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (id, code, name, address) FROM stdin;
1	PHT	Trình Cafe - 25 Phạm Hồng Thái	Quận Hải Châu, Đà Nẵng
2	LDD	Trình Cafe - 22/4 Lê Đình Dương	Quận Hải Châu, Đà Nẵng
3	NHT	Trình Cafe - 34/4 Nguyễn Hữu Thọ	Quận Thanh Khê, Đà Nẵng
4	PNX	Trình Cafe - 100/19 Phạm Như Xương	Quận Liên Chiểu, Đà Nẵng
\.


--
-- TOC entry 3530 (class 0 OID 16673)
-- Dependencies: 230
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, item_id, quantity, price) FROM stdin;
1	1	7	1	42000.00
2	1	9	1	45000.00
3	2	8	1	45000.00
4	3	45	1	45000.00
5	3	12	1	32000.00
6	3	30	1	38000.00
7	3	8	3	45000.00
8	3	53	3	35000.00
9	3	9	1	45000.00
10	3	50	3	35000.00
11	4	51	3	20000.00
12	4	6	1	40000.00
13	4	44	3	45000.00
14	4	42	2	42000.00
15	4	11	3	30000.00
16	4	36	3	40000.00
17	4	29	3	48000.00
18	5	53	2	35000.00
19	5	33	2	35000.00
20	5	52	3	38000.00
21	5	20	2	42000.00
22	5	1	3	42000.00
23	5	36	3	40000.00
24	5	52	1	38000.00
25	6	46	3	45000.00
26	6	4	2	40000.00
27	6	40	2	38000.00
28	6	17	2	42000.00
29	6	7	2	42000.00
30	6	2	3	30000.00
31	6	27	1	45000.00
32	7	25	3	40000.00
33	7	31	3	42000.00
34	7	54	2	50000.00
35	7	22	1	42000.00
36	7	36	3	40000.00
37	7	40	2	38000.00
38	7	39	2	45000.00
39	8	9	2	45000.00
40	8	28	3	45000.00
41	8	48	1	45000.00
42	8	31	2	42000.00
43	8	33	3	35000.00
44	8	17	1	42000.00
45	8	56	1	38000.00
46	9	56	2	38000.00
47	9	48	2	45000.00
48	9	50	1	35000.00
49	9	31	1	42000.00
50	9	27	1	45000.00
51	9	32	3	40000.00
52	9	46	2	45000.00
53	10	29	1	48000.00
54	10	2	1	30000.00
55	10	42	3	42000.00
56	10	12	3	32000.00
57	10	33	1	35000.00
58	10	19	1	42000.00
59	10	44	3	45000.00
60	11	11	1	30000.00
61	11	12	3	32000.00
62	11	26	1	40000.00
63	11	21	2	42000.00
64	11	54	3	50000.00
65	11	49	1	35000.00
66	11	45	3	45000.00
67	12	18	3	45000.00
68	12	7	2	42000.00
69	12	46	2	45000.00
70	12	38	3	40000.00
71	12	14	3	37000.00
72	12	39	2	45000.00
73	12	24	3	40000.00
74	13	54	1	50000.00
75	13	16	3	38000.00
76	13	32	3	40000.00
77	13	49	3	35000.00
78	13	37	2	40000.00
79	13	15	3	42000.00
80	13	56	3	38000.00
81	14	26	2	40000.00
82	14	56	1	38000.00
83	14	6	2	40000.00
84	14	22	1	42000.00
85	14	6	2	40000.00
86	14	46	3	45000.00
87	14	31	1	42000.00
88	15	28	3	45000.00
89	15	26	2	40000.00
90	15	27	1	45000.00
91	15	8	1	45000.00
92	15	32	1	40000.00
93	15	41	1	45000.00
94	15	41	3	45000.00
95	16	18	3	45000.00
96	16	56	1	38000.00
97	16	54	2	50000.00
98	16	13	2	35000.00
99	16	26	3	40000.00
100	16	45	3	45000.00
101	16	1	2	42000.00
102	17	28	2	45000.00
103	17	43	2	40000.00
104	17	40	2	38000.00
105	17	2	3	30000.00
106	17	20	3	42000.00
107	17	2	3	30000.00
108	17	50	3	35000.00
109	18	44	2	45000.00
110	18	52	2	38000.00
111	18	16	2	38000.00
112	18	33	2	35000.00
113	18	41	2	45000.00
114	18	7	3	42000.00
115	18	2	2	30000.00
116	19	45	2	45000.00
117	19	56	1	38000.00
118	19	8	2	45000.00
119	19	44	3	45000.00
120	19	45	2	45000.00
121	19	5	1	40000.00
122	19	40	3	38000.00
123	20	3	1	32000.00
124	20	51	3	20000.00
125	20	44	3	45000.00
126	20	31	3	42000.00
127	20	28	3	45000.00
128	20	14	1	37000.00
129	20	49	2	35000.00
130	21	21	3	42000.00
131	21	54	1	50000.00
132	21	5	3	40000.00
133	21	11	3	30000.00
134	21	26	1	40000.00
135	21	11	3	30000.00
136	21	16	1	38000.00
137	22	39	2	45000.00
138	22	33	3	35000.00
139	22	14	3	37000.00
140	22	9	1	45000.00
141	22	27	1	45000.00
142	22	44	3	45000.00
143	22	42	1	42000.00
144	23	56	1	38000.00
145	23	18	2	45000.00
146	23	4	2	40000.00
147	23	48	2	45000.00
148	23	39	2	45000.00
149	23	12	3	32000.00
150	23	25	3	40000.00
151	24	11	3	30000.00
152	24	32	1	40000.00
153	24	2	3	30000.00
154	24	21	3	42000.00
155	24	9	1	45000.00
156	24	10	2	35000.00
157	24	6	3	40000.00
158	25	26	3	40000.00
159	25	54	3	50000.00
160	25	46	1	45000.00
161	25	42	3	42000.00
162	25	25	2	40000.00
163	25	18	3	45000.00
164	25	50	3	35000.00
165	26	31	1	42000.00
166	26	29	3	48000.00
167	26	19	2	42000.00
168	26	25	3	40000.00
169	26	21	2	42000.00
170	26	16	1	38000.00
171	26	32	3	40000.00
172	27	46	2	45000.00
173	27	33	3	35000.00
174	27	12	2	32000.00
175	27	40	2	38000.00
176	27	18	2	45000.00
177	27	32	2	40000.00
178	27	15	2	42000.00
179	28	20	1	42000.00
180	28	35	1	38000.00
181	28	33	1	35000.00
182	28	56	3	38000.00
183	28	53	1	35000.00
184	28	36	2	40000.00
185	28	27	3	45000.00
186	29	42	1	42000.00
187	29	22	3	42000.00
188	29	16	3	38000.00
189	29	23	3	40000.00
190	29	46	2	45000.00
191	29	44	2	45000.00
192	29	49	3	35000.00
193	30	15	2	42000.00
194	30	22	3	42000.00
195	30	5	2	40000.00
196	30	25	2	40000.00
197	30	32	2	40000.00
198	30	48	1	45000.00
199	30	44	3	45000.00
200	31	23	2	40000.00
201	31	33	3	35000.00
202	31	13	2	35000.00
203	31	3	3	32000.00
204	31	8	1	45000.00
205	31	18	1	45000.00
206	31	33	1	35000.00
207	32	53	2	35000.00
208	32	25	2	40000.00
209	32	15	1	42000.00
210	32	32	1	40000.00
211	32	22	1	42000.00
212	32	32	2	40000.00
213	32	45	2	45000.00
214	33	54	2	50000.00
215	33	46	3	45000.00
216	33	36	2	40000.00
217	33	7	1	42000.00
218	33	56	1	38000.00
219	33	54	1	50000.00
220	33	3	2	32000.00
221	34	12	2	32000.00
222	34	22	2	42000.00
223	34	53	3	35000.00
224	34	15	3	42000.00
225	34	40	1	38000.00
226	34	21	1	42000.00
227	34	55	2	35000.00
228	35	30	1	38000.00
229	35	40	3	38000.00
230	35	29	3	48000.00
231	35	51	2	20000.00
232	35	5	3	40000.00
233	35	38	1	40000.00
234	35	25	2	40000.00
235	36	53	3	35000.00
236	36	52	3	38000.00
237	36	34	1	40000.00
238	36	47	3	45000.00
239	36	9	1	45000.00
240	36	45	3	45000.00
241	36	49	3	35000.00
242	37	17	2	42000.00
243	37	19	3	42000.00
244	37	36	2	40000.00
245	37	50	1	35000.00
246	37	18	2	45000.00
247	37	56	2	38000.00
248	37	24	3	40000.00
249	38	1	3	42000.00
250	38	52	2	38000.00
251	38	7	2	42000.00
252	38	55	3	35000.00
253	38	12	1	32000.00
254	38	18	3	45000.00
255	38	36	1	40000.00
256	39	49	3	35000.00
257	39	24	2	40000.00
258	39	13	2	35000.00
259	39	51	3	20000.00
260	39	31	1	42000.00
261	39	53	1	35000.00
262	39	7	2	42000.00
263	40	48	1	45000.00
264	40	25	2	40000.00
265	40	6	3	40000.00
266	40	33	2	35000.00
267	40	11	3	30000.00
268	40	18	2	45000.00
269	40	35	2	38000.00
270	41	28	2	45000.00
271	41	7	2	42000.00
272	41	11	3	30000.00
273	41	22	2	42000.00
274	41	42	3	42000.00
275	41	17	3	42000.00
276	41	20	1	42000.00
277	42	55	2	35000.00
278	42	40	3	38000.00
279	42	17	2	42000.00
280	42	39	2	45000.00
281	42	23	3	40000.00
282	42	31	3	42000.00
283	42	31	1	42000.00
284	43	54	1	50000.00
285	43	32	3	40000.00
286	43	52	1	38000.00
287	43	19	1	42000.00
288	43	25	1	40000.00
289	43	50	3	35000.00
290	43	50	2	35000.00
291	44	17	3	42000.00
292	44	48	2	45000.00
293	44	23	3	40000.00
294	44	50	3	35000.00
295	44	48	1	45000.00
296	44	53	2	35000.00
297	44	18	3	45000.00
298	45	27	2	45000.00
299	45	22	3	42000.00
300	45	30	1	38000.00
301	45	56	2	38000.00
302	45	48	2	45000.00
303	45	2	2	30000.00
304	45	52	3	38000.00
305	46	20	3	42000.00
306	46	43	2	40000.00
307	46	46	1	45000.00
308	46	47	2	45000.00
309	46	50	2	35000.00
310	46	24	2	40000.00
311	46	22	2	42000.00
312	47	22	2	42000.00
313	47	42	1	42000.00
314	47	13	3	35000.00
315	47	20	1	42000.00
316	47	5	2	40000.00
317	47	4	2	40000.00
318	47	20	3	42000.00
319	48	6	3	40000.00
320	48	20	1	42000.00
321	48	27	1	45000.00
322	48	44	2	45000.00
323	48	11	1	30000.00
324	48	51	1	20000.00
325	48	16	3	38000.00
326	49	33	3	35000.00
327	49	34	3	40000.00
328	49	39	1	45000.00
329	49	25	3	40000.00
330	49	27	2	45000.00
331	49	12	3	32000.00
332	49	56	3	38000.00
333	50	37	2	40000.00
334	50	49	1	35000.00
335	50	39	3	45000.00
336	50	34	1	40000.00
337	50	52	2	38000.00
338	50	30	1	38000.00
339	50	30	1	38000.00
340	51	16	3	38000.00
341	51	21	2	42000.00
342	51	56	2	38000.00
343	51	32	1	40000.00
344	51	2	1	30000.00
345	51	39	1	45000.00
346	51	17	2	42000.00
347	52	30	2	38000.00
348	52	22	3	42000.00
349	52	54	1	50000.00
350	52	7	1	42000.00
351	52	31	1	42000.00
352	52	41	3	45000.00
353	52	32	2	40000.00
354	53	53	2	35000.00
355	53	46	2	45000.00
356	53	16	1	38000.00
357	53	38	1	40000.00
358	53	13	1	35000.00
359	53	27	3	45000.00
360	53	39	3	45000.00
361	54	20	1	42000.00
362	54	19	2	42000.00
363	54	23	1	40000.00
364	54	18	2	45000.00
365	54	16	1	38000.00
366	54	23	2	40000.00
367	54	55	2	35000.00
368	55	40	3	38000.00
369	55	14	3	37000.00
370	55	16	3	38000.00
371	55	28	3	45000.00
372	55	24	3	40000.00
373	55	48	1	45000.00
374	55	4	2	40000.00
375	56	10	1	35000.00
376	56	25	1	40000.00
377	56	44	2	45000.00
378	56	8	3	45000.00
379	56	8	1	45000.00
380	56	22	2	42000.00
381	56	23	3	40000.00
382	57	51	1	20000.00
383	57	9	2	45000.00
384	57	5	1	40000.00
385	57	50	1	35000.00
386	57	20	2	42000.00
387	57	44	1	45000.00
388	57	17	1	42000.00
389	58	34	2	40000.00
390	58	45	2	45000.00
391	58	7	3	42000.00
392	58	29	1	48000.00
393	58	7	3	42000.00
394	58	39	3	45000.00
395	58	24	1	40000.00
396	59	38	2	40000.00
397	59	35	2	38000.00
398	59	47	1	45000.00
399	59	20	1	42000.00
400	59	41	1	45000.00
401	59	7	2	42000.00
402	59	13	2	35000.00
403	60	21	2	42000.00
404	60	20	1	42000.00
405	60	36	2	40000.00
406	60	8	3	45000.00
407	60	31	2	42000.00
408	60	41	2	45000.00
409	60	25	2	40000.00
410	61	8	1	45000.00
411	61	38	1	40000.00
412	61	26	3	40000.00
413	61	4	1	40000.00
414	61	13	3	35000.00
415	61	52	2	38000.00
416	61	20	3	42000.00
417	62	49	3	35000.00
418	62	35	2	38000.00
419	62	8	1	45000.00
420	62	12	1	32000.00
421	62	42	3	42000.00
422	62	7	2	42000.00
423	62	2	3	30000.00
424	63	44	2	45000.00
425	63	8	2	45000.00
426	63	52	1	38000.00
427	63	26	3	40000.00
428	63	52	1	38000.00
429	63	6	3	40000.00
430	63	51	1	20000.00
431	64	42	1	42000.00
432	64	30	3	38000.00
433	64	46	2	45000.00
434	64	30	3	38000.00
435	64	21	1	42000.00
436	64	19	2	42000.00
437	64	53	2	35000.00
438	65	50	1	35000.00
439	65	56	1	38000.00
440	65	1	1	42000.00
441	65	8	3	45000.00
442	65	50	2	35000.00
443	65	38	1	40000.00
444	65	30	1	38000.00
445	66	5	1	40000.00
446	66	25	3	40000.00
447	66	1	2	42000.00
448	66	11	2	30000.00
449	66	39	1	45000.00
450	66	50	3	35000.00
451	66	20	1	42000.00
452	67	32	2	40000.00
453	67	17	1	42000.00
454	67	25	2	40000.00
455	67	26	1	40000.00
456	67	16	2	38000.00
457	67	9	3	45000.00
458	67	5	1	40000.00
459	68	50	2	35000.00
460	68	5	2	40000.00
461	68	5	3	40000.00
462	68	54	3	50000.00
463	68	16	3	38000.00
464	68	6	1	40000.00
465	68	51	1	20000.00
466	69	20	1	42000.00
467	69	4	3	40000.00
468	69	40	2	38000.00
469	69	52	1	38000.00
470	69	51	3	20000.00
471	69	56	1	38000.00
472	69	5	2	40000.00
473	70	29	3	48000.00
474	70	30	1	38000.00
475	70	44	3	45000.00
476	70	30	2	38000.00
477	70	23	1	40000.00
478	70	36	1	40000.00
479	70	31	2	42000.00
480	71	46	2	45000.00
481	71	55	1	35000.00
482	71	28	2	45000.00
483	71	40	3	38000.00
484	71	47	3	45000.00
485	71	13	1	35000.00
486	71	40	1	38000.00
487	72	45	3	45000.00
488	72	31	2	42000.00
489	72	18	3	45000.00
490	72	14	2	37000.00
491	72	4	2	40000.00
492	72	13	3	35000.00
493	72	54	1	50000.00
494	73	44	3	45000.00
495	73	39	1	45000.00
496	73	6	1	40000.00
497	73	12	3	32000.00
498	73	32	2	40000.00
499	73	22	3	42000.00
500	73	53	3	35000.00
501	74	22	3	42000.00
502	74	12	2	32000.00
503	74	13	3	35000.00
504	74	28	3	45000.00
505	74	27	3	45000.00
506	74	26	3	40000.00
507	74	19	2	42000.00
508	75	45	2	45000.00
509	75	33	2	35000.00
510	75	41	3	45000.00
511	75	5	1	40000.00
512	75	32	2	40000.00
513	75	32	1	40000.00
514	75	38	3	40000.00
515	76	23	3	40000.00
516	76	19	3	42000.00
517	76	44	1	45000.00
518	76	54	3	50000.00
519	76	42	1	42000.00
520	76	29	1	48000.00
521	76	12	2	32000.00
522	77	41	2	45000.00
523	77	55	1	35000.00
524	77	14	1	37000.00
525	77	50	2	35000.00
526	77	51	2	20000.00
527	77	45	3	45000.00
528	77	11	3	30000.00
529	78	7	1	42000.00
530	78	46	1	45000.00
531	78	37	2	40000.00
532	78	7	1	42000.00
533	78	41	3	45000.00
534	78	52	2	38000.00
535	78	12	2	32000.00
536	79	18	2	45000.00
537	79	22	2	42000.00
538	79	50	1	35000.00
539	79	25	2	40000.00
540	79	12	1	32000.00
541	79	40	3	38000.00
542	79	43	2	40000.00
543	80	23	2	40000.00
544	80	38	3	40000.00
545	80	35	3	38000.00
546	80	25	1	40000.00
547	80	1	2	42000.00
548	80	34	1	40000.00
549	80	24	3	40000.00
550	81	13	2	35000.00
551	81	8	3	45000.00
552	81	10	1	35000.00
553	81	50	3	35000.00
554	81	15	1	42000.00
555	81	30	2	38000.00
556	81	38	2	40000.00
557	82	23	3	40000.00
558	82	36	2	40000.00
559	82	49	1	35000.00
560	82	25	1	40000.00
561	82	53	1	35000.00
562	82	38	1	40000.00
563	82	50	1	35000.00
564	83	37	2	40000.00
565	83	38	2	40000.00
566	83	51	2	20000.00
567	83	5	1	40000.00
568	83	26	1	40000.00
569	83	39	2	45000.00
570	83	29	1	48000.00
571	84	21	1	42000.00
572	84	38	1	40000.00
573	84	30	3	38000.00
574	84	33	2	35000.00
575	84	31	2	42000.00
576	84	34	2	40000.00
577	84	54	2	50000.00
578	85	19	1	42000.00
579	85	11	2	30000.00
580	85	49	3	35000.00
581	85	37	3	40000.00
582	85	54	2	50000.00
583	85	43	2	40000.00
584	85	2	3	30000.00
585	86	1	1	42000.00
586	86	47	1	45000.00
587	86	24	3	40000.00
588	86	18	1	45000.00
589	86	40	1	38000.00
590	86	38	3	40000.00
591	86	51	2	20000.00
592	87	25	1	40000.00
593	87	51	3	20000.00
594	87	51	3	20000.00
595	87	25	3	40000.00
596	87	35	3	38000.00
597	87	38	1	40000.00
598	87	22	2	42000.00
599	88	19	1	42000.00
600	88	21	1	42000.00
601	88	36	3	40000.00
602	88	11	2	30000.00
603	88	41	3	45000.00
604	88	45	1	45000.00
605	88	55	2	35000.00
606	89	14	2	37000.00
607	89	56	1	38000.00
608	89	8	1	45000.00
609	89	38	2	40000.00
610	89	49	1	35000.00
611	89	53	2	35000.00
612	89	26	2	40000.00
613	90	52	3	38000.00
614	90	45	2	45000.00
615	90	56	2	38000.00
616	90	43	2	40000.00
617	90	31	1	42000.00
618	90	10	1	35000.00
619	90	19	3	42000.00
620	91	7	1	42000.00
621	91	31	1	42000.00
622	91	10	3	35000.00
623	91	33	2	35000.00
624	91	51	2	20000.00
625	91	5	2	40000.00
626	91	28	3	45000.00
627	92	16	3	38000.00
628	92	9	1	45000.00
629	92	6	1	40000.00
630	92	5	1	40000.00
631	92	54	3	50000.00
632	92	12	2	32000.00
633	92	47	2	45000.00
634	93	11	1	30000.00
635	93	25	1	40000.00
636	93	31	3	42000.00
637	93	33	3	35000.00
638	93	36	1	40000.00
639	93	12	3	32000.00
640	93	21	3	42000.00
641	94	38	3	40000.00
642	94	53	2	35000.00
643	94	23	1	40000.00
644	94	46	2	45000.00
645	94	30	3	38000.00
646	94	5	1	40000.00
647	94	9	2	45000.00
648	95	21	3	42000.00
649	95	35	1	38000.00
650	95	49	2	35000.00
651	95	28	1	45000.00
652	95	11	3	30000.00
653	95	20	2	42000.00
654	95	44	1	45000.00
655	96	19	2	42000.00
656	96	29	3	48000.00
657	96	51	1	20000.00
658	96	30	2	38000.00
659	96	20	2	42000.00
660	96	23	1	40000.00
661	96	13	1	35000.00
662	97	10	1	35000.00
663	97	15	1	42000.00
664	97	18	3	45000.00
665	97	34	1	40000.00
666	97	53	1	35000.00
667	97	23	1	40000.00
668	97	4	2	40000.00
669	98	28	3	45000.00
670	98	47	3	45000.00
671	98	53	1	35000.00
672	98	7	3	42000.00
673	98	6	1	40000.00
674	98	33	2	35000.00
675	98	48	3	45000.00
676	99	32	3	40000.00
677	99	25	3	40000.00
678	99	36	3	40000.00
679	99	28	3	45000.00
680	99	52	3	38000.00
681	99	50	2	35000.00
682	99	47	2	45000.00
683	100	40	3	38000.00
684	100	14	2	37000.00
685	100	12	1	32000.00
686	100	35	3	38000.00
687	100	36	1	40000.00
688	100	38	2	40000.00
689	100	46	3	45000.00
690	101	5	3	40000.00
691	101	7	3	42000.00
692	101	44	1	45000.00
693	101	51	3	20000.00
694	101	19	1	42000.00
695	101	20	3	42000.00
696	101	4	3	40000.00
697	102	46	3	45000.00
698	102	52	2	38000.00
699	102	43	1	40000.00
700	102	5	1	40000.00
701	102	41	1	45000.00
702	102	42	2	42000.00
703	102	10	1	35000.00
704	103	9	1	45000.00
705	103	26	2	40000.00
706	103	26	3	40000.00
707	103	11	1	30000.00
708	103	53	2	35000.00
709	103	43	1	40000.00
710	103	49	2	35000.00
711	104	50	3	35000.00
712	104	38	3	40000.00
713	104	50	2	35000.00
714	104	20	3	42000.00
715	104	11	2	30000.00
716	104	14	3	37000.00
717	104	16	3	38000.00
718	105	18	2	45000.00
719	105	15	2	42000.00
720	105	51	3	20000.00
721	105	24	3	40000.00
722	105	36	1	40000.00
723	105	24	1	40000.00
724	105	15	1	42000.00
725	106	22	1	42000.00
726	106	39	2	45000.00
727	106	3	3	32000.00
728	106	4	3	40000.00
729	106	31	2	42000.00
730	106	16	2	38000.00
731	106	41	1	45000.00
732	107	33	1	35000.00
733	107	50	3	35000.00
734	107	24	3	40000.00
735	107	2	1	30000.00
736	107	30	1	38000.00
737	107	30	2	38000.00
738	107	21	2	42000.00
739	108	17	1	42000.00
740	108	24	2	40000.00
741	108	29	3	48000.00
742	108	21	1	42000.00
743	108	31	3	42000.00
744	108	9	2	45000.00
745	108	46	1	45000.00
746	109	7	2	42000.00
747	109	14	2	37000.00
748	109	54	1	50000.00
749	109	24	2	40000.00
750	109	10	3	35000.00
751	109	6	2	40000.00
752	109	36	1	40000.00
753	110	50	3	35000.00
754	110	42	3	42000.00
755	110	33	1	35000.00
756	110	8	3	45000.00
757	110	31	2	42000.00
758	110	42	1	42000.00
759	110	48	1	45000.00
760	111	19	1	42000.00
761	111	5	3	40000.00
762	111	38	2	40000.00
763	111	31	1	42000.00
764	111	52	1	38000.00
765	111	19	2	42000.00
766	111	47	2	45000.00
767	112	54	1	50000.00
768	112	21	1	42000.00
769	112	33	1	35000.00
770	112	50	1	35000.00
771	112	56	1	38000.00
772	112	15	2	42000.00
773	112	37	3	40000.00
774	113	39	1	45000.00
775	113	6	3	40000.00
776	113	51	1	20000.00
777	113	8	3	45000.00
778	113	52	1	38000.00
779	113	18	2	45000.00
780	113	17	2	42000.00
781	114	35	1	38000.00
782	114	38	1	40000.00
783	114	5	2	40000.00
784	114	12	2	32000.00
785	114	13	3	35000.00
786	114	53	2	35000.00
787	114	46	1	45000.00
788	115	54	2	50000.00
789	115	51	3	20000.00
790	115	35	2	38000.00
791	115	23	3	40000.00
792	115	23	2	40000.00
793	115	21	2	42000.00
794	115	4	3	40000.00
795	116	49	2	35000.00
796	116	52	2	38000.00
797	116	5	2	40000.00
798	116	48	1	45000.00
799	116	29	1	48000.00
800	116	33	3	35000.00
801	116	24	2	40000.00
802	117	49	1	35000.00
803	117	8	3	45000.00
804	117	31	1	42000.00
805	117	3	2	32000.00
806	117	27	1	45000.00
807	117	41	2	45000.00
808	117	1	2	42000.00
809	118	26	2	40000.00
810	118	13	2	35000.00
811	118	26	1	40000.00
812	118	53	2	35000.00
813	118	21	2	42000.00
814	118	14	1	37000.00
815	118	25	3	40000.00
816	119	48	2	45000.00
817	119	16	1	38000.00
818	119	14	3	37000.00
819	119	14	3	37000.00
820	119	44	2	45000.00
821	119	31	1	42000.00
822	119	15	3	42000.00
823	120	47	1	45000.00
824	120	22	1	42000.00
825	120	25	1	40000.00
826	120	7	1	42000.00
827	120	19	3	42000.00
828	120	8	1	45000.00
829	120	4	2	40000.00
830	121	17	3	42000.00
831	121	56	3	38000.00
832	121	19	3	42000.00
833	121	28	3	45000.00
834	121	20	2	42000.00
835	121	24	1	40000.00
836	121	27	3	45000.00
837	122	16	2	38000.00
838	122	42	3	42000.00
839	122	29	3	48000.00
840	122	41	1	45000.00
841	122	53	1	35000.00
842	122	36	1	40000.00
843	122	15	2	42000.00
844	123	26	1	40000.00
845	123	15	2	42000.00
846	123	26	3	40000.00
847	123	4	2	40000.00
848	123	53	2	35000.00
849	123	36	3	40000.00
850	123	48	3	45000.00
851	124	29	2	48000.00
852	124	26	2	40000.00
853	124	23	2	40000.00
854	124	35	2	38000.00
855	124	36	3	40000.00
856	124	27	3	45000.00
857	124	41	3	45000.00
858	125	14	1	37000.00
859	125	19	1	42000.00
860	125	14	1	37000.00
861	125	41	1	45000.00
862	125	50	3	35000.00
863	125	32	2	40000.00
864	125	50	2	35000.00
865	126	32	2	40000.00
866	126	36	3	40000.00
867	126	21	3	42000.00
868	126	15	1	42000.00
869	126	42	3	42000.00
870	126	5	3	40000.00
871	126	26	3	40000.00
872	127	2	2	30000.00
873	127	11	2	30000.00
874	127	34	3	40000.00
875	127	29	1	48000.00
876	127	3	1	32000.00
877	127	29	1	48000.00
878	127	18	3	45000.00
879	128	24	3	40000.00
880	128	12	1	32000.00
881	128	31	2	42000.00
882	128	52	3	38000.00
883	128	51	1	20000.00
884	128	56	1	38000.00
885	128	1	3	42000.00
886	129	25	3	40000.00
887	129	7	1	42000.00
888	129	17	2	42000.00
889	129	13	3	35000.00
890	129	3	3	32000.00
891	129	19	3	42000.00
892	129	42	1	42000.00
893	130	16	2	38000.00
894	130	36	1	40000.00
895	130	17	2	42000.00
896	130	39	1	45000.00
897	130	2	2	30000.00
898	130	29	2	48000.00
899	130	22	2	42000.00
900	131	2	1	30000.00
901	131	55	3	35000.00
902	131	9	1	45000.00
903	131	16	2	38000.00
904	131	38	3	40000.00
905	131	56	1	38000.00
906	131	10	3	35000.00
907	132	8	2	45000.00
908	132	35	3	38000.00
909	132	17	3	42000.00
910	132	56	1	38000.00
911	132	16	2	38000.00
912	132	10	1	35000.00
913	132	32	3	40000.00
914	133	23	2	40000.00
915	133	29	1	48000.00
916	133	17	1	42000.00
917	133	7	2	42000.00
918	133	7	1	42000.00
919	133	16	1	38000.00
920	133	41	3	45000.00
921	134	27	3	45000.00
922	134	39	2	45000.00
923	134	44	3	45000.00
924	134	30	3	38000.00
925	134	37	3	40000.00
926	134	19	2	42000.00
927	134	53	3	35000.00
928	135	2	2	30000.00
929	135	4	3	40000.00
930	135	34	1	40000.00
931	135	40	3	38000.00
932	135	53	1	35000.00
933	135	32	3	40000.00
934	135	27	1	45000.00
935	136	10	3	35000.00
936	136	51	3	20000.00
937	136	35	1	38000.00
938	136	54	1	50000.00
939	136	56	2	38000.00
940	136	37	2	40000.00
941	136	25	3	40000.00
942	137	32	3	40000.00
943	137	16	2	38000.00
944	137	48	2	45000.00
945	137	46	2	45000.00
946	137	22	3	42000.00
947	137	2	2	30000.00
948	137	43	1	40000.00
949	138	26	1	40000.00
950	138	52	1	38000.00
951	138	41	2	45000.00
952	138	16	1	38000.00
953	138	1	3	42000.00
954	138	43	3	40000.00
955	138	4	2	40000.00
956	139	54	2	50000.00
957	139	42	2	42000.00
958	139	43	2	40000.00
959	139	24	1	40000.00
960	139	47	2	45000.00
961	139	1	1	42000.00
962	139	13	1	35000.00
963	140	42	2	42000.00
964	140	21	2	42000.00
965	140	22	1	42000.00
966	140	1	1	42000.00
967	140	50	1	35000.00
968	140	37	3	40000.00
969	140	41	2	45000.00
970	141	22	2	42000.00
971	141	56	2	38000.00
972	141	32	1	40000.00
973	141	20	2	42000.00
974	141	7	3	42000.00
975	141	17	2	42000.00
976	141	9	2	45000.00
977	142	7	1	42000.00
978	142	44	2	45000.00
979	142	35	3	38000.00
980	142	14	3	37000.00
981	142	4	1	40000.00
982	142	12	2	32000.00
983	142	32	3	40000.00
984	143	56	1	38000.00
985	143	19	1	42000.00
986	143	4	1	40000.00
987	143	49	2	35000.00
988	143	53	2	35000.00
989	143	49	2	35000.00
990	143	31	2	42000.00
991	144	51	1	20000.00
992	144	46	2	45000.00
993	144	41	2	45000.00
994	144	29	2	48000.00
995	144	21	3	42000.00
996	144	24	2	40000.00
997	144	13	3	35000.00
998	145	24	1	40000.00
999	145	6	3	40000.00
1000	145	44	1	45000.00
1001	145	47	1	45000.00
1002	145	48	2	45000.00
1003	145	2	2	30000.00
1004	145	29	2	48000.00
1005	146	21	1	42000.00
1006	146	19	2	42000.00
1007	146	45	2	45000.00
1008	146	14	2	37000.00
1009	146	11	3	30000.00
1010	146	38	1	40000.00
1011	146	6	1	40000.00
1012	147	9	1	45000.00
1013	147	28	2	45000.00
1014	147	44	1	45000.00
1015	147	35	1	38000.00
1016	147	29	2	48000.00
1017	147	51	2	20000.00
1018	147	31	3	42000.00
1019	148	51	1	20000.00
1020	148	51	3	20000.00
1021	148	24	1	40000.00
1022	148	28	2	45000.00
1023	148	45	2	45000.00
1024	148	45	1	45000.00
1025	148	6	3	40000.00
1026	149	24	3	40000.00
1027	149	35	1	38000.00
1028	149	37	2	40000.00
1029	149	16	1	38000.00
1030	149	29	3	48000.00
1031	149	55	1	35000.00
1032	149	25	3	40000.00
1033	150	9	3	45000.00
1034	150	39	1	45000.00
1035	150	41	2	45000.00
1036	150	6	2	40000.00
1037	150	17	1	42000.00
1038	150	55	3	35000.00
1039	150	34	1	40000.00
1040	151	10	1	35000.00
1041	151	45	2	45000.00
1042	151	31	1	42000.00
1043	151	39	2	45000.00
1044	151	2	1	30000.00
1045	151	20	3	42000.00
1046	151	8	2	45000.00
1047	152	17	1	42000.00
1048	152	42	2	42000.00
1049	152	22	2	42000.00
1050	152	12	1	32000.00
1051	152	5	2	40000.00
1052	152	44	1	45000.00
1053	152	56	3	38000.00
1054	153	7	1	42000.00
1055	153	33	1	35000.00
1056	153	6	1	40000.00
1057	153	46	3	45000.00
1058	153	14	3	37000.00
1059	153	8	3	45000.00
1060	153	34	3	40000.00
1061	154	11	1	30000.00
1062	154	38	3	40000.00
1063	154	46	2	45000.00
1064	154	44	1	45000.00
1065	154	26	3	40000.00
1066	154	27	2	45000.00
1067	154	32	2	40000.00
1068	155	37	2	40000.00
1069	155	5	1	40000.00
1070	155	16	1	38000.00
1071	155	19	2	42000.00
1072	155	29	2	48000.00
1073	155	19	2	42000.00
1074	155	53	3	35000.00
1075	156	42	2	42000.00
1076	156	46	2	45000.00
1077	156	8	2	45000.00
1078	156	56	3	38000.00
1079	156	43	3	40000.00
1080	156	49	2	35000.00
1081	156	18	2	45000.00
1082	157	5	1	40000.00
1083	157	4	2	40000.00
1084	157	7	1	42000.00
1085	157	22	3	42000.00
1086	157	23	2	40000.00
1087	157	26	2	40000.00
1088	157	27	3	45000.00
1089	158	43	3	40000.00
1090	158	9	1	45000.00
1091	158	16	3	38000.00
1092	158	1	3	42000.00
1093	158	50	1	35000.00
1094	158	50	3	35000.00
1095	158	16	3	38000.00
1096	159	20	1	42000.00
1097	159	36	3	40000.00
1098	159	7	2	42000.00
1099	159	52	1	38000.00
1100	159	2	1	30000.00
1101	159	17	2	42000.00
1102	159	17	3	42000.00
1103	160	40	1	38000.00
1104	160	29	3	48000.00
1105	160	9	3	45000.00
1106	160	47	2	45000.00
1107	160	10	2	35000.00
1108	160	3	3	32000.00
1109	160	27	3	45000.00
1110	161	55	3	35000.00
1111	161	13	2	35000.00
1112	161	47	3	45000.00
1113	161	37	2	40000.00
1114	161	36	2	40000.00
1115	161	21	2	42000.00
1116	161	8	2	45000.00
1117	162	21	2	42000.00
1118	162	6	3	40000.00
1119	162	31	3	42000.00
1120	162	32	2	40000.00
1121	162	24	2	40000.00
1122	162	13	2	35000.00
1123	162	53	1	35000.00
1124	163	51	1	20000.00
1125	163	44	2	45000.00
1126	163	28	1	45000.00
1127	163	40	3	38000.00
1128	163	29	1	48000.00
1129	163	15	3	42000.00
1130	163	7	1	42000.00
1131	164	34	2	40000.00
1132	164	38	3	40000.00
1133	164	1	2	42000.00
1134	164	33	3	35000.00
1135	164	53	2	35000.00
1136	164	28	3	45000.00
1137	164	55	1	35000.00
1138	165	39	1	45000.00
1139	165	15	1	42000.00
1140	165	51	2	20000.00
1141	165	36	3	40000.00
1142	165	42	3	42000.00
1143	165	35	1	38000.00
1144	165	49	2	35000.00
1145	166	42	2	42000.00
1146	166	48	3	45000.00
1147	166	2	2	30000.00
1148	166	17	2	42000.00
1149	166	36	3	40000.00
1150	166	8	3	45000.00
1151	166	41	2	45000.00
1152	167	48	3	45000.00
1153	167	53	1	35000.00
1154	167	2	1	30000.00
1155	167	52	1	38000.00
1156	167	54	2	50000.00
1157	167	7	1	42000.00
1158	167	42	3	42000.00
1159	168	50	3	35000.00
1160	168	31	1	42000.00
1161	168	51	2	20000.00
1162	168	25	2	40000.00
1163	168	23	1	40000.00
1164	168	4	3	40000.00
1165	168	30	3	38000.00
1166	169	43	1	40000.00
1167	169	37	1	40000.00
1168	169	37	1	40000.00
1169	169	5	2	40000.00
1170	169	21	2	42000.00
1171	169	9	2	45000.00
1172	169	16	2	38000.00
1173	170	53	2	35000.00
1174	170	34	3	40000.00
1175	170	47	2	45000.00
1176	170	49	3	35000.00
1177	170	21	2	42000.00
1178	170	3	3	32000.00
1179	170	38	2	40000.00
1180	171	45	3	45000.00
1181	171	29	3	48000.00
1182	171	11	2	30000.00
1183	171	4	1	40000.00
1184	171	54	2	50000.00
1185	171	46	1	45000.00
1186	171	46	3	45000.00
1187	172	46	2	45000.00
1188	172	33	1	35000.00
1189	172	7	3	42000.00
1190	172	28	2	45000.00
1191	172	17	3	42000.00
1192	172	8	2	45000.00
1193	172	44	1	45000.00
1194	173	47	3	45000.00
1195	173	24	1	40000.00
1196	173	43	3	40000.00
1197	173	51	1	20000.00
1198	173	49	2	35000.00
1199	173	51	3	20000.00
1200	173	55	3	35000.00
1201	174	48	3	45000.00
1202	174	18	3	45000.00
1203	174	19	3	42000.00
1204	174	43	3	40000.00
1205	174	15	3	42000.00
1206	174	22	1	42000.00
1207	174	56	3	38000.00
1208	175	7	3	42000.00
1209	175	16	3	38000.00
1210	175	25	3	40000.00
1211	175	18	1	45000.00
1212	175	20	3	42000.00
1213	175	10	1	35000.00
1214	175	21	3	42000.00
1215	176	36	3	40000.00
1216	176	56	3	38000.00
1217	176	40	3	38000.00
1218	176	46	3	45000.00
1219	176	14	3	37000.00
1220	176	41	3	45000.00
1221	176	29	3	48000.00
1222	177	3	1	32000.00
1223	177	31	3	42000.00
1224	177	43	3	40000.00
1225	177	41	3	45000.00
1226	177	4	3	40000.00
1227	177	15	2	42000.00
1228	177	56	3	38000.00
1229	178	52	1	38000.00
1230	178	30	1	38000.00
1231	178	28	3	45000.00
1232	178	25	1	40000.00
1233	178	47	3	45000.00
1234	178	5	3	40000.00
1235	178	20	3	42000.00
1236	179	24	3	40000.00
1237	179	25	2	40000.00
1238	179	7	2	42000.00
1239	179	36	2	40000.00
1240	179	23	2	40000.00
1241	179	55	1	35000.00
1242	179	35	2	38000.00
1243	180	56	2	38000.00
1244	180	10	1	35000.00
1245	180	3	1	32000.00
1246	180	2	1	30000.00
1247	180	46	1	45000.00
1248	180	26	2	40000.00
1249	180	48	1	45000.00
1250	181	38	2	40000.00
1251	181	37	1	40000.00
1252	181	15	2	42000.00
1253	181	21	3	42000.00
1254	181	34	2	40000.00
1255	181	46	2	45000.00
1256	181	44	3	45000.00
1257	182	10	3	35000.00
1258	182	53	2	35000.00
1259	182	49	3	35000.00
1260	182	47	1	45000.00
1261	182	38	2	40000.00
1262	182	36	1	40000.00
1263	182	38	2	40000.00
1264	183	50	2	35000.00
1265	183	2	1	30000.00
1266	183	53	1	35000.00
1267	183	51	2	20000.00
1268	183	39	2	45000.00
1269	183	39	3	45000.00
1270	183	10	1	35000.00
1271	184	42	2	42000.00
1272	184	42	3	42000.00
1273	184	10	3	35000.00
1274	184	40	3	38000.00
1275	184	22	1	42000.00
1276	184	30	3	38000.00
1277	184	26	3	40000.00
1278	185	43	2	40000.00
1279	185	13	3	35000.00
1280	185	4	3	40000.00
1281	185	52	3	38000.00
1282	185	43	3	40000.00
1283	185	33	1	35000.00
1284	185	34	3	40000.00
1285	186	32	1	40000.00
1286	186	31	3	42000.00
1287	186	25	2	40000.00
1288	186	25	2	40000.00
1289	186	36	2	40000.00
1290	186	42	2	42000.00
1291	186	16	3	38000.00
1292	187	28	2	45000.00
1293	187	46	1	45000.00
1294	187	14	1	37000.00
1295	187	28	1	45000.00
1296	187	39	1	45000.00
1297	187	6	1	40000.00
1298	187	25	2	40000.00
1299	188	4	3	40000.00
1300	188	32	1	40000.00
1301	188	27	1	45000.00
1302	188	29	1	48000.00
1303	188	13	2	35000.00
1304	188	30	2	38000.00
1305	188	30	3	38000.00
1306	189	56	3	38000.00
1307	189	17	3	42000.00
1308	189	43	1	40000.00
1309	189	8	1	45000.00
1310	189	9	2	45000.00
1311	189	37	1	40000.00
1312	189	27	3	45000.00
1313	190	1	2	42000.00
1314	190	27	3	45000.00
1315	190	11	2	30000.00
1316	190	52	3	38000.00
1317	190	44	2	45000.00
1318	190	49	3	35000.00
1319	190	10	3	35000.00
1320	191	9	2	45000.00
1321	191	32	2	40000.00
1322	191	28	1	45000.00
1323	191	1	2	42000.00
1324	191	28	1	45000.00
1325	191	17	3	42000.00
1326	191	33	1	35000.00
1327	192	7	3	42000.00
1328	192	33	1	35000.00
1329	192	3	3	32000.00
1330	192	49	3	35000.00
1331	192	33	3	35000.00
1332	192	50	3	35000.00
1333	192	41	3	45000.00
1334	193	18	1	45000.00
1335	193	29	1	48000.00
1336	193	23	1	40000.00
1337	193	44	3	45000.00
1338	193	27	2	45000.00
1339	193	31	3	42000.00
1340	193	32	2	40000.00
1341	194	13	1	35000.00
1342	194	34	2	40000.00
1343	194	9	3	45000.00
1344	194	30	3	38000.00
1345	194	39	3	45000.00
1346	194	27	3	45000.00
1347	194	10	1	35000.00
1348	195	27	3	45000.00
1349	195	10	2	35000.00
1350	195	35	2	38000.00
1351	195	24	1	40000.00
1352	195	12	3	32000.00
1353	195	21	1	42000.00
1354	195	21	1	42000.00
1355	196	25	3	40000.00
1356	196	21	2	42000.00
1357	196	19	1	42000.00
1358	196	47	3	45000.00
1359	196	37	2	40000.00
1360	196	39	3	45000.00
1361	196	8	2	45000.00
1362	197	51	1	20000.00
1363	197	21	1	42000.00
1364	197	9	1	45000.00
1365	197	40	2	38000.00
1366	197	47	1	45000.00
1367	197	20	1	42000.00
1368	197	8	3	45000.00
1369	198	24	1	40000.00
1370	198	47	1	45000.00
1371	198	12	2	32000.00
1372	198	50	1	35000.00
1373	198	10	1	35000.00
1374	198	26	1	40000.00
1375	198	17	3	42000.00
1376	199	24	1	40000.00
1377	199	39	3	45000.00
1378	199	50	1	35000.00
1379	199	29	3	48000.00
1380	199	23	1	40000.00
1381	199	24	3	40000.00
1382	199	42	3	42000.00
1383	200	29	3	48000.00
1384	200	41	1	45000.00
1385	200	5	1	40000.00
1386	200	37	2	40000.00
1387	200	56	3	38000.00
1388	200	27	2	45000.00
1389	200	44	3	45000.00
1390	201	18	3	45000.00
1391	201	27	1	45000.00
1392	201	46	2	45000.00
1393	201	41	1	45000.00
1394	201	23	3	40000.00
1395	201	55	1	35000.00
1396	201	5	1	40000.00
1397	202	13	1	35000.00
1398	202	47	1	45000.00
1399	202	30	2	38000.00
1400	202	19	2	42000.00
1401	202	49	1	35000.00
1402	202	20	2	42000.00
1403	202	36	3	40000.00
1404	203	11	3	30000.00
1405	203	30	1	38000.00
1406	203	29	1	48000.00
1407	203	15	2	42000.00
1408	203	49	2	35000.00
1409	203	56	3	38000.00
1410	203	20	3	42000.00
1411	204	4	2	40000.00
1412	204	5	3	40000.00
1413	204	38	1	40000.00
1414	204	7	2	42000.00
1415	204	6	2	40000.00
1416	204	23	2	40000.00
1417	204	40	1	38000.00
1418	205	46	2	45000.00
1419	205	47	3	45000.00
1420	205	22	3	42000.00
1421	205	31	1	42000.00
1422	205	10	1	35000.00
1423	205	4	1	40000.00
1424	205	8	1	45000.00
1425	206	12	1	32000.00
1426	206	37	1	40000.00
1427	206	6	2	40000.00
1428	206	43	1	40000.00
1429	206	33	2	35000.00
1430	206	32	2	40000.00
1431	206	3	3	32000.00
1432	207	41	1	45000.00
1433	207	11	3	30000.00
1434	207	35	3	38000.00
1435	207	11	1	30000.00
1436	207	14	1	37000.00
1437	207	43	1	40000.00
1438	207	25	3	40000.00
1439	208	28	3	45000.00
1440	208	35	3	38000.00
1441	208	5	2	40000.00
1442	208	35	1	38000.00
1443	208	47	2	45000.00
1444	208	11	3	30000.00
1445	208	21	2	42000.00
1446	209	43	1	40000.00
1447	209	13	2	35000.00
1448	209	2	1	30000.00
1449	209	32	3	40000.00
1450	209	38	1	40000.00
1451	209	13	3	35000.00
1452	209	6	1	40000.00
1453	210	15	3	42000.00
1454	210	7	3	42000.00
1455	210	37	2	40000.00
1456	210	40	2	38000.00
1457	210	34	3	40000.00
1458	210	31	1	42000.00
1459	210	23	2	40000.00
1460	211	5	1	40000.00
1461	211	43	2	40000.00
1462	211	13	1	35000.00
1463	211	18	1	45000.00
1464	211	36	2	40000.00
1465	211	42	2	42000.00
1466	211	45	3	45000.00
1467	212	2	2	30000.00
1468	212	25	1	40000.00
1469	212	13	2	35000.00
1470	212	46	1	45000.00
1471	212	54	1	50000.00
1472	212	4	1	40000.00
1473	212	24	1	40000.00
1474	213	54	1	50000.00
1475	213	19	1	42000.00
1476	213	28	3	45000.00
1477	213	14	1	37000.00
1478	213	2	1	30000.00
1479	213	21	3	42000.00
1480	213	18	3	45000.00
1481	214	42	1	42000.00
1482	214	24	3	40000.00
1483	214	33	1	35000.00
1484	214	12	1	32000.00
1485	214	8	1	45000.00
1486	214	54	1	50000.00
1487	214	8	3	45000.00
1488	215	17	2	42000.00
1489	215	53	2	35000.00
1490	215	54	3	50000.00
1491	215	23	2	40000.00
1492	215	52	3	38000.00
1493	215	32	1	40000.00
1494	215	35	1	38000.00
1495	216	9	1	45000.00
1496	216	38	3	40000.00
1497	216	10	2	35000.00
1498	216	31	1	42000.00
1499	216	45	2	45000.00
1500	216	26	3	40000.00
1501	216	20	3	42000.00
1502	217	49	1	35000.00
1503	217	14	2	37000.00
1504	217	18	2	45000.00
1505	217	27	2	45000.00
1506	217	8	3	45000.00
1507	217	15	1	42000.00
1508	217	38	1	40000.00
1509	218	35	3	38000.00
1510	218	53	2	35000.00
1511	218	1	2	42000.00
1512	218	15	2	42000.00
1513	218	16	2	38000.00
1514	218	27	1	45000.00
1515	218	48	3	45000.00
1516	219	36	2	40000.00
1517	219	20	2	42000.00
1518	219	25	1	40000.00
1519	219	15	2	42000.00
1520	219	29	2	48000.00
1521	219	1	3	42000.00
1522	219	41	3	45000.00
1523	220	50	1	35000.00
1524	220	15	3	42000.00
1525	220	1	3	42000.00
1526	220	49	3	35000.00
1527	220	26	3	40000.00
1528	220	7	2	42000.00
1529	220	33	1	35000.00
1530	221	33	3	35000.00
1531	221	33	3	35000.00
1532	221	35	1	38000.00
1533	221	24	3	40000.00
1534	221	6	2	40000.00
1535	221	35	3	38000.00
1536	221	3	2	32000.00
1537	222	4	2	40000.00
1538	222	40	1	38000.00
1539	222	28	1	45000.00
1540	222	27	2	45000.00
1541	222	53	2	35000.00
1542	222	39	3	45000.00
1543	222	32	1	40000.00
1544	223	9	3	45000.00
1545	223	14	3	37000.00
1546	223	37	3	40000.00
1547	223	39	2	45000.00
1548	223	52	2	38000.00
1549	223	33	1	35000.00
1550	223	49	3	35000.00
1551	224	20	1	42000.00
1552	224	49	1	35000.00
1553	224	41	2	45000.00
1554	224	20	2	42000.00
1555	224	38	1	40000.00
1556	224	4	2	40000.00
1557	224	37	2	40000.00
1558	225	14	2	37000.00
1559	225	50	2	35000.00
1560	225	39	2	45000.00
1561	225	12	2	32000.00
1562	225	14	3	37000.00
1563	225	17	3	42000.00
1564	225	35	1	38000.00
1565	226	49	2	35000.00
1566	226	7	1	42000.00
1567	226	39	1	45000.00
1568	226	55	1	35000.00
1569	226	10	2	35000.00
1570	226	1	1	42000.00
1571	226	35	1	38000.00
1572	227	3	1	32000.00
1573	227	30	3	38000.00
1574	227	21	2	42000.00
1575	227	56	2	38000.00
1576	227	38	1	40000.00
1577	227	30	3	38000.00
1578	227	4	1	40000.00
1579	228	48	1	45000.00
1580	228	22	1	42000.00
1581	228	56	2	38000.00
1582	228	31	2	42000.00
1583	228	1	2	42000.00
1584	228	33	1	35000.00
1585	228	11	1	30000.00
1586	229	14	3	37000.00
1587	229	37	2	40000.00
1588	229	16	3	38000.00
1589	229	53	2	35000.00
1590	229	8	3	45000.00
1591	229	4	1	40000.00
1592	229	12	1	32000.00
1593	230	55	1	35000.00
1594	230	44	3	45000.00
1595	230	41	1	45000.00
1596	230	29	3	48000.00
1597	230	20	3	42000.00
1598	230	3	2	32000.00
1599	230	36	3	40000.00
1600	231	55	2	35000.00
1601	231	40	3	38000.00
1602	231	12	1	32000.00
1603	231	24	3	40000.00
1604	231	27	2	45000.00
1605	231	44	1	45000.00
1606	231	32	3	40000.00
1607	232	48	3	45000.00
1608	232	10	1	35000.00
1609	232	11	2	30000.00
1610	232	34	1	40000.00
1611	232	26	2	40000.00
1612	232	1	1	42000.00
1613	232	29	1	48000.00
1614	233	21	2	42000.00
1615	233	15	1	42000.00
1616	233	22	3	42000.00
1617	233	42	1	42000.00
1618	233	25	1	40000.00
1619	233	6	3	40000.00
1620	233	7	2	42000.00
1621	234	54	1	50000.00
1622	234	26	3	40000.00
1623	234	21	1	42000.00
1624	234	35	3	38000.00
1625	234	40	2	38000.00
1626	234	18	3	45000.00
1627	234	54	2	50000.00
1628	235	14	3	37000.00
1629	235	1	3	42000.00
1630	235	56	1	38000.00
1631	235	26	3	40000.00
1632	235	26	2	40000.00
1633	235	30	2	38000.00
1634	235	46	1	45000.00
1635	236	11	3	30000.00
1636	236	38	3	40000.00
1637	236	3	3	32000.00
1638	236	4	3	40000.00
1639	236	52	2	38000.00
1640	236	10	3	35000.00
1641	236	22	2	42000.00
1642	237	33	1	35000.00
1643	237	55	2	35000.00
1644	237	51	1	20000.00
1645	237	21	1	42000.00
1646	237	56	1	38000.00
1647	237	20	1	42000.00
1648	237	24	2	40000.00
1649	238	33	3	35000.00
1650	238	53	1	35000.00
1651	238	20	3	42000.00
1652	238	11	1	30000.00
1653	238	4	2	40000.00
1654	238	6	2	40000.00
1655	238	36	1	40000.00
1656	239	39	1	45000.00
1657	239	4	2	40000.00
1658	239	6	3	40000.00
1659	239	14	3	37000.00
1660	239	30	3	38000.00
1661	239	40	2	38000.00
1662	239	39	3	45000.00
1663	240	53	3	35000.00
1664	240	30	3	38000.00
1665	240	28	1	45000.00
1666	240	17	1	42000.00
1667	240	5	1	40000.00
1668	240	36	2	40000.00
1669	240	19	1	42000.00
1670	241	49	1	35000.00
1671	241	8	3	45000.00
1672	241	53	2	35000.00
1673	241	15	1	42000.00
1674	241	47	1	45000.00
1675	241	53	2	35000.00
1676	241	48	3	45000.00
1677	242	24	2	40000.00
1678	242	48	1	45000.00
1679	242	45	1	45000.00
1680	242	11	1	30000.00
1681	242	34	1	40000.00
1682	242	30	3	38000.00
1683	242	51	1	20000.00
1684	243	52	3	38000.00
1685	243	15	1	42000.00
1686	243	48	3	45000.00
1687	243	16	1	38000.00
1688	243	27	2	45000.00
1689	243	43	1	40000.00
1690	243	9	3	45000.00
1691	244	44	1	45000.00
1692	244	4	2	40000.00
1693	244	49	1	35000.00
1694	244	42	1	42000.00
1695	244	18	3	45000.00
1696	244	28	2	45000.00
1697	244	36	1	40000.00
1698	245	32	3	40000.00
1699	245	3	3	32000.00
1700	245	32	1	40000.00
1701	245	25	1	40000.00
1702	245	6	1	40000.00
1703	245	2	3	30000.00
1704	245	4	1	40000.00
1705	246	4	3	40000.00
1706	246	26	1	40000.00
1707	246	1	3	42000.00
1708	246	6	1	40000.00
1709	246	6	2	40000.00
1710	246	31	3	42000.00
1711	246	1	3	42000.00
1712	247	24	2	40000.00
1713	247	7	2	42000.00
1714	247	8	3	45000.00
1715	247	31	3	42000.00
1716	247	23	3	40000.00
1717	247	22	2	42000.00
1718	247	28	1	45000.00
1719	248	28	3	45000.00
1720	248	45	1	45000.00
1721	248	49	2	35000.00
1722	248	22	2	42000.00
1723	248	50	3	35000.00
1724	248	50	1	35000.00
1725	248	48	1	45000.00
1726	249	23	1	40000.00
1727	249	2	1	30000.00
1728	249	48	1	45000.00
1729	249	15	3	42000.00
1730	249	24	1	40000.00
1731	249	35	2	38000.00
1732	249	13	2	35000.00
1733	250	50	1	35000.00
1734	250	26	2	40000.00
1735	250	49	2	35000.00
1736	250	18	1	45000.00
1737	250	15	2	42000.00
1738	250	53	1	35000.00
1739	250	47	1	45000.00
1740	251	34	3	40000.00
1741	251	45	2	45000.00
1742	251	31	2	42000.00
1743	251	42	1	42000.00
1744	251	11	2	30000.00
1745	251	23	1	40000.00
1746	251	1	3	42000.00
1747	252	14	3	37000.00
1748	252	7	1	42000.00
1749	252	48	1	45000.00
1750	252	5	3	40000.00
1751	252	35	1	38000.00
1752	252	43	3	40000.00
1753	252	29	2	48000.00
1754	253	21	1	42000.00
1755	253	32	3	40000.00
1756	253	29	1	48000.00
1757	253	10	2	35000.00
1758	253	51	2	20000.00
1759	253	26	3	40000.00
1760	253	11	3	30000.00
1761	254	16	1	38000.00
1762	254	43	2	40000.00
1763	254	39	1	45000.00
1764	254	22	2	42000.00
1765	254	26	3	40000.00
1766	254	46	2	45000.00
1767	254	39	3	45000.00
1768	255	27	3	45000.00
1769	255	28	2	45000.00
1770	255	33	2	35000.00
1771	255	31	1	42000.00
1772	255	23	3	40000.00
1773	255	55	2	35000.00
1774	255	15	1	42000.00
1775	256	7	2	42000.00
1776	256	30	1	38000.00
1777	256	12	1	32000.00
1778	256	8	2	45000.00
1779	256	40	1	38000.00
1780	256	15	2	42000.00
1781	256	55	3	35000.00
1782	257	6	2	40000.00
1783	257	32	2	40000.00
1784	257	20	2	42000.00
1785	257	42	3	42000.00
1786	257	31	2	42000.00
1787	257	43	3	40000.00
1788	257	56	2	38000.00
1789	258	34	2	40000.00
1790	258	51	3	20000.00
1791	258	2	2	30000.00
1792	258	48	3	45000.00
1793	258	27	3	45000.00
1794	258	47	1	45000.00
1795	258	18	1	45000.00
1796	259	14	2	37000.00
1797	259	29	1	48000.00
1798	259	51	1	20000.00
1799	259	25	3	40000.00
1800	259	36	3	40000.00
1801	259	35	2	38000.00
1802	259	47	3	45000.00
1803	260	53	3	35000.00
1804	260	6	1	40000.00
1805	260	34	2	40000.00
1806	260	48	1	45000.00
1807	260	35	3	38000.00
1808	260	35	1	38000.00
1809	260	46	2	45000.00
1810	261	19	1	42000.00
1811	261	15	2	42000.00
1812	261	16	1	38000.00
1813	261	26	2	40000.00
1814	261	12	2	32000.00
1815	261	34	2	40000.00
1816	261	31	3	42000.00
1817	262	34	3	40000.00
1818	262	52	3	38000.00
1819	262	46	3	45000.00
1820	262	8	3	45000.00
1821	262	32	2	40000.00
1822	262	52	3	38000.00
1823	262	42	2	42000.00
1824	263	43	1	40000.00
1825	263	2	2	30000.00
1826	263	24	2	40000.00
1827	263	21	2	42000.00
1828	263	33	3	35000.00
1829	263	35	1	38000.00
1830	263	53	2	35000.00
1831	264	9	1	45000.00
1832	264	17	2	42000.00
1833	264	7	1	42000.00
1834	264	29	2	48000.00
1835	264	36	1	40000.00
1836	264	10	1	35000.00
1837	264	34	2	40000.00
1838	265	3	1	32000.00
1839	265	3	1	32000.00
1840	265	5	2	40000.00
1841	265	33	2	35000.00
1842	265	50	2	35000.00
1843	265	20	1	42000.00
1844	265	16	1	38000.00
1845	266	12	2	32000.00
1846	266	13	1	35000.00
1847	266	40	2	38000.00
1848	266	28	1	45000.00
1849	266	12	1	32000.00
1850	266	19	2	42000.00
1851	266	4	2	40000.00
1852	267	28	3	45000.00
1853	267	53	1	35000.00
1854	267	34	1	40000.00
1855	267	49	1	35000.00
1856	267	52	1	38000.00
1857	267	1	3	42000.00
1858	267	2	1	30000.00
1859	268	1	3	42000.00
1860	268	49	1	35000.00
1861	268	4	3	40000.00
1862	268	30	2	38000.00
1863	268	24	3	40000.00
1864	268	12	1	32000.00
1865	268	7	2	42000.00
1866	269	42	3	42000.00
1867	269	27	3	45000.00
1868	269	30	2	38000.00
1869	269	12	2	32000.00
1870	269	32	3	40000.00
1871	269	1	2	42000.00
1872	269	12	3	32000.00
1873	270	24	2	40000.00
1874	270	41	2	45000.00
1875	270	22	1	42000.00
1876	270	51	2	20000.00
1877	270	39	1	45000.00
1878	270	49	1	35000.00
1879	270	40	3	38000.00
1880	271	38	3	40000.00
1881	271	55	1	35000.00
1882	271	38	3	40000.00
1883	271	38	1	40000.00
1884	271	16	1	38000.00
1885	271	54	3	50000.00
1886	271	40	2	38000.00
1887	272	41	2	45000.00
1888	272	11	1	30000.00
1889	272	1	1	42000.00
1890	272	21	2	42000.00
1891	272	31	1	42000.00
1892	272	44	2	45000.00
1893	272	12	1	32000.00
1894	273	42	3	42000.00
1895	273	40	3	38000.00
1896	273	1	1	42000.00
1897	273	7	3	42000.00
1898	273	41	1	45000.00
1899	273	42	2	42000.00
1900	273	45	1	45000.00
1901	274	9	3	45000.00
1902	274	5	3	40000.00
1903	274	41	1	45000.00
1904	274	42	2	42000.00
1905	274	37	2	40000.00
1906	274	6	3	40000.00
1907	274	21	1	42000.00
1908	275	25	1	40000.00
1909	275	53	2	35000.00
1910	275	7	3	42000.00
1911	275	12	1	32000.00
1912	275	20	3	42000.00
1913	275	31	1	42000.00
1914	275	34	1	40000.00
1915	276	37	1	40000.00
1916	276	22	1	42000.00
1917	276	42	3	42000.00
1918	276	36	1	40000.00
1919	276	54	1	50000.00
1920	276	6	3	40000.00
1921	276	33	1	35000.00
1922	277	52	3	38000.00
1923	277	1	1	42000.00
1924	277	18	1	45000.00
1925	277	56	2	38000.00
1926	277	56	1	38000.00
1927	277	2	3	30000.00
1928	277	22	3	42000.00
1929	278	55	1	35000.00
1930	278	33	3	35000.00
1931	278	41	3	45000.00
1932	278	15	1	42000.00
1933	278	45	3	45000.00
1934	278	31	2	42000.00
1935	278	28	3	45000.00
1936	279	16	1	38000.00
1937	279	1	1	42000.00
1938	279	48	2	45000.00
1939	279	52	3	38000.00
1940	279	2	2	30000.00
1941	279	22	2	42000.00
1942	279	1	1	42000.00
1943	280	38	1	40000.00
1944	280	2	2	30000.00
1945	280	45	3	45000.00
1946	280	16	3	38000.00
1947	280	14	2	37000.00
1948	280	39	2	45000.00
1949	280	29	3	48000.00
1950	281	19	3	42000.00
1951	281	15	1	42000.00
1952	281	24	1	40000.00
1953	281	8	3	45000.00
1954	281	21	1	42000.00
1955	281	42	1	42000.00
1956	281	38	1	40000.00
1957	282	56	1	38000.00
1958	282	56	1	38000.00
1959	282	13	3	35000.00
1960	282	50	3	35000.00
1961	282	31	2	42000.00
1962	282	1	1	42000.00
1963	282	24	2	40000.00
1964	283	29	3	48000.00
1965	283	34	3	40000.00
1966	283	11	3	30000.00
1967	283	25	1	40000.00
1968	283	21	1	42000.00
1969	283	8	3	45000.00
1970	283	44	3	45000.00
1971	284	45	3	45000.00
1972	284	6	1	40000.00
1973	284	16	3	38000.00
1974	284	33	3	35000.00
1975	284	55	1	35000.00
1976	284	27	1	45000.00
1977	284	44	3	45000.00
1978	285	1	3	42000.00
1979	285	51	1	20000.00
1980	285	27	3	45000.00
1981	285	21	3	42000.00
1982	285	33	2	35000.00
1983	285	28	2	45000.00
1984	285	19	1	42000.00
1985	286	17	3	42000.00
1986	286	22	2	42000.00
1987	286	54	3	50000.00
1988	286	51	2	20000.00
1989	286	47	2	45000.00
1990	286	19	1	42000.00
1991	286	50	1	35000.00
1992	287	7	1	42000.00
1993	287	39	3	45000.00
1994	287	7	1	42000.00
1995	287	47	3	45000.00
1996	287	15	3	42000.00
1997	287	26	3	40000.00
1998	287	5	2	40000.00
1999	288	20	2	42000.00
2000	288	56	1	38000.00
2001	288	12	2	32000.00
2002	288	36	1	40000.00
2003	288	26	2	40000.00
2004	288	36	3	40000.00
2005	288	8	1	45000.00
2006	289	39	2	45000.00
2007	289	38	1	40000.00
2008	289	53	2	35000.00
2009	289	45	3	45000.00
2010	289	43	1	40000.00
2011	289	2	2	30000.00
2012	289	1	1	42000.00
2013	290	24	1	40000.00
2014	290	3	3	32000.00
2015	290	39	2	45000.00
2016	290	36	1	40000.00
2017	290	14	3	37000.00
2018	290	13	3	35000.00
2019	290	17	2	42000.00
2020	291	31	2	42000.00
2021	291	37	3	40000.00
2022	291	52	2	38000.00
2023	291	11	2	30000.00
2024	291	46	3	45000.00
2025	291	1	3	42000.00
2026	291	8	1	45000.00
2027	292	45	1	45000.00
2028	292	38	3	40000.00
2029	292	29	1	48000.00
2030	292	47	1	45000.00
2031	292	13	3	35000.00
2032	292	33	3	35000.00
2033	292	16	2	38000.00
2034	293	2	1	30000.00
2035	293	55	2	35000.00
2036	293	48	1	45000.00
2037	293	38	1	40000.00
2038	293	48	2	45000.00
2039	293	46	1	45000.00
2040	293	5	1	40000.00
2041	294	13	3	35000.00
2042	294	26	3	40000.00
2043	294	2	2	30000.00
2044	294	24	2	40000.00
2045	294	51	3	20000.00
2046	294	47	1	45000.00
2047	294	18	3	45000.00
2048	295	2	2	30000.00
2049	295	23	1	40000.00
2050	295	49	3	35000.00
2051	295	2	1	30000.00
2052	295	42	1	42000.00
2053	295	56	3	38000.00
2054	295	5	2	40000.00
2055	296	24	3	40000.00
2056	296	21	1	42000.00
2057	296	11	2	30000.00
2058	296	50	2	35000.00
2059	296	33	2	35000.00
2060	296	6	3	40000.00
2061	296	10	1	35000.00
2062	297	3	2	32000.00
2063	297	30	1	38000.00
2064	297	36	1	40000.00
2065	297	39	1	45000.00
2066	297	10	1	35000.00
2067	297	43	1	40000.00
2068	297	50	2	35000.00
2069	298	44	3	45000.00
2070	298	9	3	45000.00
2071	298	36	3	40000.00
2072	298	5	3	40000.00
2073	298	37	1	40000.00
2074	298	9	2	45000.00
2075	298	37	3	40000.00
2076	299	45	1	45000.00
2077	299	23	1	40000.00
2078	299	11	2	30000.00
2079	299	17	3	42000.00
2080	299	42	2	42000.00
2081	299	35	2	38000.00
2082	299	39	2	45000.00
2083	300	4	2	40000.00
2084	300	30	3	38000.00
2085	300	50	1	35000.00
2086	300	15	2	42000.00
2087	300	9	3	45000.00
2088	300	46	2	45000.00
2089	300	37	3	40000.00
2090	301	39	3	45000.00
2091	301	42	1	42000.00
2092	301	33	3	35000.00
2093	301	39	2	45000.00
2094	301	17	3	42000.00
2095	301	35	1	38000.00
2096	301	30	1	38000.00
2097	302	50	1	35000.00
2098	302	51	2	20000.00
2099	302	40	1	38000.00
2100	302	46	2	45000.00
2101	302	33	3	35000.00
2102	302	49	2	35000.00
2103	302	1	2	42000.00
2104	303	18	3	45000.00
2105	303	14	1	37000.00
2106	303	43	2	40000.00
2107	303	28	3	45000.00
2108	303	28	3	45000.00
2109	303	56	2	38000.00
2110	303	3	3	32000.00
2111	304	32	1	40000.00
2112	304	49	3	35000.00
2113	304	30	3	38000.00
2114	304	51	3	20000.00
2115	304	33	3	35000.00
2116	304	31	2	42000.00
2117	304	42	1	42000.00
2118	305	4	3	40000.00
2119	305	26	3	40000.00
2120	305	11	3	30000.00
2121	305	53	1	35000.00
2122	305	51	1	20000.00
2123	305	42	2	42000.00
2124	305	6	1	40000.00
2125	306	10	3	35000.00
2126	306	8	2	45000.00
2127	306	40	3	38000.00
2128	306	56	1	38000.00
2129	306	13	2	35000.00
2130	306	51	1	20000.00
2131	306	56	1	38000.00
2132	307	56	2	38000.00
2133	307	8	3	45000.00
2134	307	6	1	40000.00
2135	307	47	3	45000.00
2136	307	14	1	37000.00
2137	307	43	2	40000.00
2138	307	38	2	40000.00
2139	308	52	2	38000.00
2140	308	10	3	35000.00
2141	308	37	1	40000.00
2142	308	48	1	45000.00
2143	308	19	2	42000.00
2144	308	33	2	35000.00
2145	308	10	3	35000.00
2146	309	32	1	40000.00
2147	309	41	2	45000.00
2148	309	34	3	40000.00
2149	309	20	2	42000.00
2150	309	15	2	42000.00
2151	309	8	1	45000.00
2152	309	39	3	45000.00
2153	310	41	1	45000.00
2154	310	43	2	40000.00
2155	310	52	2	38000.00
2156	310	16	2	38000.00
2157	310	23	2	40000.00
2158	310	38	2	40000.00
2159	310	51	1	20000.00
2160	311	38	1	40000.00
2161	311	47	1	45000.00
2162	311	16	2	38000.00
2163	311	43	2	40000.00
2164	311	32	3	40000.00
2165	311	15	3	42000.00
2166	311	23	3	40000.00
2167	312	36	1	40000.00
2168	312	50	1	35000.00
2169	312	13	2	35000.00
2170	312	38	1	40000.00
2171	312	19	1	42000.00
2172	312	34	1	40000.00
2173	312	34	1	40000.00
2174	313	26	1	40000.00
2175	313	15	3	42000.00
2176	313	22	2	42000.00
2177	313	45	2	45000.00
2178	313	19	3	42000.00
2179	313	19	2	42000.00
2180	313	47	2	45000.00
2181	314	1	2	42000.00
2182	314	29	2	48000.00
2183	314	22	2	42000.00
2184	314	36	3	40000.00
2185	314	39	1	45000.00
2186	314	12	1	32000.00
2187	314	25	2	40000.00
2188	315	55	1	35000.00
2189	315	26	3	40000.00
2190	315	31	2	42000.00
2191	315	1	2	42000.00
2192	315	8	3	45000.00
2193	315	11	3	30000.00
2194	315	24	1	40000.00
2195	316	16	3	38000.00
2196	316	19	3	42000.00
2197	316	29	2	48000.00
2198	316	49	1	35000.00
2199	316	46	1	45000.00
2200	316	47	2	45000.00
2201	316	9	3	45000.00
2202	317	29	1	48000.00
2203	317	26	1	40000.00
2204	317	42	2	42000.00
2205	317	43	3	40000.00
2206	317	35	1	38000.00
2207	317	33	2	35000.00
2208	317	31	1	42000.00
2209	318	18	3	45000.00
2210	318	8	1	45000.00
2211	318	52	3	38000.00
2212	318	1	3	42000.00
2213	318	8	3	45000.00
2214	318	38	1	40000.00
2215	318	51	1	20000.00
2216	319	18	1	45000.00
2217	319	32	2	40000.00
2218	319	46	1	45000.00
2219	319	34	1	40000.00
2220	319	45	1	45000.00
2221	319	23	2	40000.00
2222	319	12	2	32000.00
2223	320	16	2	38000.00
2224	320	15	3	42000.00
2225	320	52	1	38000.00
2226	320	56	1	38000.00
2227	320	34	1	40000.00
2228	320	42	2	42000.00
2229	320	32	2	40000.00
2230	321	32	2	40000.00
2231	321	31	3	42000.00
2232	321	6	1	40000.00
2233	321	43	1	40000.00
2234	321	26	2	40000.00
2235	321	3	1	32000.00
2236	321	11	2	30000.00
2237	322	8	2	45000.00
2238	322	18	3	45000.00
2239	322	8	3	45000.00
2240	322	6	2	40000.00
2241	322	4	2	40000.00
2242	322	37	3	40000.00
2243	322	1	1	42000.00
2244	323	17	3	42000.00
2245	323	30	3	38000.00
2246	323	23	3	40000.00
2247	323	9	2	45000.00
2248	323	47	2	45000.00
2249	323	33	2	35000.00
2250	323	30	3	38000.00
2251	324	31	2	42000.00
2252	324	1	1	42000.00
2253	324	9	3	45000.00
2254	324	21	3	42000.00
2255	324	50	2	35000.00
2256	324	45	3	45000.00
2257	324	30	1	38000.00
2258	325	9	3	45000.00
2259	325	22	2	42000.00
2260	325	52	3	38000.00
2261	325	38	2	40000.00
2262	325	11	2	30000.00
2263	325	40	3	38000.00
2264	325	4	1	40000.00
2265	326	21	1	42000.00
2266	326	23	3	40000.00
2267	326	47	2	45000.00
2268	326	6	1	40000.00
2269	326	54	2	50000.00
2270	326	22	3	42000.00
2271	326	40	2	38000.00
2272	327	25	2	40000.00
2273	327	9	2	45000.00
2274	327	24	3	40000.00
2275	327	43	2	40000.00
2276	327	26	2	40000.00
2277	327	34	3	40000.00
2278	327	5	3	40000.00
2279	328	5	1	40000.00
2280	328	46	3	45000.00
2281	328	9	2	45000.00
2282	328	38	1	40000.00
2283	328	54	3	50000.00
2284	328	51	1	20000.00
2285	328	29	1	48000.00
2286	329	16	1	38000.00
2287	329	6	3	40000.00
2288	329	11	3	30000.00
2289	329	36	2	40000.00
2290	329	6	3	40000.00
2291	329	35	2	38000.00
2292	329	47	2	45000.00
2293	330	44	3	45000.00
2294	330	43	2	40000.00
2295	330	35	2	38000.00
2296	330	50	3	35000.00
2297	330	54	1	50000.00
2298	330	45	2	45000.00
2299	330	21	2	42000.00
2300	331	53	1	35000.00
2301	331	47	1	45000.00
2302	331	25	1	40000.00
2303	331	49	3	35000.00
2304	331	38	3	40000.00
2305	331	5	2	40000.00
2306	331	18	3	45000.00
2307	332	56	3	38000.00
2308	332	42	1	42000.00
2309	332	54	3	50000.00
2310	332	17	3	42000.00
2311	332	12	1	32000.00
2312	332	34	3	40000.00
2313	332	29	1	48000.00
2314	333	4	1	40000.00
2315	333	10	3	35000.00
2316	333	23	2	40000.00
2317	333	30	2	38000.00
2318	333	14	1	37000.00
2319	333	39	3	45000.00
2320	333	10	1	35000.00
2321	334	20	1	42000.00
2322	334	8	3	45000.00
2323	334	30	2	38000.00
2324	334	54	2	50000.00
2325	334	30	3	38000.00
2326	334	49	3	35000.00
2327	334	28	1	45000.00
2328	335	4	2	40000.00
2329	335	55	1	35000.00
2330	335	55	3	35000.00
2331	335	3	2	32000.00
2332	335	51	3	20000.00
2333	335	12	1	32000.00
2334	335	50	1	35000.00
2335	336	43	3	40000.00
2336	336	29	3	48000.00
2337	336	55	1	35000.00
2338	336	26	2	40000.00
2339	336	48	2	45000.00
2340	336	54	1	50000.00
2341	336	53	3	35000.00
2342	337	53	3	35000.00
2343	337	23	2	40000.00
2344	337	11	1	30000.00
2345	337	22	2	42000.00
2346	337	45	1	45000.00
2347	337	4	2	40000.00
2348	337	21	1	42000.00
2349	338	22	2	42000.00
2350	338	51	3	20000.00
2351	338	51	1	20000.00
2352	338	28	3	45000.00
2353	338	21	3	42000.00
2354	338	33	2	35000.00
2355	338	27	2	45000.00
2356	339	35	3	38000.00
2357	339	50	1	35000.00
2358	339	10	3	35000.00
2359	339	20	1	42000.00
2360	339	27	1	45000.00
2361	339	41	2	45000.00
2362	339	12	1	32000.00
2363	340	24	2	40000.00
2364	340	3	1	32000.00
2365	340	16	2	38000.00
2366	340	27	2	45000.00
2367	340	28	2	45000.00
2368	340	22	3	42000.00
2369	340	8	2	45000.00
2370	341	22	2	42000.00
2371	341	45	1	45000.00
2372	341	25	2	40000.00
2373	341	16	3	38000.00
2374	341	45	2	45000.00
2375	341	7	2	42000.00
2376	341	46	2	45000.00
2377	342	23	1	40000.00
2378	342	48	3	45000.00
2379	342	26	1	40000.00
2380	342	29	2	48000.00
2381	342	19	3	42000.00
2382	342	10	2	35000.00
2383	342	54	2	50000.00
2384	343	56	1	38000.00
2385	343	26	1	40000.00
2386	343	44	2	45000.00
2387	343	40	2	38000.00
2388	343	34	1	40000.00
2389	343	37	3	40000.00
2390	343	20	3	42000.00
2391	344	55	1	35000.00
2392	344	47	2	45000.00
2393	344	12	2	32000.00
2394	344	24	3	40000.00
2395	344	18	2	45000.00
2396	344	44	2	45000.00
2397	344	13	2	35000.00
2398	345	21	1	42000.00
2399	345	47	3	45000.00
2400	345	47	1	45000.00
2401	345	42	2	42000.00
2402	345	41	1	45000.00
2403	345	41	2	45000.00
2404	345	34	2	40000.00
2405	346	22	2	42000.00
2406	346	13	2	35000.00
2407	346	30	1	38000.00
2408	346	55	2	35000.00
2409	346	32	1	40000.00
2410	346	30	2	38000.00
2411	346	36	1	40000.00
2412	347	7	2	42000.00
2413	347	32	2	40000.00
2414	347	6	2	40000.00
2415	347	48	2	45000.00
2416	347	6	3	40000.00
2417	347	53	1	35000.00
2418	347	49	1	35000.00
2419	348	30	3	38000.00
2420	348	55	3	35000.00
2421	348	48	1	45000.00
2422	348	49	2	35000.00
2423	348	33	1	35000.00
2424	348	55	1	35000.00
2425	348	18	2	45000.00
2426	349	12	3	32000.00
2427	349	39	1	45000.00
2428	349	30	2	38000.00
2429	349	35	2	38000.00
2430	349	39	1	45000.00
2431	349	9	3	45000.00
2432	349	6	2	40000.00
2433	350	55	2	35000.00
2434	350	28	1	45000.00
2435	350	19	2	42000.00
2436	350	56	2	38000.00
2437	350	5	3	40000.00
2438	350	6	3	40000.00
2439	350	42	1	42000.00
2440	351	45	3	45000.00
2441	351	29	2	48000.00
2442	351	26	2	40000.00
2443	351	1	3	42000.00
2444	351	35	3	38000.00
2445	351	39	3	45000.00
2446	351	5	1	40000.00
2447	352	43	1	40000.00
2448	352	50	3	35000.00
2449	352	35	3	38000.00
2450	352	16	2	38000.00
2451	352	51	1	20000.00
2452	352	34	3	40000.00
2453	352	43	3	40000.00
2454	353	25	1	40000.00
2455	353	50	2	35000.00
2456	353	30	3	38000.00
2457	353	33	3	35000.00
2458	353	13	1	35000.00
2459	353	28	3	45000.00
2460	353	49	1	35000.00
2461	354	31	1	42000.00
2462	354	29	3	48000.00
2463	354	12	1	32000.00
2464	354	25	1	40000.00
2465	354	40	3	38000.00
2466	354	15	2	42000.00
2467	354	50	2	35000.00
2468	355	29	3	48000.00
2469	355	55	3	35000.00
2470	355	50	3	35000.00
2471	355	8	2	45000.00
2472	355	35	1	38000.00
2473	355	4	3	40000.00
2474	355	54	3	50000.00
2475	356	33	3	35000.00
2476	356	49	2	35000.00
2477	356	48	3	45000.00
2478	356	33	2	35000.00
2479	356	53	3	35000.00
2480	356	13	1	35000.00
2481	356	23	1	40000.00
2482	357	40	2	38000.00
2483	357	54	1	50000.00
2484	357	40	2	38000.00
2485	357	41	1	45000.00
2486	357	11	1	30000.00
2487	357	11	2	30000.00
2488	357	10	1	35000.00
2489	358	53	2	35000.00
2490	358	23	1	40000.00
2491	358	20	2	42000.00
2492	358	54	3	50000.00
2493	358	41	2	45000.00
2494	358	36	3	40000.00
2495	358	27	3	45000.00
2496	359	20	1	42000.00
2497	359	30	3	38000.00
2498	359	1	1	42000.00
2499	359	49	2	35000.00
2500	359	28	3	45000.00
2501	359	54	3	50000.00
2502	359	30	1	38000.00
2503	360	15	2	42000.00
2504	360	42	2	42000.00
2505	360	9	3	45000.00
2506	360	32	2	40000.00
2507	360	26	2	40000.00
2508	360	28	1	45000.00
2509	360	26	2	40000.00
2510	361	17	1	42000.00
2511	361	2	1	30000.00
2512	361	28	2	45000.00
2513	361	23	1	40000.00
2514	361	55	3	35000.00
2515	361	14	3	37000.00
2516	361	41	2	45000.00
2517	362	15	2	42000.00
2518	362	45	3	45000.00
2519	362	27	2	45000.00
2520	362	15	1	42000.00
2521	362	23	3	40000.00
2522	362	11	3	30000.00
2523	362	13	3	35000.00
2524	363	2	2	30000.00
2525	363	12	1	32000.00
2526	363	51	3	20000.00
2527	363	50	3	35000.00
2528	363	38	1	40000.00
2529	363	55	1	35000.00
2530	363	17	2	42000.00
2531	364	54	2	50000.00
2532	364	7	2	42000.00
2533	364	21	2	42000.00
2534	364	38	2	40000.00
2535	364	55	1	35000.00
2536	364	51	3	20000.00
2537	364	54	3	50000.00
2538	365	34	2	40000.00
2539	365	10	2	35000.00
2540	365	37	3	40000.00
2541	365	55	1	35000.00
2542	365	13	2	35000.00
2543	365	1	1	42000.00
2544	365	8	2	45000.00
2545	366	54	3	50000.00
2546	366	17	1	42000.00
2547	366	50	3	35000.00
2548	366	9	2	45000.00
2549	366	36	1	40000.00
2550	366	30	3	38000.00
2551	366	42	2	42000.00
2552	367	22	2	42000.00
2553	367	30	2	38000.00
2554	367	47	2	45000.00
2555	367	6	3	40000.00
2556	367	49	3	35000.00
2557	367	6	1	40000.00
2558	367	5	3	40000.00
2559	368	3	3	32000.00
2560	368	28	2	45000.00
2561	368	50	1	35000.00
2562	368	43	1	40000.00
2563	368	52	3	38000.00
2564	368	2	3	30000.00
2565	368	34	3	40000.00
2566	369	7	1	42000.00
2567	369	30	1	38000.00
2568	369	40	1	38000.00
2569	369	14	2	37000.00
2570	369	53	3	35000.00
2571	369	5	2	40000.00
2572	369	39	2	45000.00
2573	370	53	1	35000.00
2574	370	55	1	35000.00
2575	370	25	2	40000.00
2576	370	12	2	32000.00
2577	370	24	2	40000.00
2578	370	45	1	45000.00
2579	370	25	1	40000.00
2580	371	23	2	40000.00
2581	371	38	1	40000.00
2582	371	12	2	32000.00
2583	371	14	1	37000.00
2584	371	12	1	32000.00
2585	371	13	3	35000.00
2586	371	31	2	42000.00
2587	372	31	1	42000.00
2588	372	13	3	35000.00
2589	372	32	2	40000.00
2590	372	1	2	42000.00
2591	372	16	2	38000.00
2592	372	51	1	20000.00
2593	372	27	2	45000.00
2594	373	10	3	35000.00
2595	373	46	1	45000.00
2596	373	12	3	32000.00
2597	373	42	1	42000.00
2598	373	4	1	40000.00
2599	373	7	3	42000.00
2600	373	39	1	45000.00
2601	374	13	3	35000.00
2602	374	24	1	40000.00
2603	374	54	3	50000.00
2604	374	14	1	37000.00
2605	374	43	3	40000.00
2606	374	12	2	32000.00
2607	374	12	3	32000.00
2608	375	34	1	40000.00
2609	375	18	2	45000.00
2610	375	48	3	45000.00
2611	375	55	2	35000.00
2612	375	2	1	30000.00
2613	375	16	1	38000.00
2614	375	12	1	32000.00
2615	376	49	1	35000.00
2616	376	14	2	37000.00
2617	376	37	3	40000.00
2618	376	31	3	42000.00
2619	376	21	2	42000.00
2620	376	32	3	40000.00
2621	376	28	1	45000.00
2622	377	4	1	40000.00
2623	377	13	2	35000.00
2624	377	27	1	45000.00
2625	377	29	2	48000.00
2626	377	14	3	37000.00
2627	377	43	2	40000.00
2628	377	2	3	30000.00
2629	378	56	2	38000.00
2630	378	35	2	38000.00
2631	378	8	2	45000.00
2632	378	40	2	38000.00
2633	378	48	3	45000.00
2634	378	3	1	32000.00
2635	378	41	1	45000.00
2636	379	1	2	42000.00
2637	379	17	2	42000.00
2638	379	6	3	40000.00
2639	379	2	1	30000.00
2640	379	44	2	45000.00
2641	379	19	1	42000.00
2642	379	7	3	42000.00
2643	380	50	3	35000.00
2644	380	55	3	35000.00
2645	380	48	2	45000.00
2646	380	52	3	38000.00
2647	380	8	1	45000.00
2648	380	7	2	42000.00
2649	380	19	3	42000.00
2650	381	38	3	40000.00
2651	381	28	3	45000.00
2652	381	54	2	50000.00
2653	381	41	3	45000.00
2654	381	22	2	42000.00
2655	381	41	3	45000.00
2656	381	17	3	42000.00
2657	382	1	3	42000.00
2658	382	44	2	45000.00
2659	382	13	3	35000.00
2660	382	12	2	32000.00
2661	382	15	2	42000.00
2662	382	24	1	40000.00
2663	382	41	1	45000.00
2664	383	47	2	45000.00
2665	383	10	3	35000.00
2666	383	51	3	20000.00
2667	383	17	2	42000.00
2668	383	49	2	35000.00
2669	383	45	1	45000.00
2670	383	5	2	40000.00
2671	384	32	3	40000.00
2672	384	8	3	45000.00
2673	384	1	1	42000.00
2674	384	28	3	45000.00
2675	384	20	2	42000.00
2676	384	37	3	40000.00
2677	384	32	2	40000.00
2678	385	42	2	42000.00
2679	385	32	2	40000.00
2680	385	7	1	42000.00
2681	385	28	3	45000.00
2682	385	30	3	38000.00
2683	385	51	2	20000.00
2684	385	8	2	45000.00
2685	386	5	2	40000.00
2686	386	16	2	38000.00
2687	386	33	3	35000.00
2688	386	36	3	40000.00
2689	386	28	1	45000.00
2690	386	21	1	42000.00
2691	386	43	2	40000.00
2692	387	29	2	48000.00
2693	387	29	2	48000.00
2694	387	56	2	38000.00
2695	387	39	1	45000.00
2696	387	19	1	42000.00
2697	387	11	1	30000.00
2698	387	31	1	42000.00
2699	388	47	1	45000.00
2700	388	55	3	35000.00
2701	388	3	1	32000.00
2702	388	15	2	42000.00
2703	388	36	1	40000.00
2704	388	20	3	42000.00
2705	388	4	2	40000.00
2706	389	37	3	40000.00
2707	389	19	3	42000.00
2708	389	29	1	48000.00
2709	389	11	2	30000.00
2710	389	35	1	38000.00
2711	389	34	2	40000.00
2712	389	19	1	42000.00
2713	390	21	1	42000.00
2714	390	33	3	35000.00
2715	390	51	2	20000.00
2716	390	50	2	35000.00
2717	390	53	1	35000.00
2718	390	30	1	38000.00
2719	390	10	3	35000.00
2720	391	47	3	45000.00
2721	391	55	1	35000.00
2722	391	50	1	35000.00
2723	391	47	1	45000.00
2724	391	48	3	45000.00
2725	391	41	3	45000.00
2726	391	48	1	45000.00
2727	392	50	3	35000.00
2728	392	18	1	45000.00
2729	392	48	3	45000.00
2730	392	41	3	45000.00
2731	392	28	3	45000.00
2732	392	5	2	40000.00
2733	392	49	3	35000.00
2734	393	3	1	32000.00
2735	393	54	2	50000.00
2736	393	2	3	30000.00
2737	393	54	2	50000.00
2738	393	4	2	40000.00
2739	393	35	2	38000.00
2740	393	32	2	40000.00
2741	394	19	2	42000.00
2742	394	33	3	35000.00
2743	394	6	2	40000.00
2744	394	42	1	42000.00
2745	394	7	2	42000.00
2746	394	51	1	20000.00
2747	394	48	2	45000.00
2748	395	7	1	42000.00
2749	395	43	3	40000.00
2750	395	43	3	40000.00
2751	395	34	1	40000.00
2752	395	24	2	40000.00
2753	395	20	1	42000.00
2754	395	5	3	40000.00
2755	396	3	1	32000.00
2756	396	43	1	40000.00
2757	396	41	2	45000.00
2758	396	3	3	32000.00
2759	396	12	1	32000.00
2760	396	21	1	42000.00
2761	396	20	3	42000.00
2762	397	53	3	35000.00
2763	397	11	2	30000.00
2764	397	19	1	42000.00
2765	397	22	2	42000.00
2766	397	46	3	45000.00
2767	397	41	2	45000.00
2768	397	17	1	42000.00
2769	398	36	2	40000.00
2770	398	43	1	40000.00
2771	398	53	2	35000.00
2772	398	12	3	32000.00
2773	398	5	1	40000.00
2774	398	42	3	42000.00
2775	398	19	2	42000.00
2776	399	51	1	20000.00
2777	399	1	1	42000.00
2778	399	55	2	35000.00
2779	399	31	1	42000.00
2780	399	47	3	45000.00
2781	399	18	2	45000.00
2782	399	5	1	40000.00
2783	400	20	2	42000.00
2784	400	22	1	42000.00
2785	400	10	2	35000.00
2786	400	21	2	42000.00
2787	400	46	3	45000.00
2788	400	33	1	35000.00
2789	400	52	3	38000.00
2790	401	17	2	42000.00
2791	401	26	3	40000.00
2792	401	47	3	45000.00
2793	401	48	1	45000.00
2794	401	38	1	40000.00
2795	401	25	1	40000.00
2796	401	42	1	42000.00
2797	402	54	1	50000.00
2798	402	21	2	42000.00
2799	402	31	2	42000.00
2800	402	30	2	38000.00
2801	402	13	2	35000.00
2802	402	33	2	35000.00
2803	402	18	3	45000.00
2804	403	48	2	45000.00
2805	403	35	1	38000.00
2806	403	2	3	30000.00
2807	403	48	3	45000.00
2808	403	22	3	42000.00
2809	403	4	3	40000.00
2810	403	42	1	42000.00
2811	404	46	3	45000.00
2812	404	47	1	45000.00
2813	404	16	1	38000.00
2814	404	16	2	38000.00
2815	404	39	1	45000.00
2816	404	34	1	40000.00
2817	404	29	2	48000.00
2818	405	4	3	40000.00
2819	405	5	3	40000.00
2820	405	48	1	45000.00
2821	405	14	1	37000.00
2822	405	50	1	35000.00
2823	405	47	1	45000.00
2824	405	45	2	45000.00
2825	406	46	3	45000.00
2826	406	38	3	40000.00
2827	406	6	2	40000.00
2828	406	29	2	48000.00
2829	406	38	3	40000.00
2830	406	32	2	40000.00
2831	406	1	3	42000.00
2832	407	12	3	32000.00
2833	407	14	3	37000.00
2834	407	45	2	45000.00
2835	407	10	3	35000.00
2836	407	9	3	45000.00
2837	407	26	1	40000.00
2838	407	36	2	40000.00
2839	408	12	1	32000.00
2840	408	42	3	42000.00
2841	408	29	3	48000.00
2842	408	46	2	45000.00
2843	408	5	1	40000.00
2844	408	36	3	40000.00
2845	408	33	2	35000.00
2846	409	4	2	40000.00
2847	409	56	3	38000.00
2848	409	36	3	40000.00
2849	409	45	2	45000.00
2850	409	12	3	32000.00
2851	409	35	3	38000.00
2852	409	9	3	45000.00
2853	410	17	2	42000.00
2854	410	46	1	45000.00
2855	410	36	3	40000.00
2856	410	27	1	45000.00
2857	410	43	2	40000.00
2858	410	14	2	37000.00
2859	410	4	3	40000.00
2860	411	12	2	32000.00
2861	411	11	2	30000.00
2862	411	47	3	45000.00
2863	411	53	3	35000.00
2864	411	9	3	45000.00
2865	411	21	3	42000.00
2866	411	28	3	45000.00
2867	412	56	1	38000.00
2868	412	4	3	40000.00
2869	412	52	3	38000.00
2870	412	41	3	45000.00
2871	412	55	3	35000.00
2872	412	47	3	45000.00
2873	412	50	1	35000.00
2874	413	15	3	42000.00
2875	413	49	3	35000.00
2876	413	46	3	45000.00
2877	413	13	2	35000.00
2878	413	14	1	37000.00
2879	413	53	2	35000.00
2880	413	13	3	35000.00
2881	414	49	2	35000.00
2882	414	3	2	32000.00
2883	414	5	3	40000.00
2884	414	18	1	45000.00
2885	414	42	2	42000.00
2886	414	5	2	40000.00
2887	414	2	1	30000.00
2888	415	5	3	40000.00
2889	415	32	2	40000.00
2890	415	26	1	40000.00
2891	415	11	3	30000.00
2892	415	17	1	42000.00
2893	415	54	3	50000.00
2894	415	28	1	45000.00
2895	416	41	1	45000.00
2896	416	50	1	35000.00
2897	416	55	3	35000.00
2898	416	13	2	35000.00
2899	416	14	2	37000.00
2900	416	9	3	45000.00
2901	416	50	2	35000.00
2902	417	33	3	35000.00
2903	417	5	2	40000.00
2904	417	33	2	35000.00
2905	417	16	3	38000.00
2906	417	37	2	40000.00
2907	417	48	1	45000.00
2908	417	15	2	42000.00
2909	418	31	2	42000.00
2910	418	51	3	20000.00
2911	418	10	3	35000.00
2912	418	38	3	40000.00
2913	418	36	2	40000.00
2914	418	5	3	40000.00
2915	418	31	3	42000.00
2916	419	34	3	40000.00
2917	419	22	1	42000.00
2918	419	49	2	35000.00
2919	419	38	1	40000.00
2920	419	51	3	20000.00
2921	419	5	1	40000.00
2922	419	17	1	42000.00
2923	420	33	1	35000.00
2924	420	15	2	42000.00
2925	420	16	3	38000.00
2926	420	52	2	38000.00
2927	420	45	1	45000.00
2928	420	45	3	45000.00
2929	420	19	3	42000.00
2930	421	17	2	42000.00
2931	421	41	1	45000.00
2932	421	9	3	45000.00
2933	421	26	3	40000.00
2934	421	44	3	45000.00
2935	421	20	3	42000.00
2936	421	47	2	45000.00
2937	422	47	2	45000.00
2938	422	20	1	42000.00
2939	422	42	3	42000.00
2940	422	53	3	35000.00
2941	422	36	2	40000.00
2942	422	55	1	35000.00
2943	422	18	3	45000.00
2944	423	13	2	35000.00
2945	423	27	1	45000.00
2946	423	11	1	30000.00
2947	423	54	3	50000.00
2948	423	12	3	32000.00
2949	423	5	3	40000.00
2950	423	12	1	32000.00
2951	424	11	2	30000.00
2952	424	18	2	45000.00
2953	424	40	1	38000.00
2954	424	33	3	35000.00
2955	424	4	2	40000.00
2956	424	13	3	35000.00
2957	424	36	1	40000.00
2958	425	43	3	40000.00
2959	425	37	2	40000.00
2960	425	31	2	42000.00
2961	425	10	3	35000.00
2962	425	22	1	42000.00
2963	425	33	1	35000.00
2964	425	33	2	35000.00
2965	426	53	3	35000.00
2966	426	7	1	42000.00
2967	426	51	2	20000.00
2968	426	51	1	20000.00
2969	426	55	1	35000.00
2970	426	30	3	38000.00
2971	426	38	2	40000.00
2972	427	23	2	40000.00
2973	427	27	1	45000.00
2974	427	11	3	30000.00
2975	427	28	1	45000.00
2976	427	29	1	48000.00
2977	427	26	3	40000.00
2978	427	50	1	35000.00
2979	428	21	3	42000.00
2980	428	21	1	42000.00
2981	428	24	3	40000.00
2982	428	22	1	42000.00
2983	428	38	3	40000.00
2984	428	29	3	48000.00
2985	428	54	3	50000.00
2986	429	27	1	45000.00
2987	429	53	1	35000.00
2988	429	35	3	38000.00
2989	429	52	3	38000.00
2990	429	53	3	35000.00
2991	429	47	2	45000.00
2992	429	51	3	20000.00
2993	430	49	3	35000.00
2994	430	18	1	45000.00
2995	430	8	1	45000.00
2996	430	6	1	40000.00
2997	430	26	3	40000.00
2998	430	8	3	45000.00
2999	430	56	2	38000.00
3000	431	15	1	42000.00
3001	431	32	3	40000.00
3002	431	2	3	30000.00
3003	431	53	3	35000.00
3004	431	26	1	40000.00
3005	431	8	3	45000.00
3006	431	7	2	42000.00
3007	432	43	3	40000.00
3008	432	40	1	38000.00
3009	432	53	1	35000.00
3010	432	15	3	42000.00
3011	432	16	1	38000.00
3012	432	21	3	42000.00
3013	432	9	3	45000.00
3014	433	39	3	45000.00
3015	433	28	2	45000.00
3016	433	11	2	30000.00
3017	433	47	2	45000.00
3018	433	15	2	42000.00
3019	433	19	1	42000.00
3020	433	5	3	40000.00
3021	434	19	3	42000.00
3022	434	7	1	42000.00
3023	434	56	1	38000.00
3024	434	42	3	42000.00
3025	434	16	3	38000.00
3026	434	35	2	38000.00
3027	434	15	3	42000.00
3028	435	10	1	35000.00
3029	435	2	1	30000.00
3030	435	11	2	30000.00
3031	435	30	1	38000.00
3032	435	30	2	38000.00
3033	435	33	3	35000.00
3034	435	8	1	45000.00
3035	436	42	1	42000.00
3036	436	13	3	35000.00
3037	436	24	2	40000.00
3038	436	21	2	42000.00
3039	436	35	1	38000.00
3040	436	54	3	50000.00
3041	436	14	3	37000.00
3042	437	4	3	40000.00
3043	437	21	3	42000.00
3044	437	46	3	45000.00
3045	437	53	2	35000.00
3046	437	19	3	42000.00
3047	437	7	1	42000.00
3048	437	33	1	35000.00
3049	438	13	1	35000.00
3050	438	19	1	42000.00
3051	438	56	1	38000.00
3052	438	4	1	40000.00
3053	438	48	3	45000.00
3054	438	4	2	40000.00
3055	438	33	1	35000.00
3056	439	11	3	30000.00
3057	439	19	1	42000.00
3058	439	8	3	45000.00
3059	439	2	2	30000.00
3060	439	18	3	45000.00
3061	439	21	1	42000.00
3062	439	5	1	40000.00
3063	440	18	1	45000.00
3064	440	29	3	48000.00
3065	440	42	2	42000.00
3066	440	43	1	40000.00
3067	440	11	1	30000.00
3068	440	51	1	20000.00
3069	440	39	1	45000.00
3070	441	21	1	42000.00
3071	441	35	2	38000.00
3072	441	3	1	32000.00
3073	441	37	3	40000.00
3074	441	3	1	32000.00
3075	441	23	3	40000.00
3076	441	32	3	40000.00
3077	442	49	1	35000.00
3078	442	15	2	42000.00
3079	442	20	3	42000.00
3080	442	46	1	45000.00
3081	442	7	2	42000.00
3082	442	16	2	38000.00
3083	442	15	1	42000.00
3084	443	14	1	37000.00
3085	443	18	2	45000.00
3086	443	24	3	40000.00
3087	443	44	1	45000.00
3088	443	46	3	45000.00
3089	443	44	1	45000.00
3090	443	22	1	42000.00
3091	444	35	1	38000.00
3092	444	3	3	32000.00
3093	444	10	3	35000.00
3094	444	4	2	40000.00
3095	444	36	3	40000.00
3096	444	55	1	35000.00
3097	444	7	2	42000.00
3098	445	35	2	38000.00
3099	445	15	3	42000.00
3100	445	41	3	45000.00
3101	445	45	2	45000.00
3102	445	46	3	45000.00
3103	445	20	3	42000.00
3104	445	4	3	40000.00
3105	446	40	2	38000.00
3106	446	25	2	40000.00
3107	446	19	1	42000.00
3108	446	10	2	35000.00
3109	446	7	2	42000.00
3110	446	26	2	40000.00
3111	446	26	3	40000.00
3112	447	21	2	42000.00
3113	447	9	3	45000.00
3114	447	48	3	45000.00
3115	447	54	3	50000.00
3116	447	35	1	38000.00
3117	447	1	2	42000.00
3118	447	1	3	42000.00
3119	448	36	3	40000.00
3120	448	29	1	48000.00
3121	448	19	2	42000.00
3122	448	45	2	45000.00
3123	448	24	3	40000.00
3124	448	33	1	35000.00
3125	448	46	2	45000.00
3126	449	10	1	35000.00
3127	449	3	1	32000.00
3128	449	31	3	42000.00
3129	449	27	1	45000.00
3130	449	43	1	40000.00
3131	449	38	1	40000.00
3132	449	43	3	40000.00
3133	450	44	2	45000.00
3134	450	31	1	42000.00
3135	450	12	3	32000.00
3136	450	49	1	35000.00
3137	450	45	2	45000.00
3138	450	6	2	40000.00
3139	450	50	2	35000.00
3140	451	33	2	35000.00
3141	451	42	3	42000.00
3142	451	18	3	45000.00
3143	451	40	2	38000.00
3144	451	55	1	35000.00
3145	451	34	2	40000.00
3146	451	31	2	42000.00
3147	452	54	2	50000.00
3148	452	25	1	40000.00
3149	452	32	2	40000.00
3150	452	27	2	45000.00
3151	452	30	2	38000.00
3152	452	3	2	32000.00
3153	452	37	3	40000.00
3154	453	39	3	45000.00
3155	453	37	1	40000.00
3156	453	23	1	40000.00
3157	453	2	3	30000.00
3158	453	14	3	37000.00
3159	453	35	3	38000.00
3160	453	16	3	38000.00
3161	454	18	3	45000.00
3162	454	36	2	40000.00
3163	454	1	3	42000.00
3164	454	27	1	45000.00
3165	454	9	1	45000.00
3166	454	18	1	45000.00
3167	454	33	1	35000.00
3168	455	35	1	38000.00
3169	455	11	2	30000.00
3170	455	14	1	37000.00
3171	455	28	1	45000.00
3172	455	37	3	40000.00
3173	455	42	1	42000.00
3174	455	50	1	35000.00
3175	456	25	3	40000.00
3176	456	16	3	38000.00
3177	456	8	3	45000.00
3178	456	1	1	42000.00
3179	456	54	2	50000.00
3180	456	44	3	45000.00
3181	456	40	2	38000.00
3182	457	5	3	40000.00
3183	457	7	1	42000.00
3184	457	38	2	40000.00
3185	457	37	1	40000.00
3186	457	21	3	42000.00
3187	457	27	1	45000.00
3188	457	41	1	45000.00
3189	458	40	1	38000.00
3190	458	37	2	40000.00
3191	458	28	1	45000.00
3192	458	21	1	42000.00
3193	458	6	2	40000.00
3194	458	47	2	45000.00
3195	458	50	1	35000.00
3196	459	22	1	42000.00
3197	459	1	3	42000.00
3198	459	37	2	40000.00
3199	459	51	2	20000.00
3200	459	45	2	45000.00
3201	459	13	2	35000.00
3202	459	1	3	42000.00
3203	460	7	2	42000.00
3204	460	37	1	40000.00
3205	460	21	1	42000.00
3206	460	13	3	35000.00
3207	460	41	3	45000.00
3208	460	13	3	35000.00
3209	460	16	2	38000.00
3210	461	1	3	42000.00
3211	461	44	1	45000.00
3212	461	42	1	42000.00
3213	461	8	2	45000.00
3214	461	2	2	30000.00
3215	461	51	1	20000.00
3216	461	11	2	30000.00
3217	462	55	1	35000.00
3218	462	5	2	40000.00
3219	462	2	3	30000.00
3220	462	40	1	38000.00
3221	462	36	3	40000.00
3222	462	38	2	40000.00
3223	462	25	1	40000.00
3224	463	31	1	42000.00
3225	463	20	3	42000.00
3226	463	56	2	38000.00
3227	463	25	1	40000.00
3228	463	46	3	45000.00
3229	463	17	3	42000.00
3230	463	9	2	45000.00
3231	464	46	2	45000.00
3232	464	30	3	38000.00
3233	464	11	2	30000.00
3234	464	51	2	20000.00
3235	464	47	2	45000.00
3236	464	30	1	38000.00
3237	464	10	1	35000.00
3238	465	43	3	40000.00
3239	465	32	2	40000.00
3240	465	4	2	40000.00
3241	465	36	1	40000.00
3242	465	31	2	42000.00
3243	465	2	2	30000.00
3244	465	6	2	40000.00
3245	466	43	3	40000.00
3246	466	38	2	40000.00
3247	466	42	2	42000.00
3248	466	48	2	45000.00
3249	466	42	3	42000.00
3250	466	34	1	40000.00
3251	466	3	3	32000.00
3252	467	50	3	35000.00
3253	467	23	3	40000.00
3254	467	3	3	32000.00
3255	467	5	3	40000.00
3256	467	6	3	40000.00
3257	467	22	1	42000.00
3258	467	6	1	40000.00
3259	468	51	2	20000.00
3260	468	36	3	40000.00
3261	468	14	2	37000.00
3262	468	9	2	45000.00
3263	468	1	2	42000.00
3264	468	52	1	38000.00
3265	468	24	3	40000.00
3266	469	45	2	45000.00
3267	469	3	2	32000.00
3268	469	40	1	38000.00
3269	469	37	2	40000.00
3270	469	40	3	38000.00
3271	469	33	2	35000.00
3272	469	26	3	40000.00
3273	470	6	2	40000.00
3274	470	52	3	38000.00
3275	470	25	1	40000.00
3276	470	23	3	40000.00
3277	470	24	1	40000.00
3278	470	5	2	40000.00
3279	470	12	2	32000.00
3280	471	31	3	42000.00
3281	471	17	2	42000.00
3282	471	35	1	38000.00
3283	471	1	2	42000.00
3284	471	40	3	38000.00
3285	471	42	2	42000.00
3286	471	21	2	42000.00
3287	472	41	1	45000.00
3288	472	33	1	35000.00
3289	472	2	2	30000.00
3290	472	11	1	30000.00
3291	472	45	3	45000.00
3292	472	17	1	42000.00
3293	472	23	1	40000.00
3294	473	42	2	42000.00
3295	473	38	1	40000.00
3296	473	26	3	40000.00
3297	473	20	2	42000.00
3298	473	46	2	45000.00
3299	473	30	2	38000.00
3300	473	20	2	42000.00
3301	474	27	1	45000.00
3302	474	17	3	42000.00
3303	474	5	2	40000.00
3304	474	56	2	38000.00
3305	474	26	3	40000.00
3306	474	53	3	35000.00
3307	474	35	3	38000.00
3308	475	11	3	30000.00
3309	475	51	2	20000.00
3310	475	34	1	40000.00
3311	475	45	2	45000.00
3312	475	2	2	30000.00
3313	475	7	3	42000.00
3314	475	12	3	32000.00
3315	476	47	3	45000.00
3316	476	8	1	45000.00
3317	476	24	3	40000.00
3318	476	52	1	38000.00
3319	476	38	1	40000.00
3320	476	49	1	35000.00
3321	476	18	1	45000.00
3322	477	36	3	40000.00
3323	477	33	1	35000.00
3324	477	8	1	45000.00
3325	477	24	1	40000.00
3326	477	29	1	48000.00
3327	477	21	2	42000.00
3328	477	54	2	50000.00
3329	478	3	1	32000.00
3330	478	1	3	42000.00
3331	478	7	2	42000.00
3332	478	2	1	30000.00
3333	478	44	3	45000.00
3334	478	5	3	40000.00
3335	478	1	1	42000.00
3336	479	42	3	42000.00
3337	479	29	3	48000.00
3338	479	31	3	42000.00
3339	479	5	2	40000.00
3340	479	37	3	40000.00
3341	479	28	3	45000.00
3342	479	37	3	40000.00
3343	480	42	1	42000.00
3344	480	15	3	42000.00
3345	480	33	2	35000.00
3346	480	49	1	35000.00
3347	480	20	2	42000.00
3348	480	10	3	35000.00
3349	480	2	1	30000.00
3350	481	54	1	50000.00
3351	481	30	3	38000.00
3352	481	40	1	38000.00
3353	481	13	2	35000.00
3354	481	31	1	42000.00
3355	481	35	2	38000.00
3356	481	4	1	40000.00
3357	482	16	3	38000.00
3358	482	35	2	38000.00
3359	482	9	1	45000.00
3360	482	25	2	40000.00
3361	482	46	2	45000.00
3362	482	16	1	38000.00
3363	482	54	1	50000.00
3364	483	24	1	40000.00
3365	483	38	1	40000.00
3366	483	50	1	35000.00
3367	483	25	3	40000.00
3368	483	22	3	42000.00
3369	483	37	1	40000.00
3370	483	18	1	45000.00
3371	484	7	2	42000.00
3372	484	9	1	45000.00
3373	484	43	3	40000.00
3374	484	28	2	45000.00
3375	484	30	2	38000.00
3376	484	18	2	45000.00
3377	484	48	3	45000.00
3378	485	31	2	42000.00
3379	485	19	1	42000.00
3380	485	2	2	30000.00
3381	485	49	1	35000.00
3382	485	45	3	45000.00
3383	485	15	1	42000.00
3384	485	1	3	42000.00
3385	486	26	2	40000.00
3386	486	38	1	40000.00
3387	486	40	3	38000.00
3388	486	49	2	35000.00
3389	486	39	2	45000.00
3390	486	47	3	45000.00
3391	486	52	2	38000.00
3392	487	32	2	40000.00
3393	487	42	1	42000.00
3394	487	45	2	45000.00
3395	487	51	3	20000.00
3396	487	45	2	45000.00
3397	487	42	3	42000.00
3398	487	24	3	40000.00
3399	488	25	2	40000.00
3400	488	11	1	30000.00
3401	488	52	2	38000.00
3402	488	12	2	32000.00
3403	488	11	3	30000.00
3404	488	6	3	40000.00
3405	488	14	3	37000.00
3406	489	5	1	40000.00
3407	489	52	3	38000.00
3408	489	3	1	32000.00
3409	489	12	1	32000.00
3410	489	14	3	37000.00
3411	489	56	2	38000.00
3412	489	43	1	40000.00
3413	490	6	3	40000.00
3414	490	13	1	35000.00
3415	490	56	1	38000.00
3416	490	30	2	38000.00
3417	490	29	2	48000.00
3418	490	30	2	38000.00
3419	490	49	2	35000.00
3420	491	26	3	40000.00
3421	491	23	3	40000.00
3422	491	23	3	40000.00
3423	491	19	2	42000.00
3424	491	56	1	38000.00
3425	491	4	3	40000.00
3426	491	49	1	35000.00
3427	492	47	2	45000.00
3428	492	47	2	45000.00
3429	492	43	3	40000.00
3430	492	5	1	40000.00
3431	492	19	2	42000.00
3432	492	53	2	35000.00
3433	492	38	1	40000.00
3434	493	28	3	45000.00
3435	493	26	1	40000.00
3436	493	8	1	45000.00
3437	493	56	2	38000.00
3438	493	30	2	38000.00
3439	493	27	3	45000.00
3440	493	2	1	30000.00
3441	494	11	2	30000.00
3442	494	29	3	48000.00
3443	494	38	2	40000.00
3444	494	17	1	42000.00
3445	494	23	3	40000.00
3446	494	41	2	45000.00
3447	494	20	2	42000.00
3448	495	42	3	42000.00
3449	495	56	2	38000.00
3450	495	14	2	37000.00
3451	495	37	3	40000.00
3452	495	10	2	35000.00
3453	495	23	1	40000.00
3454	495	35	3	38000.00
3455	496	31	3	42000.00
3456	496	13	3	35000.00
3457	496	27	3	45000.00
3458	496	15	2	42000.00
3459	496	55	2	35000.00
3460	496	40	2	38000.00
3461	496	3	1	32000.00
3462	497	20	1	42000.00
3463	497	33	3	35000.00
3464	497	53	3	35000.00
3465	497	5	2	40000.00
3466	497	20	2	42000.00
3467	497	13	1	35000.00
3468	497	2	2	30000.00
3469	498	27	2	45000.00
3470	498	6	3	40000.00
3471	498	37	2	40000.00
3472	498	35	1	38000.00
3473	498	10	1	35000.00
3474	498	9	3	45000.00
3475	498	46	2	45000.00
3476	499	54	3	50000.00
3477	499	51	3	20000.00
3478	499	8	1	45000.00
3479	499	26	2	40000.00
3480	499	24	1	40000.00
3481	499	34	3	40000.00
3482	499	2	2	30000.00
3483	500	27	1	45000.00
3484	500	26	2	40000.00
3485	500	35	2	38000.00
3486	500	17	1	42000.00
3487	500	48	1	45000.00
3488	500	13	2	35000.00
3489	500	36	2	40000.00
3490	501	12	2	32000.00
3491	501	14	1	37000.00
3492	501	45	3	45000.00
3493	501	23	1	40000.00
3494	501	35	1	38000.00
3495	501	22	2	42000.00
3496	501	3	1	32000.00
3497	502	21	3	42000.00
3498	502	18	2	45000.00
3499	502	27	2	45000.00
3500	502	13	2	35000.00
3501	502	27	2	45000.00
3502	502	10	3	35000.00
3503	502	22	1	42000.00
3504	503	50	2	35000.00
3505	503	28	1	45000.00
3506	503	56	3	38000.00
3507	503	26	1	40000.00
3508	503	16	2	38000.00
3509	503	12	2	32000.00
3510	503	49	1	35000.00
3511	504	3	3	32000.00
3512	504	31	1	42000.00
3513	504	54	2	50000.00
3514	504	44	3	45000.00
3515	504	1	1	42000.00
3516	504	12	2	32000.00
3517	504	34	3	40000.00
3518	505	15	2	42000.00
3519	505	33	2	35000.00
3520	505	8	1	45000.00
3521	505	40	1	38000.00
3522	505	22	3	42000.00
3523	505	10	1	35000.00
3524	505	40	3	38000.00
3525	506	47	1	45000.00
3526	506	41	2	45000.00
3527	506	39	2	45000.00
3528	506	21	1	42000.00
3529	506	44	3	45000.00
3530	506	36	3	40000.00
3531	506	41	2	45000.00
3532	507	38	2	40000.00
3533	507	3	1	32000.00
3534	507	55	2	35000.00
3535	507	48	1	45000.00
3536	507	32	3	40000.00
3537	507	16	1	38000.00
3538	507	55	3	35000.00
3539	508	27	3	45000.00
3540	508	44	1	45000.00
3541	508	22	1	42000.00
3542	508	10	2	35000.00
3543	508	9	3	45000.00
3544	508	32	1	40000.00
3545	508	17	2	42000.00
3546	509	14	1	37000.00
3547	509	22	1	42000.00
3548	509	43	1	40000.00
3549	509	29	1	48000.00
3550	509	6	3	40000.00
3551	509	29	3	48000.00
3552	509	15	3	42000.00
3553	510	38	2	40000.00
3554	510	21	2	42000.00
3555	510	15	2	42000.00
3556	510	50	3	35000.00
3557	510	49	2	35000.00
3558	510	10	2	35000.00
3559	510	21	1	42000.00
3560	511	10	1	35000.00
3561	511	47	3	45000.00
3562	511	34	3	40000.00
3563	511	16	2	38000.00
3564	511	31	3	42000.00
3565	511	38	2	40000.00
3566	511	42	1	42000.00
3567	512	24	3	40000.00
3568	512	27	1	45000.00
3569	512	55	3	35000.00
3570	512	5	2	40000.00
3571	512	52	2	38000.00
3572	512	50	3	35000.00
3573	512	42	1	42000.00
3574	513	7	2	42000.00
3575	513	52	2	38000.00
3576	513	32	3	40000.00
3577	513	41	1	45000.00
3578	513	11	2	30000.00
3579	513	48	1	45000.00
3580	513	51	1	20000.00
3581	514	4	1	40000.00
3582	514	23	3	40000.00
3583	514	14	3	37000.00
3584	514	27	3	45000.00
3585	514	16	1	38000.00
3586	514	46	3	45000.00
3587	514	10	2	35000.00
3588	515	53	3	35000.00
3589	515	47	3	45000.00
3590	515	21	3	42000.00
3591	515	13	1	35000.00
3592	515	27	3	45000.00
3593	515	48	3	45000.00
3594	515	40	1	38000.00
3595	516	36	2	40000.00
3596	516	5	2	40000.00
3597	516	40	2	38000.00
3598	516	16	3	38000.00
3599	516	24	2	40000.00
3600	516	55	1	35000.00
3601	516	34	2	40000.00
3602	517	3	2	32000.00
3603	517	55	2	35000.00
3604	517	53	2	35000.00
3605	517	28	2	45000.00
3606	517	44	2	45000.00
3607	517	46	3	45000.00
3608	517	38	1	40000.00
3609	518	39	2	45000.00
3610	518	34	2	40000.00
3611	518	9	3	45000.00
3612	518	2	1	30000.00
3613	518	53	2	35000.00
3614	518	38	1	40000.00
3615	518	16	1	38000.00
3616	519	21	3	42000.00
3617	519	31	2	42000.00
3618	519	48	2	45000.00
3619	519	50	2	35000.00
3620	519	38	3	40000.00
3621	519	18	2	45000.00
3622	519	22	2	42000.00
3623	520	56	1	38000.00
3624	520	34	1	40000.00
3625	520	8	2	45000.00
3626	520	10	3	35000.00
3627	520	3	3	32000.00
3628	520	52	2	38000.00
3629	520	6	1	40000.00
3630	521	52	1	38000.00
3631	521	2	2	30000.00
3632	521	14	2	37000.00
3633	521	41	1	45000.00
3634	521	32	2	40000.00
3635	521	24	2	40000.00
3636	521	23	3	40000.00
3637	522	38	2	40000.00
3638	522	13	1	35000.00
3639	522	28	2	45000.00
3640	522	27	2	45000.00
3641	522	17	1	42000.00
3642	522	22	2	42000.00
3643	522	2	2	30000.00
3644	523	30	1	38000.00
3645	523	41	2	45000.00
3646	523	25	2	40000.00
3647	523	45	1	45000.00
3648	523	54	2	50000.00
3649	523	19	2	42000.00
3650	523	8	1	45000.00
3651	524	31	1	42000.00
3652	524	41	2	45000.00
3653	524	14	2	37000.00
3654	524	15	1	42000.00
3655	524	35	1	38000.00
3656	524	41	2	45000.00
3657	524	23	3	40000.00
3658	525	18	1	45000.00
3659	525	45	2	45000.00
3660	525	44	2	45000.00
3661	525	56	1	38000.00
3662	525	15	1	42000.00
3663	525	43	3	40000.00
3664	525	10	2	35000.00
3665	526	48	1	45000.00
3666	526	41	1	45000.00
3667	526	6	1	40000.00
3668	526	27	3	45000.00
3669	526	42	1	42000.00
3670	526	2	1	30000.00
3671	526	41	2	45000.00
3672	527	37	1	40000.00
3673	527	28	1	45000.00
3674	527	3	3	32000.00
3675	527	44	1	45000.00
3676	527	32	1	40000.00
3677	527	56	2	38000.00
3678	527	30	2	38000.00
3679	528	20	3	42000.00
3680	528	29	3	48000.00
3681	528	27	2	45000.00
3682	528	25	1	40000.00
3683	528	2	3	30000.00
3684	528	7	3	42000.00
3685	528	25	2	40000.00
3686	529	28	2	45000.00
3687	529	29	2	48000.00
3688	529	41	3	45000.00
3689	529	37	1	40000.00
3690	529	53	1	35000.00
3691	529	14	3	37000.00
3692	529	9	1	45000.00
3693	530	13	3	35000.00
3694	530	32	1	40000.00
3695	530	56	3	38000.00
3696	530	24	1	40000.00
3697	530	7	1	42000.00
3698	530	20	2	42000.00
3699	530	40	1	38000.00
3700	531	20	2	42000.00
3701	531	53	2	35000.00
3702	531	7	3	42000.00
3703	531	52	3	38000.00
3704	531	1	1	42000.00
3705	531	15	3	42000.00
3706	531	19	1	42000.00
3707	532	9	1	45000.00
3708	532	33	3	35000.00
3709	532	30	1	38000.00
3710	532	35	1	38000.00
3711	532	45	2	45000.00
3712	532	26	2	40000.00
3713	532	19	1	42000.00
3714	533	37	1	40000.00
3715	533	19	3	42000.00
3716	533	11	1	30000.00
3717	533	4	3	40000.00
3718	533	49	3	35000.00
3719	533	45	2	45000.00
3720	533	2	3	30000.00
3721	534	7	1	42000.00
3722	534	42	2	42000.00
3723	534	26	2	40000.00
3724	534	44	1	45000.00
3725	534	19	2	42000.00
3726	534	10	2	35000.00
3727	534	55	3	35000.00
3728	535	6	3	40000.00
3729	535	25	1	40000.00
3730	535	39	3	45000.00
3731	535	27	1	45000.00
3732	535	16	3	38000.00
3733	535	26	1	40000.00
3734	535	43	2	40000.00
3735	536	4	3	40000.00
3736	536	43	2	40000.00
3737	536	15	3	42000.00
3738	536	17	1	42000.00
3739	536	13	2	35000.00
3740	536	46	2	45000.00
3741	536	51	2	20000.00
3742	537	21	2	42000.00
3743	537	7	1	42000.00
3744	537	49	1	35000.00
3745	537	55	2	35000.00
3746	537	9	3	45000.00
3747	537	35	2	38000.00
3748	537	45	3	45000.00
3749	538	7	3	42000.00
3750	538	36	3	40000.00
3751	538	41	2	45000.00
3752	538	13	3	35000.00
3753	538	18	3	45000.00
3754	538	51	2	20000.00
3755	538	35	2	38000.00
3756	539	37	3	40000.00
3757	539	48	1	45000.00
3758	539	23	3	40000.00
3759	539	36	2	40000.00
3760	539	26	1	40000.00
3761	539	52	3	38000.00
3762	539	3	1	32000.00
3763	540	40	1	38000.00
3764	540	55	1	35000.00
3765	540	43	3	40000.00
3766	540	48	1	45000.00
3767	540	8	1	45000.00
3768	540	18	3	45000.00
3769	540	21	2	42000.00
3770	541	14	1	37000.00
3771	541	8	2	45000.00
3772	541	50	3	35000.00
3773	541	48	3	45000.00
3774	541	19	2	42000.00
3775	541	11	1	30000.00
3776	541	11	2	30000.00
3777	542	43	3	40000.00
3778	542	25	3	40000.00
3779	542	14	2	37000.00
3780	542	40	1	38000.00
3781	542	24	3	40000.00
3782	542	49	2	35000.00
3783	542	15	1	42000.00
3784	543	36	3	40000.00
3785	543	49	3	35000.00
3786	543	1	2	42000.00
3787	543	30	1	38000.00
3788	543	6	2	40000.00
3789	543	32	2	40000.00
3790	543	45	2	45000.00
3791	544	21	1	42000.00
3792	544	37	2	40000.00
3793	544	49	2	35000.00
3794	544	1	3	42000.00
3795	544	44	3	45000.00
3796	544	49	2	35000.00
3797	544	27	2	45000.00
3798	545	44	1	45000.00
3799	545	7	3	42000.00
3800	545	50	2	35000.00
3801	545	10	3	35000.00
3802	545	46	1	45000.00
3803	545	50	2	35000.00
3804	545	26	3	40000.00
3805	546	18	1	45000.00
3806	546	17	2	42000.00
3807	546	11	1	30000.00
3808	546	24	3	40000.00
3809	546	54	2	50000.00
3810	546	44	2	45000.00
3811	546	22	1	42000.00
3812	547	38	1	40000.00
3813	547	11	2	30000.00
3814	547	46	2	45000.00
3815	547	45	3	45000.00
3816	547	15	3	42000.00
3817	547	8	3	45000.00
3818	547	21	1	42000.00
3819	548	6	1	40000.00
3820	548	56	1	38000.00
3821	548	17	2	42000.00
3822	548	44	1	45000.00
3823	548	44	3	45000.00
3824	548	1	3	42000.00
3825	548	50	1	35000.00
3826	549	40	3	38000.00
3827	549	22	3	42000.00
3828	549	33	2	35000.00
3829	549	11	3	30000.00
3830	549	52	3	38000.00
3831	549	18	1	45000.00
3832	549	13	1	35000.00
3833	550	43	2	40000.00
3834	550	17	2	42000.00
3835	550	22	3	42000.00
3836	550	11	3	30000.00
3837	550	56	1	38000.00
3838	550	38	2	40000.00
3839	550	44	3	45000.00
3840	551	40	2	38000.00
3841	551	47	1	45000.00
3842	551	42	1	42000.00
3843	551	18	2	45000.00
3844	551	24	3	40000.00
3845	551	56	1	38000.00
3846	551	53	3	35000.00
3847	552	28	1	45000.00
3848	552	38	2	40000.00
3849	552	2	1	30000.00
3850	552	44	1	45000.00
3851	552	47	3	45000.00
3852	552	16	1	38000.00
3853	552	52	2	38000.00
3854	553	44	1	45000.00
3855	553	44	1	45000.00
3856	553	39	2	45000.00
3857	553	36	1	40000.00
3858	553	21	2	42000.00
3859	553	16	3	38000.00
3860	553	29	3	48000.00
3861	554	16	2	38000.00
3862	554	34	3	40000.00
3863	554	47	3	45000.00
3864	554	25	2	40000.00
3865	554	45	3	45000.00
3866	554	43	2	40000.00
3867	554	38	3	40000.00
3868	555	56	2	38000.00
3869	555	39	1	45000.00
3870	555	13	1	35000.00
3871	555	24	2	40000.00
3872	555	43	3	40000.00
3873	555	21	2	42000.00
3874	555	4	3	40000.00
3875	556	25	1	40000.00
3876	556	45	1	45000.00
3877	556	45	1	45000.00
3878	556	46	3	45000.00
3879	556	18	3	45000.00
3880	556	34	1	40000.00
3881	556	34	3	40000.00
3882	557	27	1	45000.00
3883	557	35	3	38000.00
3884	557	9	2	45000.00
3885	557	32	3	40000.00
3886	557	48	2	45000.00
3887	557	55	2	35000.00
3888	557	32	2	40000.00
3889	558	14	1	37000.00
3890	558	40	1	38000.00
3891	558	56	2	38000.00
3892	558	22	1	42000.00
3893	558	39	2	45000.00
3894	558	55	3	35000.00
3895	558	31	2	42000.00
3896	559	25	3	40000.00
3897	559	54	1	50000.00
3898	559	1	3	42000.00
3899	559	36	1	40000.00
3900	559	20	3	42000.00
3901	559	42	3	42000.00
3902	559	52	1	38000.00
3903	560	4	2	40000.00
3904	560	11	2	30000.00
3905	560	13	3	35000.00
3906	560	7	1	42000.00
3907	560	35	1	38000.00
3908	560	55	3	35000.00
3909	560	46	1	45000.00
3910	561	38	1	40000.00
3911	561	11	1	30000.00
3912	561	44	1	45000.00
3913	561	6	2	40000.00
3914	561	18	1	45000.00
3915	561	54	3	50000.00
3916	561	23	1	40000.00
3917	562	43	3	40000.00
3918	562	40	1	38000.00
3919	562	2	2	30000.00
3920	562	29	3	48000.00
3921	562	44	1	45000.00
3922	562	21	2	42000.00
3923	562	19	1	42000.00
3924	563	10	2	35000.00
3925	563	13	2	35000.00
3926	563	44	2	45000.00
3927	563	12	3	32000.00
3928	563	27	3	45000.00
3929	563	49	2	35000.00
3930	563	26	3	40000.00
3931	564	34	1	40000.00
3932	564	54	1	50000.00
3933	564	38	3	40000.00
3934	564	18	3	45000.00
3935	564	37	3	40000.00
3936	564	21	2	42000.00
3937	564	41	1	45000.00
3938	565	13	1	35000.00
3939	565	16	1	38000.00
3940	565	21	2	42000.00
3941	565	18	1	45000.00
3942	565	49	1	35000.00
3943	565	51	1	20000.00
3944	565	43	1	40000.00
3945	566	32	1	40000.00
3946	566	44	3	45000.00
3947	566	18	2	45000.00
3948	566	41	1	45000.00
3949	566	42	1	42000.00
3950	566	54	1	50000.00
3951	566	53	3	35000.00
3952	567	49	2	35000.00
3953	567	46	1	45000.00
3954	567	47	3	45000.00
3955	567	12	3	32000.00
3956	567	3	1	32000.00
3957	567	2	1	30000.00
3958	567	10	1	35000.00
3959	568	35	1	38000.00
3960	568	41	3	45000.00
3961	568	4	2	40000.00
3962	568	53	2	35000.00
3963	568	20	3	42000.00
3964	568	27	3	45000.00
3965	568	53	1	35000.00
3966	569	35	1	38000.00
3967	569	16	1	38000.00
3968	569	3	2	32000.00
3969	569	56	2	38000.00
3970	569	16	2	38000.00
3971	569	38	1	40000.00
3972	569	39	3	45000.00
3973	570	32	3	40000.00
3974	570	29	3	48000.00
3975	570	10	1	35000.00
3976	570	4	2	40000.00
3977	570	50	1	35000.00
3978	570	4	3	40000.00
3979	570	50	2	35000.00
3980	571	51	2	20000.00
3981	571	42	3	42000.00
3982	571	7	1	42000.00
3983	571	3	3	32000.00
3984	571	56	1	38000.00
3985	571	28	3	45000.00
3986	571	51	2	20000.00
3987	572	32	1	40000.00
3988	572	56	2	38000.00
3989	572	26	1	40000.00
3990	572	3	1	32000.00
3991	572	1	2	42000.00
3992	572	52	3	38000.00
3993	572	41	1	45000.00
3994	573	55	3	35000.00
3995	573	28	1	45000.00
3996	573	24	3	40000.00
3997	573	25	3	40000.00
3998	573	39	2	45000.00
3999	573	11	1	30000.00
4000	573	19	2	42000.00
4001	574	37	3	40000.00
4002	574	38	1	40000.00
4003	574	37	3	40000.00
4004	574	7	3	42000.00
4005	574	10	1	35000.00
4006	574	39	2	45000.00
4007	574	36	1	40000.00
4008	575	6	3	40000.00
4009	575	31	1	42000.00
4010	575	20	3	42000.00
4011	575	38	1	40000.00
4012	575	51	1	20000.00
4013	575	32	3	40000.00
4014	575	49	3	35000.00
4015	576	36	3	40000.00
4016	576	12	2	32000.00
4017	576	18	2	45000.00
4018	576	33	3	35000.00
4019	576	44	1	45000.00
4020	576	1	3	42000.00
4021	576	13	1	35000.00
4022	577	12	3	32000.00
4023	577	35	2	38000.00
4024	577	42	2	42000.00
4025	577	14	3	37000.00
4026	577	39	3	45000.00
4027	577	26	3	40000.00
4028	577	10	1	35000.00
4029	578	8	1	45000.00
4030	578	26	3	40000.00
4031	578	7	1	42000.00
4032	578	23	2	40000.00
4033	578	41	2	45000.00
4034	578	38	2	40000.00
4035	578	55	3	35000.00
4036	579	22	1	42000.00
4037	579	32	1	40000.00
4038	579	36	2	40000.00
4039	579	34	2	40000.00
4040	579	30	3	38000.00
4041	579	6	1	40000.00
4042	579	33	3	35000.00
4043	580	38	1	40000.00
4044	580	47	1	45000.00
4045	580	48	2	45000.00
4046	580	12	2	32000.00
4047	580	24	3	40000.00
4048	580	50	1	35000.00
4049	580	52	3	38000.00
4050	581	31	1	42000.00
4051	581	32	2	40000.00
4052	581	18	1	45000.00
4053	581	42	3	42000.00
4054	581	14	1	37000.00
4055	581	9	1	45000.00
4056	581	5	2	40000.00
4057	582	26	3	40000.00
4058	582	22	1	42000.00
4059	582	22	2	42000.00
4060	582	49	2	35000.00
4061	582	37	1	40000.00
4062	582	21	2	42000.00
4063	582	7	2	42000.00
4064	583	38	2	40000.00
4065	583	16	3	38000.00
4066	583	31	2	42000.00
4067	583	48	1	45000.00
4068	583	27	1	45000.00
4069	583	41	1	45000.00
4070	583	37	2	40000.00
4071	584	55	2	35000.00
4072	584	21	2	42000.00
4073	584	53	1	35000.00
4074	584	26	2	40000.00
4075	584	49	1	35000.00
4076	584	35	3	38000.00
4077	584	29	3	48000.00
4078	585	39	1	45000.00
4079	585	36	3	40000.00
4080	585	19	1	42000.00
4081	585	14	1	37000.00
4082	585	32	3	40000.00
4083	585	45	1	45000.00
4084	585	23	3	40000.00
4085	586	30	3	38000.00
4086	586	50	2	35000.00
4087	586	18	2	45000.00
4088	586	37	3	40000.00
4089	586	33	2	35000.00
4090	586	19	3	42000.00
4091	586	50	3	35000.00
4092	587	12	1	32000.00
4093	587	43	1	40000.00
4094	587	30	1	38000.00
4095	587	27	1	45000.00
4096	587	18	3	45000.00
4097	587	20	1	42000.00
4098	587	34	2	40000.00
4099	588	53	2	35000.00
4100	588	49	1	35000.00
4101	588	9	3	45000.00
4102	588	10	2	35000.00
4103	588	8	1	45000.00
4104	588	9	3	45000.00
4105	588	2	2	30000.00
4106	589	37	2	40000.00
4107	589	49	3	35000.00
4108	589	2	1	30000.00
4109	589	31	2	42000.00
4110	589	39	3	45000.00
4111	589	47	2	45000.00
4112	589	33	3	35000.00
4113	590	37	2	40000.00
4114	590	25	2	40000.00
4115	590	42	2	42000.00
4116	590	34	2	40000.00
4117	590	8	1	45000.00
4118	590	15	2	42000.00
4119	590	15	3	42000.00
4120	591	46	2	45000.00
4121	591	42	1	42000.00
4122	591	44	3	45000.00
4123	591	23	1	40000.00
4124	591	32	2	40000.00
4125	591	26	3	40000.00
4126	591	16	1	38000.00
4127	592	49	1	35000.00
4128	592	21	2	42000.00
4129	592	8	1	45000.00
4130	592	46	2	45000.00
4131	592	43	1	40000.00
4132	592	13	3	35000.00
4133	592	21	1	42000.00
4134	593	17	2	42000.00
4135	593	33	1	35000.00
4136	593	47	2	45000.00
4137	593	17	3	42000.00
4138	593	18	3	45000.00
4139	593	24	2	40000.00
4140	593	5	2	40000.00
4141	594	54	3	50000.00
4142	594	21	3	42000.00
4143	594	40	1	38000.00
4144	594	42	3	42000.00
4145	594	26	1	40000.00
4146	594	21	3	42000.00
4147	594	10	1	35000.00
4148	595	42	2	42000.00
4149	595	25	3	40000.00
4150	595	33	1	35000.00
4151	595	46	1	45000.00
4152	595	48	1	45000.00
4153	595	45	2	45000.00
4154	595	33	3	35000.00
4155	596	54	3	50000.00
4156	596	4	1	40000.00
4157	596	3	2	32000.00
4158	596	49	3	35000.00
4159	596	20	1	42000.00
4160	596	45	3	45000.00
4161	596	4	3	40000.00
4162	597	46	3	45000.00
4163	597	15	1	42000.00
4164	597	22	2	42000.00
4165	597	38	2	40000.00
4166	597	45	1	45000.00
4167	597	24	2	40000.00
4168	597	25	1	40000.00
4169	598	23	1	40000.00
4170	598	28	2	45000.00
4171	598	50	1	35000.00
4172	598	11	1	30000.00
4173	598	49	1	35000.00
4174	598	12	2	32000.00
4175	598	40	3	38000.00
4176	599	47	3	45000.00
4177	599	51	3	20000.00
4178	599	29	1	48000.00
4179	599	24	3	40000.00
4180	599	39	2	45000.00
4181	599	43	2	40000.00
4182	599	29	3	48000.00
4183	600	52	1	38000.00
4184	600	35	2	38000.00
4185	600	27	3	45000.00
4186	600	6	3	40000.00
4187	600	5	1	40000.00
4188	600	41	3	45000.00
4189	600	42	2	42000.00
4190	601	3	1	32000.00
4191	601	11	2	30000.00
4192	601	32	3	40000.00
4193	601	33	2	35000.00
4194	601	11	2	30000.00
4195	601	4	1	40000.00
4196	601	21	3	42000.00
4197	602	54	3	50000.00
4198	602	19	2	42000.00
4199	602	42	2	42000.00
4200	602	12	3	32000.00
4201	602	42	2	42000.00
4202	602	4	2	40000.00
4203	602	8	3	45000.00
4204	603	32	2	40000.00
4205	603	25	3	40000.00
4206	603	30	1	38000.00
4207	603	9	3	45000.00
4208	603	45	1	45000.00
4209	603	36	1	40000.00
4210	603	11	3	30000.00
4211	604	49	3	35000.00
4212	604	41	3	45000.00
4213	604	32	1	40000.00
4214	604	13	1	35000.00
4215	604	15	2	42000.00
4216	604	26	2	40000.00
4217	604	12	2	32000.00
4218	605	23	1	40000.00
4219	605	33	2	35000.00
4220	605	29	3	48000.00
4221	605	7	1	42000.00
4222	605	24	2	40000.00
4223	605	19	2	42000.00
4224	605	38	1	40000.00
4225	606	24	2	40000.00
4226	606	45	3	45000.00
4227	606	54	2	50000.00
4228	606	37	1	40000.00
4229	606	5	1	40000.00
4230	606	11	2	30000.00
4231	606	5	2	40000.00
4232	607	23	3	40000.00
4233	607	27	1	45000.00
4234	607	6	1	40000.00
4235	607	8	3	45000.00
4236	607	43	3	40000.00
4237	607	22	1	42000.00
4238	607	51	1	20000.00
4239	608	15	1	42000.00
4240	608	3	3	32000.00
4241	608	1	3	42000.00
4242	608	7	1	42000.00
4243	608	40	2	38000.00
4244	608	5	1	40000.00
4245	608	23	1	40000.00
4246	609	18	1	45000.00
4247	609	47	1	45000.00
4248	609	4	1	40000.00
4249	609	56	3	38000.00
4250	609	6	2	40000.00
4251	609	52	3	38000.00
4252	609	28	1	45000.00
4253	610	43	2	40000.00
4254	610	17	1	42000.00
4255	610	55	1	35000.00
4256	610	28	2	45000.00
4257	610	53	3	35000.00
4258	610	53	3	35000.00
4259	610	43	2	40000.00
4260	611	27	3	45000.00
4261	611	25	3	40000.00
4262	611	48	3	45000.00
4263	611	38	1	40000.00
4264	611	4	1	40000.00
4265	611	24	1	40000.00
4266	611	11	3	30000.00
4267	612	5	2	40000.00
4268	612	1	1	42000.00
4269	612	42	2	42000.00
4270	612	5	3	40000.00
4271	612	8	2	45000.00
4272	612	54	1	50000.00
4273	612	26	3	40000.00
4274	613	32	2	40000.00
4275	613	41	1	45000.00
4276	613	25	3	40000.00
4277	613	4	1	40000.00
4278	613	1	2	42000.00
4279	613	35	2	38000.00
4280	613	22	1	42000.00
4281	614	30	1	38000.00
4282	614	17	2	42000.00
4283	614	52	2	38000.00
4284	614	48	2	45000.00
4285	614	25	1	40000.00
4286	614	40	3	38000.00
4287	614	6	3	40000.00
4288	615	6	3	40000.00
4289	615	14	3	37000.00
4290	615	14	1	37000.00
4291	615	50	1	35000.00
4292	615	43	3	40000.00
4293	615	53	2	35000.00
4294	615	52	2	38000.00
4295	616	31	3	42000.00
4296	616	33	2	35000.00
4297	616	31	3	42000.00
4298	616	39	2	45000.00
4299	616	29	2	48000.00
4300	616	28	3	45000.00
4301	616	24	3	40000.00
4302	617	25	1	40000.00
4303	617	50	2	35000.00
4304	617	52	1	38000.00
4305	617	42	1	42000.00
4306	617	4	1	40000.00
4307	617	55	3	35000.00
4308	617	1	3	42000.00
4309	618	51	2	20000.00
4310	618	14	2	37000.00
4311	618	3	2	32000.00
4312	618	3	1	32000.00
4313	618	25	3	40000.00
4314	618	51	1	20000.00
4315	618	54	2	50000.00
4316	619	24	1	40000.00
4317	619	14	1	37000.00
4318	619	31	3	42000.00
4319	619	21	1	42000.00
4320	619	53	3	35000.00
4321	619	25	3	40000.00
4322	619	4	2	40000.00
4323	620	34	1	40000.00
4324	620	8	3	45000.00
4325	620	36	3	40000.00
4326	620	25	1	40000.00
4327	620	44	1	45000.00
4328	620	11	2	30000.00
4329	620	50	3	35000.00
4330	621	37	3	40000.00
4331	621	17	1	42000.00
4332	621	35	3	38000.00
4333	621	55	1	35000.00
4334	621	50	1	35000.00
4335	621	31	2	42000.00
4336	621	52	2	38000.00
4337	622	37	3	40000.00
4338	622	37	2	40000.00
4339	622	16	1	38000.00
4340	622	42	2	42000.00
4341	622	30	3	38000.00
4342	622	46	3	45000.00
4343	622	18	3	45000.00
4344	623	9	3	45000.00
4345	623	21	3	42000.00
4346	623	46	2	45000.00
4347	623	5	2	40000.00
4348	623	54	1	50000.00
4349	623	12	1	32000.00
4350	623	10	2	35000.00
4351	624	56	3	38000.00
4352	624	4	3	40000.00
4353	624	8	2	45000.00
4354	624	21	2	42000.00
4355	624	15	1	42000.00
4356	624	9	3	45000.00
4357	624	51	2	20000.00
4358	625	14	1	37000.00
4359	625	25	1	40000.00
4360	625	9	1	45000.00
4361	625	50	3	35000.00
4362	625	37	3	40000.00
4363	625	29	1	48000.00
4364	625	49	1	35000.00
4365	626	52	2	38000.00
4366	626	30	1	38000.00
4367	626	49	3	35000.00
4368	626	43	1	40000.00
4369	626	30	2	38000.00
4370	626	47	3	45000.00
4371	626	54	1	50000.00
4372	627	15	1	42000.00
4373	627	36	3	40000.00
4374	627	51	1	20000.00
4375	627	44	3	45000.00
4376	627	7	2	42000.00
4377	627	5	1	40000.00
4378	627	49	1	35000.00
4379	628	33	2	35000.00
4380	628	36	1	40000.00
4381	628	27	1	45000.00
4382	628	5	1	40000.00
4383	628	12	3	32000.00
4384	628	43	1	40000.00
4385	628	49	3	35000.00
4386	629	45	1	45000.00
4387	629	9	2	45000.00
4388	629	32	1	40000.00
4389	629	16	3	38000.00
4390	629	12	2	32000.00
4391	629	28	3	45000.00
4392	629	15	3	42000.00
4393	630	5	2	40000.00
4394	630	39	1	45000.00
4395	630	38	1	40000.00
4396	630	10	1	35000.00
4397	630	54	3	50000.00
4398	630	15	2	42000.00
4399	630	4	3	40000.00
4400	631	44	2	45000.00
4401	631	46	2	45000.00
4402	631	20	2	42000.00
4403	631	3	3	32000.00
4404	631	45	3	45000.00
4405	631	12	2	32000.00
4406	631	6	3	40000.00
4407	632	8	1	45000.00
4408	632	54	2	50000.00
4409	632	44	1	45000.00
4410	632	22	2	42000.00
4411	632	5	2	40000.00
4412	632	5	2	40000.00
4413	632	16	1	38000.00
4414	633	50	2	35000.00
4415	633	44	3	45000.00
4416	633	27	2	45000.00
4417	633	30	1	38000.00
4418	633	48	3	45000.00
4419	633	19	1	42000.00
4420	633	46	2	45000.00
4421	634	50	1	35000.00
4422	634	44	2	45000.00
4423	634	23	2	40000.00
4424	634	31	2	42000.00
4425	634	8	2	45000.00
4426	634	7	1	42000.00
4427	634	30	2	38000.00
4428	635	48	3	45000.00
4429	635	54	2	50000.00
4430	635	23	1	40000.00
4431	635	42	1	42000.00
4432	635	3	2	32000.00
4433	635	26	1	40000.00
4434	635	21	2	42000.00
4435	636	47	2	45000.00
4436	636	41	1	45000.00
4437	636	2	3	30000.00
4438	636	20	1	42000.00
4439	636	31	1	42000.00
4440	636	1	2	42000.00
4441	636	38	2	40000.00
4442	637	47	2	45000.00
4443	637	6	2	40000.00
4444	637	22	2	42000.00
4445	637	13	3	35000.00
4446	637	5	2	40000.00
4447	637	24	3	40000.00
4448	637	29	1	48000.00
4449	638	51	1	20000.00
4450	638	20	1	42000.00
4451	638	31	2	42000.00
4452	638	39	3	45000.00
4453	638	46	3	45000.00
4454	638	38	2	40000.00
4455	638	29	1	48000.00
4456	639	44	2	45000.00
4457	639	42	2	42000.00
4458	639	40	3	38000.00
4459	639	42	2	42000.00
4460	639	31	3	42000.00
4461	639	51	1	20000.00
4462	639	2	1	30000.00
4463	640	17	1	42000.00
4464	640	47	1	45000.00
4465	640	9	3	45000.00
4466	640	7	3	42000.00
4467	640	46	3	45000.00
4468	640	14	2	37000.00
4469	640	38	2	40000.00
4470	641	31	3	42000.00
4471	641	35	3	38000.00
4472	641	37	1	40000.00
4473	641	1	1	42000.00
4474	641	56	2	38000.00
4475	641	15	1	42000.00
4476	641	21	3	42000.00
4477	642	34	1	40000.00
4478	642	22	3	42000.00
4479	642	50	1	35000.00
4480	642	25	1	40000.00
4481	642	41	2	45000.00
4482	642	37	1	40000.00
4483	642	10	2	35000.00
4484	643	40	1	38000.00
4485	643	49	2	35000.00
4486	643	29	2	48000.00
4487	643	2	1	30000.00
4488	643	4	1	40000.00
4489	643	13	3	35000.00
4490	643	1	2	42000.00
4491	644	37	3	40000.00
4492	644	43	2	40000.00
4493	644	29	3	48000.00
4494	644	54	2	50000.00
4495	644	11	1	30000.00
4496	644	31	3	42000.00
4497	644	16	1	38000.00
4498	645	13	2	35000.00
4499	645	32	1	40000.00
4500	645	2	3	30000.00
4501	645	48	3	45000.00
4502	645	18	3	45000.00
4503	645	18	3	45000.00
4504	645	38	1	40000.00
4505	646	3	3	32000.00
4506	646	34	1	40000.00
4507	646	15	1	42000.00
4508	646	16	1	38000.00
4509	646	44	1	45000.00
4510	646	24	3	40000.00
4511	646	52	2	38000.00
4512	647	32	1	40000.00
4513	647	2	2	30000.00
4514	647	21	3	42000.00
4515	647	40	1	38000.00
4516	647	20	2	42000.00
4517	647	19	3	42000.00
4518	647	32	2	40000.00
4519	648	50	2	35000.00
4520	648	3	1	32000.00
4521	648	36	2	40000.00
4522	648	30	1	38000.00
4523	648	55	1	35000.00
4524	648	35	1	38000.00
4525	648	6	2	40000.00
4526	649	5	3	40000.00
4527	649	38	3	40000.00
4528	649	30	1	38000.00
4529	649	16	2	38000.00
4530	649	47	3	45000.00
4531	649	20	1	42000.00
4532	649	49	1	35000.00
4533	650	41	1	45000.00
4534	650	14	3	37000.00
4535	650	43	3	40000.00
4536	650	12	1	32000.00
4537	650	20	1	42000.00
4538	650	40	2	38000.00
4539	650	21	1	42000.00
4540	651	15	2	42000.00
4541	651	41	1	45000.00
4542	651	41	2	45000.00
4543	651	2	3	30000.00
4544	651	39	2	45000.00
4545	651	35	3	38000.00
4546	651	34	1	40000.00
4547	652	32	3	40000.00
4548	652	17	1	42000.00
4549	652	54	3	50000.00
4550	652	48	2	45000.00
4551	652	8	1	45000.00
4552	652	56	1	38000.00
4553	652	56	3	38000.00
4554	653	17	2	42000.00
4555	653	7	3	42000.00
4556	653	32	1	40000.00
4557	653	23	3	40000.00
4558	653	16	3	38000.00
4559	653	32	3	40000.00
4560	653	4	1	40000.00
4561	654	17	2	42000.00
4562	654	49	3	35000.00
4563	654	32	1	40000.00
4564	654	8	3	45000.00
4565	654	52	2	38000.00
4566	654	25	2	40000.00
4567	654	33	1	35000.00
4568	655	25	2	40000.00
4569	655	31	3	42000.00
4570	655	39	1	45000.00
4571	655	22	1	42000.00
4572	655	39	1	45000.00
4573	655	20	2	42000.00
4574	655	12	3	32000.00
4575	656	51	1	20000.00
4576	656	12	1	32000.00
4577	656	38	1	40000.00
4578	656	16	3	38000.00
4579	656	2	1	30000.00
4580	656	51	1	20000.00
4581	656	31	3	42000.00
4582	657	41	3	45000.00
4583	657	28	2	45000.00
4584	657	55	1	35000.00
4585	657	38	1	40000.00
4586	657	18	3	45000.00
4587	657	24	3	40000.00
4588	657	10	3	35000.00
4589	658	51	3	20000.00
4590	658	43	3	40000.00
4591	658	50	2	35000.00
4592	658	53	1	35000.00
4593	658	29	3	48000.00
4594	658	48	3	45000.00
4595	658	40	2	38000.00
4596	659	51	1	20000.00
4597	659	56	1	38000.00
4598	659	40	3	38000.00
4599	659	53	3	35000.00
4600	659	12	1	32000.00
4601	659	1	2	42000.00
4602	659	7	2	42000.00
4603	660	46	3	45000.00
4604	660	55	2	35000.00
4605	660	14	1	37000.00
4606	660	32	1	40000.00
4607	660	15	2	42000.00
4608	660	22	1	42000.00
4609	660	46	3	45000.00
4610	661	27	2	45000.00
4611	661	18	1	45000.00
4612	661	34	3	40000.00
4613	661	22	3	42000.00
4614	661	36	3	40000.00
4615	661	3	2	32000.00
4616	661	2	2	30000.00
4617	662	28	1	45000.00
4618	662	56	2	38000.00
4619	662	45	2	45000.00
4620	662	21	3	42000.00
4621	662	40	1	38000.00
4622	662	45	1	45000.00
4623	662	18	1	45000.00
4624	663	5	3	40000.00
4625	663	21	1	42000.00
4626	663	5	1	40000.00
4627	663	29	3	48000.00
4628	663	51	3	20000.00
4629	663	15	3	42000.00
4630	663	23	2	40000.00
4631	664	3	1	32000.00
4632	664	36	1	40000.00
4633	664	30	3	38000.00
4634	664	14	3	37000.00
4635	664	55	1	35000.00
4636	664	2	3	30000.00
4637	664	4	2	40000.00
4638	665	36	2	40000.00
4639	665	42	3	42000.00
4640	665	27	1	45000.00
4641	665	35	2	38000.00
4642	665	29	2	48000.00
4643	665	5	3	40000.00
4644	665	39	3	45000.00
4645	666	39	2	45000.00
4646	666	24	3	40000.00
4647	666	53	2	35000.00
4648	666	1	1	42000.00
4649	666	6	3	40000.00
4650	666	49	3	35000.00
4651	666	28	1	45000.00
4652	667	14	1	37000.00
4653	667	25	2	40000.00
4654	667	21	1	42000.00
4655	667	1	2	42000.00
4656	667	4	3	40000.00
4657	667	37	2	40000.00
4658	667	56	2	38000.00
4659	668	34	1	40000.00
4660	668	47	3	45000.00
4661	668	51	3	20000.00
4662	668	24	3	40000.00
4663	668	53	1	35000.00
4664	668	19	3	42000.00
4665	668	26	1	40000.00
4666	669	47	1	45000.00
4667	669	38	3	40000.00
4668	669	8	1	45000.00
4669	669	35	1	38000.00
4670	669	3	1	32000.00
4671	669	44	3	45000.00
4672	669	40	2	38000.00
4673	670	28	2	45000.00
4674	670	9	3	45000.00
4675	670	53	3	35000.00
4676	670	32	2	40000.00
4677	670	3	3	32000.00
4678	670	25	1	40000.00
4679	670	26	1	40000.00
4680	671	47	2	45000.00
4681	671	1	1	42000.00
4682	671	37	3	40000.00
4683	671	20	3	42000.00
4684	671	34	3	40000.00
4685	671	53	3	35000.00
4686	671	55	3	35000.00
4687	672	50	1	35000.00
4688	672	4	2	40000.00
4689	672	13	1	35000.00
4690	672	31	3	42000.00
4691	672	22	3	42000.00
4692	672	20	3	42000.00
4693	672	19	1	42000.00
4694	673	8	2	45000.00
4695	673	26	2	40000.00
4696	673	34	2	40000.00
4697	673	46	1	45000.00
4698	673	12	2	32000.00
4699	673	41	3	45000.00
4700	673	23	2	40000.00
4701	674	12	2	32000.00
4702	674	47	2	45000.00
4703	674	5	2	40000.00
4704	674	17	2	42000.00
4705	674	32	3	40000.00
4706	674	29	1	48000.00
4707	674	41	2	45000.00
4708	675	6	1	40000.00
4709	675	14	2	37000.00
4710	675	7	3	42000.00
4711	675	47	2	45000.00
4712	675	49	1	35000.00
4713	675	52	3	38000.00
4714	675	23	3	40000.00
4715	676	10	1	35000.00
4716	676	56	2	38000.00
4717	676	47	1	45000.00
4718	676	53	1	35000.00
4719	676	30	2	38000.00
4720	676	52	3	38000.00
4721	676	49	3	35000.00
4722	677	5	3	40000.00
4723	677	5	2	40000.00
4724	677	35	1	38000.00
4725	677	16	1	38000.00
4726	677	17	1	42000.00
4727	677	21	3	42000.00
4728	677	55	3	35000.00
4729	678	11	1	30000.00
4730	678	26	3	40000.00
4731	678	44	3	45000.00
4732	678	16	2	38000.00
4733	678	19	3	42000.00
4734	678	24	2	40000.00
4735	678	21	3	42000.00
4736	679	56	2	38000.00
4737	679	50	2	35000.00
4738	679	33	3	35000.00
4739	679	15	3	42000.00
4740	679	41	2	45000.00
4741	679	50	2	35000.00
4742	679	51	1	20000.00
4743	680	33	1	35000.00
4744	680	42	1	42000.00
4745	680	4	3	40000.00
4746	680	29	2	48000.00
4747	680	11	2	30000.00
4748	680	26	1	40000.00
4749	680	31	1	42000.00
4750	681	45	2	45000.00
4751	681	10	3	35000.00
4752	681	36	1	40000.00
4753	681	35	1	38000.00
4754	681	16	1	38000.00
4755	681	51	2	20000.00
4756	681	10	3	35000.00
4757	682	13	2	35000.00
4758	682	9	1	45000.00
4759	682	31	3	42000.00
4760	682	9	3	45000.00
4761	682	17	1	42000.00
4762	682	25	2	40000.00
4763	682	55	3	35000.00
4764	683	5	3	40000.00
4765	683	21	2	42000.00
4766	683	44	3	45000.00
4767	683	10	3	35000.00
4768	683	26	1	40000.00
4769	683	26	1	40000.00
4770	683	33	2	35000.00
4771	684	27	2	45000.00
4772	684	7	1	42000.00
4773	684	11	1	30000.00
4774	684	31	3	42000.00
4775	684	2	3	30000.00
4776	684	13	3	35000.00
4777	684	28	3	45000.00
4778	685	2	1	30000.00
4779	685	8	2	45000.00
4780	685	24	3	40000.00
4781	685	30	1	38000.00
4782	685	52	3	38000.00
4783	685	12	3	32000.00
4784	685	19	1	42000.00
4785	686	32	2	40000.00
4786	686	18	1	45000.00
4787	686	30	3	38000.00
4788	686	41	2	45000.00
4789	686	16	3	38000.00
4790	686	48	3	45000.00
4791	686	49	3	35000.00
4792	687	20	1	42000.00
4793	687	15	3	42000.00
4794	687	43	1	40000.00
4795	687	52	2	38000.00
4796	687	21	3	42000.00
4797	687	8	3	45000.00
4798	687	46	3	45000.00
4799	688	43	2	40000.00
4800	688	10	3	35000.00
4801	688	17	3	42000.00
4802	688	52	1	38000.00
4803	688	48	1	45000.00
4804	688	42	1	42000.00
4805	688	39	3	45000.00
4806	689	55	2	35000.00
4807	689	21	3	42000.00
4808	689	46	2	45000.00
4809	689	28	2	45000.00
4810	689	20	2	42000.00
4811	689	36	1	40000.00
4812	689	45	1	45000.00
4813	690	52	1	38000.00
4814	690	37	3	40000.00
4815	690	10	3	35000.00
4816	690	35	3	38000.00
4817	690	36	2	40000.00
4818	690	53	3	35000.00
4819	690	4	2	40000.00
4820	691	11	1	30000.00
4821	691	21	2	42000.00
4822	691	39	1	45000.00
4823	691	6	3	40000.00
4824	691	24	3	40000.00
4825	691	39	2	45000.00
4826	691	48	1	45000.00
4827	692	13	2	35000.00
4828	692	5	1	40000.00
4829	692	5	2	40000.00
4830	692	51	1	20000.00
4831	692	11	3	30000.00
4832	692	34	3	40000.00
4833	692	41	2	45000.00
4834	693	3	2	32000.00
4835	693	42	2	42000.00
4836	693	25	1	40000.00
4837	693	21	3	42000.00
4838	693	12	2	32000.00
4839	693	27	2	45000.00
4840	693	21	3	42000.00
4841	694	23	2	40000.00
4842	694	38	3	40000.00
4843	694	31	1	42000.00
4844	694	2	3	30000.00
4845	694	32	2	40000.00
4846	694	48	2	45000.00
4847	694	28	1	45000.00
4848	695	42	3	42000.00
4849	695	23	3	40000.00
4850	695	1	2	42000.00
4851	695	30	3	38000.00
4852	695	48	1	45000.00
4853	695	48	2	45000.00
4854	695	55	3	35000.00
4855	696	21	2	42000.00
4856	696	54	1	50000.00
4857	696	41	1	45000.00
4858	696	26	1	40000.00
4859	696	39	1	45000.00
4860	696	55	2	35000.00
4861	696	5	1	40000.00
4862	697	54	1	50000.00
4863	697	38	3	40000.00
4864	697	54	3	50000.00
4865	697	4	1	40000.00
4866	697	47	3	45000.00
4867	697	12	2	32000.00
4868	697	24	2	40000.00
4869	698	17	2	42000.00
4870	698	31	2	42000.00
4871	698	40	3	38000.00
4872	698	37	1	40000.00
4873	698	43	2	40000.00
4874	698	33	2	35000.00
4875	698	5	3	40000.00
4876	699	8	2	45000.00
4877	699	7	3	42000.00
4878	699	15	3	42000.00
4879	699	10	2	35000.00
4880	699	9	1	45000.00
4881	699	28	3	45000.00
4882	699	16	1	38000.00
4883	700	40	3	38000.00
4884	700	23	1	40000.00
4885	700	29	3	48000.00
4886	700	33	1	35000.00
4887	700	25	2	40000.00
4888	700	56	3	38000.00
4889	700	6	3	40000.00
4890	701	27	2	45000.00
4891	701	33	2	35000.00
4892	701	13	3	35000.00
4893	701	21	2	42000.00
4894	701	45	1	45000.00
4895	701	34	2	40000.00
4896	701	1	3	42000.00
4897	702	45	3	45000.00
4898	702	8	1	45000.00
4899	702	20	3	42000.00
4900	702	26	3	40000.00
4901	702	35	1	38000.00
4902	702	19	2	42000.00
4903	702	21	2	42000.00
4904	703	49	3	35000.00
4905	703	11	1	30000.00
4906	703	5	1	40000.00
4907	703	47	3	45000.00
4908	703	8	3	45000.00
4909	703	50	3	35000.00
4910	703	32	2	40000.00
4911	704	35	2	38000.00
4912	704	39	3	45000.00
4913	704	42	3	42000.00
4914	704	1	1	42000.00
4915	704	23	2	40000.00
4916	704	55	3	35000.00
4917	704	33	1	35000.00
4918	705	44	3	45000.00
4919	705	32	1	40000.00
4920	705	16	1	38000.00
4921	705	32	3	40000.00
4922	705	1	2	42000.00
4923	705	32	2	40000.00
4924	705	49	3	35000.00
4925	706	43	2	40000.00
4926	706	51	1	20000.00
4927	706	7	2	42000.00
4928	706	14	1	37000.00
4929	706	54	1	50000.00
4930	706	36	2	40000.00
4931	706	3	1	32000.00
4932	707	40	1	38000.00
4933	707	51	3	20000.00
4934	707	48	1	45000.00
4935	707	21	1	42000.00
4936	707	9	2	45000.00
4937	707	7	2	42000.00
4938	707	41	2	45000.00
4939	708	50	2	35000.00
4940	708	19	3	42000.00
4941	708	21	1	42000.00
4942	708	41	2	45000.00
4943	708	18	1	45000.00
4944	708	7	3	42000.00
4945	708	2	2	30000.00
4946	709	4	1	40000.00
4947	709	49	1	35000.00
4948	709	55	2	35000.00
4949	709	36	3	40000.00
4950	709	39	2	45000.00
4951	709	18	3	45000.00
4952	709	40	3	38000.00
4953	710	32	1	40000.00
4954	710	18	2	45000.00
4955	710	12	3	32000.00
4956	710	28	2	45000.00
4957	710	21	2	42000.00
4958	710	14	2	37000.00
4959	710	20	2	42000.00
4960	711	30	3	38000.00
4961	711	10	3	35000.00
4962	711	5	3	40000.00
4963	711	44	2	45000.00
4964	711	18	1	45000.00
4965	711	42	3	42000.00
4966	711	18	1	45000.00
4967	712	4	2	40000.00
4968	712	56	3	38000.00
4969	712	6	2	40000.00
4970	712	41	1	45000.00
4971	712	17	2	42000.00
4972	712	48	1	45000.00
4973	712	3	2	32000.00
4974	713	4	3	40000.00
4975	713	2	3	30000.00
4976	713	35	1	38000.00
4977	713	27	1	45000.00
4978	713	56	2	38000.00
4979	713	35	3	38000.00
4980	713	34	1	40000.00
4981	714	21	1	42000.00
4982	714	30	2	38000.00
4983	714	41	1	45000.00
4984	714	42	1	42000.00
4985	714	48	1	45000.00
4986	714	47	3	45000.00
4987	714	28	2	45000.00
4988	715	25	3	40000.00
4989	715	53	1	35000.00
4990	715	9	2	45000.00
4991	715	9	3	45000.00
4992	715	11	3	30000.00
4993	715	5	3	40000.00
4994	715	17	3	42000.00
4995	716	10	2	35000.00
4996	716	6	2	40000.00
4997	716	53	2	35000.00
4998	716	26	1	40000.00
4999	716	33	2	35000.00
5000	716	26	3	40000.00
5001	716	23	2	40000.00
5002	717	40	1	38000.00
5003	717	44	2	45000.00
5004	717	24	3	40000.00
5005	717	26	3	40000.00
5006	717	18	3	45000.00
5007	717	3	3	32000.00
5008	717	28	3	45000.00
5009	718	35	3	38000.00
5010	718	22	2	42000.00
5011	718	12	1	32000.00
5012	718	27	1	45000.00
5013	718	11	2	30000.00
5014	718	53	3	35000.00
5015	718	49	3	35000.00
5016	719	33	1	35000.00
5017	719	40	2	38000.00
5018	719	8	1	45000.00
5019	719	46	3	45000.00
5020	719	47	3	45000.00
5021	719	18	3	45000.00
5022	719	42	2	42000.00
5023	720	42	3	42000.00
5024	720	47	2	45000.00
5025	720	24	2	40000.00
5026	720	23	1	40000.00
5027	720	35	1	38000.00
5028	720	42	3	42000.00
5029	720	14	1	37000.00
5030	721	45	3	45000.00
5031	721	1	2	42000.00
5032	721	38	1	40000.00
5033	721	46	1	45000.00
5034	721	39	1	45000.00
5035	721	32	3	40000.00
5036	721	10	1	35000.00
5037	722	23	3	40000.00
5038	722	7	2	42000.00
5039	722	52	3	38000.00
5040	722	6	2	40000.00
5041	722	13	2	35000.00
5042	722	21	2	42000.00
5043	722	54	2	50000.00
5044	723	38	3	40000.00
5045	723	37	2	40000.00
5046	723	32	1	40000.00
5047	723	16	1	38000.00
5048	723	14	1	37000.00
5049	723	42	1	42000.00
5050	723	33	1	35000.00
5051	724	5	3	40000.00
5052	724	41	1	45000.00
5053	724	28	1	45000.00
5054	724	36	2	40000.00
5055	724	46	2	45000.00
5056	724	2	1	30000.00
5057	724	43	2	40000.00
5058	725	7	1	42000.00
5059	725	25	2	40000.00
5060	725	38	1	40000.00
5061	725	4	1	40000.00
5062	725	21	1	42000.00
5063	725	2	3	30000.00
5064	725	34	2	40000.00
5065	726	26	1	40000.00
5066	726	14	1	37000.00
5067	726	31	2	42000.00
5068	726	3	1	32000.00
5069	726	41	2	45000.00
5070	726	20	1	42000.00
5071	726	25	2	40000.00
5072	727	40	2	38000.00
5073	727	22	2	42000.00
5074	727	9	1	45000.00
5075	727	39	3	45000.00
5076	727	56	2	38000.00
5077	727	18	3	45000.00
5078	727	38	1	40000.00
5079	728	10	3	35000.00
5080	728	50	3	35000.00
5081	728	41	2	45000.00
5082	728	19	1	42000.00
5083	728	56	3	38000.00
5084	728	21	1	42000.00
5085	728	31	3	42000.00
5086	729	2	3	30000.00
5087	729	32	1	40000.00
5088	729	16	1	38000.00
5089	729	14	3	37000.00
5090	729	4	1	40000.00
5091	729	2	3	30000.00
5092	729	13	3	35000.00
5093	730	11	2	30000.00
5094	730	29	3	48000.00
5095	730	39	3	45000.00
5096	730	6	2	40000.00
5097	730	23	2	40000.00
5098	730	30	2	38000.00
5099	730	15	3	42000.00
5100	731	13	1	35000.00
5101	731	51	2	20000.00
5102	731	6	2	40000.00
5103	731	32	1	40000.00
5104	731	32	2	40000.00
5105	731	32	3	40000.00
5106	731	29	2	48000.00
5107	732	39	2	45000.00
5108	732	23	2	40000.00
5109	732	33	3	35000.00
5110	732	34	1	40000.00
5111	732	48	3	45000.00
5112	732	42	1	42000.00
5113	732	39	2	45000.00
5114	733	1	1	42000.00
5115	733	44	1	45000.00
5116	733	35	3	38000.00
5117	733	37	3	40000.00
5118	733	3	3	32000.00
5119	733	1	3	42000.00
5120	733	24	1	40000.00
5121	734	20	3	42000.00
5122	734	51	2	20000.00
5123	734	19	3	42000.00
5124	734	51	1	20000.00
5125	734	14	2	37000.00
5126	734	4	3	40000.00
5127	734	27	2	45000.00
5128	735	9	2	45000.00
5129	735	3	2	32000.00
5130	735	16	2	38000.00
5131	735	24	2	40000.00
5132	735	14	1	37000.00
5133	735	24	2	40000.00
5134	735	24	3	40000.00
5135	736	34	3	40000.00
5136	736	51	2	20000.00
5137	736	34	2	40000.00
5138	736	24	3	40000.00
5139	736	42	1	42000.00
5140	736	38	3	40000.00
5141	736	21	3	42000.00
5142	737	33	3	35000.00
5143	737	29	2	48000.00
5144	737	35	2	38000.00
5145	737	43	2	40000.00
5146	737	41	2	45000.00
5147	737	32	1	40000.00
5148	737	15	2	42000.00
5149	738	47	1	45000.00
5150	738	34	1	40000.00
5151	738	18	3	45000.00
5152	738	47	1	45000.00
5153	738	21	1	42000.00
5154	738	2	1	30000.00
5155	738	34	3	40000.00
5156	739	39	3	45000.00
5157	739	33	2	35000.00
5158	739	42	2	42000.00
5159	739	43	2	40000.00
5160	739	38	1	40000.00
5161	739	18	1	45000.00
5162	739	45	3	45000.00
5163	740	35	2	38000.00
5164	740	29	2	48000.00
5165	740	10	2	35000.00
5166	740	28	3	45000.00
5167	740	39	1	45000.00
5168	740	55	2	35000.00
5169	740	54	1	50000.00
5170	741	12	1	32000.00
5171	741	26	3	40000.00
5172	741	27	3	45000.00
5173	741	32	1	40000.00
5174	741	35	2	38000.00
5175	741	27	2	45000.00
5176	741	23	3	40000.00
5177	742	17	2	42000.00
5178	742	48	1	45000.00
5179	742	1	1	42000.00
5180	742	9	3	45000.00
5181	742	5	3	40000.00
5182	742	13	3	35000.00
5183	742	16	3	38000.00
5184	743	40	2	38000.00
5185	743	1	2	42000.00
5186	743	16	2	38000.00
5187	743	17	3	42000.00
5188	743	55	1	35000.00
5189	743	35	3	38000.00
5190	743	19	3	42000.00
5191	744	11	3	30000.00
5192	744	1	1	42000.00
5193	744	9	2	45000.00
5194	744	10	2	35000.00
5195	744	30	1	38000.00
5196	744	5	2	40000.00
5197	744	54	1	50000.00
5198	745	42	2	42000.00
5199	745	23	1	40000.00
5200	745	24	1	40000.00
5201	745	36	2	40000.00
5202	745	31	1	42000.00
5203	745	12	2	32000.00
5204	745	52	2	38000.00
5205	746	42	3	42000.00
5206	746	10	3	35000.00
5207	746	20	3	42000.00
5208	746	55	1	35000.00
5209	746	38	3	40000.00
5210	746	13	3	35000.00
5211	746	48	2	45000.00
5212	747	19	1	42000.00
5213	747	6	2	40000.00
5214	747	37	1	40000.00
5215	747	30	2	38000.00
5216	747	1	3	42000.00
5217	747	53	2	35000.00
5218	747	7	1	42000.00
5219	748	56	1	38000.00
5220	748	56	2	38000.00
5221	748	10	3	35000.00
5222	748	1	3	42000.00
5223	748	49	3	35000.00
5224	748	25	1	40000.00
5225	748	4	1	40000.00
5226	749	43	1	40000.00
5227	749	48	3	45000.00
5228	749	18	3	45000.00
5229	749	19	1	42000.00
5230	749	14	2	37000.00
5231	749	30	1	38000.00
5232	749	35	1	38000.00
5233	750	51	3	20000.00
5234	750	25	2	40000.00
5235	750	13	2	35000.00
5236	750	13	1	35000.00
5237	750	46	3	45000.00
5238	750	14	1	37000.00
5239	750	41	3	45000.00
5240	751	44	2	45000.00
5241	751	54	1	50000.00
5242	751	51	1	20000.00
5243	751	11	1	30000.00
5244	751	11	2	30000.00
5245	751	26	2	40000.00
5246	751	54	2	50000.00
5247	752	10	2	35000.00
5248	752	23	1	40000.00
5249	752	43	1	40000.00
5250	752	55	2	35000.00
5251	752	24	3	40000.00
5252	752	3	3	32000.00
5253	752	16	3	38000.00
5254	753	47	2	45000.00
5255	753	34	1	40000.00
5256	753	56	1	38000.00
5257	753	11	3	30000.00
5258	753	51	1	20000.00
5259	753	43	1	40000.00
5260	753	3	3	32000.00
5261	754	50	1	35000.00
5262	754	32	1	40000.00
5263	754	54	3	50000.00
5264	754	20	3	42000.00
5265	754	7	2	42000.00
5266	754	18	1	45000.00
5267	754	12	1	32000.00
5268	755	21	3	42000.00
5269	755	20	1	42000.00
5270	755	36	3	40000.00
5271	755	24	2	40000.00
5272	755	34	1	40000.00
5273	755	15	1	42000.00
5274	755	21	1	42000.00
5275	756	37	1	40000.00
5276	756	16	2	38000.00
5277	756	35	2	38000.00
5278	756	16	3	38000.00
5279	756	26	2	40000.00
5280	756	38	1	40000.00
5281	756	21	2	42000.00
5282	757	18	3	45000.00
5283	757	50	2	35000.00
5284	757	25	2	40000.00
5285	757	47	3	45000.00
5286	757	22	1	42000.00
5287	757	32	3	40000.00
5288	757	43	1	40000.00
5289	758	13	1	35000.00
5290	758	18	3	45000.00
5291	758	30	1	38000.00
5292	758	24	2	40000.00
5293	758	55	1	35000.00
5294	758	15	3	42000.00
5295	758	22	1	42000.00
5296	759	53	3	35000.00
5297	759	55	3	35000.00
5298	759	12	1	32000.00
5299	759	29	2	48000.00
5300	759	53	3	35000.00
5301	759	35	2	38000.00
5302	759	19	3	42000.00
5303	760	12	1	32000.00
5304	760	38	3	40000.00
5305	760	5	2	40000.00
5306	760	41	2	45000.00
5307	760	11	1	30000.00
5308	760	30	1	38000.00
5309	760	24	1	40000.00
5310	761	9	3	45000.00
5311	761	23	3	40000.00
5312	761	21	3	42000.00
5313	761	38	2	40000.00
5314	761	20	1	42000.00
5315	761	13	1	35000.00
5316	761	2	2	30000.00
5317	762	19	3	42000.00
5318	762	20	1	42000.00
5319	762	15	1	42000.00
5320	762	44	3	45000.00
5321	762	33	3	35000.00
5322	762	42	3	42000.00
5323	762	26	3	40000.00
5324	763	9	3	45000.00
5325	763	54	3	50000.00
5326	763	20	1	42000.00
5327	763	2	1	30000.00
5328	763	25	1	40000.00
5329	763	37	3	40000.00
5330	763	11	2	30000.00
5331	764	45	1	45000.00
5332	764	29	3	48000.00
5333	764	35	2	38000.00
5334	764	7	2	42000.00
5335	764	49	2	35000.00
5336	764	21	3	42000.00
5337	764	55	2	35000.00
5338	765	17	3	42000.00
5339	765	20	1	42000.00
5340	765	38	2	40000.00
5341	765	32	1	40000.00
5342	765	4	2	40000.00
5343	765	20	1	42000.00
5344	765	39	1	45000.00
5345	766	29	2	48000.00
5346	766	37	2	40000.00
5347	766	39	1	45000.00
5348	766	50	2	35000.00
5349	766	55	1	35000.00
5350	766	52	1	38000.00
5351	766	42	3	42000.00
5352	767	6	2	40000.00
5353	767	52	3	38000.00
5354	767	30	2	38000.00
5355	767	25	1	40000.00
5356	767	18	3	45000.00
5357	767	12	1	32000.00
5358	767	30	2	38000.00
5359	768	33	1	35000.00
5360	768	3	1	32000.00
5361	768	14	3	37000.00
5362	768	52	3	38000.00
5363	768	2	2	30000.00
5364	768	52	1	38000.00
5365	768	11	3	30000.00
5366	769	2	2	30000.00
5367	769	16	3	38000.00
5368	769	32	2	40000.00
5369	769	49	1	35000.00
5370	769	4	1	40000.00
5371	769	6	1	40000.00
5372	769	47	1	45000.00
5373	770	44	3	45000.00
5374	770	24	3	40000.00
5375	770	21	2	42000.00
5376	770	27	3	45000.00
5377	770	29	3	48000.00
5378	770	54	2	50000.00
5379	770	43	1	40000.00
5380	771	15	2	42000.00
5381	771	30	2	38000.00
5382	771	32	3	40000.00
5383	771	13	1	35000.00
5384	771	40	2	38000.00
5385	771	50	1	35000.00
5386	771	35	1	38000.00
5387	772	39	3	45000.00
5388	772	46	2	45000.00
5389	772	19	1	42000.00
5390	772	14	1	37000.00
5391	772	33	3	35000.00
5392	772	5	1	40000.00
5393	772	22	2	42000.00
5394	773	44	2	45000.00
5395	773	14	2	37000.00
5396	773	20	1	42000.00
5397	773	31	3	42000.00
5398	773	42	2	42000.00
5399	773	49	1	35000.00
5400	773	20	1	42000.00
5401	774	10	2	35000.00
5402	774	54	3	50000.00
5403	774	35	2	38000.00
5404	774	20	1	42000.00
5405	774	49	1	35000.00
5406	774	17	3	42000.00
5407	774	54	3	50000.00
5408	775	2	1	30000.00
5409	775	34	1	40000.00
5410	775	23	2	40000.00
5411	775	25	1	40000.00
5412	775	48	1	45000.00
5413	775	38	1	40000.00
5414	775	16	3	38000.00
5415	776	16	1	38000.00
5416	776	38	3	40000.00
5417	776	23	2	40000.00
5418	776	19	1	42000.00
5419	776	5	2	40000.00
5420	776	21	2	42000.00
5421	776	53	3	35000.00
5422	777	15	1	42000.00
5423	777	30	3	38000.00
5424	777	32	1	40000.00
5425	777	15	3	42000.00
5426	777	36	2	40000.00
5427	777	55	2	35000.00
5428	777	31	1	42000.00
5429	778	34	1	40000.00
5430	778	51	3	20000.00
5431	778	6	1	40000.00
5432	778	27	3	45000.00
5433	778	15	3	42000.00
5434	778	6	2	40000.00
5435	778	12	1	32000.00
5436	779	8	2	45000.00
5437	779	48	1	45000.00
5438	779	38	1	40000.00
5439	779	48	3	45000.00
5440	779	48	2	45000.00
5441	779	3	1	32000.00
5442	779	6	1	40000.00
5443	780	45	1	45000.00
5444	780	10	3	35000.00
5445	780	38	3	40000.00
5446	780	34	2	40000.00
5447	780	35	3	38000.00
5448	780	15	2	42000.00
5449	780	23	2	40000.00
5450	781	31	1	42000.00
5451	781	43	1	40000.00
5452	781	26	2	40000.00
5453	781	29	2	48000.00
5454	781	42	3	42000.00
5455	781	3	3	32000.00
5456	781	21	2	42000.00
5457	782	46	3	45000.00
5458	782	11	2	30000.00
5459	782	43	2	40000.00
5460	782	9	2	45000.00
5461	782	52	1	38000.00
5462	782	19	1	42000.00
5463	782	16	2	38000.00
5464	783	46	2	45000.00
5465	783	36	1	40000.00
5466	783	46	1	45000.00
5467	783	56	1	38000.00
5468	783	25	2	40000.00
5469	783	54	2	50000.00
5470	783	24	3	40000.00
5471	784	8	2	45000.00
5472	784	22	1	42000.00
5473	784	18	3	45000.00
5474	784	19	1	42000.00
5475	784	14	3	37000.00
5476	784	34	2	40000.00
5477	784	48	3	45000.00
5478	785	48	3	45000.00
5479	785	36	1	40000.00
5480	785	13	3	35000.00
5481	785	39	3	45000.00
5482	785	29	1	48000.00
5483	785	10	1	35000.00
5484	785	23	1	40000.00
5485	786	46	2	45000.00
5486	786	6	3	40000.00
5487	786	3	1	32000.00
5488	786	32	3	40000.00
5489	786	38	3	40000.00
5490	786	11	1	30000.00
5491	786	39	3	45000.00
5492	787	44	1	45000.00
5493	787	9	1	45000.00
5494	787	1	2	42000.00
5495	787	6	2	40000.00
5496	787	38	3	40000.00
5497	787	11	2	30000.00
5498	787	1	1	42000.00
5499	788	28	2	45000.00
5500	788	10	3	35000.00
5501	788	46	2	45000.00
5502	788	19	1	42000.00
5503	788	32	2	40000.00
5504	788	19	2	42000.00
5505	788	43	1	40000.00
5506	789	46	3	45000.00
5507	789	23	3	40000.00
5508	789	23	3	40000.00
5509	789	11	1	30000.00
5510	789	51	2	20000.00
5511	789	41	3	45000.00
5512	789	12	2	32000.00
5513	790	50	3	35000.00
5514	790	39	3	45000.00
5515	790	45	2	45000.00
5516	790	37	1	40000.00
5517	790	48	1	45000.00
5518	790	27	3	45000.00
5519	790	4	3	40000.00
5520	791	39	3	45000.00
5521	791	33	2	35000.00
5522	791	5	3	40000.00
5523	791	21	1	42000.00
5524	791	50	1	35000.00
5525	791	32	2	40000.00
5526	791	50	2	35000.00
5527	792	36	2	40000.00
5528	792	19	1	42000.00
5529	792	35	3	38000.00
5530	792	32	3	40000.00
5531	792	23	1	40000.00
5532	792	18	3	45000.00
5533	792	7	2	42000.00
5534	793	56	3	38000.00
5535	793	51	2	20000.00
5536	793	49	3	35000.00
5537	793	28	1	45000.00
5538	793	10	3	35000.00
5539	793	41	3	45000.00
5540	793	11	1	30000.00
5541	794	46	2	45000.00
5542	794	49	1	35000.00
5543	794	5	1	40000.00
5544	794	42	1	42000.00
5545	794	43	3	40000.00
5546	794	34	2	40000.00
5547	794	2	3	30000.00
5548	795	18	1	45000.00
5549	795	42	2	42000.00
5550	795	27	1	45000.00
5551	795	12	2	32000.00
5552	795	55	2	35000.00
5553	795	54	3	50000.00
5554	795	20	1	42000.00
5555	796	18	1	45000.00
5556	796	38	1	40000.00
5557	796	28	3	45000.00
5558	796	24	3	40000.00
5559	796	48	2	45000.00
5560	796	1	1	42000.00
5561	796	32	1	40000.00
5562	797	47	2	45000.00
5563	797	1	3	42000.00
5564	797	8	3	45000.00
5565	797	10	3	35000.00
5566	797	23	3	40000.00
5567	797	26	3	40000.00
5568	797	11	1	30000.00
5569	798	30	1	38000.00
5570	798	10	1	35000.00
5571	798	16	2	38000.00
5572	798	37	1	40000.00
5573	798	8	1	45000.00
5574	798	48	1	45000.00
5575	798	29	2	48000.00
5576	799	24	2	40000.00
5577	799	7	2	42000.00
5578	799	20	2	42000.00
5579	799	7	1	42000.00
5580	799	28	1	45000.00
5581	799	26	1	40000.00
5582	799	5	2	40000.00
5583	800	34	2	40000.00
5584	800	3	3	32000.00
5585	800	26	3	40000.00
5586	800	21	2	42000.00
5587	800	53	3	35000.00
5588	800	47	1	45000.00
5589	800	47	1	45000.00
5590	801	29	1	48000.00
5591	801	9	3	45000.00
5592	801	12	1	32000.00
5593	801	43	2	40000.00
5594	801	31	1	42000.00
5595	801	21	1	42000.00
5596	801	15	1	42000.00
5597	802	43	3	40000.00
5598	802	14	2	37000.00
5599	802	22	3	42000.00
5600	802	8	3	45000.00
5601	802	15	2	42000.00
5602	802	26	1	40000.00
5603	802	27	1	45000.00
5604	803	45	3	45000.00
5605	803	5	1	40000.00
5606	803	40	2	38000.00
5607	803	19	3	42000.00
5608	803	25	3	40000.00
5609	803	2	3	30000.00
5610	803	38	2	40000.00
5611	804	11	2	30000.00
5612	804	52	1	38000.00
5613	804	6	3	40000.00
5614	804	11	3	30000.00
5615	804	18	3	45000.00
5616	804	37	3	40000.00
5617	804	16	1	38000.00
5618	805	38	1	40000.00
5619	805	55	3	35000.00
5620	805	42	1	42000.00
5621	805	1	1	42000.00
5622	805	19	3	42000.00
5623	805	23	2	40000.00
5624	805	23	2	40000.00
5625	806	41	2	45000.00
5626	806	13	2	35000.00
5627	806	55	3	35000.00
5628	806	19	1	42000.00
5629	806	19	1	42000.00
5630	806	51	2	20000.00
5631	806	27	3	45000.00
5632	807	46	3	45000.00
5633	807	26	2	40000.00
5634	807	31	3	42000.00
5635	807	21	2	42000.00
5636	807	44	1	45000.00
5637	807	29	3	48000.00
5638	807	46	1	45000.00
5639	808	45	3	45000.00
5640	808	45	2	45000.00
5641	808	8	2	45000.00
5642	808	50	3	35000.00
5643	808	5	1	40000.00
5644	808	15	1	42000.00
5645	808	24	2	40000.00
5646	809	32	1	40000.00
5647	809	26	3	40000.00
5648	809	49	1	35000.00
5649	809	4	2	40000.00
5650	809	40	2	38000.00
5651	809	55	1	35000.00
5652	809	12	2	32000.00
5653	810	51	2	20000.00
5654	810	23	2	40000.00
5655	810	23	1	40000.00
5656	810	36	1	40000.00
5657	810	3	3	32000.00
5658	810	8	2	45000.00
5659	810	38	3	40000.00
5660	811	41	2	45000.00
5661	811	43	2	40000.00
5662	811	48	1	45000.00
5663	811	40	3	38000.00
5664	811	37	2	40000.00
5665	811	7	1	42000.00
5666	811	44	2	45000.00
5667	812	14	3	37000.00
5668	812	34	2	40000.00
5669	812	42	3	42000.00
5670	812	41	2	45000.00
5671	812	24	2	40000.00
5672	812	6	3	40000.00
5673	812	16	3	38000.00
5674	813	40	2	38000.00
5675	813	28	2	45000.00
5676	813	34	2	40000.00
5677	813	20	3	42000.00
5678	813	33	3	35000.00
5679	813	15	2	42000.00
5680	813	16	3	38000.00
5681	814	49	2	35000.00
5682	814	54	1	50000.00
5683	814	34	3	40000.00
5684	814	21	1	42000.00
5685	814	56	1	38000.00
5686	814	22	2	42000.00
5687	814	12	2	32000.00
5688	815	19	2	42000.00
5689	815	21	2	42000.00
5690	815	30	2	38000.00
5691	815	22	1	42000.00
5692	815	39	3	45000.00
5693	815	38	1	40000.00
5694	815	4	1	40000.00
5695	816	18	3	45000.00
5696	816	40	3	38000.00
5697	816	49	2	35000.00
5698	816	48	3	45000.00
5699	816	11	2	30000.00
5700	816	27	3	45000.00
5701	816	37	1	40000.00
5702	817	17	1	42000.00
5703	817	37	3	40000.00
5704	817	2	3	30000.00
5705	817	32	2	40000.00
5706	817	21	2	42000.00
5707	817	40	3	38000.00
5708	817	12	2	32000.00
5709	818	28	1	45000.00
5710	818	44	2	45000.00
5711	818	30	2	38000.00
5712	818	46	3	45000.00
5713	818	53	1	35000.00
5714	818	5	1	40000.00
5715	818	51	1	20000.00
5716	819	42	3	42000.00
5717	819	7	2	42000.00
5718	819	29	2	48000.00
5719	819	41	2	45000.00
5720	819	13	3	35000.00
5721	819	24	2	40000.00
5722	819	31	1	42000.00
5723	820	55	2	35000.00
5724	820	7	2	42000.00
5725	820	7	1	42000.00
5726	820	34	2	40000.00
5727	820	7	3	42000.00
5728	820	52	2	38000.00
5729	820	26	2	40000.00
5730	821	49	1	35000.00
5731	821	37	1	40000.00
5732	821	24	2	40000.00
5733	821	53	1	35000.00
5734	821	34	2	40000.00
5735	821	24	3	40000.00
5736	821	4	1	40000.00
5737	822	28	1	45000.00
5738	822	40	1	38000.00
5739	822	55	2	35000.00
5740	822	49	1	35000.00
5741	822	42	3	42000.00
5742	822	36	2	40000.00
5743	822	16	3	38000.00
5744	823	47	1	45000.00
5745	823	12	2	32000.00
5746	823	1	2	42000.00
5747	823	29	3	48000.00
5748	823	39	2	45000.00
5749	823	5	3	40000.00
5750	823	5	1	40000.00
5751	824	4	2	40000.00
5752	824	18	2	45000.00
5753	824	9	2	45000.00
5754	824	9	2	45000.00
5755	824	51	3	20000.00
5756	824	2	3	30000.00
5757	824	9	2	45000.00
5758	825	23	1	40000.00
5759	825	43	3	40000.00
5760	825	38	2	40000.00
5761	825	20	2	42000.00
5762	825	18	1	45000.00
5763	825	55	1	35000.00
5764	825	6	1	40000.00
5765	826	2	3	30000.00
5766	826	52	1	38000.00
5767	826	55	3	35000.00
5768	826	23	3	40000.00
5769	826	41	3	45000.00
5770	826	6	1	40000.00
5771	826	54	1	50000.00
5772	827	41	2	45000.00
5773	827	40	3	38000.00
5774	827	43	2	40000.00
5775	827	50	1	35000.00
5776	827	37	2	40000.00
5777	827	46	2	45000.00
5778	827	47	2	45000.00
5779	828	7	1	42000.00
5780	828	29	1	48000.00
5781	829	37	1	40000.00
5782	829	29	1	48000.00
5783	829	9	1	45000.00
5784	830	21	2	42000.00
5785	830	42	1	42000.00
5786	831	53	1	35000.00
5787	831	55	1	35000.00
5788	831	37	1	40000.00
5789	831	39	1	45000.00
5790	832	7	1	42000.00
5791	833	7	1	42000.00
5792	833	9	1	45000.00
\.


--
-- TOC entry 3528 (class 0 OID 16656)
-- Dependencies: 228
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, table_id, status, total, created_at) FROM stdin;
62	118	paid	558000.00	2025-01-01 16:42:46
63	52	paid	516000.00	2025-01-05 17:09:53
64	100	paid	556000.00	2025-01-13 17:17:13
1	112	paid	87000.00	2025-11-22 22:07:35.760754
65	13	paid	398000.00	2025-01-11 18:11:32
2	112	paid	45000.00	2025-11-22 22:15:33.494756
3	75	paid	505000.00	2025-01-19 18:06:34
4	22	paid	673000.00	2025-01-25 10:10:38
5	2	paid	622000.00	2025-01-08 09:46:04
6	51	paid	594000.00	2025-01-08 14:32:05
7	60	paid	674000.00	2025-01-06 08:56:29
8	109	paid	539000.00	2025-01-11 19:10:45
9	91	paid	498000.00	2025-01-28 08:38:56
10	10	paid	512000.00	2025-01-26 19:45:05
11	110	paid	570000.00	2025-01-05 19:24:29
12	5	paid	750000.00	2025-01-15 16:04:08
13	85	paid	709000.00	2025-01-04 08:15:32
14	79	paid	497000.00	2025-01-11 17:04:15
15	115	paid	525000.00	2025-01-02 11:15:13
16	88	paid	682000.00	2025-01-18 08:44:07
17	114	paid	657000.00	2025-01-25 09:51:23
18	115	paid	588000.00	2025-01-06 15:18:11
19	32	paid	597000.00	2025-01-26 08:38:11
20	92	paid	595000.00	2025-01-22 10:53:06
21	73	paid	554000.00	2025-01-21 13:06:39
22	89	paid	573000.00	2025-01-28 17:43:09
23	34	paid	604000.00	2025-01-25 16:53:45
24	112	paid	581000.00	2025-01-21 18:09:38
25	33	paid	761000.00	2025-01-19 19:01:12
26	38	paid	632000.00	2025-01-03 12:30:43
27	71	paid	589000.00	2025-01-03 10:32:40
28	112	paid	479000.00	2025-01-11 09:37:31
29	83	paid	687000.00	2025-01-14 13:58:55
30	56	paid	630000.00	2025-01-16 16:19:27
31	41	paid	476000.00	2025-01-06 18:51:05
32	92	paid	444000.00	2025-01-21 17:06:37
33	49	paid	509000.00	2025-01-27 08:55:01
34	51	paid	529000.00	2025-01-12 10:35:19
35	120	paid	576000.00	2025-01-10 11:57:09
36	103	paid	679000.00	2025-01-09 09:22:11
37	101	paid	611000.00	2025-01-22 17:20:18
38	20	paid	598000.00	2025-01-21 19:15:02
39	58	paid	476000.00	2025-01-24 10:07:02
40	15	paid	571000.00	2025-01-21 10:40:27
41	61	paid	642000.00	2025-01-07 16:55:12
42	68	paid	646000.00	2025-01-06 14:41:52
43	100	paid	465000.00	2025-01-03 19:00:31
44	40	paid	691000.00	2025-01-07 18:46:30
45	39	paid	594000.00	2025-01-12 18:58:51
46	59	paid	575000.00	2025-01-06 18:29:07
47	111	paid	559000.00	2025-01-13 18:09:11
48	113	paid	461000.00	2025-01-28 13:10:01
49	13	paid	690000.00	2025-01-23 14:40:21
50	50	paid	442000.00	2025-01-23 16:49:41
51	62	paid	473000.00	2025-01-10 15:56:29
52	114	paid	551000.00	2025-01-20 11:17:07
53	15	paid	543000.00	2025-01-25 12:11:16
54	117	paid	444000.00	2025-01-21 16:36:52
55	27	paid	719000.00	2025-01-18 12:34:10
56	20	paid	549000.00	2025-01-01 18:13:19
57	110	paid	356000.00	2025-01-10 14:26:06
58	81	paid	645000.00	2025-01-26 12:10:44
59	33	paid	442000.00	2025-01-01 17:21:42
60	33	paid	595000.00	2025-01-16 16:35:33
61	86	paid	552000.00	2025-01-09 09:25:02
66	83	paid	496000.00	2025-01-27 16:48:40
67	94	paid	493000.00	2025-01-17 08:17:12
68	74	paid	594000.00	2025-01-08 18:46:36
69	60	paid	454000.00	2025-01-19 10:34:56
70	101	paid	557000.00	2025-01-03 18:38:42
71	65	paid	537000.00	2025-01-10 11:11:15
72	43	paid	663000.00	2025-01-21 08:01:03
73	65	paid	627000.00	2025-01-16 15:15:49
74	32	paid	769000.00	2025-01-17 12:49:42
75	37	paid	575000.00	2025-01-12 15:15:38
76	19	paid	595000.00	2025-01-24 12:36:57
77	38	paid	497000.00	2025-01-05 11:51:31
78	83	paid	484000.00	2025-02-02 08:10:15
79	33	paid	515000.00	2025-02-03 12:25:58
80	93	paid	598000.00	2025-02-17 11:38:11
81	5	paid	543000.00	2025-02-10 16:53:40
82	4	paid	385000.00	2025-02-22 11:24:40
83	41	paid	418000.00	2025-02-10 15:13:27
84	96	paid	530000.00	2025-02-13 13:15:09
85	45	paid	597000.00	2025-02-03 12:14:11
86	67	paid	450000.00	2025-02-20 11:23:47
87	83	paid	518000.00	2025-02-19 14:24:12
88	19	paid	514000.00	2025-02-07 13:46:28
89	37	paid	422000.00	2025-02-07 09:29:23
90	69	paid	563000.00	2025-02-28 13:14:15
91	91	paid	514000.00	2025-02-07 13:53:04
92	92	paid	543000.00	2025-02-02 19:02:31
93	83	paid	563000.00	2025-02-05 11:44:29
94	62	paid	564000.00	2025-02-24 10:50:51
95	64	paid	498000.00	2025-02-15 18:23:36
96	48	paid	483000.00	2025-02-09 13:10:44
97	78	paid	407000.00	2025-02-22 11:58:32
98	110	paid	676000.00	2025-02-02 15:04:33
99	11	paid	769000.00	2025-02-02 09:11:22
100	60	paid	589000.00	2025-02-12 16:02:24
101	9	paid	639000.00	2025-02-05 09:51:43
102	69	paid	455000.00	2025-02-17 12:34:28
103	83	paid	455000.00	2025-02-19 15:41:06
104	35	paid	706000.00	2025-02-03 19:48:25
105	5	paid	476000.00	2025-02-14 14:07:18
106	35	paid	553000.00	2025-02-27 17:12:15
107	6	paid	488000.00	2025-02-19 14:25:32
108	50	paid	569000.00	2025-02-19 19:29:48
109	41	paid	513000.00	2025-02-17 16:55:16
110	37	paid	572000.00	2025-02-08 13:01:56
111	62	paid	496000.00	2025-02-06 15:07:43
112	93	paid	404000.00	2025-02-06 12:55:14
113	59	paid	532000.00	2025-02-17 19:10:43
114	37	paid	442000.00	2025-02-09 17:17:35
115	98	paid	640000.00	2025-02-06 09:30:12
116	15	paid	504000.00	2025-02-18 09:47:31
117	33	paid	495000.00	2025-02-09 16:56:24
118	4	paid	501000.00	2025-02-05 16:15:07
119	37	paid	608000.00	2025-02-14 13:56:36
120	25	paid	420000.00	2025-02-08 11:07:26
121	89	paid	760000.00	2025-02-05 12:26:33
122	39	paid	550000.00	2025-02-22 09:14:26
123	1	paid	649000.00	2025-02-21 15:07:57
124	38	paid	722000.00	2025-02-04 14:32:40
125	58	paid	416000.00	2025-02-26 11:01:56
126	110	paid	734000.00	2025-02-01 15:02:08
127	65	paid	503000.00	2025-02-14 16:16:07
128	7	paid	534000.00	2025-02-24 16:45:15
129	20	paid	615000.00	2025-02-09 09:48:13
130	77	paid	485000.00	2025-02-13 08:50:16
131	107	paid	519000.00	2025-02-11 12:07:34
132	37	paid	599000.00	2025-02-13 17:22:44
133	83	paid	469000.00	2025-02-23 12:12:47
134	25	paid	783000.00	2025-02-14 19:18:02
135	44	paid	534000.00	2025-02-15 10:37:01
136	20	paid	529000.00	2025-02-26 14:09:20
137	50	paid	602000.00	2025-02-28 18:08:12
138	120	paid	532000.00	2025-02-23 10:42:33
139	22	paid	471000.00	2025-02-02 08:05:50
140	1	paid	497000.00	2025-02-28 16:42:31
141	114	paid	584000.00	2025-02-14 09:55:29
142	64	paid	581000.00	2025-02-07 09:33:09
143	63	paid	414000.00	2025-02-10 16:14:03
144	3	paid	607000.00	2025-02-07 16:23:46
145	51	paid	496000.00	2025-02-22 19:07:45
146	19	paid	460000.00	2025-02-08 09:24:03
147	115	paid	480000.00	2025-02-09 17:55:34
148	48	paid	465000.00	2025-02-05 19:27:17
149	11	paid	575000.00	2025-02-15 15:49:47
150	20	paid	537000.00	2025-02-13 10:57:51
151	55	paid	503000.00	2025-02-27 14:56:14
152	86	paid	481000.00	2025-02-17 15:20:37
153	44	paid	618000.00	2025-03-22 09:24:49
154	67	paid	575000.00	2025-03-05 19:50:18
155	44	paid	527000.00	2025-03-01 10:44:53
156	76	paid	658000.00	2025-03-23 08:55:54
157	111	paid	583000.00	2025-03-07 10:22:02
158	92	paid	659000.00	2025-03-28 13:34:01
159	50	paid	524000.00	2025-03-09 17:16:53
160	26	paid	708000.00	2025-03-16 17:04:19
161	46	paid	644000.00	2025-03-21 09:44:49
162	12	paid	595000.00	2025-03-08 16:47:09
163	91	paid	485000.00	2025-03-14 17:06:33
164	18	paid	629000.00	2025-03-17 11:21:21
165	89	paid	481000.00	2025-03-17 12:01:08
166	22	paid	708000.00	2025-03-24 13:05:58
167	37	paid	506000.00	2025-03-06 12:13:29
168	85	paid	541000.00	2025-03-12 19:50:02
169	86	paid	450000.00	2025-03-09 12:10:52
170	95	paid	645000.00	2025-03-24 14:04:04
171	86	paid	659000.00	2025-03-20 09:53:23
172	66	paid	602000.00	2025-03-16 18:35:44
173	68	paid	550000.00	2025-03-13 12:04:27
174	15	paid	798000.00	2025-03-15 08:19:32
175	81	paid	692000.00	2025-03-26 15:58:40
176	50	paid	873000.00	2025-03-28 16:44:41
177	95	paid	731000.00	2025-03-22 08:18:07
178	2	paid	632000.00	2025-03-07 15:51:29
179	30	paid	555000.00	2025-03-26 08:17:28
180	13	paid	343000.00	2025-03-12 14:10:39
181	40	paid	635000.00	2025-03-17 16:02:29
182	70	paid	525000.00	2025-03-27 17:26:41
183	7	paid	435000.00	2025-03-08 09:11:34
184	91	paid	705000.00	2025-03-19 12:10:31
185	6	paid	694000.00	2025-03-24 11:08:46
186	40	paid	604000.00	2025-03-18 15:48:39
187	40	paid	382000.00	2025-03-06 14:01:12
188	47	paid	513000.00	2025-03-17 18:52:10
189	38	paid	590000.00	2025-03-04 08:26:03
190	36	paid	693000.00	2025-03-09 08:05:17
191	36	paid	505000.00	2025-03-09 10:50:05
192	48	paid	707000.00	2025-03-15 11:43:26
193	96	paid	564000.00	2025-03-23 16:10:26
194	92	paid	669000.00	2025-03-27 08:45:50
195	91	paid	501000.00	2025-03-09 15:23:43
196	103	paid	686000.00	2025-03-22 12:52:34
197	94	paid	405000.00	2025-03-03 17:51:46
198	32	paid	385000.00	2025-03-12 12:20:56
199	25	paid	640000.00	2025-03-18 19:56:40
200	71	paid	648000.00	2025-03-22 18:33:04
201	45	paid	510000.00	2025-03-19 18:45:30
202	73	paid	479000.00	2025-03-03 18:04:45
203	7	paid	570000.00	2025-03-14 19:23:52
204	81	paid	522000.00	2025-03-26 16:35:17
205	9	paid	513000.00	2025-03-06 14:08:10
206	56	paid	438000.00	2025-03-27 19:32:35
207	108	paid	476000.00	2025-03-21 17:21:07
208	100	paid	631000.00	2025-03-26 12:39:04
209	62	paid	445000.00	2025-03-27 18:36:30
210	108	paid	650000.00	2025-03-28 13:49:07
211	60	paid	499000.00	2025-03-13 16:11:53
212	46	paid	345000.00	2025-03-21 14:47:46
213	4	paid	555000.00	2025-03-22 12:57:21
214	84	paid	459000.00	2025-03-07 18:45:23
215	55	paid	576000.00	2025-03-07 14:05:48
216	63	paid	613000.00	2025-03-17 13:52:03
217	77	paid	506000.00	2025-03-19 10:10:01
218	101	paid	608000.00	2025-03-24 11:15:19
219	55	paid	645000.00	2025-03-21 16:25:43
220	113	paid	631000.00	2025-03-03 13:13:36
221	38	paid	626000.00	2025-03-17 13:21:13
222	94	paid	498000.00	2025-03-27 14:02:54
223	119	paid	672000.00	2025-03-19 08:19:19
224	15	paid	451000.00	2025-03-21 14:40:58
225	37	paid	573000.00	2025-03-12 08:43:42
226	103	paid	342000.00	2025-03-20 18:05:10
227	57	paid	500000.00	2025-03-23 09:07:52
228	13	paid	396000.00	2025-04-22 19:52:21
229	56	paid	582000.00	2025-04-06 16:39:25
230	92	paid	669000.00	2025-04-09 11:14:43
231	36	paid	591000.00	2025-04-04 18:13:57
232	11	paid	440000.00	2025-04-25 19:27:36
233	77	paid	538000.00	2025-04-06 16:12:45
234	21	paid	637000.00	2025-04-14 08:07:39
235	43	paid	596000.00	2025-04-06 17:44:06
236	58	paid	691000.00	2025-04-14 17:32:01
237	49	paid	327000.00	2025-04-20 11:52:24
238	106	paid	496000.00	2025-04-06 15:48:04
239	69	paid	681000.00	2025-04-08 17:49:47
240	71	paid	468000.00	2025-04-19 16:19:19
241	16	paid	532000.00	2025-04-03 11:46:15
242	114	paid	374000.00	2025-04-24 17:26:23
243	78	paid	594000.00	2025-04-07 19:40:01
244	11	paid	467000.00	2025-04-18 12:05:41
245	82	paid	466000.00	2025-04-20 17:41:43
246	47	paid	658000.00	2025-04-10 08:09:54
247	23	paid	674000.00	2025-04-11 14:21:04
248	28	paid	519000.00	2025-04-17 13:27:03
249	46	paid	427000.00	2025-04-23 19:04:27
250	119	paid	394000.00	2025-04-23 16:01:25
251	88	paid	562000.00	2025-04-23 11:41:47
252	28	paid	572000.00	2025-04-12 13:41:27
253	3	paid	530000.00	2025-04-11 09:19:26
254	94	paid	592000.00	2025-04-13 11:44:30
255	97	paid	569000.00	2025-04-17 12:39:43
256	58	paid	471000.00	2025-04-20 16:33:38
257	112	paid	650000.00	2025-04-17 16:44:07
258	28	paid	560000.00	2025-04-16 18:07:49
259	42	paid	593000.00	2025-04-20 18:06:02
260	78	paid	512000.00	2025-04-07 11:48:07
261	114	paid	514000.00	2025-04-03 10:20:25
262	20	paid	782000.00	2025-04-08 18:15:09
263	16	paid	477000.00	2025-04-12 13:57:47
264	57	paid	422000.00	2025-04-15 17:36:36
265	14	paid	364000.00	2025-04-01 08:47:24
266	102	paid	416000.00	2025-04-10 16:09:49
267	99	paid	439000.00	2025-04-14 09:18:34
268	116	paid	593000.00	2025-04-03 17:57:28
269	50	paid	701000.00	2025-04-14 09:11:15
270	47	paid	446000.00	2025-04-11 19:20:32
271	33	paid	579000.00	2025-04-23 09:26:23
272	100	paid	410000.00	2025-04-18 08:04:34
273	74	paid	582000.00	2025-04-14 13:17:36
274	82	paid	626000.00	2025-04-02 14:23:06
275	10	paid	476000.00	2025-04-19 13:36:43
276	22	paid	453000.00	2025-04-02 08:09:20
277	35	paid	531000.00	2025-04-26 14:15:32
278	74	paid	671000.00	2025-04-08 16:12:31
279	20	paid	470000.00	2025-04-27 14:53:53
280	51	paid	657000.00	2025-04-13 18:14:00
281	97	paid	467000.00	2025-04-07 08:57:31
282	97	paid	492000.00	2025-04-17 08:29:48
283	59	paid	706000.00	2025-04-18 15:00:51
284	45	paid	609000.00	2025-04-16 16:49:24
285	118	paid	609000.00	2025-04-12 13:25:57
286	50	paid	567000.00	2025-04-12 12:41:34
287	51	paid	680000.00	2025-04-06 09:13:35
288	113	paid	471000.00	2025-04-12 19:32:42
289	101	paid	477000.00	2025-04-01 19:38:35
290	104	paid	566000.00	2025-04-27 13:46:20
291	52	paid	646000.00	2025-04-08 11:05:39
292	3	paid	544000.00	2025-04-08 17:03:38
293	44	paid	360000.00	2025-04-04 13:16:12
294	79	paid	605000.00	2025-04-20 13:24:44
295	77	paid	471000.00	2025-04-02 11:05:51
296	104	paid	517000.00	2025-04-09 08:04:32
297	35	paid	332000.00	2025-04-19 19:49:00
298	111	paid	760000.00	2025-04-20 16:51:03
299	63	paid	521000.00	2025-04-26 18:39:44
300	27	paid	658000.00	2025-04-08 14:52:31
301	31	paid	574000.00	2025-04-01 15:33:15
302	103	paid	462000.00	2025-04-10 10:52:10
303	21	paid	694000.00	2025-05-05 17:52:54
304	92	paid	550000.00	2025-05-05 15:29:49
305	84	paid	509000.00	2025-05-21 08:31:52
306	72	paid	475000.00	2025-05-18 09:39:16
307	77	paid	583000.00	2025-05-01 12:33:25
308	86	paid	525000.00	2025-05-28 10:25:52
309	68	paid	598000.00	2025-05-10 19:29:58
310	42	paid	457000.00	2025-05-10 12:38:28
311	42	paid	607000.00	2025-05-21 15:27:37
312	12	paid	307000.00	2025-05-05 12:18:57
313	60	paid	640000.00	2025-05-14 12:07:09
314	75	paid	541000.00	2025-05-21 16:23:22
315	98	paid	588000.00	2025-05-08 11:40:35
316	52	paid	641000.00	2025-05-12 08:38:45
317	56	paid	442000.00	2025-05-04 12:47:23
318	109	paid	615000.00	2025-05-21 15:38:53
319	69	paid	399000.00	2025-05-11 19:45:32
320	113	paid	482000.00	2025-05-11 08:36:36
321	91	paid	458000.00	2025-05-02 11:37:21
322	69	paid	682000.00	2025-05-01 13:35:17
323	8	paid	724000.00	2025-05-18 13:24:27
324	85	paid	630000.00	2025-05-13 19:50:09
325	72	paid	627000.00	2025-05-08 19:20:31
326	83	paid	594000.00	2025-05-01 11:35:34
327	116	paid	690000.00	2025-05-15 08:35:37
328	115	paid	523000.00	2025-05-14 18:06:55
329	48	paid	614000.00	2025-05-23 16:28:25
330	80	paid	620000.00	2025-05-25 14:19:32
331	114	paid	560000.00	2025-05-28 16:57:25
332	61	paid	632000.00	2025-05-20 16:47:55
333	106	paid	508000.00	2025-05-15 15:26:33
334	55	paid	617000.00	2025-05-08 08:46:45
335	41	paid	411000.00	2025-05-02 14:55:42
336	22	paid	624000.00	2025-05-21 19:11:41
337	38	paid	466000.00	2025-05-27 13:47:31
338	74	paid	585000.00	2025-05-14 13:49:30
339	81	paid	463000.00	2025-05-13 13:20:43
340	47	paid	584000.00	2025-05-24 09:23:20
341	32	paid	587000.00	2025-05-05 13:34:55
342	16	paid	607000.00	2025-05-07 17:14:24
343	30	paid	530000.00	2025-05-01 10:09:37
344	71	paid	559000.00	2025-05-02 10:07:10
345	116	paid	521000.00	2025-05-23 15:34:34
346	78	paid	418000.00	2025-05-11 11:01:58
347	58	paid	524000.00	2025-05-04 12:38:49
348	18	paid	494000.00	2025-05-23 08:48:35
349	64	paid	553000.00	2025-05-16 11:36:10
350	2	paid	557000.00	2025-05-13 18:58:51
351	68	paid	726000.00	2025-05-08 14:44:44
352	58	paid	595000.00	2025-05-04 12:21:52
353	54	paid	534000.00	2025-05-10 10:19:05
354	80	paid	526000.00	2025-05-05 10:06:49
355	119	paid	752000.00	2025-05-09 09:07:28
356	49	paid	560000.00	2025-05-11 19:19:28
357	90	paid	372000.00	2025-05-17 10:53:34
358	61	paid	689000.00	2025-05-08 15:18:04
359	109	paid	591000.00	2025-05-10 15:51:48
360	51	paid	588000.00	2025-05-22 15:31:29
361	4	paid	508000.00	2025-05-09 14:56:44
362	64	paid	666000.00	2025-05-11 14:30:07
363	96	paid	416000.00	2025-05-02 11:29:26
364	67	paid	593000.00	2025-05-10 08:41:03
365	53	paid	507000.00	2025-05-27 11:47:54
366	35	paid	625000.00	2025-05-21 13:25:08
367	36	paid	635000.00	2025-05-25 12:34:29
368	90	paid	585000.00	2025-05-28 13:07:05
369	26	paid	467000.00	2025-05-13 16:49:19
370	12	paid	379000.00	2025-05-09 13:57:08
371	57	paid	442000.00	2025-05-11 09:20:45
372	63	paid	497000.00	2025-05-08 13:30:05
373	95	paid	499000.00	2025-05-19 09:57:04
374	86	paid	612000.00	2025-05-09 14:32:46
375	14	paid	435000.00	2025-05-14 12:30:48
376	112	paid	604000.00	2025-05-01 12:42:32
377	51	paid	532000.00	2025-05-03 16:12:21
378	27	paid	530000.00	2025-06-07 14:57:13
379	101	paid	576000.00	2025-06-04 13:01:56
380	37	paid	669000.00	2025-06-24 16:17:58
381	30	paid	835000.00	2025-06-20 18:31:39
382	75	paid	554000.00	2025-06-06 10:50:43
383	118	paid	534000.00	2025-06-14 15:36:18
384	35	paid	716000.00	2025-06-03 19:08:16
385	43	paid	585000.00	2025-06-04 14:13:27
386	83	paid	548000.00	2025-06-19 09:21:22
387	113	paid	427000.00	2025-06-17 15:56:02
388	11	paid	512000.00	2025-06-23 12:11:11
389	58	paid	514000.00	2025-06-20 09:43:22
390	27	paid	435000.00	2025-06-09 17:01:24
391	54	paid	565000.00	2025-06-02 11:00:28
392	107	paid	740000.00	2025-06-15 19:31:14
393	105	paid	558000.00	2025-06-27 14:34:34
394	73	paid	505000.00	2025-06-04 11:36:28
395	4	paid	564000.00	2025-06-13 11:24:14
396	51	paid	458000.00	2025-06-10 12:26:00
397	43	paid	558000.00	2025-06-19 17:29:46
398	72	paid	536000.00	2025-06-11 13:56:08
399	75	paid	439000.00	2025-06-02 08:47:14
400	39	paid	564000.00	2025-06-23 12:46:29
401	119	paid	506000.00	2025-06-19 09:53:55
402	93	paid	569000.00	2025-06-07 13:43:47
403	56	paid	641000.00	2025-06-16 17:40:51
404	46	paid	475000.00	2025-06-20 16:44:47
405	42	paid	492000.00	2025-06-12 17:49:10
406	15	paid	757000.00	2025-06-12 08:41:25
407	36	paid	657000.00	2025-06-07 16:38:55
408	49	paid	622000.00	2025-06-14 15:27:40
409	77	paid	749000.00	2025-06-02 10:08:49
410	20	paid	568000.00	2025-06-23 13:04:31
411	64	paid	760000.00	2025-06-09 12:33:30
412	13	paid	682000.00	2025-06-20 08:13:10
413	59	paid	648000.00	2025-06-12 18:19:12
414	76	paid	493000.00	2025-06-06 10:58:47
415	73	paid	567000.00	2025-06-04 09:21:05
416	59	paid	534000.00	2025-06-20 13:26:22
417	65	paid	578000.00	2025-06-07 14:09:01
418	86	paid	695000.00	2025-06-09 13:28:50
419	16	paid	414000.00	2025-06-28 19:10:07
420	12	paid	615000.00	2025-06-22 18:57:06
421	4	paid	735000.00	2025-06-13 19:53:02
422	77	paid	613000.00	2025-06-20 11:16:30
423	110	paid	543000.00	2025-06-05 16:58:33
424	100	paid	518000.00	2025-06-01 11:31:51
425	4	paid	536000.00	2025-06-26 12:52:36
426	14	paid	436000.00	2025-06-01 17:38:20
427	56	paid	463000.00	2025-06-02 08:34:37
428	63	paid	744000.00	2025-06-23 18:19:21
429	70	paid	563000.00	2025-06-02 14:28:38
430	83	paid	566000.00	2025-06-08 13:32:39
431	111	paid	616000.00	2025-06-01 16:09:06
432	103	paid	618000.00	2025-06-05 09:55:49
433	22	paid	621000.00	2025-06-15 13:04:51
434	72	paid	648000.00	2025-06-12 09:57:09
435	109	paid	389000.00	2025-06-10 12:48:39
436	16	paid	610000.00	2025-06-20 16:30:02
437	52	paid	654000.00	2025-06-08 17:07:39
438	70	paid	405000.00	2025-06-08 10:16:20
439	60	paid	544000.00	2025-06-19 16:00:16
440	114	paid	408000.00	2025-06-10 11:38:03
441	15	paid	542000.00	2025-06-05 08:15:21
442	41	paid	492000.00	2025-06-02 12:55:43
443	107	paid	514000.00	2025-06-01 08:20:13
444	39	paid	558000.00	2025-06-11 10:51:10
445	68	paid	808000.00	2025-06-11 14:10:07
446	85	paid	552000.00	2025-06-27 19:43:35
447	46	paid	752000.00	2025-06-27 14:11:33
448	42	paid	587000.00	2025-06-28 10:32:26
449	22	paid	438000.00	2025-06-02 09:17:23
450	107	paid	503000.00	2025-06-05 09:50:31
451	32	paid	606000.00	2025-06-27 13:17:37
452	116	paid	570000.00	2025-06-22 13:43:38
453	83	paid	644000.00	2025-07-24 13:14:11
454	56	paid	511000.00	2025-07-01 17:07:41
455	10	paid	377000.00	2025-07-07 17:22:17
456	45	paid	722000.00	2025-07-10 16:40:47
457	43	paid	498000.00	2025-07-17 15:04:42
458	117	paid	410000.00	2025-07-13 14:13:20
459	18	paid	574000.00	2025-07-28 08:54:24
460	80	paid	587000.00	2025-07-11 17:13:41
461	51	paid	443000.00	2025-07-27 10:16:50
462	85	paid	483000.00	2025-07-27 08:44:37
463	50	paid	635000.00	2025-07-14 11:11:30
464	5	paid	467000.00	2025-07-13 15:08:38
465	44	paid	544000.00	2025-07-14 16:03:30
466	107	paid	636000.00	2025-07-27 14:11:48
467	114	paid	643000.00	2025-07-27 14:45:49
468	102	paid	566000.00	2025-07-14 09:03:10
469	69	paid	576000.00	2025-07-02 17:36:12
470	42	paid	538000.00	2025-07-12 16:43:28
471	56	paid	614000.00	2025-07-26 16:14:27
472	115	paid	387000.00	2025-07-03 12:50:05
473	17	paid	578000.00	2025-07-08 11:42:50
474	18	paid	666000.00	2025-07-05 16:05:15
475	106	paid	542000.00	2025-07-18 19:58:39
476	84	paid	458000.00	2025-07-16 17:02:53
477	29	paid	472000.00	2025-07-10 11:49:39
478	63	paid	569000.00	2025-07-18 13:25:04
479	112	paid	851000.00	2025-07-15 09:55:06
480	27	paid	492000.00	2025-07-28 10:15:23
481	86	paid	430000.00	2025-07-23 18:01:51
482	30	paid	493000.00	2025-07-23 14:32:56
483	7	paid	446000.00	2025-07-22 16:37:09
484	113	paid	640000.00	2025-07-27 17:10:48
485	45	paid	524000.00	2025-07-14 10:40:43
486	85	paid	605000.00	2025-07-13 17:12:32
487	39	paid	608000.00	2025-07-07 09:38:30
488	11	paid	571000.00	2025-07-21 11:26:51
489	109	paid	445000.00	2025-07-28 09:12:50
490	115	paid	511000.00	2025-07-25 15:08:54
491	26	paid	637000.00	2025-07-08 09:03:56
492	2	paid	534000.00	2025-07-01 14:42:21
493	35	paid	537000.00	2025-07-15 18:15:37
494	113	paid	620000.00	2025-07-20 10:31:03
495	10	paid	620000.00	2025-07-23 11:08:09
496	46	paid	628000.00	2025-07-15 14:21:28
497	39	paid	511000.00	2025-07-16 18:04:48
498	39	paid	588000.00	2025-07-26 15:44:19
499	79	paid	555000.00	2025-07-16 15:01:45
500	100	paid	438000.00	2025-07-01 15:17:30
501	65	paid	430000.00	2025-07-12 17:01:32
502	18	paid	613000.00	2025-07-15 13:41:40
503	116	paid	444000.00	2025-07-17 12:46:08
504	4	paid	599000.00	2025-07-09 18:18:54
505	77	paid	512000.00	2025-07-28 11:19:45
506	32	paid	612000.00	2025-07-18 09:46:05
507	90	paid	490000.00	2025-07-01 16:34:14
508	81	paid	551000.00	2025-07-28 18:13:33
509	40	paid	557000.00	2025-07-11 16:42:53
510	81	paid	535000.00	2025-07-17 10:02:49
511	81	paid	614000.00	2025-07-26 13:02:36
512	48	paid	573000.00	2025-07-20 19:11:16
513	8	paid	450000.00	2025-07-17 09:46:46
514	32	paid	649000.00	2025-07-08 08:33:13
515	43	paid	709000.00	2025-07-09 09:11:48
516	114	paid	545000.00	2025-07-28 15:53:11
517	19	paid	559000.00	2025-07-11 10:24:44
518	56	paid	483000.00	2025-07-23 13:09:54
519	94	paid	664000.00	2025-07-08 10:30:39
520	77	paid	485000.00	2025-07-15 16:04:37
521	49	paid	497000.00	2025-07-17 19:17:25
522	63	paid	481000.00	2025-07-24 10:39:00
523	27	paid	482000.00	2025-07-04 12:18:02
524	1	paid	496000.00	2025-07-27 13:55:18
525	50	paid	495000.00	2025-07-05 18:50:30
526	65	paid	427000.00	2025-07-23 10:53:39
527	63	paid	418000.00	2025-07-06 12:18:14
528	10	paid	696000.00	2025-08-20 15:44:50
529	78	paid	552000.00	2025-08-14 13:14:11
530	10	paid	463000.00	2025-08-03 13:39:21
531	16	paid	604000.00	2025-08-26 12:50:28
532	18	paid	438000.00	2025-08-19 14:45:38
533	95	paid	601000.00	2025-08-01 13:52:37
534	117	paid	510000.00	2025-08-18 10:44:37
535	49	paid	574000.00	2025-08-11 17:58:06
536	67	paid	568000.00	2025-08-09 14:49:56
537	1	paid	577000.00	2025-08-17 19:01:12
538	33	paid	692000.00	2025-08-16 09:54:25
539	53	paid	551000.00	2025-08-06 09:14:31
540	18	paid	502000.00	2025-08-02 18:16:20
541	29	paid	541000.00	2025-08-06 19:52:18
542	50	paid	584000.00	2025-08-03 17:34:15
543	96	paid	597000.00	2025-08-05 18:22:18
544	64	paid	613000.00	2025-08-03 13:51:43
545	58	paid	581000.00	2025-08-12 09:57:20
546	16	paid	511000.00	2025-08-20 18:17:09
547	75	paid	628000.00	2025-08-03 19:13:17
548	96	paid	503000.00	2025-08-20 13:53:06
549	62	paid	594000.00	2025-08-06 19:11:38
550	74	paid	633000.00	2025-08-17 15:24:43
551	18	paid	516000.00	2025-08-25 11:33:53
552	76	paid	449000.00	2025-08-24 11:58:03
553	15	paid	562000.00	2025-08-23 17:06:56
554	3	paid	746000.00	2025-08-24 14:36:01
555	22	paid	560000.00	2025-08-15 13:35:51
556	40	paid	560000.00	2025-08-24 16:30:40
557	115	paid	609000.00	2025-08-27 09:20:42
558	119	paid	472000.00	2025-08-25 14:20:15
559	82	paid	626000.00	2025-08-02 16:40:03
560	56	paid	475000.00	2025-08-09 15:10:12
561	41	paid	430000.00	2025-08-26 15:40:44
562	57	paid	533000.00	2025-08-11 15:32:14
563	76	paid	651000.00	2025-08-08 12:28:39
564	71	paid	594000.00	2025-08-24 10:15:18
565	65	paid	297000.00	2025-08-19 18:54:33
566	117	paid	507000.00	2025-08-21 18:44:57
567	65	paid	443000.00	2025-08-24 12:16:34
568	15	paid	619000.00	2025-08-28 15:08:02
569	65	paid	467000.00	2025-08-26 17:08:17
570	69	paid	604000.00	2025-08-18 17:18:33
571	40	paid	517000.00	2025-08-02 09:15:49
572	67	paid	431000.00	2025-08-28 16:02:34
573	12	paid	594000.00	2025-08-22 12:33:08
574	119	paid	571000.00	2025-08-26 11:57:38
575	36	paid	573000.00	2025-08-12 16:44:23
576	98	paid	585000.00	2025-08-06 08:26:54
577	55	paid	657000.00	2025-08-20 14:01:08
578	25	paid	562000.00	2025-08-04 14:00:01
579	109	paid	501000.00	2025-08-27 11:38:31
580	68	paid	508000.00	2025-08-18 18:39:11
581	60	paid	455000.00	2025-08-19 13:35:21
582	10	paid	524000.00	2025-08-09 12:56:40
583	92	paid	493000.00	2025-08-27 14:34:49
584	99	paid	562000.00	2025-08-02 17:42:53
585	78	paid	529000.00	2025-08-10 12:19:17
586	96	paid	695000.00	2025-08-17 17:22:18
587	95	paid	412000.00	2025-08-04 15:27:50
588	35	paid	550000.00	2025-08-23 16:17:32
589	30	paid	629000.00	2025-08-22 10:45:51
590	49	paid	579000.00	2025-08-09 11:27:57
591	9	paid	545000.00	2025-08-01 08:50:36
592	102	paid	441000.00	2025-08-03 08:24:25
593	58	paid	630000.00	2025-08-09 13:22:55
594	77	paid	641000.00	2025-08-08 16:33:03
595	28	paid	524000.00	2025-08-10 09:26:25
596	103	paid	656000.00	2025-08-23 18:30:18
597	118	paid	506000.00	2025-08-28 19:33:50
598	3	paid	408000.00	2025-08-16 09:03:12
599	75	paid	677000.00	2025-08-06 15:22:58
600	35	paid	628000.00	2025-08-15 17:07:56
601	82	paid	508000.00	2025-08-25 17:47:13
602	54	paid	713000.00	2025-08-04 15:21:36
603	61	paid	548000.00	2025-09-08 12:49:58
604	44	paid	543000.00	2025-09-28 15:34:13
605	43	paid	500000.00	2025-09-26 19:36:14
606	104	paid	535000.00	2025-09-21 11:10:40
607	55	paid	522000.00	2025-09-22 17:34:25
608	81	paid	462000.00	2025-09-16 12:27:03
609	70	paid	483000.00	2025-09-13 19:06:02
610	61	paid	537000.00	2025-09-05 09:26:58
611	25	paid	600000.00	2025-09-17 10:21:45
612	31	paid	586000.00	2025-09-03 12:21:55
613	119	paid	487000.00	2025-09-09 16:31:52
614	36	paid	562000.00	2025-09-27 12:54:23
615	58	paid	569000.00	2025-09-11 14:57:49
616	10	paid	763000.00	2025-09-26 12:36:26
617	67	paid	461000.00	2025-09-17 13:19:54
618	14	paid	450000.00	2025-09-13 16:34:21
619	34	paid	550000.00	2025-09-21 13:48:26
620	7	paid	545000.00	2025-09-01 18:21:09
621	57	paid	506000.00	2025-09-07 15:50:13
622	96	paid	706000.00	2025-09-20 11:43:52
623	76	paid	583000.00	2025-09-15 12:19:29
624	47	paid	625000.00	2025-09-12 14:37:55
625	9	paid	430000.00	2025-09-23 11:47:52
626	115	paid	520000.00	2025-09-17 13:14:49
627	91	paid	476000.00	2025-09-16 13:41:00
628	80	paid	436000.00	2025-09-22 19:32:45
629	33	paid	614000.00	2025-09-01 18:06:21
630	32	paid	554000.00	2025-09-26 18:26:24
631	87	paid	679000.00	2025-09-17 10:52:12
632	102	paid	472000.00	2025-09-12 16:19:34
633	55	paid	600000.00	2025-09-13 13:45:08
634	89	paid	497000.00	2025-09-14 14:47:23
635	99	paid	505000.00	2025-09-10 08:31:51
636	5	paid	473000.00	2025-09-10 18:05:40
637	12	paid	607000.00	2025-09-12 12:24:21
638	104	paid	544000.00	2025-09-12 08:11:11
639	95	paid	548000.00	2025-09-11 14:27:11
640	51	paid	637000.00	2025-09-27 09:03:09
641	63	paid	566000.00	2025-09-26 17:50:09
642	87	paid	441000.00	2025-09-03 09:33:01
643	83	paid	463000.00	2025-09-21 09:37:10
644	46	paid	638000.00	2025-09-15 09:50:19
645	53	paid	645000.00	2025-09-28 12:20:54
646	117	paid	457000.00	2025-09-09 19:50:57
647	75	paid	554000.00	2025-09-17 12:36:21
648	73	paid	373000.00	2025-09-26 11:18:08
649	26	paid	566000.00	2025-09-03 17:24:38
650	70	paid	468000.00	2025-09-10 14:01:34
651	73	paid	553000.00	2025-09-17 08:26:06
652	3	paid	599000.00	2025-09-19 18:17:14
653	71	paid	644000.00	2025-09-10 16:45:53
654	1	paid	555000.00	2025-09-02 09:43:40
655	17	paid	518000.00	2025-09-17 12:40:28
656	119	paid	382000.00	2025-09-09 15:24:19
657	118	paid	660000.00	2025-09-04 08:21:05
658	79	paid	640000.00	2025-09-27 17:19:37
659	41	paid	477000.00	2025-09-03 15:18:09
660	91	paid	543000.00	2025-09-20 19:17:27
661	91	paid	625000.00	2025-09-03 17:57:32
662	115	paid	465000.00	2025-09-01 17:11:30
663	54	paid	612000.00	2025-09-12 14:26:47
664	87	paid	502000.00	2025-09-20 17:46:15
665	80	paid	678000.00	2025-09-08 17:27:16
666	115	paid	592000.00	2025-09-03 14:55:50
667	7	paid	519000.00	2025-09-23 17:22:57
668	84	paid	556000.00	2025-09-04 14:36:51
669	86	paid	491000.00	2025-09-23 14:43:15
670	83	paid	586000.00	2025-09-17 10:50:09
671	59	paid	708000.00	2025-09-17 19:22:01
672	108	paid	570000.00	2025-09-02 12:33:16
673	1	paid	574000.00	2025-09-22 19:02:58
674	107	paid	576000.00	2025-09-15 13:57:02
675	7	paid	599000.00	2025-09-11 11:29:56
676	102	paid	486000.00	2025-09-17 13:24:18
677	36	paid	549000.00	2025-09-12 12:07:26
678	57	paid	693000.00	2025-10-10 19:29:36
679	23	paid	557000.00	2025-10-27 14:01:56
680	96	paid	435000.00	2025-10-10 15:20:50
681	23	paid	456000.00	2025-10-11 14:08:42
682	118	paid	603000.00	2025-10-09 11:47:06
683	17	paid	594000.00	2025-10-04 18:09:07
684	86	paid	618000.00	2025-10-28 17:50:40
685	114	paid	530000.00	2025-10-08 19:55:33
686	4	paid	683000.00	2025-10-18 14:02:33
687	7	paid	680000.00	2025-10-18 17:50:39
688	61	paid	571000.00	2025-10-10 19:01:10
689	115	paid	545000.00	2025-10-11 08:20:33
690	110	paid	642000.00	2025-10-05 11:57:32
691	117	paid	534000.00	2025-10-13 13:42:48
692	57	paid	510000.00	2025-10-17 11:20:00
693	69	paid	594000.00	2025-10-03 08:38:20
694	93	paid	547000.00	2025-10-08 10:19:55
695	35	paid	684000.00	2025-10-24 19:08:01
696	109	paid	374000.00	2025-10-24 14:11:49
697	57	paid	639000.00	2025-10-19 10:43:53
698	45	paid	592000.00	2025-10-17 11:34:30
699	38	paid	630000.00	2025-10-01 09:35:35
700	63	paid	647000.00	2025-10-04 15:23:12
701	120	paid	600000.00	2025-10-06 09:02:06
702	36	paid	632000.00	2025-10-02 10:06:30
703	21	paid	630000.00	2025-10-16 12:26:01
704	3	paid	599000.00	2025-10-19 11:35:39
705	49	paid	602000.00	2025-10-02 13:25:56
706	29	paid	383000.00	2025-10-10 19:55:17
707	1	paid	449000.00	2025-10-05 08:21:57
708	36	paid	559000.00	2025-10-16 13:44:44
709	105	paid	604000.00	2025-10-20 08:52:08
710	71	paid	558000.00	2025-10-28 17:53:17
711	84	paid	645000.00	2025-10-18 13:42:37
712	80	paid	512000.00	2025-10-15 09:14:47
713	92	paid	523000.00	2025-10-09 09:40:00
714	63	paid	475000.00	2025-10-21 13:15:05
715	87	paid	716000.00	2025-10-21 08:49:23
716	36	paid	530000.00	2025-10-11 12:24:56
717	1	paid	734000.00	2025-10-19 09:30:48
718	73	paid	545000.00	2025-10-19 18:47:12
719	73	paid	645000.00	2025-10-02 16:25:53
720	88	paid	537000.00	2025-10-23 17:35:06
721	80	paid	504000.00	2025-10-07 17:49:15
722	52	paid	652000.00	2025-10-11 17:18:38
723	79	paid	392000.00	2025-10-04 11:16:52
724	63	paid	490000.00	2025-10-28 19:48:13
725	81	paid	414000.00	2025-10-28 18:18:12
726	12	paid	405000.00	2025-10-23 08:37:16
727	19	paid	591000.00	2025-10-11 18:50:27
728	29	paid	624000.00	2025-10-23 14:10:45
729	44	paid	514000.00	2025-10-13 14:13:23
730	63	paid	701000.00	2025-10-25 19:22:34
731	75	paid	491000.00	2025-10-11 10:56:28
732	116	paid	582000.00	2025-10-14 17:41:06
733	106	paid	583000.00	2025-10-14 13:15:36
734	12	paid	596000.00	2025-10-12 15:36:46
735	27	paid	547000.00	2025-10-03 19:21:11
736	59	paid	648000.00	2025-10-06 08:06:43
737	102	paid	571000.00	2025-10-28 15:31:49
738	7	paid	457000.00	2025-10-06 14:00:10
739	37	paid	589000.00	2025-10-16 19:29:46
740	95	paid	542000.00	2025-10-10 13:17:35
741	11	paid	613000.00	2025-10-02 11:58:15
742	58	paid	645000.00	2025-10-10 17:52:12
743	2	paid	637000.00	2025-10-28 15:09:04
744	77	paid	460000.00	2025-10-04 14:30:42
745	72	paid	426000.00	2025-10-01 15:44:42
746	61	paid	707000.00	2025-10-22 10:45:44
747	40	paid	476000.00	2025-10-27 10:36:08
748	107	paid	530000.00	2025-10-09 09:33:47
749	111	paid	502000.00	2025-10-27 17:11:57
750	100	paid	552000.00	2025-10-24 11:08:33
751	72	paid	430000.00	2025-10-16 16:13:57
752	31	paid	550000.00	2025-10-24 17:42:30
753	44	paid	414000.00	2025-11-01 09:48:23
754	58	paid	512000.00	2025-11-04 09:17:53
755	22	paid	492000.00	2025-11-16 19:38:09
756	107	paid	510000.00	2025-11-20 15:57:44
757	110	paid	622000.00	2025-11-19 10:19:05
758	18	paid	491000.00	2025-11-11 16:10:18
759	108	paid	645000.00	2025-11-20 09:43:03
760	71	paid	430000.00	2025-11-20 17:19:34
761	93	paid	598000.00	2025-11-10 13:13:23
762	17	paid	696000.00	2025-11-24 10:47:20
763	117	paid	577000.00	2025-11-20 11:23:43
764	88	paid	615000.00	2025-11-17 15:38:33
765	58	paid	455000.00	2025-11-24 12:38:30
766	53	paid	490000.00	2025-11-06 13:58:53
767	99	paid	553000.00	2025-11-01 12:35:39
768	38	paid	480000.00	2025-11-14 10:14:06
769	34	paid	414000.00	2025-11-13 19:13:23
770	83	paid	758000.00	2025-11-11 12:36:40
771	28	paid	464000.00	2025-11-14 18:51:07
772	44	paid	533000.00	2025-11-08 08:35:36
773	53	paid	493000.00	2025-11-15 18:37:14
774	40	paid	649000.00	2025-11-06 09:29:10
775	102	paid	389000.00	2025-11-20 14:04:23
776	106	paid	549000.00	2025-11-17 11:12:47
777	15	paid	514000.00	2025-11-19 11:56:49
778	76	paid	513000.00	2025-11-06 19:54:05
779	27	paid	472000.00	2025-11-17 09:57:33
780	71	paid	628000.00	2025-11-13 13:41:41
781	6	paid	564000.00	2025-11-26 19:46:21
782	61	paid	521000.00	2025-11-15 18:44:43
783	118	paid	513000.00	2025-11-19 13:24:17
784	4	paid	635000.00	2025-11-25 11:03:49
785	15	paid	538000.00	2025-11-25 08:14:27
786	16	paid	647000.00	2025-11-03 10:17:13
787	92	paid	476000.00	2025-11-19 18:15:05
788	76	paid	531000.00	2025-11-18 18:30:31
789	72	paid	644000.00	2025-11-25 10:08:25
790	115	paid	670000.00	2025-11-27 19:18:12
791	110	paid	552000.00	2025-11-03 14:13:06
792	40	paid	615000.00	2025-11-01 12:32:07
793	50	paid	574000.00	2025-11-01 19:06:34
794	99	paid	497000.00	2025-11-27 10:41:15
795	103	paid	500000.00	2025-11-27 15:14:34
796	84	paid	512000.00	2025-11-18 10:14:54
797	101	paid	726000.00	2025-11-09 16:36:49
798	66	paid	375000.00	2025-11-26 14:31:03
799	81	paid	455000.00	2025-11-06 13:43:14
800	33	paid	575000.00	2025-11-13 19:36:17
801	65	paid	421000.00	2025-11-19 13:36:40
802	27	paid	624000.00	2025-11-08 15:24:04
803	27	paid	667000.00	2025-11-15 13:24:04
804	75	paid	601000.00	2025-11-02 13:09:27
805	91	paid	515000.00	2025-11-23 11:46:28
806	101	paid	524000.00	2025-11-10 11:14:49
807	62	paid	659000.00	2025-11-25 18:22:22
808	69	paid	582000.00	2025-11-22 15:21:26
809	16	paid	450000.00	2025-11-13 18:45:42
810	83	paid	506000.00	2025-11-17 09:49:22
811	96	paid	541000.00	2025-11-02 14:57:32
812	27	paid	721000.00	2025-11-26 19:38:13
813	13	paid	675000.00	2025-11-26 19:22:40
814	109	paid	468000.00	2025-11-12 09:32:53
815	74	paid	501000.00	2025-11-19 14:10:43
816	48	paid	689000.00	2025-11-14 14:19:29
817	63	paid	594000.00	2025-11-03 18:31:36
818	87	paid	441000.00	2025-11-13 09:55:56
819	28	paid	623000.00	2025-11-04 12:33:22
820	18	paid	558000.00	2025-11-05 16:24:07
821	112	paid	430000.00	2025-11-20 19:13:55
822	119	paid	508000.00	2025-11-20 17:55:44
823	9	paid	587000.00	2025-11-12 08:49:05
824	49	paid	590000.00	2025-11-01 14:49:14
825	40	paid	444000.00	2025-11-07 10:00:45
826	40	paid	578000.00	2025-11-18 12:27:03
827	60	paid	579000.00	2025-11-23 15:13:09
828	31	paid	90000.00	2025-11-23 10:13:44.996075
829	34	paid	133000.00	2025-11-23 21:26:18.009259
830	54	paid	126000.00	2025-11-23 21:39:09.263209
831	119	paid	155000.00	2025-11-24 06:39:02.67754
832	51	paid	42000.00	2025-11-24 09:00:45.735818
833	5	paid	87000.00	2025-12-06 09:10:15.293883
\.


--
-- TOC entry 3532 (class 0 OID 16690)
-- Dependencies: 232
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, order_id, amount, method, status, created_at) FROM stdin;
1	1	87000.00	cash	completed	2025-11-22 22:19:39.8427
2	2	45000.00	ewallet	completed	2025-11-22 22:20:04.560701
3	3	505000.00	cash	completed	2025-01-19 18:06:34
4	4	673000.00	cash	completed	2025-01-25 10:10:38
5	5	622000.00	cash	completed	2025-01-08 09:46:04
6	6	594000.00	cash	completed	2025-01-08 14:32:05
7	7	674000.00	cash	completed	2025-01-06 08:56:29
8	8	539000.00	cash	completed	2025-01-11 19:10:45
9	9	498000.00	cash	completed	2025-01-28 08:38:56
10	10	512000.00	cash	completed	2025-01-26 19:45:05
11	11	570000.00	cash	completed	2025-01-05 19:24:29
12	12	750000.00	cash	completed	2025-01-15 16:04:08
13	13	709000.00	cash	completed	2025-01-04 08:15:32
14	14	497000.00	cash	completed	2025-01-11 17:04:15
15	15	525000.00	cash	completed	2025-01-02 11:15:13
16	16	682000.00	cash	completed	2025-01-18 08:44:07
17	17	657000.00	cash	completed	2025-01-25 09:51:23
18	18	588000.00	cash	completed	2025-01-06 15:18:11
19	19	597000.00	cash	completed	2025-01-26 08:38:11
20	20	595000.00	cash	completed	2025-01-22 10:53:06
21	21	554000.00	cash	completed	2025-01-21 13:06:39
22	22	573000.00	cash	completed	2025-01-28 17:43:09
23	23	604000.00	cash	completed	2025-01-25 16:53:45
24	24	581000.00	cash	completed	2025-01-21 18:09:38
25	25	761000.00	cash	completed	2025-01-19 19:01:12
26	26	632000.00	cash	completed	2025-01-03 12:30:43
27	27	589000.00	cash	completed	2025-01-03 10:32:40
28	28	479000.00	cash	completed	2025-01-11 09:37:31
29	29	687000.00	cash	completed	2025-01-14 13:58:55
30	30	630000.00	cash	completed	2025-01-16 16:19:27
31	31	476000.00	cash	completed	2025-01-06 18:51:05
32	32	444000.00	cash	completed	2025-01-21 17:06:37
33	33	509000.00	cash	completed	2025-01-27 08:55:01
34	34	529000.00	cash	completed	2025-01-12 10:35:19
35	35	576000.00	cash	completed	2025-01-10 11:57:09
36	36	679000.00	cash	completed	2025-01-09 09:22:11
37	37	611000.00	cash	completed	2025-01-22 17:20:18
38	38	598000.00	cash	completed	2025-01-21 19:15:02
39	39	476000.00	cash	completed	2025-01-24 10:07:02
40	40	571000.00	cash	completed	2025-01-21 10:40:27
41	41	642000.00	cash	completed	2025-01-07 16:55:12
42	42	646000.00	cash	completed	2025-01-06 14:41:52
43	43	465000.00	cash	completed	2025-01-03 19:00:31
44	44	691000.00	cash	completed	2025-01-07 18:46:30
45	45	594000.00	cash	completed	2025-01-12 18:58:51
46	46	575000.00	cash	completed	2025-01-06 18:29:07
47	47	559000.00	cash	completed	2025-01-13 18:09:11
48	48	461000.00	cash	completed	2025-01-28 13:10:01
49	49	690000.00	cash	completed	2025-01-23 14:40:21
50	50	442000.00	cash	completed	2025-01-23 16:49:41
51	51	473000.00	cash	completed	2025-01-10 15:56:29
52	52	551000.00	cash	completed	2025-01-20 11:17:07
53	53	543000.00	cash	completed	2025-01-25 12:11:16
54	54	444000.00	cash	completed	2025-01-21 16:36:52
55	55	719000.00	cash	completed	2025-01-18 12:34:10
56	56	549000.00	cash	completed	2025-01-01 18:13:19
57	57	356000.00	cash	completed	2025-01-10 14:26:06
58	58	645000.00	cash	completed	2025-01-26 12:10:44
59	59	442000.00	cash	completed	2025-01-01 17:21:42
60	60	595000.00	cash	completed	2025-01-16 16:35:33
61	61	552000.00	cash	completed	2025-01-09 09:25:02
62	62	558000.00	cash	completed	2025-01-01 16:42:46
63	63	516000.00	cash	completed	2025-01-05 17:09:53
64	64	556000.00	cash	completed	2025-01-13 17:17:13
65	65	398000.00	cash	completed	2025-01-11 18:11:32
66	66	496000.00	cash	completed	2025-01-27 16:48:40
67	67	493000.00	cash	completed	2025-01-17 08:17:12
68	68	594000.00	cash	completed	2025-01-08 18:46:36
69	69	454000.00	cash	completed	2025-01-19 10:34:56
70	70	557000.00	cash	completed	2025-01-03 18:38:42
71	71	537000.00	cash	completed	2025-01-10 11:11:15
72	72	663000.00	cash	completed	2025-01-21 08:01:03
73	73	627000.00	cash	completed	2025-01-16 15:15:49
74	74	769000.00	cash	completed	2025-01-17 12:49:42
75	75	575000.00	cash	completed	2025-01-12 15:15:38
76	76	595000.00	cash	completed	2025-01-24 12:36:57
77	77	497000.00	cash	completed	2025-01-05 11:51:31
78	78	484000.00	cash	completed	2025-02-02 08:10:15
79	79	515000.00	cash	completed	2025-02-03 12:25:58
80	80	598000.00	cash	completed	2025-02-17 11:38:11
81	81	543000.00	cash	completed	2025-02-10 16:53:40
82	82	385000.00	cash	completed	2025-02-22 11:24:40
83	83	418000.00	cash	completed	2025-02-10 15:13:27
84	84	530000.00	cash	completed	2025-02-13 13:15:09
85	85	597000.00	cash	completed	2025-02-03 12:14:11
86	86	450000.00	cash	completed	2025-02-20 11:23:47
87	87	518000.00	cash	completed	2025-02-19 14:24:12
88	88	514000.00	cash	completed	2025-02-07 13:46:28
89	89	422000.00	cash	completed	2025-02-07 09:29:23
90	90	563000.00	cash	completed	2025-02-28 13:14:15
91	91	514000.00	cash	completed	2025-02-07 13:53:04
92	92	543000.00	cash	completed	2025-02-02 19:02:31
93	93	563000.00	cash	completed	2025-02-05 11:44:29
94	94	564000.00	cash	completed	2025-02-24 10:50:51
95	95	498000.00	cash	completed	2025-02-15 18:23:36
96	96	483000.00	cash	completed	2025-02-09 13:10:44
97	97	407000.00	cash	completed	2025-02-22 11:58:32
98	98	676000.00	cash	completed	2025-02-02 15:04:33
99	99	769000.00	cash	completed	2025-02-02 09:11:22
100	100	589000.00	cash	completed	2025-02-12 16:02:24
101	101	639000.00	cash	completed	2025-02-05 09:51:43
102	102	455000.00	cash	completed	2025-02-17 12:34:28
103	103	455000.00	cash	completed	2025-02-19 15:41:06
104	104	706000.00	cash	completed	2025-02-03 19:48:25
105	105	476000.00	cash	completed	2025-02-14 14:07:18
106	106	553000.00	cash	completed	2025-02-27 17:12:15
107	107	488000.00	cash	completed	2025-02-19 14:25:32
108	108	569000.00	cash	completed	2025-02-19 19:29:48
109	109	513000.00	cash	completed	2025-02-17 16:55:16
110	110	572000.00	cash	completed	2025-02-08 13:01:56
111	111	496000.00	cash	completed	2025-02-06 15:07:43
112	112	404000.00	cash	completed	2025-02-06 12:55:14
113	113	532000.00	cash	completed	2025-02-17 19:10:43
114	114	442000.00	cash	completed	2025-02-09 17:17:35
115	115	640000.00	cash	completed	2025-02-06 09:30:12
116	116	504000.00	cash	completed	2025-02-18 09:47:31
117	117	495000.00	cash	completed	2025-02-09 16:56:24
118	118	501000.00	cash	completed	2025-02-05 16:15:07
119	119	608000.00	cash	completed	2025-02-14 13:56:36
120	120	420000.00	cash	completed	2025-02-08 11:07:26
121	121	760000.00	cash	completed	2025-02-05 12:26:33
122	122	550000.00	cash	completed	2025-02-22 09:14:26
123	123	649000.00	cash	completed	2025-02-21 15:07:57
124	124	722000.00	cash	completed	2025-02-04 14:32:40
125	125	416000.00	cash	completed	2025-02-26 11:01:56
126	126	734000.00	cash	completed	2025-02-01 15:02:08
127	127	503000.00	cash	completed	2025-02-14 16:16:07
128	128	534000.00	cash	completed	2025-02-24 16:45:15
129	129	615000.00	cash	completed	2025-02-09 09:48:13
130	130	485000.00	cash	completed	2025-02-13 08:50:16
131	131	519000.00	cash	completed	2025-02-11 12:07:34
132	132	599000.00	cash	completed	2025-02-13 17:22:44
133	133	469000.00	cash	completed	2025-02-23 12:12:47
134	134	783000.00	cash	completed	2025-02-14 19:18:02
135	135	534000.00	cash	completed	2025-02-15 10:37:01
136	136	529000.00	cash	completed	2025-02-26 14:09:20
137	137	602000.00	cash	completed	2025-02-28 18:08:12
138	138	532000.00	cash	completed	2025-02-23 10:42:33
139	139	471000.00	cash	completed	2025-02-02 08:05:50
140	140	497000.00	cash	completed	2025-02-28 16:42:31
141	141	584000.00	cash	completed	2025-02-14 09:55:29
142	142	581000.00	cash	completed	2025-02-07 09:33:09
143	143	414000.00	cash	completed	2025-02-10 16:14:03
144	144	607000.00	cash	completed	2025-02-07 16:23:46
145	145	496000.00	cash	completed	2025-02-22 19:07:45
146	146	460000.00	cash	completed	2025-02-08 09:24:03
147	147	480000.00	cash	completed	2025-02-09 17:55:34
148	148	465000.00	cash	completed	2025-02-05 19:27:17
149	149	575000.00	cash	completed	2025-02-15 15:49:47
150	150	537000.00	cash	completed	2025-02-13 10:57:51
151	151	503000.00	cash	completed	2025-02-27 14:56:14
152	152	481000.00	cash	completed	2025-02-17 15:20:37
153	153	618000.00	cash	completed	2025-03-22 09:24:49
154	154	575000.00	cash	completed	2025-03-05 19:50:18
155	155	527000.00	cash	completed	2025-03-01 10:44:53
156	156	658000.00	cash	completed	2025-03-23 08:55:54
157	157	583000.00	cash	completed	2025-03-07 10:22:02
158	158	659000.00	cash	completed	2025-03-28 13:34:01
159	159	524000.00	cash	completed	2025-03-09 17:16:53
160	160	708000.00	cash	completed	2025-03-16 17:04:19
161	161	644000.00	cash	completed	2025-03-21 09:44:49
162	162	595000.00	cash	completed	2025-03-08 16:47:09
163	163	485000.00	cash	completed	2025-03-14 17:06:33
164	164	629000.00	cash	completed	2025-03-17 11:21:21
165	165	481000.00	cash	completed	2025-03-17 12:01:08
166	166	708000.00	cash	completed	2025-03-24 13:05:58
167	167	506000.00	cash	completed	2025-03-06 12:13:29
168	168	541000.00	cash	completed	2025-03-12 19:50:02
169	169	450000.00	cash	completed	2025-03-09 12:10:52
170	170	645000.00	cash	completed	2025-03-24 14:04:04
171	171	659000.00	cash	completed	2025-03-20 09:53:23
172	172	602000.00	cash	completed	2025-03-16 18:35:44
173	173	550000.00	cash	completed	2025-03-13 12:04:27
174	174	798000.00	cash	completed	2025-03-15 08:19:32
175	175	692000.00	cash	completed	2025-03-26 15:58:40
176	176	873000.00	cash	completed	2025-03-28 16:44:41
177	177	731000.00	cash	completed	2025-03-22 08:18:07
178	178	632000.00	cash	completed	2025-03-07 15:51:29
179	179	555000.00	cash	completed	2025-03-26 08:17:28
180	180	343000.00	cash	completed	2025-03-12 14:10:39
181	181	635000.00	cash	completed	2025-03-17 16:02:29
182	182	525000.00	cash	completed	2025-03-27 17:26:41
183	183	435000.00	cash	completed	2025-03-08 09:11:34
184	184	705000.00	cash	completed	2025-03-19 12:10:31
185	185	694000.00	cash	completed	2025-03-24 11:08:46
186	186	604000.00	cash	completed	2025-03-18 15:48:39
187	187	382000.00	cash	completed	2025-03-06 14:01:12
188	188	513000.00	cash	completed	2025-03-17 18:52:10
189	189	590000.00	cash	completed	2025-03-04 08:26:03
190	190	693000.00	cash	completed	2025-03-09 08:05:17
191	191	505000.00	cash	completed	2025-03-09 10:50:05
192	192	707000.00	cash	completed	2025-03-15 11:43:26
193	193	564000.00	cash	completed	2025-03-23 16:10:26
194	194	669000.00	cash	completed	2025-03-27 08:45:50
195	195	501000.00	cash	completed	2025-03-09 15:23:43
196	196	686000.00	cash	completed	2025-03-22 12:52:34
197	197	405000.00	cash	completed	2025-03-03 17:51:46
198	198	385000.00	cash	completed	2025-03-12 12:20:56
199	199	640000.00	cash	completed	2025-03-18 19:56:40
200	200	648000.00	cash	completed	2025-03-22 18:33:04
201	201	510000.00	cash	completed	2025-03-19 18:45:30
202	202	479000.00	cash	completed	2025-03-03 18:04:45
203	203	570000.00	cash	completed	2025-03-14 19:23:52
204	204	522000.00	cash	completed	2025-03-26 16:35:17
205	205	513000.00	cash	completed	2025-03-06 14:08:10
206	206	438000.00	cash	completed	2025-03-27 19:32:35
207	207	476000.00	cash	completed	2025-03-21 17:21:07
208	208	631000.00	cash	completed	2025-03-26 12:39:04
209	209	445000.00	cash	completed	2025-03-27 18:36:30
210	210	650000.00	cash	completed	2025-03-28 13:49:07
211	211	499000.00	cash	completed	2025-03-13 16:11:53
212	212	345000.00	cash	completed	2025-03-21 14:47:46
213	213	555000.00	cash	completed	2025-03-22 12:57:21
214	214	459000.00	cash	completed	2025-03-07 18:45:23
215	215	576000.00	cash	completed	2025-03-07 14:05:48
216	216	613000.00	cash	completed	2025-03-17 13:52:03
217	217	506000.00	cash	completed	2025-03-19 10:10:01
218	218	608000.00	cash	completed	2025-03-24 11:15:19
219	219	645000.00	cash	completed	2025-03-21 16:25:43
220	220	631000.00	cash	completed	2025-03-03 13:13:36
221	221	626000.00	cash	completed	2025-03-17 13:21:13
222	222	498000.00	cash	completed	2025-03-27 14:02:54
223	223	672000.00	cash	completed	2025-03-19 08:19:19
224	224	451000.00	cash	completed	2025-03-21 14:40:58
225	225	573000.00	cash	completed	2025-03-12 08:43:42
226	226	342000.00	cash	completed	2025-03-20 18:05:10
227	227	500000.00	cash	completed	2025-03-23 09:07:52
228	228	396000.00	cash	completed	2025-04-22 19:52:21
229	229	582000.00	cash	completed	2025-04-06 16:39:25
230	230	669000.00	cash	completed	2025-04-09 11:14:43
231	231	591000.00	cash	completed	2025-04-04 18:13:57
232	232	440000.00	cash	completed	2025-04-25 19:27:36
233	233	538000.00	cash	completed	2025-04-06 16:12:45
234	234	637000.00	cash	completed	2025-04-14 08:07:39
235	235	596000.00	cash	completed	2025-04-06 17:44:06
236	236	691000.00	cash	completed	2025-04-14 17:32:01
237	237	327000.00	cash	completed	2025-04-20 11:52:24
238	238	496000.00	cash	completed	2025-04-06 15:48:04
239	239	681000.00	cash	completed	2025-04-08 17:49:47
240	240	468000.00	cash	completed	2025-04-19 16:19:19
241	241	532000.00	cash	completed	2025-04-03 11:46:15
242	242	374000.00	cash	completed	2025-04-24 17:26:23
243	243	594000.00	cash	completed	2025-04-07 19:40:01
244	244	467000.00	cash	completed	2025-04-18 12:05:41
245	245	466000.00	cash	completed	2025-04-20 17:41:43
246	246	658000.00	cash	completed	2025-04-10 08:09:54
247	247	674000.00	cash	completed	2025-04-11 14:21:04
248	248	519000.00	cash	completed	2025-04-17 13:27:03
249	249	427000.00	cash	completed	2025-04-23 19:04:27
250	250	394000.00	cash	completed	2025-04-23 16:01:25
251	251	562000.00	cash	completed	2025-04-23 11:41:47
252	252	572000.00	cash	completed	2025-04-12 13:41:27
253	253	530000.00	cash	completed	2025-04-11 09:19:26
254	254	592000.00	cash	completed	2025-04-13 11:44:30
255	255	569000.00	cash	completed	2025-04-17 12:39:43
256	256	471000.00	cash	completed	2025-04-20 16:33:38
257	257	650000.00	cash	completed	2025-04-17 16:44:07
258	258	560000.00	cash	completed	2025-04-16 18:07:49
259	259	593000.00	cash	completed	2025-04-20 18:06:02
260	260	512000.00	cash	completed	2025-04-07 11:48:07
261	261	514000.00	cash	completed	2025-04-03 10:20:25
262	262	782000.00	cash	completed	2025-04-08 18:15:09
263	263	477000.00	cash	completed	2025-04-12 13:57:47
264	264	422000.00	cash	completed	2025-04-15 17:36:36
265	265	364000.00	cash	completed	2025-04-01 08:47:24
266	266	416000.00	cash	completed	2025-04-10 16:09:49
267	267	439000.00	cash	completed	2025-04-14 09:18:34
268	268	593000.00	cash	completed	2025-04-03 17:57:28
269	269	701000.00	cash	completed	2025-04-14 09:11:15
270	270	446000.00	cash	completed	2025-04-11 19:20:32
271	271	579000.00	cash	completed	2025-04-23 09:26:23
272	272	410000.00	cash	completed	2025-04-18 08:04:34
273	273	582000.00	cash	completed	2025-04-14 13:17:36
274	274	626000.00	cash	completed	2025-04-02 14:23:06
275	275	476000.00	cash	completed	2025-04-19 13:36:43
276	276	453000.00	cash	completed	2025-04-02 08:09:20
277	277	531000.00	cash	completed	2025-04-26 14:15:32
278	278	671000.00	cash	completed	2025-04-08 16:12:31
279	279	470000.00	cash	completed	2025-04-27 14:53:53
280	280	657000.00	cash	completed	2025-04-13 18:14:00
281	281	467000.00	cash	completed	2025-04-07 08:57:31
282	282	492000.00	cash	completed	2025-04-17 08:29:48
283	283	706000.00	cash	completed	2025-04-18 15:00:51
284	284	609000.00	cash	completed	2025-04-16 16:49:24
285	285	609000.00	cash	completed	2025-04-12 13:25:57
286	286	567000.00	cash	completed	2025-04-12 12:41:34
287	287	680000.00	cash	completed	2025-04-06 09:13:35
288	288	471000.00	cash	completed	2025-04-12 19:32:42
289	289	477000.00	cash	completed	2025-04-01 19:38:35
290	290	566000.00	cash	completed	2025-04-27 13:46:20
291	291	646000.00	cash	completed	2025-04-08 11:05:39
292	292	544000.00	cash	completed	2025-04-08 17:03:38
293	293	360000.00	cash	completed	2025-04-04 13:16:12
294	294	605000.00	cash	completed	2025-04-20 13:24:44
295	295	471000.00	cash	completed	2025-04-02 11:05:51
296	296	517000.00	cash	completed	2025-04-09 08:04:32
297	297	332000.00	cash	completed	2025-04-19 19:49:00
298	298	760000.00	cash	completed	2025-04-20 16:51:03
299	299	521000.00	cash	completed	2025-04-26 18:39:44
300	300	658000.00	cash	completed	2025-04-08 14:52:31
301	301	574000.00	cash	completed	2025-04-01 15:33:15
302	302	462000.00	cash	completed	2025-04-10 10:52:10
303	303	694000.00	cash	completed	2025-05-05 17:52:54
304	304	550000.00	cash	completed	2025-05-05 15:29:49
305	305	509000.00	cash	completed	2025-05-21 08:31:52
306	306	475000.00	cash	completed	2025-05-18 09:39:16
307	307	583000.00	cash	completed	2025-05-01 12:33:25
308	308	525000.00	cash	completed	2025-05-28 10:25:52
309	309	598000.00	cash	completed	2025-05-10 19:29:58
310	310	457000.00	cash	completed	2025-05-10 12:38:28
311	311	607000.00	cash	completed	2025-05-21 15:27:37
312	312	307000.00	cash	completed	2025-05-05 12:18:57
313	313	640000.00	cash	completed	2025-05-14 12:07:09
314	314	541000.00	cash	completed	2025-05-21 16:23:22
315	315	588000.00	cash	completed	2025-05-08 11:40:35
316	316	641000.00	cash	completed	2025-05-12 08:38:45
317	317	442000.00	cash	completed	2025-05-04 12:47:23
318	318	615000.00	cash	completed	2025-05-21 15:38:53
319	319	399000.00	cash	completed	2025-05-11 19:45:32
320	320	482000.00	cash	completed	2025-05-11 08:36:36
321	321	458000.00	cash	completed	2025-05-02 11:37:21
322	322	682000.00	cash	completed	2025-05-01 13:35:17
323	323	724000.00	cash	completed	2025-05-18 13:24:27
324	324	630000.00	cash	completed	2025-05-13 19:50:09
325	325	627000.00	cash	completed	2025-05-08 19:20:31
326	326	594000.00	cash	completed	2025-05-01 11:35:34
327	327	690000.00	cash	completed	2025-05-15 08:35:37
328	328	523000.00	cash	completed	2025-05-14 18:06:55
329	329	614000.00	cash	completed	2025-05-23 16:28:25
330	330	620000.00	cash	completed	2025-05-25 14:19:32
331	331	560000.00	cash	completed	2025-05-28 16:57:25
332	332	632000.00	cash	completed	2025-05-20 16:47:55
333	333	508000.00	cash	completed	2025-05-15 15:26:33
334	334	617000.00	cash	completed	2025-05-08 08:46:45
335	335	411000.00	cash	completed	2025-05-02 14:55:42
336	336	624000.00	cash	completed	2025-05-21 19:11:41
337	337	466000.00	cash	completed	2025-05-27 13:47:31
338	338	585000.00	cash	completed	2025-05-14 13:49:30
339	339	463000.00	cash	completed	2025-05-13 13:20:43
340	340	584000.00	cash	completed	2025-05-24 09:23:20
341	341	587000.00	cash	completed	2025-05-05 13:34:55
342	342	607000.00	cash	completed	2025-05-07 17:14:24
343	343	530000.00	cash	completed	2025-05-01 10:09:37
344	344	559000.00	cash	completed	2025-05-02 10:07:10
345	345	521000.00	cash	completed	2025-05-23 15:34:34
346	346	418000.00	cash	completed	2025-05-11 11:01:58
347	347	524000.00	cash	completed	2025-05-04 12:38:49
348	348	494000.00	cash	completed	2025-05-23 08:48:35
349	349	553000.00	cash	completed	2025-05-16 11:36:10
350	350	557000.00	cash	completed	2025-05-13 18:58:51
351	351	726000.00	cash	completed	2025-05-08 14:44:44
352	352	595000.00	cash	completed	2025-05-04 12:21:52
353	353	534000.00	cash	completed	2025-05-10 10:19:05
354	354	526000.00	cash	completed	2025-05-05 10:06:49
355	355	752000.00	cash	completed	2025-05-09 09:07:28
356	356	560000.00	cash	completed	2025-05-11 19:19:28
357	357	372000.00	cash	completed	2025-05-17 10:53:34
358	358	689000.00	cash	completed	2025-05-08 15:18:04
359	359	591000.00	cash	completed	2025-05-10 15:51:48
360	360	588000.00	cash	completed	2025-05-22 15:31:29
361	361	508000.00	cash	completed	2025-05-09 14:56:44
362	362	666000.00	cash	completed	2025-05-11 14:30:07
363	363	416000.00	cash	completed	2025-05-02 11:29:26
364	364	593000.00	cash	completed	2025-05-10 08:41:03
365	365	507000.00	cash	completed	2025-05-27 11:47:54
366	366	625000.00	cash	completed	2025-05-21 13:25:08
367	367	635000.00	cash	completed	2025-05-25 12:34:29
368	368	585000.00	cash	completed	2025-05-28 13:07:05
369	369	467000.00	cash	completed	2025-05-13 16:49:19
370	370	379000.00	cash	completed	2025-05-09 13:57:08
371	371	442000.00	cash	completed	2025-05-11 09:20:45
372	372	497000.00	cash	completed	2025-05-08 13:30:05
373	373	499000.00	cash	completed	2025-05-19 09:57:04
374	374	612000.00	cash	completed	2025-05-09 14:32:46
375	375	435000.00	cash	completed	2025-05-14 12:30:48
376	376	604000.00	cash	completed	2025-05-01 12:42:32
377	377	532000.00	cash	completed	2025-05-03 16:12:21
378	378	530000.00	cash	completed	2025-06-07 14:57:13
379	379	576000.00	cash	completed	2025-06-04 13:01:56
380	380	669000.00	cash	completed	2025-06-24 16:17:58
381	381	835000.00	cash	completed	2025-06-20 18:31:39
382	382	554000.00	cash	completed	2025-06-06 10:50:43
383	383	534000.00	cash	completed	2025-06-14 15:36:18
384	384	716000.00	cash	completed	2025-06-03 19:08:16
385	385	585000.00	cash	completed	2025-06-04 14:13:27
386	386	548000.00	cash	completed	2025-06-19 09:21:22
387	387	427000.00	cash	completed	2025-06-17 15:56:02
388	388	512000.00	cash	completed	2025-06-23 12:11:11
389	389	514000.00	cash	completed	2025-06-20 09:43:22
390	390	435000.00	cash	completed	2025-06-09 17:01:24
391	391	565000.00	cash	completed	2025-06-02 11:00:28
392	392	740000.00	cash	completed	2025-06-15 19:31:14
393	393	558000.00	cash	completed	2025-06-27 14:34:34
394	394	505000.00	cash	completed	2025-06-04 11:36:28
395	395	564000.00	cash	completed	2025-06-13 11:24:14
396	396	458000.00	cash	completed	2025-06-10 12:26:00
397	397	558000.00	cash	completed	2025-06-19 17:29:46
398	398	536000.00	cash	completed	2025-06-11 13:56:08
399	399	439000.00	cash	completed	2025-06-02 08:47:14
400	400	564000.00	cash	completed	2025-06-23 12:46:29
401	401	506000.00	cash	completed	2025-06-19 09:53:55
402	402	569000.00	cash	completed	2025-06-07 13:43:47
403	403	641000.00	cash	completed	2025-06-16 17:40:51
404	404	475000.00	cash	completed	2025-06-20 16:44:47
405	405	492000.00	cash	completed	2025-06-12 17:49:10
406	406	757000.00	cash	completed	2025-06-12 08:41:25
407	407	657000.00	cash	completed	2025-06-07 16:38:55
408	408	622000.00	cash	completed	2025-06-14 15:27:40
409	409	749000.00	cash	completed	2025-06-02 10:08:49
410	410	568000.00	cash	completed	2025-06-23 13:04:31
411	411	760000.00	cash	completed	2025-06-09 12:33:30
412	412	682000.00	cash	completed	2025-06-20 08:13:10
413	413	648000.00	cash	completed	2025-06-12 18:19:12
414	414	493000.00	cash	completed	2025-06-06 10:58:47
415	415	567000.00	cash	completed	2025-06-04 09:21:05
416	416	534000.00	cash	completed	2025-06-20 13:26:22
417	417	578000.00	cash	completed	2025-06-07 14:09:01
418	418	695000.00	cash	completed	2025-06-09 13:28:50
419	419	414000.00	cash	completed	2025-06-28 19:10:07
420	420	615000.00	cash	completed	2025-06-22 18:57:06
421	421	735000.00	cash	completed	2025-06-13 19:53:02
422	422	613000.00	cash	completed	2025-06-20 11:16:30
423	423	543000.00	cash	completed	2025-06-05 16:58:33
424	424	518000.00	cash	completed	2025-06-01 11:31:51
425	425	536000.00	cash	completed	2025-06-26 12:52:36
426	426	436000.00	cash	completed	2025-06-01 17:38:20
427	427	463000.00	cash	completed	2025-06-02 08:34:37
428	428	744000.00	cash	completed	2025-06-23 18:19:21
429	429	563000.00	cash	completed	2025-06-02 14:28:38
430	430	566000.00	cash	completed	2025-06-08 13:32:39
431	431	616000.00	cash	completed	2025-06-01 16:09:06
432	432	618000.00	cash	completed	2025-06-05 09:55:49
433	433	621000.00	cash	completed	2025-06-15 13:04:51
434	434	648000.00	cash	completed	2025-06-12 09:57:09
435	435	389000.00	cash	completed	2025-06-10 12:48:39
436	436	610000.00	cash	completed	2025-06-20 16:30:02
437	437	654000.00	cash	completed	2025-06-08 17:07:39
438	438	405000.00	cash	completed	2025-06-08 10:16:20
439	439	544000.00	cash	completed	2025-06-19 16:00:16
440	440	408000.00	cash	completed	2025-06-10 11:38:03
441	441	542000.00	cash	completed	2025-06-05 08:15:21
442	442	492000.00	cash	completed	2025-06-02 12:55:43
443	443	514000.00	cash	completed	2025-06-01 08:20:13
444	444	558000.00	cash	completed	2025-06-11 10:51:10
445	445	808000.00	cash	completed	2025-06-11 14:10:07
446	446	552000.00	cash	completed	2025-06-27 19:43:35
447	447	752000.00	cash	completed	2025-06-27 14:11:33
448	448	587000.00	cash	completed	2025-06-28 10:32:26
449	449	438000.00	cash	completed	2025-06-02 09:17:23
450	450	503000.00	cash	completed	2025-06-05 09:50:31
451	451	606000.00	cash	completed	2025-06-27 13:17:37
452	452	570000.00	cash	completed	2025-06-22 13:43:38
453	453	644000.00	cash	completed	2025-07-24 13:14:11
454	454	511000.00	cash	completed	2025-07-01 17:07:41
455	455	377000.00	cash	completed	2025-07-07 17:22:17
456	456	722000.00	cash	completed	2025-07-10 16:40:47
457	457	498000.00	cash	completed	2025-07-17 15:04:42
458	458	410000.00	cash	completed	2025-07-13 14:13:20
459	459	574000.00	cash	completed	2025-07-28 08:54:24
460	460	587000.00	cash	completed	2025-07-11 17:13:41
461	461	443000.00	cash	completed	2025-07-27 10:16:50
462	462	483000.00	cash	completed	2025-07-27 08:44:37
463	463	635000.00	cash	completed	2025-07-14 11:11:30
464	464	467000.00	cash	completed	2025-07-13 15:08:38
465	465	544000.00	cash	completed	2025-07-14 16:03:30
466	466	636000.00	cash	completed	2025-07-27 14:11:48
467	467	643000.00	cash	completed	2025-07-27 14:45:49
468	468	566000.00	cash	completed	2025-07-14 09:03:10
469	469	576000.00	cash	completed	2025-07-02 17:36:12
470	470	538000.00	cash	completed	2025-07-12 16:43:28
471	471	614000.00	cash	completed	2025-07-26 16:14:27
472	472	387000.00	cash	completed	2025-07-03 12:50:05
473	473	578000.00	cash	completed	2025-07-08 11:42:50
474	474	666000.00	cash	completed	2025-07-05 16:05:15
475	475	542000.00	cash	completed	2025-07-18 19:58:39
476	476	458000.00	cash	completed	2025-07-16 17:02:53
477	477	472000.00	cash	completed	2025-07-10 11:49:39
478	478	569000.00	cash	completed	2025-07-18 13:25:04
479	479	851000.00	cash	completed	2025-07-15 09:55:06
480	480	492000.00	cash	completed	2025-07-28 10:15:23
481	481	430000.00	cash	completed	2025-07-23 18:01:51
482	482	493000.00	cash	completed	2025-07-23 14:32:56
483	483	446000.00	cash	completed	2025-07-22 16:37:09
484	484	640000.00	cash	completed	2025-07-27 17:10:48
485	485	524000.00	cash	completed	2025-07-14 10:40:43
486	486	605000.00	cash	completed	2025-07-13 17:12:32
487	487	608000.00	cash	completed	2025-07-07 09:38:30
488	488	571000.00	cash	completed	2025-07-21 11:26:51
489	489	445000.00	cash	completed	2025-07-28 09:12:50
490	490	511000.00	cash	completed	2025-07-25 15:08:54
491	491	637000.00	cash	completed	2025-07-08 09:03:56
492	492	534000.00	cash	completed	2025-07-01 14:42:21
493	493	537000.00	cash	completed	2025-07-15 18:15:37
494	494	620000.00	cash	completed	2025-07-20 10:31:03
495	495	620000.00	cash	completed	2025-07-23 11:08:09
496	496	628000.00	cash	completed	2025-07-15 14:21:28
497	497	511000.00	cash	completed	2025-07-16 18:04:48
498	498	588000.00	cash	completed	2025-07-26 15:44:19
499	499	555000.00	cash	completed	2025-07-16 15:01:45
500	500	438000.00	cash	completed	2025-07-01 15:17:30
501	501	430000.00	cash	completed	2025-07-12 17:01:32
502	502	613000.00	cash	completed	2025-07-15 13:41:40
503	503	444000.00	cash	completed	2025-07-17 12:46:08
504	504	599000.00	cash	completed	2025-07-09 18:18:54
505	505	512000.00	cash	completed	2025-07-28 11:19:45
506	506	612000.00	cash	completed	2025-07-18 09:46:05
507	507	490000.00	cash	completed	2025-07-01 16:34:14
508	508	551000.00	cash	completed	2025-07-28 18:13:33
509	509	557000.00	cash	completed	2025-07-11 16:42:53
510	510	535000.00	cash	completed	2025-07-17 10:02:49
511	511	614000.00	cash	completed	2025-07-26 13:02:36
512	512	573000.00	cash	completed	2025-07-20 19:11:16
513	513	450000.00	cash	completed	2025-07-17 09:46:46
514	514	649000.00	cash	completed	2025-07-08 08:33:13
515	515	709000.00	cash	completed	2025-07-09 09:11:48
516	516	545000.00	cash	completed	2025-07-28 15:53:11
517	517	559000.00	cash	completed	2025-07-11 10:24:44
518	518	483000.00	cash	completed	2025-07-23 13:09:54
519	519	664000.00	cash	completed	2025-07-08 10:30:39
520	520	485000.00	cash	completed	2025-07-15 16:04:37
521	521	497000.00	cash	completed	2025-07-17 19:17:25
522	522	481000.00	cash	completed	2025-07-24 10:39:00
523	523	482000.00	cash	completed	2025-07-04 12:18:02
524	524	496000.00	cash	completed	2025-07-27 13:55:18
525	525	495000.00	cash	completed	2025-07-05 18:50:30
526	526	427000.00	cash	completed	2025-07-23 10:53:39
527	527	418000.00	cash	completed	2025-07-06 12:18:14
528	528	696000.00	cash	completed	2025-08-20 15:44:50
529	529	552000.00	cash	completed	2025-08-14 13:14:11
530	530	463000.00	cash	completed	2025-08-03 13:39:21
531	531	604000.00	cash	completed	2025-08-26 12:50:28
532	532	438000.00	cash	completed	2025-08-19 14:45:38
533	533	601000.00	cash	completed	2025-08-01 13:52:37
534	534	510000.00	cash	completed	2025-08-18 10:44:37
535	535	574000.00	cash	completed	2025-08-11 17:58:06
536	536	568000.00	cash	completed	2025-08-09 14:49:56
537	537	577000.00	cash	completed	2025-08-17 19:01:12
538	538	692000.00	cash	completed	2025-08-16 09:54:25
539	539	551000.00	cash	completed	2025-08-06 09:14:31
540	540	502000.00	cash	completed	2025-08-02 18:16:20
541	541	541000.00	cash	completed	2025-08-06 19:52:18
542	542	584000.00	cash	completed	2025-08-03 17:34:15
543	543	597000.00	cash	completed	2025-08-05 18:22:18
544	544	613000.00	cash	completed	2025-08-03 13:51:43
545	545	581000.00	cash	completed	2025-08-12 09:57:20
546	546	511000.00	cash	completed	2025-08-20 18:17:09
547	547	628000.00	cash	completed	2025-08-03 19:13:17
548	548	503000.00	cash	completed	2025-08-20 13:53:06
549	549	594000.00	cash	completed	2025-08-06 19:11:38
550	550	633000.00	cash	completed	2025-08-17 15:24:43
551	551	516000.00	cash	completed	2025-08-25 11:33:53
552	552	449000.00	cash	completed	2025-08-24 11:58:03
553	553	562000.00	cash	completed	2025-08-23 17:06:56
554	554	746000.00	cash	completed	2025-08-24 14:36:01
555	555	560000.00	cash	completed	2025-08-15 13:35:51
556	556	560000.00	cash	completed	2025-08-24 16:30:40
557	557	609000.00	cash	completed	2025-08-27 09:20:42
558	558	472000.00	cash	completed	2025-08-25 14:20:15
559	559	626000.00	cash	completed	2025-08-02 16:40:03
560	560	475000.00	cash	completed	2025-08-09 15:10:12
561	561	430000.00	cash	completed	2025-08-26 15:40:44
562	562	533000.00	cash	completed	2025-08-11 15:32:14
563	563	651000.00	cash	completed	2025-08-08 12:28:39
564	564	594000.00	cash	completed	2025-08-24 10:15:18
565	565	297000.00	cash	completed	2025-08-19 18:54:33
566	566	507000.00	cash	completed	2025-08-21 18:44:57
567	567	443000.00	cash	completed	2025-08-24 12:16:34
568	568	619000.00	cash	completed	2025-08-28 15:08:02
569	569	467000.00	cash	completed	2025-08-26 17:08:17
570	570	604000.00	cash	completed	2025-08-18 17:18:33
571	571	517000.00	cash	completed	2025-08-02 09:15:49
572	572	431000.00	cash	completed	2025-08-28 16:02:34
573	573	594000.00	cash	completed	2025-08-22 12:33:08
574	574	571000.00	cash	completed	2025-08-26 11:57:38
575	575	573000.00	cash	completed	2025-08-12 16:44:23
576	576	585000.00	cash	completed	2025-08-06 08:26:54
577	577	657000.00	cash	completed	2025-08-20 14:01:08
578	578	562000.00	cash	completed	2025-08-04 14:00:01
579	579	501000.00	cash	completed	2025-08-27 11:38:31
580	580	508000.00	cash	completed	2025-08-18 18:39:11
581	581	455000.00	cash	completed	2025-08-19 13:35:21
582	582	524000.00	cash	completed	2025-08-09 12:56:40
583	583	493000.00	cash	completed	2025-08-27 14:34:49
584	584	562000.00	cash	completed	2025-08-02 17:42:53
585	585	529000.00	cash	completed	2025-08-10 12:19:17
586	586	695000.00	cash	completed	2025-08-17 17:22:18
587	587	412000.00	cash	completed	2025-08-04 15:27:50
588	588	550000.00	cash	completed	2025-08-23 16:17:32
589	589	629000.00	cash	completed	2025-08-22 10:45:51
590	590	579000.00	cash	completed	2025-08-09 11:27:57
591	591	545000.00	cash	completed	2025-08-01 08:50:36
592	592	441000.00	cash	completed	2025-08-03 08:24:25
593	593	630000.00	cash	completed	2025-08-09 13:22:55
594	594	641000.00	cash	completed	2025-08-08 16:33:03
595	595	524000.00	cash	completed	2025-08-10 09:26:25
596	596	656000.00	cash	completed	2025-08-23 18:30:18
597	597	506000.00	cash	completed	2025-08-28 19:33:50
598	598	408000.00	cash	completed	2025-08-16 09:03:12
599	599	677000.00	cash	completed	2025-08-06 15:22:58
600	600	628000.00	cash	completed	2025-08-15 17:07:56
601	601	508000.00	cash	completed	2025-08-25 17:47:13
602	602	713000.00	cash	completed	2025-08-04 15:21:36
603	603	548000.00	cash	completed	2025-09-08 12:49:58
604	604	543000.00	cash	completed	2025-09-28 15:34:13
605	605	500000.00	cash	completed	2025-09-26 19:36:14
606	606	535000.00	cash	completed	2025-09-21 11:10:40
607	607	522000.00	cash	completed	2025-09-22 17:34:25
608	608	462000.00	cash	completed	2025-09-16 12:27:03
609	609	483000.00	cash	completed	2025-09-13 19:06:02
610	610	537000.00	cash	completed	2025-09-05 09:26:58
611	611	600000.00	cash	completed	2025-09-17 10:21:45
612	612	586000.00	cash	completed	2025-09-03 12:21:55
613	613	487000.00	cash	completed	2025-09-09 16:31:52
614	614	562000.00	cash	completed	2025-09-27 12:54:23
615	615	569000.00	cash	completed	2025-09-11 14:57:49
616	616	763000.00	cash	completed	2025-09-26 12:36:26
617	617	461000.00	cash	completed	2025-09-17 13:19:54
618	618	450000.00	cash	completed	2025-09-13 16:34:21
619	619	550000.00	cash	completed	2025-09-21 13:48:26
620	620	545000.00	cash	completed	2025-09-01 18:21:09
621	621	506000.00	cash	completed	2025-09-07 15:50:13
622	622	706000.00	cash	completed	2025-09-20 11:43:52
623	623	583000.00	cash	completed	2025-09-15 12:19:29
624	624	625000.00	cash	completed	2025-09-12 14:37:55
625	625	430000.00	cash	completed	2025-09-23 11:47:52
626	626	520000.00	cash	completed	2025-09-17 13:14:49
627	627	476000.00	cash	completed	2025-09-16 13:41:00
628	628	436000.00	cash	completed	2025-09-22 19:32:45
629	629	614000.00	cash	completed	2025-09-01 18:06:21
630	630	554000.00	cash	completed	2025-09-26 18:26:24
631	631	679000.00	cash	completed	2025-09-17 10:52:12
632	632	472000.00	cash	completed	2025-09-12 16:19:34
633	633	600000.00	cash	completed	2025-09-13 13:45:08
634	634	497000.00	cash	completed	2025-09-14 14:47:23
635	635	505000.00	cash	completed	2025-09-10 08:31:51
636	636	473000.00	cash	completed	2025-09-10 18:05:40
637	637	607000.00	cash	completed	2025-09-12 12:24:21
638	638	544000.00	cash	completed	2025-09-12 08:11:11
639	639	548000.00	cash	completed	2025-09-11 14:27:11
640	640	637000.00	cash	completed	2025-09-27 09:03:09
641	641	566000.00	cash	completed	2025-09-26 17:50:09
642	642	441000.00	cash	completed	2025-09-03 09:33:01
643	643	463000.00	cash	completed	2025-09-21 09:37:10
644	644	638000.00	cash	completed	2025-09-15 09:50:19
645	645	645000.00	cash	completed	2025-09-28 12:20:54
646	646	457000.00	cash	completed	2025-09-09 19:50:57
647	647	554000.00	cash	completed	2025-09-17 12:36:21
648	648	373000.00	cash	completed	2025-09-26 11:18:08
649	649	566000.00	cash	completed	2025-09-03 17:24:38
650	650	468000.00	cash	completed	2025-09-10 14:01:34
651	651	553000.00	cash	completed	2025-09-17 08:26:06
652	652	599000.00	cash	completed	2025-09-19 18:17:14
653	653	644000.00	cash	completed	2025-09-10 16:45:53
654	654	555000.00	cash	completed	2025-09-02 09:43:40
655	655	518000.00	cash	completed	2025-09-17 12:40:28
656	656	382000.00	cash	completed	2025-09-09 15:24:19
657	657	660000.00	cash	completed	2025-09-04 08:21:05
658	658	640000.00	cash	completed	2025-09-27 17:19:37
659	659	477000.00	cash	completed	2025-09-03 15:18:09
660	660	543000.00	cash	completed	2025-09-20 19:17:27
661	661	625000.00	cash	completed	2025-09-03 17:57:32
662	662	465000.00	cash	completed	2025-09-01 17:11:30
663	663	612000.00	cash	completed	2025-09-12 14:26:47
664	664	502000.00	cash	completed	2025-09-20 17:46:15
665	665	678000.00	cash	completed	2025-09-08 17:27:16
666	666	592000.00	cash	completed	2025-09-03 14:55:50
667	667	519000.00	cash	completed	2025-09-23 17:22:57
668	668	556000.00	cash	completed	2025-09-04 14:36:51
669	669	491000.00	cash	completed	2025-09-23 14:43:15
670	670	586000.00	cash	completed	2025-09-17 10:50:09
671	671	708000.00	cash	completed	2025-09-17 19:22:01
672	672	570000.00	cash	completed	2025-09-02 12:33:16
673	673	574000.00	cash	completed	2025-09-22 19:02:58
674	674	576000.00	cash	completed	2025-09-15 13:57:02
675	675	599000.00	cash	completed	2025-09-11 11:29:56
676	676	486000.00	cash	completed	2025-09-17 13:24:18
677	677	549000.00	cash	completed	2025-09-12 12:07:26
678	678	693000.00	cash	completed	2025-10-10 19:29:36
679	679	557000.00	cash	completed	2025-10-27 14:01:56
680	680	435000.00	cash	completed	2025-10-10 15:20:50
681	681	456000.00	cash	completed	2025-10-11 14:08:42
682	682	603000.00	cash	completed	2025-10-09 11:47:06
683	683	594000.00	cash	completed	2025-10-04 18:09:07
684	684	618000.00	cash	completed	2025-10-28 17:50:40
685	685	530000.00	cash	completed	2025-10-08 19:55:33
686	686	683000.00	cash	completed	2025-10-18 14:02:33
687	687	680000.00	cash	completed	2025-10-18 17:50:39
688	688	571000.00	cash	completed	2025-10-10 19:01:10
689	689	545000.00	cash	completed	2025-10-11 08:20:33
690	690	642000.00	cash	completed	2025-10-05 11:57:32
691	691	534000.00	cash	completed	2025-10-13 13:42:48
692	692	510000.00	cash	completed	2025-10-17 11:20:00
693	693	594000.00	cash	completed	2025-10-03 08:38:20
694	694	547000.00	cash	completed	2025-10-08 10:19:55
695	695	684000.00	cash	completed	2025-10-24 19:08:01
696	696	374000.00	cash	completed	2025-10-24 14:11:49
697	697	639000.00	cash	completed	2025-10-19 10:43:53
698	698	592000.00	cash	completed	2025-10-17 11:34:30
699	699	630000.00	cash	completed	2025-10-01 09:35:35
700	700	647000.00	cash	completed	2025-10-04 15:23:12
701	701	600000.00	cash	completed	2025-10-06 09:02:06
702	702	632000.00	cash	completed	2025-10-02 10:06:30
703	703	630000.00	cash	completed	2025-10-16 12:26:01
704	704	599000.00	cash	completed	2025-10-19 11:35:39
705	705	602000.00	cash	completed	2025-10-02 13:25:56
706	706	383000.00	cash	completed	2025-10-10 19:55:17
707	707	449000.00	cash	completed	2025-10-05 08:21:57
708	708	559000.00	cash	completed	2025-10-16 13:44:44
709	709	604000.00	cash	completed	2025-10-20 08:52:08
710	710	558000.00	cash	completed	2025-10-28 17:53:17
711	711	645000.00	cash	completed	2025-10-18 13:42:37
712	712	512000.00	cash	completed	2025-10-15 09:14:47
713	713	523000.00	cash	completed	2025-10-09 09:40:00
714	714	475000.00	cash	completed	2025-10-21 13:15:05
715	715	716000.00	cash	completed	2025-10-21 08:49:23
716	716	530000.00	cash	completed	2025-10-11 12:24:56
717	717	734000.00	cash	completed	2025-10-19 09:30:48
718	718	545000.00	cash	completed	2025-10-19 18:47:12
719	719	645000.00	cash	completed	2025-10-02 16:25:53
720	720	537000.00	cash	completed	2025-10-23 17:35:06
721	721	504000.00	cash	completed	2025-10-07 17:49:15
722	722	652000.00	cash	completed	2025-10-11 17:18:38
723	723	392000.00	cash	completed	2025-10-04 11:16:52
724	724	490000.00	cash	completed	2025-10-28 19:48:13
725	725	414000.00	cash	completed	2025-10-28 18:18:12
726	726	405000.00	cash	completed	2025-10-23 08:37:16
727	727	591000.00	cash	completed	2025-10-11 18:50:27
728	728	624000.00	cash	completed	2025-10-23 14:10:45
729	729	514000.00	cash	completed	2025-10-13 14:13:23
730	730	701000.00	cash	completed	2025-10-25 19:22:34
731	731	491000.00	cash	completed	2025-10-11 10:56:28
732	732	582000.00	cash	completed	2025-10-14 17:41:06
733	733	583000.00	cash	completed	2025-10-14 13:15:36
734	734	596000.00	cash	completed	2025-10-12 15:36:46
735	735	547000.00	cash	completed	2025-10-03 19:21:11
736	736	648000.00	cash	completed	2025-10-06 08:06:43
737	737	571000.00	cash	completed	2025-10-28 15:31:49
738	738	457000.00	cash	completed	2025-10-06 14:00:10
739	739	589000.00	cash	completed	2025-10-16 19:29:46
740	740	542000.00	cash	completed	2025-10-10 13:17:35
741	741	613000.00	cash	completed	2025-10-02 11:58:15
742	742	645000.00	cash	completed	2025-10-10 17:52:12
743	743	637000.00	cash	completed	2025-10-28 15:09:04
744	744	460000.00	cash	completed	2025-10-04 14:30:42
745	745	426000.00	cash	completed	2025-10-01 15:44:42
746	746	707000.00	cash	completed	2025-10-22 10:45:44
747	747	476000.00	cash	completed	2025-10-27 10:36:08
748	748	530000.00	cash	completed	2025-10-09 09:33:47
749	749	502000.00	cash	completed	2025-10-27 17:11:57
750	750	552000.00	cash	completed	2025-10-24 11:08:33
751	751	430000.00	cash	completed	2025-10-16 16:13:57
752	752	550000.00	cash	completed	2025-10-24 17:42:30
753	753	414000.00	cash	completed	2025-11-01 09:48:23
754	754	512000.00	cash	completed	2025-11-04 09:17:53
755	755	492000.00	cash	completed	2025-11-16 19:38:09
756	756	510000.00	cash	completed	2025-11-20 15:57:44
757	757	622000.00	cash	completed	2025-11-19 10:19:05
758	758	491000.00	cash	completed	2025-11-11 16:10:18
759	759	645000.00	cash	completed	2025-11-20 09:43:03
760	760	430000.00	cash	completed	2025-11-20 17:19:34
761	761	598000.00	cash	completed	2025-11-10 13:13:23
762	762	696000.00	cash	completed	2025-11-24 10:47:20
763	763	577000.00	cash	completed	2025-11-20 11:23:43
764	764	615000.00	cash	completed	2025-11-17 15:38:33
765	765	455000.00	cash	completed	2025-11-24 12:38:30
766	766	490000.00	cash	completed	2025-11-06 13:58:53
767	767	553000.00	cash	completed	2025-11-01 12:35:39
768	768	480000.00	cash	completed	2025-11-14 10:14:06
769	769	414000.00	cash	completed	2025-11-13 19:13:23
770	770	758000.00	cash	completed	2025-11-11 12:36:40
771	771	464000.00	cash	completed	2025-11-14 18:51:07
772	772	533000.00	cash	completed	2025-11-08 08:35:36
773	773	493000.00	cash	completed	2025-11-15 18:37:14
774	774	649000.00	cash	completed	2025-11-06 09:29:10
775	775	389000.00	cash	completed	2025-11-20 14:04:23
776	776	549000.00	cash	completed	2025-11-17 11:12:47
777	777	514000.00	cash	completed	2025-11-19 11:56:49
778	778	513000.00	cash	completed	2025-11-06 19:54:05
779	779	472000.00	cash	completed	2025-11-17 09:57:33
780	780	628000.00	cash	completed	2025-11-13 13:41:41
781	781	564000.00	cash	completed	2025-11-26 19:46:21
782	782	521000.00	cash	completed	2025-11-15 18:44:43
783	783	513000.00	cash	completed	2025-11-19 13:24:17
784	784	635000.00	cash	completed	2025-11-25 11:03:49
785	785	538000.00	cash	completed	2025-11-25 08:14:27
786	786	647000.00	cash	completed	2025-11-03 10:17:13
787	787	476000.00	cash	completed	2025-11-19 18:15:05
788	788	531000.00	cash	completed	2025-11-18 18:30:31
789	789	644000.00	cash	completed	2025-11-25 10:08:25
790	790	670000.00	cash	completed	2025-11-27 19:18:12
791	791	552000.00	cash	completed	2025-11-03 14:13:06
792	792	615000.00	cash	completed	2025-11-01 12:32:07
793	793	574000.00	cash	completed	2025-11-01 19:06:34
794	794	497000.00	cash	completed	2025-11-27 10:41:15
795	795	500000.00	cash	completed	2025-11-27 15:14:34
796	796	512000.00	cash	completed	2025-11-18 10:14:54
797	797	726000.00	cash	completed	2025-11-09 16:36:49
798	798	375000.00	cash	completed	2025-11-26 14:31:03
799	799	455000.00	cash	completed	2025-11-06 13:43:14
800	800	575000.00	cash	completed	2025-11-13 19:36:17
801	801	421000.00	cash	completed	2025-11-19 13:36:40
802	802	624000.00	cash	completed	2025-11-08 15:24:04
803	803	667000.00	cash	completed	2025-11-15 13:24:04
804	804	601000.00	cash	completed	2025-11-02 13:09:27
805	805	515000.00	cash	completed	2025-11-23 11:46:28
806	806	524000.00	cash	completed	2025-11-10 11:14:49
807	807	659000.00	cash	completed	2025-11-25 18:22:22
808	808	582000.00	cash	completed	2025-11-22 15:21:26
809	809	450000.00	cash	completed	2025-11-13 18:45:42
810	810	506000.00	cash	completed	2025-11-17 09:49:22
811	811	541000.00	cash	completed	2025-11-02 14:57:32
812	812	721000.00	cash	completed	2025-11-26 19:38:13
813	813	675000.00	cash	completed	2025-11-26 19:22:40
814	814	468000.00	cash	completed	2025-11-12 09:32:53
815	815	501000.00	cash	completed	2025-11-19 14:10:43
816	816	689000.00	cash	completed	2025-11-14 14:19:29
817	817	594000.00	cash	completed	2025-11-03 18:31:36
818	818	441000.00	cash	completed	2025-11-13 09:55:56
819	819	623000.00	cash	completed	2025-11-04 12:33:22
820	820	558000.00	cash	completed	2025-11-05 16:24:07
821	821	430000.00	cash	completed	2025-11-20 19:13:55
822	822	508000.00	cash	completed	2025-11-20 17:55:44
823	823	587000.00	cash	completed	2025-11-12 08:49:05
824	824	590000.00	cash	completed	2025-11-01 14:49:14
825	825	444000.00	cash	completed	2025-11-07 10:00:45
826	826	578000.00	cash	completed	2025-11-18 12:27:03
827	827	579000.00	cash	completed	2025-11-23 15:13:09
828	828	90000.00	cash	completed	2025-11-23 10:18:05.536599
829	829	133000.00	cash	completed	2025-11-23 21:26:44.521696
830	830	126000.00	cash	completed	2025-11-23 21:39:37.107113
831	830	126000.00	cash	completed	2025-11-23 21:39:45.534575
\.


--
-- TOC entry 3516 (class 0 OID 16574)
-- Dependencies: 216
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, full_name, email, password_hash, role, created_at) FROM stdin;
1	Administrator	admin@trinhcafe.vn	$2a$10$wbNKtzsgiyqZOGIv5vEv9eKgXyY5BFXQ4QZLhFR78ttQsmGSsI4Fu	admin	2025-11-22 21:31:25.731585
2	Nhật 	trailangdaubinh@gmail.com	$2a$10$3aadhDB8pGx22Po7jIlBg.4Ydg6UUGfrx5CJmdf7hx5WOrOBlo5km	customer	2025-11-22 22:07:25.270931
3	Lê Nam	nam@gmail.com	$2a$10$hcCp4p.cPOW8hf1ZrEmOiOm2jOcpSCrAXMSIybBXpCYInmvDmw8Lq	customer	2025-11-24 10:58:44.085423
\.


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 221
-- Name: cafe_tables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cafe_tables_id_seq', 120, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 223
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 12, true);


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 219
-- Name: floors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.floors_id_seq', 4, true);


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 225
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 56, true);


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 217
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_id_seq', 4, true);


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 229
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 5792, true);


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 227
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 833, true);


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 231
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 831, true);


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- TOC entry 3353 (class 2606 OID 16620)
-- Name: cafe_tables cafe_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cafe_tables
    ADD CONSTRAINT cafe_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 3355 (class 2606 OID 16639)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3351 (class 2606 OID 16605)
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (id);


--
-- TOC entry 3357 (class 2606 OID 16649)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 3347 (class 2606 OID 16596)
-- Name: locations locations_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_code_key UNIQUE (code);


--
-- TOC entry 3349 (class 2606 OID 16594)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 3361 (class 2606 OID 16678)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3359 (class 2606 OID 16666)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 3363 (class 2606 OID 16699)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 3343 (class 2606 OID 16585)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3345 (class 2606 OID 16583)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3365 (class 2606 OID 16626)
-- Name: cafe_tables cafe_tables_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cafe_tables
    ADD CONSTRAINT cafe_tables_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(id) ON DELETE CASCADE;


--
-- TOC entry 3366 (class 2606 OID 16621)
-- Name: cafe_tables cafe_tables_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cafe_tables
    ADD CONSTRAINT cafe_tables_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE CASCADE;


--
-- TOC entry 3364 (class 2606 OID 16606)
-- Name: floors floors_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE CASCADE;


--
-- TOC entry 3367 (class 2606 OID 16650)
-- Name: items items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;


--
-- TOC entry 3369 (class 2606 OID 16684)
-- Name: order_items order_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- TOC entry 3370 (class 2606 OID 16679)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3368 (class 2606 OID 16667)
-- Name: orders orders_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_table_id_fkey FOREIGN KEY (table_id) REFERENCES public.cafe_tables(id) ON DELETE RESTRICT;


--
-- TOC entry 3371 (class 2606 OID 16700)
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE RESTRICT;


-- Completed on 2025-12-07 01:05:53 +07

--
-- PostgreSQL database dump complete
--

\unrestrict EiSpbr8eEoQuybt6rPNUcCl75HPqjkcON7ajwIuwgz2lWFtUyFI0Znb3zJGowR0

