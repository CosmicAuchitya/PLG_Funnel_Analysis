/* =========================================================
   PROJECT: Product-Led Growth (PLG) Funnel Analysis
   DATABASE: plg_analytics
   AUTHOR: Auchitya singh
   STATUS: Analysis Complete | Insights Documented Separately

   DESCRIPTION:
   This SQL script contains the complete end-to-end analysis
   of a freemium SaaS Product-Led Growth (PLG) funnel.
   All steps are executed sequentially and documented
   alongside the analysis workflow.

   NOTE:
   - Schema definitions are provided below for reference.
   - This script is intentionally kept as a single file
     to preserve execution order and analytical narrative.
   ========================================================= */


/* =========================================================
   DATABASE SCHEMA REFERENCE
   (Logical structure used for analysis)
   =========================================================

   TABLE: users
   ---------------------------------------------------------
   user_id              VARCHAR
   signup_date          DATE
   persona              VARCHAR
       -- student | hobbyist | professional | team
   acquisition_channel  VARCHAR
       -- organic | paid_ads | email | referral


   TABLE: events
   ---------------------------------------------------------
   user_id      VARCHAR
   event_time   DATETIME
   event_name   VARCHAR
       -- signup | code_run | deploy | collaborate | upgrade
   platform     VARCHAR
   session_id   VARCHAR


   TABLE: subscriptions
   ---------------------------------------------------------
   user_id      VARCHAR
   plan_type    VARCHAR
   start_date   DATE
   mrr          DECIMAL


   TABLE: marketing_spend
   ---------------------------------------------------------
   date         DATETIME
   channel      VARCHAR
   spend        DECIMAL

========================================================= */



/* =========================================================
   STEP 1: SCHEMA VERIFICATION & INITIAL DATA VALIDATION
   Purpose: Ensure all base tables exist and contain data
   ========================================================= */

SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM marketing_spend;
SELECT COUNT(*) FROM subscriptions;
SELECT COUNT(*) FROM events;


/* =========================================================
   STEP 2: EVENTS TABLE RESET (CLEAN REBUILD)
   Purpose: Resolve CSV loading issues by recreating table
   ========================================================= */

DROP TABLE IF EXISTS events;
USE plg_analytics;

CREATE TABLE events (
    user_id VARCHAR(20),
    event_time DATETIME,
    event_name VARCHAR(50),
    platform VARCHAR(20),
    session_id VARCHAR(50)
);


/* =========================================================
   STEP 3: ENABLE LARGE FILE INGESTION
   Purpose: Allow bulk CSV loading using LOAD DATA INFILE
   ========================================================= */

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';


/* =========================================================
   STEP 4: BULK LOAD EVENT-LEVEL DATA
   Purpose: Load large-scale event data into MySQL
   ========================================================= */

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv'
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


/* =========================================================
   STEP 5: POST-LOAD DATA VALIDATION
   Purpose: Sanity check event volume and key funnel events
   ========================================================= */

SELECT COUNT(*) FROM events;

SELECT COUNT(DISTINCT user_id)
FROM events
WHERE event_name = 'signup';

SELECT COUNT(DISTINCT user_id)
FROM events
WHERE event_name = 'upgrade';


/* =========================================================
   STEP 6: OVERALL FUNNEL AGGREGATION
   Purpose: Measure user progression across PLG funnel
   ========================================================= */

SELECT
    event_name,
    COUNT(DISTINCT user_id) AS users
FROM events
WHERE event_name IN ('signup','code_run','deploy','collaborate','upgrade')
GROUP BY event_name
ORDER BY FIELD(event_name,'signup','code_run','deploy','collaborate','upgrade');


/* =========================================================
   STEP 7: END-TO-END CONVERSION RATE
   Purpose: Calculate signup → paid upgrade conversion
   ========================================================= */

SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name='upgrade' THEN user_id END)
        * 100.0 /
        COUNT(DISTINCT CASE WHEN event_name='signup' THEN user_id END),
    2) AS conversion_rate_percent
FROM events;


/* =========================================================
   STEP 8: FUNNEL DROP-OFF ANALYSIS
   Purpose: Identify major activation bottlenecks
   ========================================================= */

WITH funnel AS (
    SELECT
        event_name,
        COUNT(DISTINCT user_id) AS users
    FROM events
    WHERE event_name IN ('signup','code_run','deploy','collaborate','upgrade')
    GROUP BY event_name
)
SELECT
    event_name,
    users,
    users - LEAD(users) OVER (
        ORDER BY FIELD(event_name,'signup','code_run','deploy','collaborate','upgrade')
    ) AS drop_off
FROM funnel;


/* =========================================================
   STEP 9: PERSONA-WISE FUNNEL ANALYSIS
   Purpose: Compare funnel behavior across user personas
   ========================================================= */

SELECT
    u.persona,
    e.event_name,
    COUNT(DISTINCT e.user_id) AS users
FROM events e
JOIN users u ON e.user_id = u.user_id
WHERE e.event_name IN ('signup','code_run','deploy','collaborate','upgrade')
GROUP BY u.persona, e.event_name
ORDER BY u.persona,
         FIELD(e.event_name,'signup','code_run','deploy','collaborate','upgrade');


/* =========================================================
   STEP 10: CHANNEL-WISE FUNNEL AGGREGATION
   Purpose: Measure funnel depth by acquisition channel
   ========================================================= */

SELECT
    u.acquisition_channel,
    COUNT(DISTINCT CASE WHEN e.event_name = 'signup' THEN u.user_id END) AS signup_users,
    COUNT(DISTINCT CASE WHEN e.event_name = 'code_run' THEN u.user_id END) AS code_run_users,
    COUNT(DISTINCT CASE WHEN e.event_name = 'deploy' THEN u.user_id END) AS deploy_users,
    COUNT(DISTINCT CASE WHEN e.event_name = 'collaborate' THEN u.user_id END) AS collaborate_users,
    COUNT(DISTINCT CASE WHEN e.event_name = 'upgrade' THEN u.user_id END) AS upgrade_users
FROM users u
LEFT JOIN events e
    ON u.user_id = e.user_id
GROUP BY u.acquisition_channel
ORDER BY upgrade_users DESC;


/* =========================================================
   STEP 11: CHANNEL-WISE CONVERSION RATE
   Purpose: Compare signup → upgrade efficiency by channel
   ========================================================= */

SELECT
    u.acquisition_channel,
    COUNT(DISTINCT u.user_id) AS signup_users,
    COUNT(DISTINCT s.user_id) AS upgrade_users,
    ROUND(
        COUNT(DISTINCT s.user_id) * 100.0 /
        COUNT(DISTINCT u.user_id),
    2) AS conversion_rate_percent
FROM users u
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id
GROUP BY u.acquisition_channel
ORDER BY conversion_rate_percent DESC;


/* =========================================================
   STEP 12: CHANNEL-WISE MARKETING SPEND
   Purpose: Aggregate total spend per acquisition channel
   ========================================================= */

SELECT
    channel AS acquisition_channel,
    SUM(spend) AS total_marketing_spend
FROM marketing_spend
GROUP BY channel
ORDER BY total_marketing_spend DESC;


/* =========================================================
   STEP 13: COST PER UPGRADE (ROI PREPARATION)
   Purpose: Measure cost efficiency of paid conversions
   ========================================================= */

SELECT
    ms.channel AS acquisition_channel,
    SUM(ms.spend) AS total_marketing_spend,
    COUNT(DISTINCT s.user_id) AS upgrade_users,
    ROUND(
        SUM(ms.spend) / COUNT(DISTINCT s.user_id),
    2) AS cost_per_upgrade
FROM marketing_spend ms
LEFT JOIN users u
    ON ms.channel = u.acquisition_channel
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id
GROUP BY ms.channel
ORDER BY cost_per_upgrade ASC;
