CREATE TABLE users
(
    id         BIGINT PRIMARY KEY,
    email      VARCHAR NOT NULL,
    firstName  VARCHAR NOT NULL,
    lastName   VARCHAR NOT NULL,
    verified   BOOLEAN NOT NULL,
    blocked    BOOLEAN NOT NULL,
    role       VARCHAR NOT NULL,
    password   VARCHAR NOT NULL,
    updated_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE products
(
    id                 BIGINT PRIMARY KEY,
    name               VARCHAR NOT NULL,
    image_url          VARCHAR NOT NULL,
    description        VARCHAR,
    available_quantity INT     NOT NULL CHECK (available_quantity >= 0),
    price              DECIMAL NOT NULL CHECK (price >= 0),
    enabled            BOOLEAN NOT NULL,
    updated_at         TIMESTAMP,
    created_at         TIMESTAMP
);

CREATE TABLE discount
(
    id             BIGINT PRIMARY KEY,
    product_id     BIGINT  NOT NULL,
    discount_value DECIMAL NOT NULL CHECK (discount_value >= 0 AND discount_value <= 100),
    start_date     DATE    NOT NULL,
    end_date       DATE    NOT NULL CHECK (end_date >= start_date),
    enabled        BOOLEAN NOT NULL,
    updated_at     TIMESTAMP,
    created_at     TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE reviews
(
    id         BIGINT PRIMARY KEY,
    product_id BIGINT  NOT NULL,
    user_id    BIGINT  NOT NULL,
    rating     INT     NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text       VARCHAR NOT NULL,
    created_at TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE carts
(
    id         BIGINT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE cart_items
(
    id         BIGINT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    cart_id    BIGINT NOT NULL,
    quantity   INT    NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (cart_id) REFERENCES carts (id)
);

CREATE TABLE orders
(
    id             BIGINT PRIMARY KEY,
    user_id        BIGINT  NOT NULL,
    phone_number   VARCHAR NOT NULL,
    city           VARCHAR NOT NULL,
    delivery_price DECIMAL NOT NULL CHECK (delivery_price >= 0),
    totalPrice     DECIMAL NOT NULL CHECK (totalPrice >= 0),
    postal_code    VARCHAR NOT NULL,
    comment        VARCHAR,
    payment_type   VARCHAR NOT NULL CHECK (payment_type IN ('CARD', 'CASH')),
    status         VARCHAR NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    delivery_type  VARCHAR NOT NULL CHECK (delivery_type IN ('COURIER', 'PICKUP', 'POST')),
    created_at     TIMESTAMP,
    updated_at     TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE order_items
(
    id         BIGINT PRIMARY KEY,
    product_id BIGINT  NOT NULL,
    order_id   BIGINT  NOT NULL,
    quantity   INT     NOT NULL CHECK (quantity > 0),
    price      DECIMAL NOT NULL CHECK (price >= 0),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE reservations
(
    id         BIGINT PRIMARY KEY,
    order_id   BIGINT  NOT NULL,
    status     VARCHAR NOT NULL CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELED', 'COMPLETED')),
    updated_at TIMESTAMP,
    created_at TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders (id)
);

CREATE TABLE reservation_items
(
    id             BIGINT PRIMARY KEY,
    product_id     BIGINT NOT NULL,
    reservation_id BIGINT NOT NULL,
    quantity       INT    NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (reservation_id) REFERENCES reservations (id)
);



INSERT INTO users (id, email, firstName, lastName, verified, blocked, role, password, updated_at, created_at)
VALUES (1, 'ivan.petrenko@mail.ua', 'Іван', 'Петренко', true, false, 'USER', 'password123', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP),
       (2, 'anna.sydorenko@mail.ua', 'Анна', 'Сидоренко', true, false, 'USER', 'password456', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP),
       (3, 'admin@shop.ua', 'Адмін', 'Адмінов', true, false, 'ADMIN', 'adminpass', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP),
       (4, 'maria.ivanenko@mail.ua', 'Марія', 'Іваненко', false, false, 'USER', 'password789', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP),
       (5, 'serhiy.kovalenko@mail.ua', 'Сергій', 'Коваленко', true, true, 'USER', 'password000', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP);

INSERT INTO products (id, name, image_url, description, available_quantity, price, enabled, updated_at, created_at)
VALUES (1, 'iPhone 15 Pro', 'https://example.com/iphone15pro.jpg', 'Флагманський смартфон Apple', 25, 1299.99, true,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (2, 'Samsung Galaxy S24', 'https://example.com/galaxys24.jpg', 'Смартфон Samsung з AI', 30, 999.99, true,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (3, 'MacBook Air M3', 'https://example.com/macbookair.jpg', 'Ноутбук Apple на чіпі M3', 15, 1499.99, true,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (4, 'Sony WH-1000XM5', 'https://example.com/sonyheadphones.jpg', 'Бездротові навушники з шумозаглушенням', 40,
        349.99, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (5, 'iPad Air', 'https://example.com/ipadair.jpg', 'Планшет Apple з чіпом M1', 20, 799.99, true,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO discount (id, product_id, discount_value, start_date, end_date, enabled, updated_at, created_at)
VALUES (1, 1, 10.00, '2024-01-01', '2024-01-31', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (2, 2, 15.00, '2024-01-15', '2024-02-15', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (3, 3, 5.00, '2024-02-01', '2024-02-28', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (4, 4, 20.00, '2024-01-20', '2024-02-20', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (5, 5, 12.50, '2024-03-01', '2024-03-31', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO reviews (id, product_id, user_id, rating, text, created_at)
VALUES (1, 1, 1, 5, 'Відмінний телефон! Батарея тримає довго', CURRENT_TIMESTAMP),
       (2, 1, 2, 4, 'Хороший, але дорогий', CURRENT_TIMESTAMP),
       (3, 2, 3, 5, 'AI функції вражають', CURRENT_TIMESTAMP),
       (4, 3, 4, 5, 'Найкращий ноутбук для роботи', CURRENT_TIMESTAMP),
       (5, 4, 5, 4, 'Шумозаглушення на висоті', CURRENT_TIMESTAMP);

INSERT INTO carts (id, user_id, created_at, updated_at)
VALUES (1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (4, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (5, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO cart_items (id, product_id, cart_id, quantity)
VALUES (1, 1, 1, 1),
       (2, 2, 1, 2),
       (3, 3, 2, 1),
       (4, 4, 3, 1),
       (5, 5, 4, 3);

INSERT INTO orders (id, user_id, phone_number, city, delivery_price, totalPrice, postal_code, comment, payment_type,
                    status, delivery_type, created_at, updated_at)
VALUES (1, 1, '+380631234567', 'Київ', 5.00, 1304.99, '01001', 'Подзвонити за годину', 'CARD', 'CONFIRMED', 'COURIER',
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (2, 2, '+380667654321', 'Львів', 3.00, 1002.99, '79000', 'Без коментарів', 'CASH', 'PENDING',
        'PICKUP', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (3, 3, '+380501112233', 'Одеса', 7.00, 1506.99, '65000', 'Код домофона 123', 'CARD', 'SHIPPED', 'POST',
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (4, 4, '+380934443322', 'Харків', 6.00, 805.99, '61000', 'Доставити до 18:00', 'CASH', 'DELIVERED',
        'COURIER', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (5, 5, '+380998887766', 'Дніпро', 4.00, 355.99, '49000', 'Залишити біля дверей', 'CARD', 'CANCELLED', 'PICKUP',
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO order_items (id, product_id, order_id, quantity, price)
VALUES (1, 1, 1, 1, 1299.99),
       (2, 2, 2, 1, 999.99),
       (3, 3, 3, 1, 1499.99),
       (4, 5, 4, 1, 799.99),
       (5, 4, 5, 1, 349.99);

INSERT INTO reservations (id, order_id, status, updated_at, created_at)
VALUES (1, 1, 'CONFIRMED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (2, 2, 'PENDING', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (3, 3, 'COMPLETED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (4, 4, 'CANCELED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       (5, 5, 'CONFIRMED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO reservation_items (id, product_id, reservation_id, quantity)
VALUES (1, 1, 1, 1),
       (2, 2, 2, 1),
       (3, 3, 3, 1),
       (4, 5, 4, 1),
       (5, 4, 5, 1);
