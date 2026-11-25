{% docs fulfilled_order %}
An order whose status is `completed` or `shipped`. Cancelled and refunded
orders are excluded from `fct_orders` and from lifetime revenue. The
status list lives in one place, `fulfilled_statuses` in
`dbt_project.yml`, and every model reads it through the
`fulfilled_statuses_list` macro.
{% enddocs %}

{% docs net_revenue %}
Gross revenue minus the discount actually applied. The discount is
capped at gross revenue (see `capped_discount`), so net revenue can
never go below zero for an order, even when the raw discount is larger
than the order value.
{% enddocs %}

{% docs discount_applied %}
The discount actually subtracted from an order: the raw discount,
floored at zero and capped at the order's gross revenue. When the raw
discount is larger than gross revenue, `discount_applied` is smaller
than `discount_amount`; the difference is the amount the cap removed.
{% enddocs %}

{% docs value_tier %}
Customer value band from lifetime fulfilled revenue: `high_value` at or
above the high threshold, `mid_value` at or above the mid threshold,
`low_value` for customers with orders below the mid threshold, and
`never_ordered` for customers with no orders. Thresholds are the
`value_tier_high_threshold` and `value_tier_mid_threshold` vars in
`dbt_project.yml`.
{% enddocs %}

{% docs gross_margin_pct %}
Gross profit as a share of gross revenue. Null when gross revenue is
zero, so a zero-revenue order never raises a divide-by-zero error.
{% enddocs %}
