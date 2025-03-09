-- Create database
CREATE DATABASE IF NOT EXISTS tms;

-- Change database
USE tms;

-- Create vehicle table
CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    licensePlate VARCHAR(255) NOT NULL,
    licensePlateState VARCHAR(255) NOT NULL,
    wheelCount INT NOT NULL
);

-- Insert example data
INSERT INTO vehicles (licensePlate, licensePlateState, wheelCount) 
VALUES ('AR7699', 'Utah', 22), ('RC4242', 'Utah', 22);

-- Create a user for Debezium
CREATE USER 'debezium'@'%' IDENTIFIED BY 'dbz';

-- Grant the necessary privileges to the user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';

-- Apply the changes
FLUSH PRIVILEGES;