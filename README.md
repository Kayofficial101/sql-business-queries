# SQL for Business Analytics

Eight focused **MySQL 8.0** query patterns for common commercial and operating questions. Each query is written to produce a decision-ready output rather than demonstrate syntax in isolation.

## Query map

| # | Business question | SQL concepts |
|---|---|---|
| 1 | How is revenue changing month over month? | CTE, `LAG`, safe division |
| 2 | Which customers drive the most lifetime value? | Aggregation, date range, ranking |
| 3 | How does retention change by acquisition cohort? | Multi-step CTE, date arithmetic |
| 4 | What is the running trend and three-month baseline? | Window frames, moving average |
| 5 | Which products are frequently purchased together? | Self-join, basket analysis |
| 6 | Which products lead within each category? | `DENSE_RANK`, partitioning |
| 7 | Which valuable customers have become inactive? | `HAVING`, recency calculation |
| 8 | Is the order data safe to report? | Duplicate, null and domain checks |

## Files

- [`business_queries.sql`](business_queries.sql): the eight analysis queries
- [`schema.sql`](schema.sql): minimal table definitions and relationships

## Run order

1. Create the four tables with `schema.sql`.
2. Load your own customer, product, order and order-item data.
3. Run the numbered sections in `business_queries.sql` independently.

The dialect is intentionally stated as MySQL 8.0. The repository does not claim PostgreSQL compatibility because several date functions are MySQL-specific.

## Design choices

- Completed orders are isolated before revenue calculations.
- Divisions use `NULLIF` where a zero denominator is possible.
- Cohort size is calculated separately so retention percentages stay auditable.
- The final query checks the basic conditions that can invalidate a report.
