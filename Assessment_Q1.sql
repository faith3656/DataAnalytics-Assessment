SELECT
    u.id AS owner_id,
    COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name)) AS name,
    COALESCE(s.savings_count, 0) AS savings_count,
    COALESCE(i.investment_count, 0) AS investment_count,
    COALESCE(SUM(sa.confirmed_amount), 0) / 100 AS total_deposits -- conerting kobo to naira 
FROM
    users_customuser u
    -- count of savings plan per customer 
    LEFT JOIN (
        SELECT owner_id, COUNT(*) AS savings_count
        FROM plans_plan
        WHERE is_regular_savings = 1
        GROUP BY owner_id
    ) s ON u.id = s.owner_id
    --count of investment plan per customer 
    LEFT JOIN (
        SELECT owner_id, COUNT(*) AS investment_count
        FROM plans_plan
        WHERE is_a_fund = 1
        GROUP BY owner_id
    ) i ON u.id = i.owner_id
    -- join savings deposit to sum total deposit per customer 
    LEFT JOIN savings_savingsaccount sa ON u.id = sa.owner_id
WHERE
    COALESCE(s.savings_count, 0) > 0
    AND COALESCE(i.investment_count, 0) > 0
GROUP BY
    u.id, u.name, u.first_name, u.last_name, s.savings_count, i.investment_count
ORDER BY
    total_deposits DESC
LIMIT 10;


