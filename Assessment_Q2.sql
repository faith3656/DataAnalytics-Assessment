-- Q2: Transaction Frequency Analysis
-- Calculate transaction frequency category for each customer

WITH customer_activity AS (
    SELECT
        sa.owner_id,
        COUNT(*) AS total_transactions,
        GREATEST(
            TIMESTAMPDIFF(MONTH, MIN(sa.transaction_date), MAX(sa.transaction_date)),
            1
        ) AS months_active

    FROM

        savings_savingsaccount sa

    GROUP BY

        sa.owner_id
),
transaction_frequency AS (

    SELECT

        ca.owner_id,
        ca.total_transactions,
        ca.months_active,
        ca.total_transactions / ca.months_active AS avg_txn_per_month,
        CASE

            WHEN ca.total_transactions / ca.months_active >= 10 THEN 'High Frequency'
            WHEN ca.total_transactions / ca.months_active BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'

        END AS frequency_category

    FROM

        customer_activity ca
)

  -- Final output: group by category
  
SELECT

    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month

FROM

    transaction_frequency

GROUP BY

    frequency_category

ORDER BY

    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');






