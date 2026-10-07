# Interview project walkthrough

## A short introduction to practise

Use your own words: this project started as a financial customer SQL assessment. It answers four questions about funded product ownership, transaction frequency, inactivity and an estimated customer profit metric. The revision makes the definitions explicit, corrects edge cases, and adds a monthly trend query. A small synthetic dataset helps check the results without exposing customer information.

## Five-minute demonstration

1. Explain the three tables and their grains. One customer can own many plans; one plan can have many transactions.
2. Open Q1. Show why positive inflows must qualify each product, and why aggregating first prevents double counting.
3. Open Q2. Explain the inclusive calendar-month denominator and the 9.5 boundary case. A different business goal may need signup-to-today frequency.
4. Open Q3. Explain strict >365-day inactivity, reporting date, and why never-funded plans are a separate review list.
5. Open Q4. Explain kobo-to-naira conversion, zero tenure and the assumed 0.1% profit margin. Call the result an annual profit proxy.
6. Open the trend query. Explain the calendar spine, LAG and NULL change after a zero month.
7. Show outputs or the dashboard if you have actually built it. State clearly what was tested and what still needs validation against the source system.

## Questions to rehearse

| Question | Point to cover |
| --- | --- |
| Why not join all three tables and count directly? | Multiple transactions per plan multiply rows. Establish reporting grain and aggregate first. |
| What does funded mean? | At least one positive confirmed_amount linked to the plan and owner; validate status/reversal semantics with the data owner. |
| Why not treat no transactions as 9999 inactive days? | No last transaction does not establish age. Creation date is needed for onboarding-age analysis. |
| What if a customer has 9.5 monthly transactions? | Medium, using >=3 and <10; no gap between category boundaries. |
| Is your metric really lifetime value? | It is the assessment's annualised profit proxy. Lifetime value needs retention, forecast horizon and richer cost assumptions. |
| Why LAG with a calendar spine? | Without zero months, the previous row may not be the previous calendar month. |
| How would you make it faster? | Inspect EXPLAIN ANALYZE and row counts first; evaluate owner/plan/date indexes on representative data, and measure before/after. |
| How did you test it? | Synthetic boundary-case assertions using SQLite compatibility functions; native MySQL and original data validation remain to do. |
| What business action follows? | Product-adoption review, re-engagement of dated stale plans, separate unfunded onboarding follow-up; demonstrate logic without claiming actual revenue results. |

## Limits to disclose

Original database/schema and active-status semantics were unavailable. New code is a reviewed portfolio revision with assistance, so practise until you can explain and change every query yourself. No live Metabase deployment, PostgreSQL/JSONB implementation, production query-plan benchmarking or measured business impact is claimed.
