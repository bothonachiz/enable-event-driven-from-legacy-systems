-- Create database
CREATE DATABASE IF NOT EXISTS tms;

-- Change database
USE tms;

-- Create the outbox table
CREATE TABLE IF NOT EXISTS outbox (
    id CHAR(36) PRIMARY KEY NOT NULL DEFAULT (UUID()),
    aggregatetype VARCHAR(255) NOT NULL,
    aggregateid VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    payload JSON NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sale order table
CREATE TABLE IF NOT EXISTS sale_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_order_number VARCHAR(12) NOT NULL,
    customer VARCHAR(255) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    total_items INT NOT NULL,
    is_cancelled BOOLEAN DEFAULT FALSE
);

-- Create sale order item table
CREATE TABLE IF NOT EXISTS sale_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_order_id INT NOT NULL,
    sale_order_item_number VARCHAR(15) NOT NULL,
    sku VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sale_order_id) REFERENCES sale_orders(id)
);

-- Change delimiter to define triggers
DELIMITER //

-- Create trigger to capture new sale orders
CREATE TRIGGER sale_order_created
AFTER INSERT ON sale_orders
FOR EACH ROW
BEGIN
    INSERT INTO outbox (id, aggregatetype, aggregateid, type, payload)
    VALUES (UUID(), 'sale_order', NEW.id, 'created', JSON_OBJECT('sale_order_number', NEW.sale_order_number, 'customer', NEW.customer, 'total_price', NEW.total_price, 'total_items', NEW.total_items));
END;
//

-- Create trigger to capture cancelled sale orders
CREATE TRIGGER sale_order_cancelled
AFTER UPDATE ON sale_orders
FOR EACH ROW
BEGIN
    IF NEW.is_cancelled = TRUE THEN
        INSERT INTO outbox (id, aggregatetype, aggregateid, type, payload)
        VALUES (UUID(), 'sale_order', NEW.id, 'cancelled', JSON_OBJECT('sale_order_number', NEW.sale_order_number));
    END IF;
END;
//

-- Create trigger to capture new sale order items
CREATE TRIGGER sale_order_item_created
AFTER INSERT ON sale_order_items
FOR EACH ROW
BEGIN
    INSERT INTO outbox (id, aggregatetype, aggregateid, type, payload)
    VALUES (UUID(), 'sale_order', NEW.sale_order_id, 'item_created', JSON_OBJECT('sale_order_id', NEW.sale_order_id, 'sale_order_item_number', NEW.sale_order_item_number, 'sku', NEW.sku, 'quantity', NEW.quantity, 'unit_price', NEW.unit_price, 'total_price', NEW.total_price));
END;
//

-- Restore the default delimiter
DELIMITER ;

-- Create a user for Debezium
CREATE USER 'debezium'@'%' IDENTIFIED BY 'dbz';

-- Grant the necessary privileges to the user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';

-- Apply the changes
FLUSH PRIVILEGES;

-- Insert example data #1
START TRANSACTION;

INSERT INTO sale_orders (sale_order_number, customer, total_price, total_items)
VALUES ('SO2503000211','John Doe', 200.00, 4);

SET @sale_order_id = LAST_INSERT_ID();

INSERT INTO sale_order_items (sale_order_id, sale_order_item_number, sku, quantity, unit_price, total_price)
VALUES (@sale_order_id, 'SO2503000211-01', 'SKU-001', 1, 50.00, 50.00),
       (@sale_order_id, 'SO2503000211-02', 'SKU-002', 3, 50.00, 150.00);

COMMIT;

-- Insert example data #2
START TRANSACTION;

INSERT INTO sale_orders (sale_order_number, customer, total_price, total_items)
VALUES ('SO2503000212','Jane Marie', 300.00, 3);

SET @sale_order_id = LAST_INSERT_ID();

INSERT INTO sale_order_items (sale_order_id, sale_order_item_number, sku, quantity, unit_price, total_price)
VALUES (@sale_order_id, 'SO2503000212-01', 'SKU-003', 2, 100.00, 200.00),
       (@sale_order_id, 'SO2503000212-02', 'SKU-004', 1, 100.00, 100.00);

COMMIT;