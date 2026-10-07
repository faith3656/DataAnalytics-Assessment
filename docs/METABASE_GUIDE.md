# Build the financial customer dashboard

This is a build guide, not evidence of an existing dashboard. Use only the synthetic demo database.

1. Connect Metabase to the new MySQL database with a read-only user after loading the fixture.
2. Save each root query as a native SQL question. Give each question a plain title and explain units and date scope in its description.
3. Create a dashboard named **Financial Customer Analytics — Synthetic Demo**.
4. Add Q1 as a customer table; Q2 as a category bar chart; Q3 as a stale-plan table; Q4 as a customer value table; trends as a monthly line chart. Keep the unfunded-plan question separate from the stale-plan metric.
5. Format currency as NGN, percentage as percent, and month on the horizontal axis. Do not render NULL month-on-month values as zero.
6. Add a dashboard text card stating: synthetic data; reporting date 7 October 2026 for Q3/Q4; April–September 2026 for the trend chart; remaining questions use available history; margin assumption 0.1%.
7. Reconcile the displayed trend total to NGN 5,900 and full-history inflows to NGN 7,150. Confirm the 9.5 frequency case is medium and plan 61 is the only stale plan.
8. Export a screenshot only after verifying the dashboard. Add it to the README with an accurate caption.

## Optional date control

In Q3/Q4, replace `CAST('2026-10-07' AS DATE)` with `CAST({{as_of_date}} AS DATE)` inside the parameters CTE. Configure `as_of_date` as a required **Date** variable and supply 7 October 2026 for the demo. This is a basic variable, not a field filter. Confirm dashboard mapping to both questions, then rerun reconciliation.

## What to explain

Describe which reports are customer-level versus plan-level, how dates change the population, and why unfunded plans need a different follow-up list. Say you built the Metabase dashboard only after actually completing and testing these steps.
