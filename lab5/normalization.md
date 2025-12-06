# Лабораторна робота 5 – Нормалізація

## Вибрані проблемні таблиці та функціональні залежності
1. **orders** (`lab2/DDL.sql`):
   - `id → user_id, phone_number, city, delivery_price, totalPrice, postal_code, comment, payment_type, status, delivery_type, created_at, updated_at`
   - `postal_code → city` (поштовий індекс однозначно відповідає населеному пункту)
   - `delivery_type → {допустимість оплати готівкою, базова вартість}` (прихована залежність довідника)
   - `payment_type → {чи потрібна передоплата}` (прихований довідник)
   - `order_id → Σ(order_items.quantity × order_items.price) = totalPrice` (похідна залежність від підлеглої таблиці)

2. **cart_items** (`lab2/DDL.sql`):
   - `id → cart_id, product_id, quantity`
   - фактичний ключ предметної області: `cart_id, product_id → quantity`
   - дублікати пари `cart_id + product_id` призводять до повторюваних груп.

3. **order_items** (`lab2/DDL.sql`):
   - `id → order_id, product_id, quantity, price`
   - реальний ключ: `order_id, product_id → quantity, price`
   - дублювання пар продукт/замовлення + збереження похідної ціни.



4. **reviews** (`lab2/DDL.sql`):
   - `id → product_id, user_id, rating, text`
   - предметний ключ: `product_id, user_id → rating, text`
   - допускає більше ніж один відгук користувача на той самий товар.

5. **reservations** (`lab2/DDL.sql`):
   - `id → order_id, status, updated_at, created_at`
   - `status → {чи фінальний стан}` (прихований довідник, який неможливо розширити без дублювання).

6. **users** (`lab2/DDL.sql`):
   - `id → email, firstName, lastName, verified, blocked, role, password, updated_at, created_at`
   - `role → {перелік дозволів, назва ролі}` – у схему не закладено довідник ролей.

## Перевірка нормальних форм
| Таблиця       | 1NF | 2NF | 3NF | Виявлені аномалії / функціональні залежності |
|---------------|:---:|:---:|:---:|----------------------------------------------|
| `orders`      | ✓   |  ✓  | ✗ | транзитивна залежність `postal_code → city`, дублювання довідникових значень (`payment_type`, `delivery_type`, `status`) та збереження похідного `totalPrice` |
| `cart_items`  | ✓   |  ✓  | ✗ | семантичний факт описується ключем (`cart_id`, `product_id`). Є ФЗ `cart_id, product_id → quantity`, але детермінант не є ключем (через сурогат `id`), тому 3НФ порушена й можливі дублікати фактів |
| `order_items` | ✓   |  ✓  | ✗ | аналогічно, ФЗ `order_id, product_id → quantity, price`, проте PK = `id`, отже неключовий детермінант порушує 3НФ; додатково зберігається похідна ціна |
| `reviews`     | ✓   |  ✓  | ✗ | бізнес-ключ `product_id, user_id` не реалізований. ФЗ `product_id, user_id → rating, text` має детермінант, що не є ключем, тому можливі дублікати й аномалії |
| `reservations`| ✓   |  ✓  | ✗ | поле `status` одночасно ідентифікатор і словник стану (концептуальна ФЗ `status → {display_name, is_terminal}`), але `status` не ключ, тому 3НФ порушена |
| `users`       | ✓   |  ✓  | ✗ | значення `role` дублюється, а ФЗ `role → {опис, набір дозволів}` не контролюється ключем, що спричиняє транзитивну залежність від `id` |

## Кроки нормалізації

### 1. Таблиця `orders`
1. **Прибирання похідного атрибуту** – вилучено `totalPrice`. Підсумок замовлення обчислюється у представленні `order_totals`, яке повертає єдиний стовпець `total_amount = сума позицій + доставка`.
2. **Усунення транзитивних залежностей** – `city` винесено у довідник `postal_codes(id, code, city, region)`, а в `order_shipping` зберігається лише посилання на індекс (`postal_code_id`) та конкретна адреса.
3. **Довідники для статусів та методів** – `payment_type`, `delivery_type` та `status` замінено на зовнішні ключі (`payment_methods`, `delivery_methods`, `order_statuses`) зі стовпцями `*_id`, щоб уникнути дублювання текстових значень та зберігати додаткові атрибути (наприклад, `is_prepaid`).
4. **Структурування доставки** – в окремій таблиці `order_shipping(order_id, postal_code_id, address_line, delivery_fee)` зафіксовано суму доставки й адресу, що зберігає факт один раз.

```sql
ALTER TABLE orders
    DROP COLUMN totalPrice,
    DROP COLUMN city,
    DROP COLUMN delivery_price,
    DROP COLUMN postal_code,
    DROP COLUMN payment_type,
    DROP COLUMN delivery_type,
    DROP COLUMN status,
    ADD COLUMN payment_method_id BIGINT,
    ADD COLUMN delivery_method_id BIGINT,
    ADD COLUMN status_id BIGINT,
    ADD CONSTRAINT orders_payment_method_fk FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id),
    ADD CONSTRAINT orders_delivery_method_fk FOREIGN KEY (delivery_method_id) REFERENCES delivery_methods(id),
    ADD CONSTRAINT orders_status_fk FOREIGN KEY (status_id) REFERENCES order_statuses(id);

CREATE TABLE postal_codes (...);
CREATE TABLE order_shipping (...);
CREATE VIEW order_totals AS (...);
```

### 2. Таблиці перетинів (`cart_items`, `order_items`, `reviews`)
1. **Реальні ключі** – вилучено сурогатні `id`, запроваджено складені PK з бізнес-атрибутів (`cart_id + product_id`, `order_id + product_id`, `product_id + user_id`).
2. **Запобігання дубляжу** – складені ключі усувають повторювані групи й забезпечують 3НФ.
3. **Фіксація історичної ціни** – для `order_items` додано `unit_price`, що містить ціну в момент покупки, а фінальний підсумок обчислюється через представлення.

```sql
ALTER TABLE cart_items
    DROP CONSTRAINT cart_items_pkey,
    DROP COLUMN id,
    ADD PRIMARY KEY (cart_id, product_id);

ALTER TABLE order_items
    DROP CONSTRAINT order_items_pkey,
    DROP COLUMN id,
    ADD COLUMN unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    ADD PRIMARY KEY (order_id, product_id);

ALTER TABLE reviews
    DROP CONSTRAINT reviews_pkey,
    DROP COLUMN id,
    ADD PRIMARY KEY (product_id, user_id);
```

### 3. Таблиці станів та довідники (`reservations`, `users`)
1. **Розділення статусів бронювань** – створено `reservation_statuses(id, name, is_terminal)` та замінено текстовий стовпець `status` на `status_id`.
2. **Довідник ролей користувачів** – нова таблиця `user_roles`, у `users` замість атрибуту `role` використовується `role_id`, що дозволяє централізовано керувати описом ролей.

```sql
CREATE TABLE reservation_statuses (...);
ALTER TABLE reservations
    DROP COLUMN status,
    ADD COLUMN status_id BIGINT,
    ADD CONSTRAINT reservations_status_fk FOREIGN KEY (status_id) REFERENCES reservation_statuses(id);

CREATE TABLE user_roles (...);
ALTER TABLE users
    ADD COLUMN role_id BIGINT,
    UPDATE users
    SET role_id = CASE
                      WHEN role = 'ADMIN' THEN (SELECT id FROM user_roles WHERE name = 'Administrator')
                      ELSE (SELECT id FROM user_roles WHERE name = 'Registered user')
                  END,
    ALTER TABLE users ALTER COLUMN role_id SET NOT NULL,
    ADD CONSTRAINT users_role_fk FOREIGN KEY (role_id) REFERENCES user_roles(id),
    DROP COLUMN role;
```

## Фінальна структура
- **Оновлена ER-схема**: `lab5/normalized_er.svg` (генерується вручну, відображає всі зв’язки після нормалізації).

