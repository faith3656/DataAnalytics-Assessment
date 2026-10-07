-- Plans without a positive inflow: separate onboarding review, NOT >365-day inactivity.
SELECT p.id AS plan_id, p.owner_id, 'No positive inflow recorded' AS review_reason
FROM plans_plan p
WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1)
  AND NOT EXISTS (
    SELECT 1 FROM savings_savingsaccount sa
    WHERE sa.plan_id = p.id AND sa.owner_id = p.owner_id AND sa.confirmed_amount > 0
  )
ORDER BY p.id;
