# Google-studycase-cyclist
Data analytics case study analyzing Cyclistic bike-share data (April 2025–March 2026) using SQL for data wrangling and Tableau for interactive dashboard visualization.
# Case Study: Cyclistic Bike-Share User Behavior Analysis

**Project Overview:** An end-to-end data analytics case study executing the data analysis lifecycle (Ask, Prepare, Process, Analyze, Share, Act) to isolate behavioral differences between annual members and casual riders. 

* **Live Interactive Dashboard:** [PASTE YOUR TABLEAU PUBLIC LINK HERE]
* **Tools Used:** SQL (Google BigQuery / Data Schema Management), Tableau Public

---

## 1. Ask (The Business Challenge)
The business objective is to analyze historical trip data to identify how annual members and casual riders utilize Cyclistic bike-shares differently. These data-backed insights will guide targeted marketing strategies aimed at converting high-value casual riders into annual subscribers.

## 2. Prepare (Data Sourcing)
The analysis utilizes 12 months of historical trip data spanning from **April 2025 to March 2026**. The dataset tracks granular trip details including bike classifications, user categories, and anonymized start/end timestamps. 

## 3. Process (Data Cleaning & Wrangle Pipelines)
To handle a multi-million-row volume inefficient for spreadsheet software, data transformation was engineered using optimized SQL scripts to ensure rigorous data integrity:
* **Data Aggregation:** Utilized **`UNION ALL`** statements to vertically stack and consolidate 12 distinct monthly CSV tables into a single, unified relational database schema.
* * **Deduplication Validation:** Executed uniqueness checks by running a query pairing **`GROUP BY ride_id`** with a **`HAVING COUNT(*) > 1`** filter across the entire 12-month merged table to confirm zero duplicate primary key entries existed.
* **Feature Engineering:** * Extracted trip duration metrics in minutes using **`TIMESTAMP_DIFF`** (or **`DATEDIFF`**) between `started_at` and `ended_at` fields.
  * Formatted temporal attributes using string and date extraction functions (**`EXTRACT`** / **`CASE WHEN`**) to isolate specific months and days of the week.
* **Data Cleaning & Constraints:** * Enforced **`WHERE`** clause filters to strip data anomalies, including negative trip durations and maintenance test rows.
  * Screened database integrity using **`IS NOT NULL`** operators to handle missing spatial coordinates and incomplete station rows.
  * Streamlined the target scope by filtering the `rideable_type` strings to isolate active consumer variants (**Classic** and **Electric** models).

## 4. Analyze (SQL Data Exploration)
Aggregated metrics were queried using advanced descriptive statistics to extract operational insights:
* **Descriptive Aggregations:** Applied **`COUNT`**, **`AVG`**, and **`ROUND`** arithmetic functions paired with multi-level **`GROUP BY`** and **`ORDER BY`** clauses to calculate baseline user statistics.
* **Key Findings:**
  * **Trip Durations:** Casual riders maintain an average ride length more than double (2x) that of annual members across every single day of the week, indicating leisure-dominant usage patterns.
  * **Bike Preferences:** Volumetric analysis proved that electric bikes heavily dominate total trip counts across both annual members and casual user segments.
  * * **Weekly Distribution & Commute Patterns:** 
  * **Annual Members:** Showcase prominent volume spikes on weekdays (Monday through Friday) specifically during standard peak commuting windows (8:00 AM and 5:00 PM), heavily indicating utility-driven, routine transit usage.
  * **Casual Riders:** Ridership concentrates heavily on weekends (Saturday and Sunday), with a smooth, continuous volume buildup peaking in the mid-afternoon, pointing toward recreational and leisure use.

## 5. Share (High-Fidelity Visualization)
Insights were compiled into 3-page Tableau dashboard:
* **Dashboard Design & Hierarchy:** Built using **Fixed-Size Desktop Layouts** rather than automatic sizing to prevent component warping and preserve visual grid alignment across different recruiter monitors.
* **Sheet Streamlining:** Used the **Workbook Optimizer** framework to identify performance bottlenecks, hide unused data fields, and hide the 12 underlying building-block worksheets to deliver a clean tabbed user interface.
* **Data-to-Color Mapping:** Maintained strict visual continuity by mapping user categories to a limited, two-tone professional color schema while keeping peripheral axes and chart titles completely neutral.

## 6. Act (Strategic Recommendations)
Based on the data trends, the following business recommendations are proposed:
1. **Targeted Electric Bike Benefits:** Leverage the high popularity of electric bikes by designing marketing campaigns that highlight exclusive membership pricing, seasonal bundles, or priority access to electric bikes for annual subscribers.
2. **High-Duration Membership Conversion:** Since casual riders use bikes for significantly longer durations (likely for weekend leisure), introduce targeted, context-aware application prompts offering a retroactive subscription discount based on their long trip history.

