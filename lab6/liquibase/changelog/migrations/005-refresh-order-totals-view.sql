--liquibase formatted sql

--changeset lab6:005-refresh-order-totals-view
DROP VIEW IF EXISTS order_totals;
CREATE VIEW order_totals AS
SELECT
    oi.order_id,
    SUM(oi.quantity * oi.unit_price)::DECIMAL(12,2)                             AS merchandise_total,
    os.delivery_fee,
    (SUM(oi.quantity * oi.unit_price) + COALESCE(os.delivery_fee, 0))::DECIMAL(12,2) AS grand_total
FROM order_items oi
LEFT JOIN order_shipping os ON os.order_id = oi.order_id
GROUP BY oi.order_id, os.delivery_fee;
--rollback DROP VIEW IF EXISTS order_totals;
