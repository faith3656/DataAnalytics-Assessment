-- Q3: Account Inactivity Alert

SELECT

    p.id AS plan_id,

    p.owner_id,

    CASE

        WHEN p.is_regular_savings = 1 THEN 'Savings'

        WHEN p.is_a_fund = 1 THEN 'Investment'

        ELSE  'Other'

    END AS type,

    MAX(sa.transaction_date) AS last_transaction_date,

    COALESCE(DATEDIFF(CURDATE(), MAX(sa.transaction_date)), 9999) AS inactivity_days,

    CASE

        WHEN MAX(sa.transaction_date) IS NULL THEN 'No transactions ever'

        WHEN DATEDIFF(CURDATE(), MAX(sa.transaction_date)) > 365 THEN 'Inactive > 1 year'

        ELSE 'Active'

    END AS inactivity_reason

FROM

    plans_plan p

LEFT JOIN

    savings_savingsaccount sa ON p.id = sa.plan_id
    AND sa.confirmed_amount > 0

WHERE

    p.is_regular_savings = 1 OR p.is_a_fund = 1

GROUP BY

    p.id, p.owner_id, type

HAVING

    inactivity_reason IN ('No transactions ever', 'Inactive > 1 year')

ORDER BY

    inactivity_days DESC;




