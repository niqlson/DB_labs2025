DROP VIEW IF EXISTS order_totals;

DROP TABLE IF EXISTS reservation_items CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS reservation_statuses CASCADE;

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS order_shipping CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS order_statuses CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
DROP TABLE IF EXISTS delivery_methods CASCADE;

DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;

DROP TABLE IF EXISTS reviews CASCADE;

DROP TABLE IF EXISTS discounts CASCADE;
DROP TABLE IF EXISTS discount CASCADE;
DROP TABLE IF EXISTS products CASCADE;

DROP TABLE IF EXISTS postal_codes CASCADE;

DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;


CREATE TABLE user_roles
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(64)  NOT NULL,
    description VARCHAR(255) NULL
);

CREATE TABLE users
(
    id         BIGINT PRIMARY KEY,
    email      VARCHAR      NOT NULL UNIQUE,
    firstName  VARCHAR      NOT NULL,
    lastName   VARCHAR      NOT NULL,
    verified   BOOLEAN      NOT NULL,
    blocked    BOOLEAN      NOT NULL,
    role_id    BIGINT       NOT NULL,
    password   VARCHAR      NOT NULL,
    updated_at TIMESTAMP,
    created_at TIMESTAMP,
    CONSTRAINT users_role_id_fk FOREIGN KEY (role_id) REFERENCES user_roles (id)
);

CREATE TABLE products
(
    id                 BIGINT PRIMARY KEY,
    name               VARCHAR      NOT NULL,
    image_url          VARCHAR      NOT NULL,
    description        VARCHAR,
    available_quantity INT          NOT NULL CHECK (available_quantity >= 0),
    price              DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    enabled            BOOLEAN      NOT NULL,
    updated_at         TIMESTAMP,
    created_at         TIMESTAMP
);

CREATE TABLE discounts
(
    id             BIGINT PRIMARY KEY,
    product_id     BIGINT       NOT NULL,
    discount_value DECIMAL(5,2) NOT NULL CHECK (discount_value >= 0 AND discount_value <= 100),
    start_date     DATE         NOT NULL,
    end_date       DATE         NOT NULL CHECK (end_date >= start_date),
    enabled        BOOLEAN      NOT NULL,
    updated_at     TIMESTAMP,
    created_at     TIMESTAMP,
    CONSTRAINT discounts_product_fk FOREIGN KEY (product_id) REFERENCES products (id),
    CONSTRAINT discounts_unique_period UNIQUE (product_id, start_date, end_date)
);

CREATE TABLE reviews
(
    product_id BIGINT  NOT NULL,
    user_id    BIGINT  NOT NULL,
    rating     INT     NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text       VARCHAR NOT NULL,
    created_at TIMESTAMP,
    PRIMARY KEY (product_id, user_id),
    CONSTRAINT reviews_product_fk FOREIGN KEY (product_id) REFERENCES products (id),
    CONSTRAINT reviews_user_fk FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE carts
(
    id         BIGINT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT carts_user_fk FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE cart_items
(
    cart_id   BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity  INT    NOT NULL CHECK (quantity > 0),
    added_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cart_id, product_id),
    CONSTRAINT cart_items_cart_fk FOREIGN KEY (cart_id) REFERENCES carts (id) ON DELETE CASCADE,
    CONSTRAINT cart_items_product_fk FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE payment_methods
(
    id         BIGINT PRIMARY KEY,
    name       VARCHAR(64) NOT NULL,
    is_prepaid BOOLEAN     NOT NULL
);

CREATE TABLE delivery_methods
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(64) NOT NULL,
    supports_cod BOOLEAN    NOT NULL
);

CREATE TABLE order_statuses
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(64) NOT NULL,
    is_terminal BOOLEAN     NOT NULL
);

CREATE TABLE postal_codes
(
    id    BIGINT PRIMARY KEY,
    code  VARCHAR(12) NOT NULL UNIQUE,
    city  VARCHAR     NOT NULL,
    region VARCHAR
);

CREATE TABLE orders
(
    id                   BIGINT PRIMARY KEY,
    user_id              BIGINT      NOT NULL,
    payment_method_id    BIGINT      NOT NULL,
    status_id            BIGINT      NOT NULL,
    delivery_method_id   BIGINT      NOT NULL,
    phone_number         VARCHAR     NOT NULL,
    comment              VARCHAR,
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP,
    CONSTRAINT orders_user_fk FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT orders_payment_method_fk FOREIGN KEY (payment_method_id) REFERENCES payment_methods (id),
    CONSTRAINT orders_status_fk FOREIGN KEY (status_id) REFERENCES order_statuses (id),
    CONSTRAINT orders_delivery_method_fk FOREIGN KEY (delivery_method_id) REFERENCES delivery_methods (id)
);

CREATE TABLE order_shipping
(
    order_id     BIGINT PRIMARY KEY,
    postal_code_id BIGINT NOT NULL,
    address_line VARCHAR     NOT NULL,
    delivery_fee DECIMAL(12,2) NOT NULL CHECK (delivery_fee >= 0),
    CONSTRAINT order_shipping_order_fk FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT order_shipping_postal_fk FOREIGN KEY (postal_code_id) REFERENCES postal_codes (id)
);

CREATE TABLE order_items
(
    order_id   BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity   INT    NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT order_items_order_fk FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT order_items_product_fk FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE VIEW order_totals AS
SELECT
    oi.order_id,
    (SUM(oi.quantity * oi.unit_price) + COALESCE(MAX(os.delivery_fee), 0))::DECIMAL(12,2) AS total_amount
FROM order_items oi
LEFT JOIN order_shipping os ON os.order_id = oi.order_id
GROUP BY oi.order_id;

SELECT order_id, total_amount FROM order_totals;

CREATE TABLE reservation_statuses
(
    id          BIGINT PRIMARY KEY,
    name        VARCHAR(64) NOT NULL,
    is_terminal BOOLEAN     NOT NULL
);

CREATE TABLE reservations
(
    id          BIGINT PRIMARY KEY,
    order_id    BIGINT      NOT NULL,
    status_id   BIGINT      NOT NULL,
    updated_at  TIMESTAMP,
    created_at  TIMESTAMP,
    CONSTRAINT reservations_order_fk FOREIGN KEY (order_id) REFERENCES orders (id),
    CONSTRAINT reservations_status_fk FOREIGN KEY (status_id) REFERENCES reservation_statuses (id)
);

CREATE TABLE reservation_items
(
    reservation_id BIGINT NOT NULL,
    product_id     BIGINT NOT NULL,
    quantity       INT    NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (reservation_id, product_id),
    CONSTRAINT reservation_items_reservation_fk FOREIGN KEY (reservation_id) REFERENCES reservations (id) ON DELETE CASCADE,
    CONSTRAINT reservation_items_product_fk FOREIGN KEY (product_id) REFERENCES products (id)
);


INSERT INTO user_roles (id, name, description)
VALUES
    (1, 'Registered user', 'Customer that can place orders'),
    (2, 'Administrator', 'Back office employee');

INSERT INTO payment_methods (id, name, is_prepaid)
VALUES
    (1, 'Online card', TRUE),
    (2, 'Cash on delivery', FALSE);

INSERT INTO delivery_methods (id, name, supports_cod)
VALUES
    (1, 'Courier to door', TRUE),
    (2, 'Store pickup', TRUE),
    (3, 'Postal service', TRUE);

INSERT INTO order_statuses (id, name, is_terminal)
VALUES
    (1, 'Pending payment', FALSE),
    (2, 'Confirmed', FALSE),
    (3, 'Shipped to carrier', FALSE),
    (4, 'Delivered successfully', TRUE),
    (5, 'Cancelled by user', TRUE);

INSERT INTO reservation_statuses (id, name, is_terminal)
VALUES
    (1, 'Pending reservation', FALSE),
    (2, 'Reserved', FALSE),
    (3, 'Reservation completed', TRUE),
    (4, 'Reservation canceled', TRUE);



INSERT INTO users (id, email, firstName, lastName, verified, blocked, role_id, password, created_at, updated_at)
VALUES (
           1,
           'demo@example.com',
           'Demo',
           'User',
           true,
           false,
           1,
           'hash-or-temp-password',
           NOW(),
           NOW()
       );

INSERT INTO orders(id, user_id, payment_method_id, delivery_method_id, status_id, phone_number)
VALUES (1, 1, 1, 1, 1, '+0000000000');

INSERT INTO postal_codes (id, code, city, region)
VALUES (1, '01001', 'Київ', 'Київська обл.');

INSERT INTO order_shipping(order_id, postal_code_id, address_line, delivery_fee)
VALUES (1, 1, 'Some address', 5.00);

INSERT INTO products (
    id, name, image_url, description,
    available_quantity, price, enabled,
    updated_at, created_at
) VALUES (
             1,
             'Demo product',
             'https://example.com/demo.jpg',
             'Тестовий товар',
             100,
             100.00,
             true,
             NOW(),
             NOW()
         );

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (1, 1, 2, 100.00);
