-- 1. БАЗОВА АГРЕГАЦІЯ

SELECT COUNT(*) AS total_users
FROM users;

SELECT AVG(price) AS average_price
FROM products;

SELECT MIN(price) AS min_price, MAX(price) AS max_price
FROM products;

SELECT SUM(available_quantity) AS total_available_products
FROM products;


-- 2. ГРУПУВАННЯ ДАНИХ

SELECT role, COUNT(*) AS user_count
FROM users
GROUP BY role;

SELECT p.name, AVG(r.rating) AS average_rating
FROM products p
         JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name;

SELECT status, SUM(totalPrice) AS total_amount
FROM orders
GROUP BY status;

SELECT delivery_type, COUNT(*) AS order_count
FROM orders
GROUP BY delivery_type;

-- 3. ФІЛЬТРУВАННЯ ГРУП (HAVING)

SELECT p.name, AVG(r.rating) AS average_rating
FROM products p
         JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
HAVING AVG(r.rating) > 4.0;

SELECT u.firstName, u.lastName, COUNT(o.id) AS order_count
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.firstName, u.lastName
HAVING COUNT(o.id) >= 1;

SELECT delivery_type, AVG(delivery_price) AS avg_delivery_price
FROM orders
GROUP BY delivery_type
HAVING AVG(delivery_price) > 1;

-- 4. ЗАПИТИ JOIN

SELECT o.id AS order_id, u.firstName, u.lastName, o.totalPrice, o.status
FROM orders o
         INNER JOIN users u ON o.user_id = u.id;

SELECT p.name, p.price, d.discount_value, d.start_date, d.end_date
FROM products p
         LEFT JOIN discount d ON p.id = d.product_id AND d.enabled = true;

SELECT r.rating, r.text, u.firstName, u.lastName
FROM reviews r
         RIGHT JOIN users u ON r.user_id = u.id;

SELECT u.email, c.id AS cart_id, c.created_at
FROM users u
         FULL JOIN carts c ON u.id = c.user_id;

-- 5. БАГАТОТАБЛИЧНА АГРЕГАЦІЯ

SELECT u.firstName, u.lastName, SUM(o.totalPrice) AS total_spent
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.firstName, u.lastName;

SELECT u.firstName, u.lastName, SUM(ci.quantity) AS total_cart_items
FROM users u
         JOIN carts c ON u.id = c.user_id
         JOIN cart_items ci ON c.id = ci.cart_id
GROUP BY u.id;

SELECT p.name, p.available_quantity, AVG(r.rating) AS average_rating
FROM products p
         JOIN reviews r ON p.id = r.product_id
GROUP BY p.name, p.available_quantity;

-- 6. ПІДЗАПИТИ

SELECT name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

SELECT firstName, lastName, email
FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders);

SELECT o.id, o.totalPrice,
       (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.id) AS item_count
FROM orders o;

SELECT p.name,
       (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id) AS review_count
FROM products p;

SELECT u.firstName, u.lastName, MAX(o.totalPrice) AS max_order_value
FROM users u
         JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.firstName, u.lastName
HAVING MAX(o.totalPrice) > (SELECT AVG(totalPrice) FROM orders);

-- 7. ДОДАТКОВІ АНАЛІТИЧНІ ЗАПИТИ

SELECT p.name, SUM(ci.quantity) AS total_in_carts
FROM products p
         JOIN cart_items ci ON p.id = ci.product_id
GROUP BY p.id, p.name
ORDER BY total_in_carts DESC
LIMIT 3;

SELECT city,
       COUNT(*) AS order_count,
       AVG(totalPrice) AS avg_order_value,
       SUM(totalPrice) AS total_revenue
FROM orders
GROUP BY city;

SELECT p.name,
       p.price AS original_price,
       d.discount_value,
       ROUND(p.price * (1 - d.discount_value/100), 2) AS discounted_price
FROM products p
         JOIN discount d ON p.id = d.product_id
WHERE d.enabled = true