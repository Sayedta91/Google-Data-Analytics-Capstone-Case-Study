-- Project: Fitbit User Activity Analysis
-- Objective: Explore user activity patterns and identify trends in behavior

-- View full dataset (for initial exploration - can be removed)
SELECT *
FROM dailyactivity_merged;


-- Count the number of unique users in the dataset
SELECT COUNT(DISTINCT Id) AS unique_users
FROM dailyactivity_merged;


-- Count total number of records (rows)
SELECT COUNT(*) AS total_rows
FROM dailyactivity_merged;


-- Find the date range covered in the dataset
SELECT 
    MIN(ActivityDate) AS earliest_date, 
    MAX(ActivityDate) AS latest_date
FROM dailyactivity_merged;


-- Check for missing values in key columns
SELECT *
FROM dailyActivity_merged
WHERE Id IS NULL
   OR ActivityDate IS NULL
   OR TotalSteps IS NULL
   OR Calories IS NULL;


-- Calculate average steps and calories burned per day
-- Helps identify overall daily trends
SELECT 
    ActivityDate, 
    ROUND(AVG(TotalSteps), 2) AS avg_steps, 
    ROUND(AVG(Calories), 2) AS avg_calories
FROM dailyactivity_merged
GROUP BY ActivityDate
ORDER BY ActivityDate;


-- Calculate average steps and calories per user
-- Also count how many days each user has data for
SELECT 
    Id, 
    ROUND(AVG(TotalSteps), 2) AS avg_daily_steps, 
    ROUND(AVG(Calories), 2) AS avg_daily_calories, 
    COUNT(*) AS tracked_days
FROM dailyactivity_merged
GROUP BY Id
ORDER BY avg_daily_steps DESC;


/*
Calculate percentage of time spent in each activity level per user:
- Very active
- Fairly active
- Lightly active
- Sedentary
*/

SELECT 
    Id,
    ROUND(AVG((VeryActiveMinutes * 1.0 / NULLIF(total_minutes, 0)) * 100), 2) AS avg_pct_very_active,
    ROUND(AVG((FairlyActiveMinutes * 1.0 / NULLIF(total_minutes, 0)) * 100), 2) AS avg_pct_fairly_active,
    ROUND(AVG((LightlyActiveMinutes * 1.0 / NULLIF(total_minutes, 0)) * 100), 2) AS avg_pct_lightly_active,
    ROUND(AVG((SedentaryMinutes * 1.0 / NULLIF(total_minutes, 0)) * 100), 2) AS avg_pct_sedentary,
    COUNT(*) AS tracked_days
FROM (
    -- Calculate total minutes per day for each user
    SELECT *,
        VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes AS total_minutes
    FROM dailyactivity_merged
) AS sub
GROUP BY Id
ORDER BY avg_pct_sedentary DESC;


-- Segment users into activity levels based on average daily steps
-- This helps group users into low, moderate, and high activity categories

SELECT 
    Id,
    avg_steps,
    avg_calories,
    CASE
        WHEN avg_steps < 5000 THEN 'Low Activity'
        WHEN avg_steps BETWEEN 5000 AND 10000 THEN 'Moderate Activity'
        WHEN avg_steps > 10000 THEN 'High Activity'
    END AS activity_group
FROM (
    -- Calculate average steps and calories per user
    SELECT 
        Id, 
        ROUND(AVG(TotalSteps), 2) AS avg_steps, 
        ROUND(AVG(Calories), 2) AS avg_calories
    FROM dailyactivity_merged
    GROUP BY Id
) AS sub
ORDER BY avg_steps DESC;

-- Key Insight:
-- Users with higher average daily steps tend to burn more calories,
-- indicating a strong relationship between activity level and energy expenditure.
