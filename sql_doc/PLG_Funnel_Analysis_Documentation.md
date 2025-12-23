📘 DATA ENGINEERING & SQL ANALYSIS — STEP-BY-STEP DOCUMENTATION

(Work in Progress)

Environment

All SQL queries were executed inside the plg_analytics schema using MySQL Workbench.

🔹 STEP 1: Schema Verification & Initial Data Validation
Objective

To confirm that all required base tables exist and contain valid data before starting funnel analysis.

SQL Executed
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM marketing_spend;
SELECT COUNT(*) FROM subscriptions;
SELECT COUNT(*) FROM events;

Purpose

Verified successful ingestion of core tables: users, marketing_spend, and subscriptions

Ensured data availability before proceeding with event-based analysis

🔹 STEP 2: Events Table Reset (Clean Rebuild)
Objective

To rebuild the events table to resolve CSV loading issues and ensure a clean event-level dataset.

SQL Executed
DROP TABLE IF EXISTS events;
USE plg_analytics;

CREATE TABLE events (
    user_id VARCHAR(20),
    event_time DATETIME,
    event_name VARCHAR(50),
    platform VARCHAR(20),
    session_id VARCHAR(50)
);

Purpose

The events table was dropped and recreated to resolve initial CSV loading issues

A clean and structured event table blueprint was prepared before re-ingesting the data

🔹 STEP 3: Enable Large File Ingestion (MySQL Configuration)
Objective

To allow bulk CSV ingestion using LOAD DATA INFILE.

SQL Executed
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

Purpose

Enabled MySQL server-side bulk file loading

Confirmed that local_infile was successfully activated

🔹 STEP 4: Bulk Load Event-Level Data
Objective

To efficiently load large-scale event data into MySQL.

SQL Executed
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv'
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

Purpose

Event-level data was successfully ingested using bulk loading

A total of 277,009 event records were loaded into the events table

Proper CSV parsing and header handling were ensured

🔹 STEP 5: Post-Load Data Validation
Objective

To validate successful ingestion and perform sanity checks on key funnel metrics.

SQL Executed
SELECT COUNT(*) FROM events;

SELECT COUNT(DISTINCT user_id)
FROM events
WHERE event_name = 'signup';

SELECT COUNT(DISTINCT user_id)
FROM events
WHERE event_name = 'upgrade';

Output
Total event records loaded: 277,009

Unique users with signup event: 100,000

Unique users with upgrade event: 18,704

Purpose

Verified total event volume after ingestion

Confirmed realistic counts for signup and upgrade events

🔹 STEP 6: Overall Funnel Aggregation
Objective

To calculate distinct user counts at each stage of the product funnel.

SQL Executed
SELECT
    event_name,
    COUNT(DISTINCT user_id) AS users
FROM events
WHERE event_name IN ('signup','code_run','deploy','collaborate','upgrade')
GROUP BY event_name
ORDER BY FIELD(event_name,'signup','code_run','deploy','collaborate','upgrade');

Output
| Funnel Stage | Users   |
| ------------ | ------- |
| signup       | 100,000 |
| code_run     | 85,071  |
| deploy       | 50,109  |
| collaborate  | 23,125  |
| upgrade      | 18,704  |

Purpose

Established the base PLG funnel from signup to paid upgrade

Generated funnel metrics for downstream analysis

🔹 STEP 7: End-to-End Conversion Rate Calculation
Objective

To measure overall product conversion efficiency.

SQL Executed
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name='upgrade' THEN user_id END)
        * 100.0 /
        COUNT(DISTINCT CASE WHEN event_name='signup' THEN user_id END),
    2) AS conversion_rate_percent
FROM events;
Output
Signup → Upgrade conversion rate: 18.70%

Purpose

Calculated signup → paid upgrade conversion rate

Established a baseline PLG performance metric

🔹 STEP 8: Funnel Drop-Off Analysis
Objective

To identify major friction points within the funnel.

SQL Executed
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

Output
| Funnel Stage | Users   | Drop-off |
| ------------ | ------- | -------- |
| signup       | 100,000 | 14,929   |
| code_run     | 85,071  | 34,962   |
| deploy       | 50,109  | 26,984   |
| collaborate  | 23,125  | 4,421    |
| upgrade      | 18,704  | —        |

Purpose

Measured user attrition between consecutive funnel stages

Prepared data to identify activation bottlenecks

🔹 STEP 9: Persona-Wise Funnel Analysis
Objective

To compare funnel progression across different user personas.

SQL Executed
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

Output
| Persona      | Signup | Code Run | Deploy | Collaborate | Upgrade |
| ------------ | ------ | -------- | ------ | ----------- | ------- |
| Student      | 34,810 | 29,662   | 10,509 | 3,443       | 2,695   |
| Hobbyist     | 24,899 | 21,185   | 11,055 | 3,716       | 3,008   |
| Professional | 25,193 | 21,400   | 16,486 | 7,676       | 6,311   |
| Team         | 15,098 | 12,824   | 12,059 | 8,290       | 6,690   |

Purpose

Analyzed persona-level engagement across funnel stages

Enabled segmentation-based funnel comparison

🔹 STEP 10: Channel-Wise Funnel Aggregation
Objective

To analyze funnel performance across different acquisition channels.

SQL Executed
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

Output
| Channel  | Signup | Code Run | Deploy | Collaborate | Upgrade |
| -------- | ------ | -------- | ------ | ----------- | ------- |
| Organic  | 40,080 | 34,111   | 20,185 | 9,298       | 7,593   |
| Paid Ads | 29,975 | 25,471   | 14,970 | 6,904       | 4,488   |
| Email    | 19,947 | 16,956   | 9,898  | 4,535       | 4,111   |
| Referral | 9,998  | 8,533    | 5,056  | 2,388       | 2,512   |

Purpose

Compared full-funnel behavior across acquisition channels

Prepared channel-level metrics for quality and efficiency analysis

🔹 STEP 11: Channel-Wise Conversion Rate (Signup → Upgrade)
Objective

To calculate the signup to paid upgrade conversion rate for each acquisition channel.

SQL Executed
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

Output
| Channel  | Signup Users | Upgrade Users | Conversion Rate (%) |
| -------- | ------------ | ------------- | ------------------- |
| Paid Ads | 29,975       | 2,773         | 9.25                |
| Organic  | 40,080       | 3,664         | 9.14                |
| Referral | 9,998        | 892           | 8.92                |
| Email    | 19,947       | 1,757         | 8.81                |


Purpose

Measured conversion efficiency of each acquisition channel

Enabled comparison of user quality across channels independent of volume

Prepared channel-level metrics for downstream ROI and cost-efficiency analysis

🔹 STEP 12: Channel-Wise Marketing Spend Aggregation
Objective

To calculate the total marketing spend per acquisition channel in order to support downstream ROI and cost-efficiency analysis.

SQL Executed
SELECT
    channel AS acquisition_channel,
    SUM(spend) AS total_marketing_spend
FROM marketing_spend
GROUP BY channel
ORDER BY total_marketing_spend DESC;

Output Summary
| Channel  | Total Marketing Spend |
| -------- | --------------------- |
| Paid Ads | 16,736                |
| Email    | 14,267                |
| Referral | 13,494                |
| Organic  | 13,415                |

Purpose

Aggregated total marketing investment by acquisition channel

Prepared cost-side metrics for ROI and cost-per-upgrade calculations

Enabled alignment of spend data with channel-level conversion performance

🔹 STEP 13: Channel-Wise Cost per Upgrade (ROI Preparation)
Objective

To calculate the cost required to acquire one paid user for each acquisition channel by combining marketing spend and paid upgrade counts.

SQL Executed
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

Output Summary
| Acquisition Channel | Total Marketing Spend | Upgrade Users | Cost per Upgrade |
| ------------------- | --------------------- | ------------- | ---------------- |
| Organic             | 574,162,000           | 3,664         | 156,703.60       |
| Referral            | 143,953,992           | 892           | 161,383.40       |
| Email               | 303,230,818           | 1,757         | 172,584.42       |
| Paid Ads            | 535,401,376           | 2,773         | 193,076.59       |

Purpose

Combined marketing spend and paid conversion data at the channel level

Calculated cost efficiency for acquiring a paid user

Prepared final metrics required for ROI comparison across acquisition channels

📌 FINAL INSIGHTS & TAKEAWAYS

(Product-Led Growth Funnel Analysis)

1️⃣ Overall Product Funnel Insights

The end-to-end Signup → Paid Upgrade conversion rate is 18.7%, indicating a strong PLG motion for a freemium SaaS product.

A significant portion of users successfully move beyond initial usage, validating the core product value.

2️⃣ Key Activation & Drop-Off Insights

The largest drop-off occurs between code_run → deploy, making deployment the primary activation bottleneck.

Users who successfully deploy are far more likely to proceed toward collaboration and paid upgrades.

Improving the deployment experience would have the highest leverage impact on overall conversion.

3️⃣ Persona-Level Insights

Students

Highest signup volume but lowest upgrade conversion.

Primarily value the free tier and contribute more to usage than revenue.

Hobbyists

Moderate engagement with reasonable conversion.

Likely to convert with better feature education and pricing clarity.

Professionals

Strong deployment and collaboration behavior.

High paid conversion, making them a core revenue-driving persona.

Teams

Lowest acquisition volume but highest conversion rate.

Collaboration usage strongly correlates with monetization.

4️⃣ Channel Quality Insights (Volume vs Quality)

Organic

Highest signup volume and highest number of paid upgrades.

Strong funnel depth across deployment and collaboration.

Indicates high-intent, self-motivated users.

Referral

Lower volume but strong funnel progression.

Referral users demonstrate high trust and intent.

Email

Moderate volume with steady conversion.

Effective as a nurturing and re-engagement channel.

Paid Ads

High acquisition volume but weakest cost efficiency.

Users show higher early-stage drop-off, especially before deployment.

5️⃣ Cost & ROI Insights

Cost per Upgrade (Lowest → Highest)

Organic

Referral

Email

Paid Ads

Organic and referral channels deliver the best ROI, acquiring paid users at the lowest cost.

Paid ads are the most expensive channel per paid user, indicating a need for better targeting or onboarding optimization.

6️⃣ Strategic Business Takeaways

Deployment is the single most important activation milestone in the product funnel.

Collaboration is the strongest behavioral signal of purchase intent.

Professional and Team users should be the primary focus for revenue growth.

Organic and referral growth loops should be prioritized over scaling paid acquisition.

Paid ads should be optimized for deployment success, not just signups.

7️⃣ Final Conclusion

This analysis demonstrates a healthy product-led growth system where user behavior, not aggressive sales tactics, drives monetization.
By optimizing activation (deployment), strengthening collaboration workflows, and reallocating marketing spend toward high-intent channels, the platform can significantly improve both conversion efficiency and ROI.