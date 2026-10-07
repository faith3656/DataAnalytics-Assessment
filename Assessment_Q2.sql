-- MySQL 8+. Frequency of dated positive inflows, not every ledger row.
-- Calendar-month span between first/last inflow, inclusive (minimum 1).
-- This is observed activity frequency, not signup-to-today engagement.
WITH customer_activity AS (
    SELECT owner_id, COUNT(*) AS total_transactions,
           (YEAR(MAX(transaction_date)) - YEAR(MIN(transaction_date))) * 12
           + MONTH(MAX(transaction_date)) - MONTH(MIN(transaction_date)) + 1 AS months_active
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0 AND transaction_date IS NOT NULL
    GROUP BY owner_id
), frequency AS (
    SELECT owner_id, total_transactions * 1.0 / months_active AS avg_txn_per_month
    FROM customer_activity
), categories AS (
    SELECT owner_id, avg_txn_per_month,
           CASE WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
                WHEN avg_txn_per_month >= 3 THEN 'Medium Frequency'
                ELSE 'Low Frequency' END AS frequency_category
    FROM frequency
)
SELECT frequency_category, COUNT(*) AS customer_count,
       ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM categories
GROUP BY frequency_category
ORDER BY CASE frequency_category WHEN 'High Frequency' THEN 1 WHEN 'Medium Frequency' THEN 2 ELSE 3 END;
