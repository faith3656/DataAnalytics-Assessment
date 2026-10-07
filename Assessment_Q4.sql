-- MySQL 8+. Assessment CLV formula is an annualised profit proxy, not full lifetime value.
-- Assumed margin = 0.1%; confirmed_amount is kobo. Fixed reporting date.
WITH parameters AS (SELECT CAST('2026-10-07' AS DATE) AS as_of_date), activity AS (
    SELECT sa.owner_id, COUNT(*) AS total_transactions,
           AVG(sa.confirmed_amount) / 100.0 AS avg_transaction_ngn
    FROM savings_savingsaccount sa CROSS JOIN parameters r
    WHERE sa.confirmed_amount > 0 AND sa.transaction_date <= r.as_of_date
    GROUP BY sa.owner_id
), customer_metrics AS (
    SELECT u.id AS customer_id,
           COALESCE(NULLIF(TRIM(u.name), ''), NULLIF(TRIM(CONCAT_WS(' ', u.first_name, u.last_name)), ''), 'Unknown') AS name,
           TIMESTAMPDIFF(MONTH, u.date_joined, r.as_of_date) AS tenure_months,
           COALESCE(a.total_transactions, 0) AS total_transactions,
           COALESCE(a.avg_transaction_ngn, 0) AS avg_transaction_ngn
    FROM users_customuser u CROSS JOIN parameters r
    LEFT JOIN activity a ON a.owner_id = u.id
)
SELECT customer_id, name, tenure_months, total_transactions,
       ROUND(CASE WHEN tenure_months <= 0 THEN NULL
                  ELSE total_transactions * 1.0 / tenure_months * 12 * avg_transaction_ngn * 0.001 END, 2)
           AS estimated_annual_profit_ngn
FROM customer_metrics
ORDER BY estimated_annual_profit_ngn DESC, customer_id;
