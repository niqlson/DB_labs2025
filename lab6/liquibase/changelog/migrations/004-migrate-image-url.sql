--liquibase formatted sql

--changeset lab6:004-copy-images-to-media
INSERT INTO product_media (product_id, url, alt_text, is_primary, sort_order, created_at)
SELECT
    id,
    image_url,
    CONCAT('Primary image for product ', name),
    TRUE,
    0,
    COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)
FROM products
WHERE image_url IS NOT NULL;
--rollback DELETE FROM product_media WHERE alt_text LIKE 'Primary image for product %';

--changeset lab6:004-drop-product-image-url
ALTER TABLE products DROP COLUMN IF EXISTS image_url;
--rollback ALTER TABLE products ADD COLUMN image_url VARCHAR;
