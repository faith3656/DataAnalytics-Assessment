CREATE DATABASE IF NOT EXISTS metabase_app;
CREATE USER IF NOT EXISTS 'metabase_app'@'%' IDENTIFIED BY 'synthetic-demo-app';
GRANT ALL PRIVILEGES ON metabase_app.* TO 'metabase_app'@'%';
CREATE USER IF NOT EXISTS 'demo_reader'@'%' IDENTIFIED BY 'synthetic-demo-reader';
GRANT SELECT ON financial_customer_demo.* TO 'demo_reader'@'%';
