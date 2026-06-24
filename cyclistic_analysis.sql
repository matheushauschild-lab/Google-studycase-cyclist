-- ==============================================================================
-- CASE STUDY: CYCLISTIC BIKE-SHARE DATA ANALYSIS (COMPLETE PIPELINE)
-- Target Engine: DuckDB
-- Database Target: My_data_analisys.main
-- Author: Matheus Flores Hauschild
-- ==============================================================================

-- ==============================================================================
-- PHASE 1: DATA AGGREGATION & INITIAL RAW DATA CHECKS
-- ==============================================================================


-- Step 1.1: Consolidating the raw folder data

CREATE TABLE Merged_tables AS
SELECT * FROM apr2025_tripdata
UNION ALL
SELECT * FROM may2025_tripdata
UNION ALL
SELECT * FROM jun2025_tripdata
UNION ALL
SELECT * FROM jul2025_tripdata
UNION ALL
SELECT * FROM aug2025_tripdata
UNION ALL
SELECT * FROM sep2025_tripdata
UNION ALL
SELECT * FROM oct2025_tripdata
UNION ALL
SELECT * FROM nov2025_tripdata
UNION ALL
SELECT * FROM dec2025_tripdata
UNION ALL
SELECT * FROM jan2026_tripdata
UNION ALL
SELECT * FROM feb2026_tripdata
UNION ALL
SELECT * FROM mar2026_tripdata;

-- Step 1.2: Checking if data imported is correctly formatted

DESCRIBE Merged_tables

-- Step 1.3: Checking if the consolidated file uloaded the entire 12 month range.

SELECT 
    MIN(started_at) AS earliest_date,
    MAX(started_at) AS latest_date,
    COUNT(*) AS total_rows
FROM Merged_tables;


-- Step 1.4: Initial Integrity Check - Deduplication Verification
-- Executing a primary key screening on the raw dataset to identify duplicate records.
SELECT 
    ride_id, 
    COUNT(*) AS occurrence_count
FROM Merged_tables
GROUP BY ride_id
HAVING COUNT(*) > 1;


-- Step 1.5: Initial Integrity Check - Missing Value & Structural Baseline Scan
-- Auditing total volumes and inspecting spatial field completeness before cleaning.
SELECT 
    COUNT(*) AS total_raw_records,
    COUNT(start_station_name) AS non_null_start_stations,
    COUNT(end_station_name) AS non_null_end_stations
FROM Merged_tables;

-- Step 1.6: Rows with missing or impossible coordinates verification

SELECT COUNT(*) 
FROM Merged_tables 
WHERE (start_lat IS NULL OR start_lat = 0)
   OR (start_lng IS NULL OR start_lng = 0)
   OR (end_lat IS NULL OR end_lat = 0)
   OR (end_lng IS NULL OR end_lng = 0);

-- Step 1.7: Check impossible rides, started before ended or lasted more than 1 day (more than 24h can heavily distort metrics) 

SELECT 
    started_at, 
    ended_at,
    (ended_at - started_at) AS trip_duration
FROM Merged_tables 
WHERE ended_at < started_at
   OR (ended_at - started_at) > INTERVAL '1 day'
LIMIT 10;


-- ==============================================================================
-- PHASE 2: DATA CLEANING & TRANSFORMATION LAYER
-- ==============================================================================

CREATE TABLE Cleaned_Final_Data AS 
SELECT 
    ride_id,
    rideable_type,
    member_casual,
    started_at,
    ended_at,
-- Cleans up missing station names
    COALESCE(start_station_name, 'Unknown Station') AS start_station_name,
    COALESCE(end_station_name, 'Unknown Station') AS end_station_name,
    start_station_id,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng
FROM Merged_tables
WHERE 
-- eliminates rows completely missing GPS data
    start_lat IS NOT NULL AND start_lng IS NOT NULL
    AND end_lat IS NOT NULL AND end_lng IS NOT NULL
    AND start_lat != 0 AND start_lng != 0
    AND end_lat != 0 AND end_lng != 0
-- Elminates trips with negative durations
    AND ended_at => started_at
-- Eliminates zero second trips
    AND ended_at > started_at
-- Eliminates trips that lasted longer than 1 day
    AND (ended_at - started_at) <= INTERVAL '1 day'

-- This line numbers duplicate ride_ids and only keeps the very first occurrence (elminates ride_id duplicates)
QUALIFY ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) = 1;


-- ==============================================================================
-- PHASE 3: EXPLORATORY DATA ANALYSIS (CORE LOGIC)
-- Replicating the exact queries used to uncover trends for the Tableau visualization.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 1: WEEKLY DISTRIBUTION & READABLE DAY CONVERSIONS
-- Triggers a conditional mapping structure to parse day numbers into text strings.
-- ------------------------------------------------------------------------------
SELECT 
    member_casual,
    DAYOFWEEK(started_at) AS day_number,
    -- Turns the number into a readable day name
    CASE DAYOFWEEK(started_at)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS total_rides
FROM Cleaned_Final_Data
GROUP BY member_casual, day_number, day_of_week
ORDER BY member_casual, day_number;


-- ------------------------------------------------------------------------------
-- QUERY 2: GLOBAL USER SHARE BREAKDOWN WITH WINDOW AGGREGATION
-- Uses an empty OVER() clause to divide individual counts by total dataset volume.
-- ------------------------------------------------------------------------------
SELECT
    member_casual,
    COUNT(*) AS totl_rides,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total,
    AVG(ended_at - started_at) AS avg_duration
FROM Cleaned_Final_Data
GROUP BY member_casual;


-- ------------------------------------------------------------------------------
-- QUERY 3: HOURLY TREND OPERATIONS BY USER PROFILE
-- Extracts the explicit hour integer to trace daily commute rush hour spikes.
-- ------------------------------------------------------------------------------
SELECT 
    member_casual,
    EXTRACT(HOUR FROM started_at) AS hour_of_day,
    COUNT(*) AS total_rides
FROM Cleaned_Final_Data
GROUP BY member_casual, hour_of_day
ORDER BY member_casual, hour_of_day;


-- ------------------------------------------------------------------------------
-- QUERY 4: BIKE MODEL VARIANT PREFERENCES (WITHIN-GROUP PERCENTAGE)
-- Employs a PARTITION BY window function to find asset splits per user category.
-- ------------------------------------------------------------------------------
SELECT 
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY member_casual), 2) AS pct_within_user_type
FROM Cleaned_Final_Data
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;


-- ------------------------------------------------------------------------------
-- QUERY 5: DATA CAP FILTERS & DETAILED TRIP LENGTH CALCULATION
-- Implements a Common Table Expression (CTE) to clean and isolate outlier rides.
-- ------------------------------------------------------------------------------
WITH computed_rides AS (
    SELECT 
        member_casual,
        -- Calculate exact minutes using seconds to get true decimals
        DATE_DIFF('second', started_at, ended_at) / 60.0 AS duration_minutes
    FROM Cleaned_Final_Data
)
SELECT 
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(duration_minutes), 1) AS raw_avg_duration
FROM computed_rides
WHERE duration_minutes >= 1.0 AND duration_minutes <= 1440.0
GROUP BY member_casual;
