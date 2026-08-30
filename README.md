# SQL for business analysis

Eight MySQL 8.0 queries for recurring commercial and reporting questions.

| # | Question | Main SQL |
|---|---|---|
| 1 | How is revenue changing month by month? | CTE, `LAG`, safe division |
| 2 | Which customers drive lifetime value? | Aggregation and ranking |
| 3 | How does retention change by acquisition cohort? | Multi-step CTE and date arithmetic |
| 4 | What is the running trend and three-month average? | Window frames |
| 5 | Which products are bought together? | Self-join and basket analysis |
| 6 | Which products lead each category? | `DENSE_RANK` and partitioning |
| 7 | Which valuable customers have gone inactive? | `HAVING` and recency |
| 8 | Is the order data safe to report? | Duplicate, null and domain checks |

## Run

1. Create the tables with [`schema.sql`](schema.sql).
2. Load customer, product, order and order-item data.
3. Run the numbered sections in [`business_queries.sql`](business_queries.sql) independently.

Completed orders are isolated before revenue calculations. Divisions use `NULLIF` when the denominator may be zero. Cohort size is calculated separately so the retention percentage can be checked. Several date functions are MySQL-specific, so the repository does not claim PostgreSQL compatibility.
