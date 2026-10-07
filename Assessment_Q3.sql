-- MySQL 8+. Fixed reporting date makes the demo reproducible; update for a live report.
-- Only funded plans with a known last inflow can be aged reliably.
-- No source active-status or plan-creation column has been verified.
WITH parameters AS (SELECT CAST('2026-10-07' AS DATE) AS as_of_date), last_inflow AS (
    SELECT p.id AS plan_id, p.owner_id,
           CASE WHEN p.is_regular_savings = 1 AND p.is_a_fund = 1 THEN 'Savings / Investment'
                WHEN p.is_regular_savings = 1 THEN 'Savings' ELSE 'Investment' END AS type,
           MAX(sa.transaction_date) AS last_transaction_date
    FROM plans_plan p
    JOIN savings_savingsaccount sa ON sa.plan_id = p.id AND sa.owner_id = p.owner_id
    CROSS JOIN parameters r
    WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1)
      AND sa.confirmed_amount > 0 AND sa.transaction_date <= r.as_of_date
    GROUP BY p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
)
SELECT l.*, DATEDIFF(r.as_of_date, l.last_transaction_date) AS inactivity_days
FROM last_inflow l CROSS JOIN parameters r
WHERE DATEDIFF(r.as_of_date, l.last_transaction_date) > 365
ORDER BY inactivity_days DESC, plan_id;
