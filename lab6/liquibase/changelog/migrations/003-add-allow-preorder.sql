--liquibase formatted sql

--changeset lab6:003-add-allow-preorder
ALTER TABLE products
    ADD COLUMN allow_preorder BOOLEAN NOT NULL DEFAULT FALSE;
COMMENT ON COLUMN products.allow_preorder IS 'Indicates whether a product can be preordered when out of stock.';
--rollback ALTER TABLE products DROP COLUMN IF EXISTS allow_preorder;
