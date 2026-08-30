# SQL for business analysis

This repository contains eight MySQL 8.0 queries for business questions that come up repeatedly in reporting and analysis.

## What is included

| Business question | SQL used |
|---|---|
| How is revenue changing each month? | CTE, `LAG`, safe division |
| Which customers drive lifetime value? | Aggregation and ranking |
| How does retention change by acquisition cohort? | Multi-step CTE and date arithmetic |
| What is the running trend and three-month average? | Window frames |
| Which products are bought together? | Self-join and basket analysis |
| Which products lead each category? | `DENSE_RANK` and partitioning |
| Which valuable customers have gone inactive? | `HAVING` and recency |
| Is the order data safe to report? | Duplicate, null and domain checks |

## How I structured it

Completed orders are isolated before revenue is calculated. Divisions use `NULLIF` when a denominator could be zero. Cohort size is calculated separately so the retention percentage can be checked.

## Tools used

MySQL 8.0, CTEs, window functions, joins, date functions and data-quality checks.

## Run it

1. Create the tables with [schema.sql](schema.sql).
2. Load customer, product, order and order-item data.
3. Run the numbered sections in [business_queries.sql](business_queries.sql) one at a time.

Some date functions are specific to MySQL, so the queries are not presented as PostgreSQL-compatible.
