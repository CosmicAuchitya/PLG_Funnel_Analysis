📊 End-to-End Product-Led Growth (PLG) Analytics for a Freemium SaaS

SQL • Experimentation (A/B Testing) • High-Intent User Prediction

🔖 Executive Summary

This project presents an end-to-end Product-Led Growth (PLG) analytics case study for a freemium SaaS product, designed to mirror real-world growth and marketing analytics work.

Using a synthetically generated but realistic dataset (100K users), I analyzed user behavior from signup to paid conversion, identified funnel bottlenecks, validated experimentation logic through A/B testing, and built an interpretable model to predict high-intent users.

The goal of this project is not model complexity, but clear business thinking, decision-making, and analytical rigor — exactly how data is used in modern PLG SaaS companies.

⚠️ Important Note on Data

All data used in this project is self-generated.
No proprietary, scraped, or copied datasets were used.

The dataset was created to simulate real SaaS user behavior

Event distributions, drop-offs, and conversion patterns were intentionally designed to resemble realistic PLG funnels

This allows safe public sharing while preserving real-world analytical complexity

🧠 Business Context

Product type: Freemium developer-focused SaaS
Growth motion: Product-Led Growth (PLG)

Typical user journey:

Signup → Code Run → Deploy → Collaborate → Upgrade (Paid)

Core Business Questions

Where do users drop off in the product funnel?

Which users are most likely to convert to paid plans?

How should marketing and growth teams prioritize users?

How do we validate product changes using experimentation?

📂 Repository Structure
plg-growth-analytics/
├── README.md                  ← Master case study (this file)
├── sql/
│   └── funnel_analysis.sql
├── notebooks/
│   ├── ab_testing.ipynb
│   └── high_intent_model.ipynb
├── data/
│   └── raw/ (synthetic CSV files)
└── docs/
    └── detailed_sql_notes.md

🔹 Phase 1: SQL Funnel & Growth Analysis
Objective

Understand where and why users drop off in the PLG funnel and quantify the business impact.

Key Steps

Loaded 277K+ event records into MySQL

Built the full product funnel using event-level data

Analyzed conversion rates by:

Funnel stage

Persona (student, hobbyist, professional, team)

Acquisition channel (organic, paid, email, referral)

Integrated marketing spend to estimate cost per paid upgrade

Core Insight

The largest drop-off occurs between code_run → deploy

Deployment is the primary activation bottleneck

Team and professional personas convert at significantly higher rates

Paid acquisition channels show higher volume but lower efficiency than organic

📌 Business takeaway:
Improving deployment experience yields the highest leverage for growth.

🔹 Phase 2: A/B Testing & Experimentation (Offline Simulation)
Objective

Validate whether a product change (e.g., improved deployment flow) could improve conversion.

Experiment Design

Target population: users who performed code_run

Randomized users into:

Control (A)

Variant (B)

Metric: Deployment conversion rate

Result

The experiment produced a neutral outcome

No statistically significant lift was observed

⚠️ Why a Neutral Result Is Correct Here

This A/B test was performed on historical (offline) data.

Real-World A/B Test	This Project
Variant users see a new feature	All users saw the same experience
Behavior can change	Behavior is already fixed
Lift is expected	Lift should be ~0

Because the data is historical, random splits naturally converge to the same behavior due to the Law of Large Numbers.

📌 What this proves:
The experimentation framework, randomization logic, and metric design are statistically sound and unbiased.

🔹 Phase 3: High-Intent User Prediction (Python)
Objective

Identify which free users are most likely to upgrade, enabling smarter targeting by growth and marketing teams.

Feature Engineering

Converted raw events into user-level behavioral signals:

Total events

Active days

Code runs

Deployments

Collaborations

Days since signup

Persona & acquisition channel

Intent Label
high_intent = 1 → user upgraded (event or subscription)
high_intent = 0 → free user


Distribution:

High intent: ~33%

Low intent: ~67% (realistic for freemium SaaS)

🔸 Baseline Intent Scoring (Before ML)

A simple, interpretable scoring system was created using business logic:

Deployment and collaboration strongly signal intent

Consistent activity matters more than raw usage volume

Insight

Users combining deployment + collaboration show near-certain conversion, validating earlier funnel findings.

🔸 Logistic Regression Model

A lightweight, explainable model was trained to rank users by upgrade probability.

Performance

Accuracy: ~85%

ROC-AUC: ~0.78

Key Insight

Consistency (active_days) is the strongest predictor

Raw code execution alone does not guarantee monetization

Model is designed for prioritization, not perfect classification

📌 Correct usage:
Rank users for targeted nudges, not hard yes/no decisions.

📌 Final Business Recommendations

Prioritize users with consistent activity over raw usage

Trigger upgrade nudges after deployment + collaboration

Avoid over-targeting users based only on code execution

Use intent scores to:

Optimize lifecycle emails

Improve paid retargeting efficiency

Support sales-assisted outreach for high-value users

✅ What This Project Demonstrates

End-to-end analytical thinking

Strong SQL foundations

Experimentation and causal reasoning

Interpretable modeling (not black-box ML)

Business-first decision making

🔚 Closing Note

This project intentionally emphasizes clarity over complexity.

Real impact in data roles comes from
asking the right questions, validating assumptions,
and translating analysis into action.