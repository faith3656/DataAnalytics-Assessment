# Financial Customer Analytics | SQL Portfolio

An assessment-based project exploring savings and investment customers: funded product ownership, transaction frequency, inactive plans and an estimated annual profit metric. The original work is preserved in `original/`; the root queries are a documented portfolio revision.

**Technology:** MySQL 8+ SQL, joins, CTEs, conditional aggregation, date arithmetic, recursive calendar spine and `LAG` window function.

**Status:** SQL review and synthetic edge-case smoke tests completed. Original source data and schema were not supplied. Native MySQL execution, production reconciliation and a live Metabase dashboard have not yet been verified. No HerVest data or business results are represented here.

## Business questions

| File | Question | Reporting grain |
| --- | --- | --- |
| `Assessment_Q1.sql` | Which customers have funded savings and investment plans? | Customer |
| `Assessment_Q2.sql` | How frequently do customers make positive inflows? | Frequency category |
| `Assessment_Q3.sql` | Which previously funded plans have no inflow for over 365 days? | Plan |
| `Assessment_Q4.sql` | What annual profit proxy follows from the assessment formula? | Customer |
| `Monthly_Deposit_Trends.sql` | How do deposits change across consecutive calendar months? | Month |
| `Unfunded_Plans_Review.sql` | Which plans have no positive inflow recorded? | Plan |

## Run the demonstration

1. Create a **new, empty** MySQL 8+ database for this project. Do not use a production database.
2. Run `demo/setup_mysql.sql` inside that database. All names and transactions are synthetic.
3. Run the root SQL files. Q3/Q4 use a fixed reporting date of **7 October 2026**; the trend query covers **April–September 2026**.
4. Compare with `demo/*_output.csv`. These expected outputs were generated through SQLite compatibility smoke tests, so verify them on MySQL before describing this as a MySQL-tested project.
5. Follow `docs/METABASE_GUIDE.md` to build the dashboard.

Optional local smoke check: `python demo/verify_demo.py` (Python standard library only). It regenerates the synthetic fixture, expected CSVs and validation report. See the script for its explicit MySQL-to-SQLite date-expression substitutions.

## Data contract and metric definitions

The demo schema reflects only columns visible in the original SQL, not a recovered production schema.

| Table | Grain | Key fields |
| --- | --- | --- |
| `users_customuser` | One customer | `id`, name fields, `date_joined` |
| `plans_plan` | One plan | `id`, `owner_id`, `is_regular_savings`, `is_a_fund` |
| `savings_savingsaccount` | One transaction record | `id`, `owner_id`, `plan_id`, `transaction_date`, `confirmed_amount` |

- Amounts are treated as **kobo**, following the original Q1 convention; outputs divide by 100 to report naira.
- `confirmed_amount > 0` defines a positive inflow. This is an assumption, not a verified successful-payment status filter. Withdrawals, reversals and failed-payment semantics need a source data dictionary.
- Q1 qualifies each product through a positive transaction linked to that plan and owner. Deposit totals include all positive customer inflows. It returns all qualifying customers; apply a display limit separately.
- Q2 uses **inclusive calendar months between first and last dated positive inflow**. High is >=10/month; medium is >=3 and <10; low is <3. Customers without dated positive inflows are excluded. This measure does not include inactivity after the last inflow.
- Q3 applies a strict **>365 days** threshold to dated positive inflows on or before the reporting date. Never-funded plans are reviewed separately. An active-status field and plan creation date have not been verified; this query therefore makes no claim to restrict results to currently active plans.
- Q4 uses completed signup-to-reporting months. Tenure <=0 returns NULL; established customers without qualifying transactions return zero. The assessment's assumed 0.1% margin is retained. The metric is an **annualised profit proxy**, not a retention-based lifetime-value model.
- Q1/Q2/unfunded review use all available qualifying history; Q3/Q4 are as-of-date reports, and trends use the stated six-month window. Align these scopes explicitly before making a production dashboard.
- A plan with both product flags qualifies for both categories; Q3 labels it `Savings / Investment`. Confirm whether this is valid in the real model.

## Quality checks and demonstrable results

The small synthetic fixture deliberately covers boundary cases. These are demonstrations, not commercial outcomes:

- One customer qualifies for both funded products; deposits total **NGN 3,000**.
- A customer at **9.5** transactions/month is medium frequency.
- A plan at exactly **365** days is excluded; one at **366** is included.
- A new never-funded plan is not incorrectly labelled inactive for a year.
- April–September deposits are **NGN 5,900**, including zero months.
- All positive inflows across the full fixture total **NGN 7,150**.
- The sample customer's annual profit proxy is **NGN 3**, with consistent currency conversion.
- Month-on-month change is NULL when the prior month is zero or missing.

The smoke checks use SQLite with compatibility functions. They check logical outputs, not MySQL parser/optimizer behavior, permissions, BI deployment or production performance.

## Design choices

Aggregate to the required grain before joining: counting transaction rows as plans would inflate product counts. Use explicit units and reporting windows; avoid fake sentinel dates for unknown inactivity. Use a full calendar spine before `LAG`, so a missing month does not silently compare non-adjacent periods.

Before production use, verify transaction IDs are unique, plan/customer references match, timestamps have a defined timezone, and amount/status semantics are documented. Investigate NULL dates and future transactions instead of silently treating them as normal activity. Use `EXPLAIN ANALYZE` on representative MySQL data before choosing indexes; no performance improvement is claimed from this tiny fixture.

## Presentation

See `docs/INTERVIEW_WALKTHROUGH.md` for a short project introduction, query explanations and likely follow-up questions. Metabase is the next demonstration step; its dashboard is not yet built.
