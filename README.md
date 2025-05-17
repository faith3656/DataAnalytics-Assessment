 DataAnalytics-Assessment  
This repository contains my solutions for the SQL proficiency assessment designed to test data retrieval, aggregation, joins, subqueries, and data manipulation skills across multiple tables.

---

 Per-Question Explanations

 Question 1: High-Value Customers with Multiple Products

Approach:  
- Joined the `users_customuser` table with aggregated savings and investment plans from `plans_plan`.  
- Filtered customers having at least one funded savings plan and one funded investment plan.  
- Calculated total deposits from `savings_savingsaccount`.  
- Sorted customers by total deposits to highlight high-value customers with cross-selling opportunities.

Challenges: 
- Avoiding double counting due to multiple joins and aggregation.  
- Handling cases where customer names were missing by concatenating first and last names.

---

Question 2: Transaction Frequency Analysis

Approach:  
- Counted total transactions per customer from `savings_savingsaccount`.  
- Calculated account tenure in months between first and last transactions.  
- Derived average transactions per month per customer.  
- Categorized customers into High (≥10), Medium (3-9), and Low (≤2) frequency groups.  
- Aggregated counts and averages per frequency category.

Challenges:  
- Managing null or missing dates in transaction records.  
- Accurate tenure calculation to avoid skewed averages.  
- Defining clear frequency category thresholds.

---

Question 3: Account Inactivity Alert

Approach:  
- Identified active plans from `plans_plan` and linked related transactions in `savings_savingsaccount`.  
- Calculated last transaction date and inactivity days (days since last transaction).  
- Flagged accounts with no inflow transactions for over 365 days, including those with no transactions ever (NULL last transaction date).  
- Included plan type (Savings or Investment) in results.

Challenges:  
- Handling NULL transaction dates representing no transaction history.  
- Combining data from different plan types into one unified report.  
- Correct date arithmetic for inactivity calculation.

---

Question 4: Customer Lifetime Value (CLV) Estimation

Approach:  
- Computed account tenure in months based on customer signup date.  
- Summed total transactions from `savings_savingsaccount`.  
- Calculated average profit per transaction as 0.1% of transaction values.  
- Estimated CLV using the formula:  
  `(total_transactions / tenure) * 12 * avg_profit_per_transaction`  
- Ordered results descending by estimated CLV to identify top customers.

Challenges:  
- Avoiding division by zero for customers with zero tenure.  
- Accurately aggregating transaction data for profit calculation.  
- Applying business logic consistently in the CLV formula.

---

General Challenges

- Ensuring accurate joins and aggregations across multiple tables without duplications.  
- Handling missing or incomplete data gracefully.  
- Writing efficient queries suitable for large datasets.  
- Formatting output clearly to match expected results.

---



