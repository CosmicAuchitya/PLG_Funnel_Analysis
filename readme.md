# Product-Led Growth Funnel Analysis

An end-to-end analytics case study for a freemium SaaS product, combining SQL funnel analysis, A/B testing, and high-intent user prediction.

## Executive Summary

This project analyzes a synthetic but realistic Product-Led Growth dataset to understand user behavior from signup to paid conversion. The work focuses on business-first analytics rather than model complexity.

The project answers questions such as:

- where users drop off in the funnel
- which user groups show stronger upgrade intent
- how experimentation should be evaluated
- how growth teams can prioritize likely converters

## Project Scope

The analysis is split into three main parts:

1. SQL funnel analysis to measure stage-by-stage conversion
2. A/B testing to validate experimentation logic
3. Predictive modeling to identify high-intent users

## Key Insights

- the largest funnel drop-off happens between code execution and deployment
- deployment is a major activation bottleneck
- team and professional personas convert at higher rates
- consistent activity is a stronger indicator of upgrade intent than raw usage volume

## Tech Stack

- SQL
- Python
- Jupyter Notebook
- pandas
- scikit-learn

## Repository Structure

```text
readme.md
sql/
  PLG_Funnel_Analysis.sql
sql_doc/
  PLG_Funnel_Analysis_Documentation.md
notebook/
  ab_testing.ipynb
  high_intent_model.ipynb
_data/
  users.csv
  events.csv
  subscriptions.csv
  marketing_spend.csv
```

## Business Questions

- Which funnel stages create the biggest growth bottlenecks?
- Which personas and channels drive the best conversion efficiency?
- How should high-intent users be identified for targeted nudges?
- How can experimentation logic be evaluated in a statistically sound way?

## What This Project Demonstrates

- strong SQL-based product analytics
- growth and conversion analysis for a PLG business
- experimentation thinking with realistic constraints
- interpretable modeling for prioritization and targeting
- business communication through a full case-study format

## Note On Data

The dataset used in this project is synthetic and was created to simulate realistic SaaS behavior patterns while remaining safe to share publicly.
