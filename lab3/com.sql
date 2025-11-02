
SELECT id, firstName, lastName, email FROM users WHERE verified = true AND blocked = false;
SELECT name, price FROM products WHERE price > 1000;

SELECT products.name, discount.discount_value FROM products
    JOIN discount ON products.id = discount.product_id
    WHERE discount.enabled = true;

SELECT users.firstName, reviews.rating, reviews.text FROM reviews
    JOIN users ON reviews.user_id = users.id
    WHERE rating >= 4;

SELECT name, price FROM products WHERE enabled = true ORDER BY price DESC LIMIT 3;

SELECT DISTINCT u.firstName, u.lastName, r.text FROM users u
    JOIN reviews r ON u.id = r.user_id
    WHERE r.rating = 5;

SELECT products.name, products.price, discount.discount_value FROM discount
    JOIN products ON discount.product_id = products.id
    WHERE discount.enabled = true AND products.price > 900;

SELECT o.id AS order_id, o.totalPrice, o.status, o.created_at FROM orders o
    JOIN users u ON o.user_id = u.id
    WHERE u.email = 'ivan.petrenko@mail.ua';

SELECT city, totalPrice, status FROM orders WHERE status IN ('CONFIRMED', 'SHIPPED');

INSERT INTO users (id, email, firstName, lastName, verified, blocked, role, password, updated_at, created_at)
VALUES (6, 'oleh.melnuk@mail.ua', 'Олег', 'Мельнюк', true, false, 'USER', 'olehpass', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

SELECT * FROM users WHERE id = 6;

INSERT INTO products (id, name, image_url, description, available_quantity, price, enabled, updated_at, created_at)
VALUES (6, 'Apple Watch Ultra 2', 'https://example.com/watch.jpg', 'Смарт-годинник Apple', 10, 999.99, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

SELECT * FROM products WHERE id = 6;

INSERT INTO orders (id, user_id, phone_number, city, delivery_price, totalPrice, postal_code, comment, payment_type, status, delivery_type, created_at, updated_at)
VALUES (6, 6, '+380931112244', 'Чернівці', 4.00, 1003.99, '58000', 'Доставка у будні', 'CARD', 'PENDING', 'COURIER', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

SELECT * FROM orders WHERE id = 6;

UPDATE users
SET verified = true, blocked = false
WHERE id = 4;

SELECT * FROM users WHERE id = 4;

UPDATE products
SET price = price * 0.9
WHERE id IN (1, 2, 3);

SELECT id, name, price FROM products WHERE id IN (1, 2, 3);

UPDATE orders
SET status = 'CONFIRMED'
WHERE id = 2;

UPDATE products
SET available_quantity = available_quantity - 1
WHERE id = 1;

UPDATE users
SET role = 'ADMIN'
WHERE id = 6;

UPDATE products
SET price = price * 1.05
WHERE price < 500;

SELECT id, status FROM orders WHERE id = 2;

DELETE FROM reviews WHERE id = 2;
SELECT * FROM reviews;

DELETE FROM discount WHERE end_date < '2024-02-01';
SELECT * FROM discount;

DELETE FROM cart_items WHERE quantity = 3 AND cart_id = 5;
SELECT * FROM cart_items WHERE cart_id = 5;

