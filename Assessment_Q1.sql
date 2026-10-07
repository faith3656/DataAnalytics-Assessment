-- MySQL 8+. Positive confirmed_amount defines funded; amounts are kobo.
-- Preaggregate deposits before counting plans to prevent join fan-out.
WITH funded_plans AS (
    SELECT p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
    FROM plans_plan p
    JOIN savings_savingsaccount sa
      ON sa.plan_id = p.id AND sa.owner_id = p.owner_id
    WHERE sa.confirmed_amount > 0
    GROUP BY p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
), products AS (
    SELECT owner_id,
           SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
           SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count
    FROM funded_plans GROUP BY owner_id
), deposits AS (
    SELECT owner_id, SUM(confirmed_amount) / 100.0 AS total_deposits_ngn
    FROM savings_savingsaccount WHERE confirmed_amount > 0 GROUP BY owner_id
)
SELECT u.id AS owner_id,
       COALESCE(NULLIF(TRIM(u.name), ''), NULLIF(TRIM(CONCAT_WS(' ', u.first_name, u.last_name)), ''), 'Unknown') AS name,
       p.savings_count, p.investment_count,
       ROUND(d.total_deposits_ngn, 2) AS total_deposits_ngn
FROM users_customuser u
JOIN products p ON p.owner_id = u.id
JOIN deposits d ON d.owner_id = u.id
WHERE p.savings_count > 0 AND p.investment_count > 0
ORDER BY total_deposits_ngn DESC, owner_id;
