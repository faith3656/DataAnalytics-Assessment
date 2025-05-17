SELECT

    u.id AS customer_id,

    COALESCE(u.name, CONCAT_WS(' ', u.first_name, u.last_name)) AS name,

    
    -- Calculate account tenure in months (from signup to today)


    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    
    -- Total number of transactions per customer


    COUNT(sa.id) AS total_transactions,
    
    -- Average profit per transaction = 0.1% of transaction value
    -- estimated_clv = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
    -- avg_profit_per_transaction = AVG(confirmed_amount) * 0.001


    CASE
        WHEN TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) = 0 THEN NULL
        ELSE 

            (COUNT(sa.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (AVG(sa.confirmed_amount) * 0.001)


    END AS estimated_clv

FROM

    users_customuser u

LEFT JOIN

    savings_savingsaccount sa ON u.id = sa.owner_id

GROUP BY


    u.id, u.name, u.first_name, u.last_name, u.date_joined

ORDER BY


    estimated_clv DESC;






