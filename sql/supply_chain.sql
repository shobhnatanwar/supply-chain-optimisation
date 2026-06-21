use supply_chain;
show tables;
select * from supply_chain_data;
SELECT COUNT(*) FROM supply_chain_data;
SELECT * FROM supply_chain_data LIMIT 5;

##Check for any missing values
SELECT
    COUNT(*) - COUNT(delivery_date) AS missing_delivery,
    COUNT(*) - COUNT(shipping_cost) AS missing_cost,
    COUNT(*) - COUNT(route_id) AS missing_route
FROM supply_chain_data;

##On-Time Delivery %
SELECT
    ROUND(
        SUM(CASE WHEN delay_days_calc <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate
FROM supply_chain_data;

##Logistics Cost
SELECT
    ROUND(SUM(shipping_cost), 2) AS total_cost
FROM supply_chain_data;

##Average Cost per delivery
SELECT
    ROUND(AVG(shipping_cost), 2) AS avg_cost
FROM supply_chain_data;

##Average Delivery Time
SELECT
    ROUND(AVG(delivery_time), 2) AS avg_delivery_time
FROM supply_chain_data;

##Cost Lost due to delays
SELECT
    ROUND(SUM(shipping_cost), 2) AS delay_cost
FROM supply_chain_data
WHERE delay_days_calc > 0;

##Regional Performance
SELECT
    region,
    COUNT(*) AS orders,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(AVG(delay_days_calc), 2) AS avg_delay,
    ROUND(
        SUM(CASE WHEN delay_days_calc > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate
FROM supply_chain_data
GROUP BY region
ORDER BY avg_cost DESC;

##Inefficient Routes
SELECT
    route_id,
    COUNT(*) AS orders,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(AVG(delivery_time), 2) AS avg_time
FROM supply_chain_data
GROUP BY route_id
ORDER BY avg_cost DESC, avg_time DESC;

##Worst Routes
SELECT *
FROM (
    SELECT
        route_id,
        AVG(shipping_cost) AS avg_cost,
        AVG(delivery_time) AS avg_time
    FROM supply_chain_data
    GROUP BY route_id
) t
WHERE avg_cost > (SELECT AVG(shipping_cost) FROM supply_chain_data)
AND avg_time > (SELECT AVG(delivery_time) FROM supply_chain_data);

##Carrier analysis
SELECT
    carrier_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(
        SUM(CASE WHEN delay_days_calc <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate
FROM supply_chain_data
GROUP BY carrier_id
ORDER BY avg_cost ASC;

##High Value Risk
SELECT
    high_value,
    COUNT(*) AS orders,
    ROUND(AVG(delay_days_calc), 2) AS avg_delay,
    ROUND(
        SUM(CASE WHEN delay_days_calc > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS delay_rate
FROM supply_chain_data
GROUP BY high_value;

##Monthly Trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS orders,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(AVG(delay_days_calc), 2) AS avg_delay
FROM supply_chain_data
GROUP BY month
ORDER BY month;

##KPI
CREATE VIEW kpi_summary AS
SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(AVG(delivery_time), 2) AS avg_delivery_time,
    ROUND(
        SUM(CASE WHEN delay_days_calc <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_rate
FROM supply_chain_data;

##KPI Regional
CREATE VIEW region_analysis AS
SELECT
    region,
    COUNT(*) AS total_orders,
    AVG(shipping_cost) AS avg_cost,
    AVG(delay_days_calc) AS avg_delay
FROM supply_chain_data
GROUP BY region;