-- MySQL 8+. Calendar spine preserves zero-inflow months; LAG compares adjacent months.
WITH RECURSIVE months AS (
    SELECT CAST('2026-04-01' AS DATE) AS month_start
    UNION ALL SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM months WHERE month_start < CAST('2026-09-01' AS DATE)
), totals AS (
    SELECT m.month_start, COALESCE(SUM(sa.confirmed_amount), 0) / 100.0 AS deposits_ngn
    FROM months m LEFT JOIN savings_savingsaccount sa
      ON sa.transaction_date >= m.month_start
     AND sa.transaction_date < DATE_ADD(m.month_start, INTERVAL 1 MONTH)
     AND sa.confirmed_amount > 0
    GROUP BY m.month_start
), comparison AS (
    SELECT month_start, deposits_ngn,
           LAG(deposits_ngn) OVER (ORDER BY month_start) AS prior_month_deposits_ngn
    FROM totals
)
SELECT month_start, deposits_ngn, prior_month_deposits_ngn,
       ROUND((deposits_ngn - prior_month_deposits_ngn) * 100.0
             / NULLIF(prior_month_deposits_ngn, 0), 2) AS mom_change_pct
FROM comparison ORDER BY month_start;
