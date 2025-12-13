============================================================================================================================================================================================
Q1: User Activity Summary
============================================================================================================================================================================================
SELECT
	customer_id,
	MAX(activity_date) AS last_activity_date,
	SUM(minutes_used) AS total_minutes,
	COUNT(DISTINCT activity_date) AS active_days
FROM Usage_Data
GROUP BY customer_id

============================================================================================================================================================================================
Q2: Days Since Last Activity
============================================================================================================================================================================================
SELECT 
	customer_id,
	MAX(activity_date) AS last_activity_date,
	DATEDIFF(DAY,MAX(activity_date),'2025-12-31') days_since_last_activity			 
FROM Usage_Data
GROUP BY customer_id

============================================================================================================================================================================================
Q3: User Segmentation
============================================================================================================================================================================================
SELECT 
	customer_id,
	MAX(activity_date) AS last_activity_date,
	SUM(minutes_used) AS total_minutes,
	DATEDIFF(DAY,MAX(activity_date),'2025-12-31') days_since_last_activity,
	CASE 
		WHEN DATEDIFF(DAY,MAX(activity_date),'2025-12-31') > 45 THEN 'High Risk'
		WHEN DATEDIFF(DAY,MAX(activity_date),'2025-12-31') <= 45 AND  SUM(minutes_used) < 100 THEN 'Low Engagement'
		WHEN DATEDIFF(DAY,MAX(activity_date),'2025-12-31') <= 45 AND  SUM(minutes_used) >= 100 THEN 'Highly Engaged'
	END AS user_segment			 
FROM Usage_Data
GROUP BY customer_id

============================================================================================================================================================================================
Q4: Behavior + Support (Customer Level)
============================================================================================================================================================================================
WITH CTE_usage AS
(
	SELECT 
		customer_id,
		MAX(activity_date) AS last_activity_date,
		SUM(minutes_used) AS total_minutes,
		COUNT(DISTINCT activity_date) AS active_days, 
		DATEDIFF(DAY,MAX(activity_date),'2025-12-31') AS days_since_last_activity			 
	FROM Usage_Data
	GROUP BY customer_id
),
CTE_support AS
( 
	SELECT 
		customer_id,
		COUNT(ticket_id) AS ticket_count,
		AVG(resolution_days) AS avg_resolution_days
	FROM Support_Tickets
	GROUP BY customer_id
)

SELECT
    u.customer_id,
    u.last_activity_date,
    u.days_since_last_activity,
    u.total_minutes,
    u.active_days,
    s.ticket_count,
    s.avg_resolution_days,
    CASE
        WHEN u.days_since_last_activity > 45 THEN 'High Risk'
        WHEN u.days_since_last_activity <= 45
             AND u.total_minutes < 100 THEN 'Low Engagement'
        ELSE 'Highly Engaged'
    END AS user_segment
FROM CTE_usage u
LEFT JOIN CTE_support s
    ON u.customer_id = s.customer_id
ORDER BY
    CASE
        WHEN u.days_since_last_activity > 45 THEN 1
        WHEN u.days_since_last_activity <= 45
             AND u.total_minutes < 100 THEN 2
        ELSE 3
    END;

============================================================================================================================================================================================
Q5.1: Support Volume vs Churn Risk
============================================================================================================================================================================================

WITH CTE_usage AS
(
	SELECT 
		customer_id,
		MAX(activity_date) AS last_activity_date,
		SUM(minutes_used) AS total_minutes,
		COUNT(DISTINCT activity_date) AS active_days, 
		DATEDIFF(DAY,MAX(activity_date),'2025-12-31') AS days_since_last_activity			 
	FROM Usage_Data
	GROUP BY customer_id
),

CTE_support AS
( 
	SELECT 
		customer_id,
		COUNT(ticket_id) AS ticket_count,
		AVG(resolution_days) AS avg_resolution_days
	FROM Support_Tickets
	GROUP BY customer_id
),

CTE_cust_base AS 
(
    SELECT
        U.customer_id,
        CASE 
		WHEN U.days_since_last_activity > 45 THEN 'High Risk'
		WHEN U.days_since_last_activity <= 45 AND  U.total_minutes < 100 THEN 'Low Engagement'
		ELSE 'Highly Engaged'
	END AS user_segment,
    COALESCE(S.ticket_count,0) AS ticket_count
    FROM CTE_usage U
    LEFT JOIN CTE_support S
    ON U.customer_id = S.customer_id    
)

SELECT
    user_segment,
    COUNT(customer_id) AS customer_count,
    AVG(ticket_count) AS avg_tickets_per_customer
FROM CTE_cust_base 
GROUP BY user_segment
ORDER BY avg_tickets_per_customer DESC

============================================================================================================================================================================================
Q5.2: Resolution Time vs Churn Risk
============================================================================================================================================================================================
WITH CTE_usage AS 
(
	SELECT 
		customer_id,
		SUM(minutes_used) AS total_minutes,
		DATEDIFF(DAY,MAX(activity_date),'2025-12-31') AS days_since_last_activity
	FROM Usage_Data
	GROUP BY customer_id
),

CTE_support AS
(
	SELECT
		customer_id,
		AVG(resolution_days) AS avg_resolution_days
	FROM Support_Tickets
	GROUP BY customer_id
),

CTE_cust_base AS 
(
	SELECT 
		U.customer_id,
		CASE 
			WHEN U.days_since_last_activity > 45 THEN 'High Risk'
			WHEN U.days_since_last_activity <= 45 AND  U.total_minutes < 100 THEN 'Low Engagement'
			ELSE 'Highly Engaged'
	    END AS user_segment,
		S.avg_resolution_days
	FROM CTE_usage U
	LEFT JOIN CTE_support S
	ON U.customer_id = S.customer_id
)

SELECT
	user_segment,
	AVG(avg_resolution_days) AS avg_resolution_days
FROM CTE_cust_base
GROUP BY user_segment
ORDER BY avg_resolution_days DESC

============================================================================================================================================================================================
Q5.3: Silent Churn Risk
============================================================================================================================================================================================
WITH CTE_usage AS 
(
	SELECT 
		customer_id,
		SUM(minutes_used) AS total_minutes,
		DATEDIFF(DAY,MAX(activity_date),'2025-12-31') AS days_since_last_activity
	FROM Usage_Data
	GROUP BY customer_id
),

CTE_support AS
(
	SELECT
		customer_id,
		COUNT(ticket_id) AS ticket_count
	FROM Support_Tickets
	GROUP BY customer_id
)

SELECT
	U.customer_id,
	U.days_since_last_activity,
	U.total_minutes,
	COALESCE(S.ticket_count,0) AS ticket_count
FROM CTE_usage U
LEFT JOIN CTE_support S
ON U.customer_id = S.customer_id
WHERE ticket_count = 0 AND U.days_since_last_activity > 45
ORDER BY U.days_since_last_activity DESC
