-- Databricks notebook source
Viewership CODE 

-- The first code SELECT* is to help see what is in the table
SELECT*
FROM workspace.default.viewership
LIMIT 10;

-- Second code: Applying DATE FUNCTIONS, these are used in the date column to extract date i.e. day, month, year
-- In this select statement 'RecordDate2' is a date column a.k.a timestamp and it will return watch_time in the YYY-MM-DD format 

SELECT TO_DATE(RecordDate2) AS watch_date --TO_DATE Converts a string into a date YYYT-MM-DD
FROM workspace.default.viewership;

-- In this code, we just added the RecordDate2 column to the select statement and the watch_date column to return both columns

SELECT 
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date --TO_DATE Converts a string into a date YYYY-MM-DD
FROM workspace.default.viewership;

-- Now let's extract the dates using more DATE FUNCTIONS names, year, and day
-- You can add visuals to them from the database

SELECT
    UserID0,
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date, --TO_DATE Converts a string into a date YYYY-MM-DD
    DAYNAME(TO_DATE(RecordDate2)) AS day_name, -- Extracts the day name
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name, -- Extracts the month name
    YEAR(TO_DATE(RecordDate2)) AS event_year, -- Extracts the year value
    DAY(TO_DATE(RecordDate2)) AS event_dt -- Extracts day value
FROM workspace.default.viewership;

-- DATE FUNCTIONS allow us to build a CASE statement within them
-- Also returning Count Distinct number of subscribers
-- And then create a Temporary TABLE to save the results and create your own version of the table, here it will be called 'viewership'

CREATE OR REPLACE TEMPORARY VIEW viewership AS (
SELECT 
    COUNT(DISTINCT UserID0) AS number_of_subs,
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date, --TO_DATE Converts a string into a date YYYT-MM-DD
    DAYNAME(TO_DATE(RecordDate2)) AS day_name, -- Extracts the day name
    CASE 
        WHEN DAYNAME(TO_DATE(RecordDate2)) IN ('Sat', 'Sun') THEN '02. Weekend'
        ELSE '01. Weekday'
    END AS Day_classification,
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name, -- Extracts the month name
    YEAR(TO_DATE(RecordDate2)) AS event_year, -- Extracts the year value
    DAY(TO_DATE(RecordDate2)) AS event_dt -- Extracts day value
FROM workspace.default.viewership
WHERE UserID0 IS NOT NULL
GROUP BY ALL
ORDER BY watch_date DESC);

-- How many people are watching Weekdays and Weekends
SELECT SUM (number_of_subs) AS subs,
        day_classification
FROM viewership
Group BY day_classification;

--Viewership table check
SELECT *
FROM viewership;

