# Google-studycase-cyclist
Data analytics case study analyzing Cyclistic bike-share data (April 2025–March 2026) using SQL for data wrangling and Tableau for interactive dashboard visualization.
# Case Study: Cyclistic Bike-Share User Behavior Analysis

**Project Overview:** An end-to-end data analytics case study executing the data analysis lifecycle (Ask, Prepare, Process, Analyze, Share, Act) to isolate behavioral differences between annual members and casual riders. 

* **Live Interactive Dashboard:** [https://public.tableau.com/app/profile/matheus.hauschild/viz/Cyclist_DataGoogleCapstoneProject/OverviewKeyMetrics]
**Tools Used:** SQL (DuckDB / Local Data Pipeline Execution), Tableau Public

---

## 1. Ask (The Business Challenge)
The business objective is to analyze historical trip data to identify how annual members and casual riders utilize Cyclistic bike-shares differently. These data-backed insights will guide targeted marketing strategies aimed at converting high-value casual riders into annual subscribers.

## 2. Prepare (Data Sourcing)
The analysis utilizes 12 months of historical trip data spanning from **April 2025 to March 2026**. The dataset tracks granular trip details including bike classifications, user categories, and anonymized start/end timestamps. 

# 3. Process (Data Cleaning & Wrangle Pipelines)
To handle a multi-million-row volume inefficient for standard spreadsheet software, data transformation was engineered locally using high-performance DuckDB SQL scripts to ensure rigorous data integrity:

### A. Data Aggregation & Structural Profiling
* **Table Consolidation:** Utilized **`UNION ALL`** statements to vertically stack and consolidate 12 distinct monthly CSV tables into a unified relational staging table named `Merged_tables`.
* **Schema Validation:** Executed the **`DESCRIBE`** command to audit structural formatting across all imported data attributes.
* **Timeline Verification:** Queried **`MIN(started_at)`** and **`MAX(started_at)`** functions to confirm that the consolidated data boundary spanned the exact target 12-month sequence.

### B. Pre-Cleaning Integrity Scans
* **Anomalous Volume Screening:** Proactively queried the dataset to count missing or invalid zero-valued geographic boundaries (`start_lat = 0`, `end_lng = 0`).
* **Logical Flow Audit:** Flagged baseline data corruption by running logical comparisons to isolate negative time deltas (`ended_at < started_at`) and excessive outlier trips exceeding a single day (`> INTERVAL '1 day'`).

### C. Data Cleaning, Constraints & Window Deduplication
* **Coordinate & Time Integrity:** Enforced a multi-conditional **`WHERE`** clause to drop records containing empty or zero coordinates (`IS NOT NULL` and `!= 0`), strip zero-second trips (`ended_at > started_at`), and remove duration outliers exceeding 24 hours (`<= INTERVAL '1 day'`).
* **Handling Missing Spatial Data:** Applied the **`COALESCE`** function to intercept `NULL` values in the station attributes, dynamically swapping missing records with a default text fallback string (**`'Unknown Station'`**) to preserve total volumetric counts while avoiding breakdown errors in Tableau.
* **Advanced Window Deduplication:** Instead of a generic filter, primary key uniqueness was strictly enforced during table generation by leveraging an analytical window function: **`QUALIFY ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) = 1`** to dynamically preserve only the initial chronological record occurrence per unique ID.

---

## 4. Analyze (SQL Data Exploration)
Aggregated metrics were extracted from the production table (`Cleaned_Final_Data`) using advanced analytic queries and window calculations to prepare data structures directly matching dashboard charts:

* **Weekly Distribution Patterns:** Leveraged **`DAYOFWEEK()`** alongside a conditional **`CASE WHEN`** mapping sequence to transform numerical weekday metrics into distinct chronological labels (`0` as `'Sunday'` through `6` as `'Saturday'`).
* **Global Cohort Calculations:** Applied an unpartitioned window aggregate **`SUM(COUNT(*)) OVER ()`** to mathematically divide user segment frequencies by the total row-count matrix, returning the precise percentage share of total rides.
* **Hourly Trend Visual Preparation:** Extracted explicit time integers using **`EXTRACT(HOUR FROM started_at)`** to group overall trip patterns into historical 24-hour operational profiles.
* **Fleet Segmentation Mixes:** Deployed partitioned window functions (**`SUM(COUNT(*)) OVER(PARTITION BY member_casual)`**) to discover internal hardware usage choices (Classic vs. Electric) independently isolated inside each distinct rider archetype.
* **Refined Ride-Length Metrics:** Designed a Common Table Expression (**`WITH computed_rides AS...`**) to extract precise decimal minute intervals via **`DATE_DIFF('second', started_at, ended_at) / 60.0`**, calculating exact averages across stabilized data windows (between 1.0 and 1440.0 minutes).

## 5. Share (High-Fidelity Visualization)
Insights were compiled into 3-page Tableau dashboard:
* **Dashboard Design & Hierarchy:** Built using **Fixed-Size Desktop Layouts** rather than automatic sizing to prevent component warping and preserve visual grid alignment across different recruiter monitors.
* **Sheet Streamlining:** Used the **Workbook Optimizer** framework to identify performance bottlenecks, hide unused data fields, and hide the 12 underlying building-block worksheets to deliver a clean tabbed user interface.
* **Data-to-Color Mapping:** Maintained strict visual continuity by mapping user categories to a limited, two-tone professional color schema while keeping peripheral axes and chart titles completely neutral.

## 6. Act (Strategic Recommendations)
Based on the data trends, the following business recommendations are proposed:
1. **Targeted Electric Bike Benefits:** Leverage the high popularity of electric bikes by designing marketing campaigns that highlight exclusive membership pricing, seasonal bundles, or priority access to electric bikes for annual subscribers.
2. **High-Duration Membership Conversion:** Since casual riders use bikes for significantly longer durations (likely for weekend leisure), introduce targeted, context-aware application prompts offering a retroactive subscription discount based on their long trip history.

