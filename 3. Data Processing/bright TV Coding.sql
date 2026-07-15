-- Databricks notebook source
--I want to see data from the table User_Profile

SELECT *
FROM workspace.default.user_profile
LIMIT 1000;

--I want to see data from the table Viewership
SELECT *
FROM workspace.default.viewership
LIMIT 1000;

SELECT COUNT(*)
FROM workspace.default.user_profile

------------------------------------------
--Gender checks
------------------------------------------

SELECT DISTINCT gender
FROM workspace.default.user_profile

SELECT COUNT(*)
FROM workspace.default.user_profile
WHERE gender =' ';

SELECT
COUNT(DISTINCT UserID) AS subs,
CASE
WHEN gender =' ' THEN 'None'
ELSE gender
END AS Gender
FROM workspace.default.user_profile
GROUP BY
    CASE
         WHEN gender =' ' THEN 'None'
         ELSE gender
    END;     

--This is a count of users by gender
SELECT gender, COUNT(*) AS TotalUsers
FROM workspace.default.user_profile
GROUP BY gender

SELECT DISTINCT
    CASE
         WHEN gender = 'None' THEN 'Unknown'
         WHEN gender = '' THEN 'Unknown'
         WHEN gender IS NULL THEN 'Unknown'
         ELSE gender 
    END AS sex
FROM workspace.default.user_profile
-------------------------------------------
--Race Checks
-------------------------------------------
SELECT DISTINCT race
FROM workspace.default.user_profile

SELECT COUNT(*) AS num_rows
FROM workspace.default.user_profile
WHERE Race IS NULL;SELECT DISTINCT Race
FROM workspace.default.user_profile
       
SELECT DISTINCT
    CASE
         WHEN race = 'None' THEN 'Unknown'
         WHEN race = '' THEN 'Unknown'
         WHEN race IS NULL THEN 'Unknown'
         ELSE race 
    END AS race
FROM workspace.default.user_profile

--Number of each users in each race
SELECT race,
       COUNT(*) AS TotalUsers
FROM workspace.default.user_profile
GROUP BY race
ORDER BY TotalUsers DESC
-------------------------------------
--Age Checks
-------------------------------------
SELECT DISTINCT age
FROM workspace.default.user_profile

--Rearranging the age column in ascending order
SELECT name,
       age
FROM workspace.default.user_profile
ORDER BY age ASC

--Number of users in each age group
SELECT name,
       age,
       CASE
           WHEN age < 18 THEN 'minor'
           WHEN age BETWEEN 18 AND 35 THEN 'young adult'
           WHEN age BETWEEN 36 AND 55 THEN 'adult'
           ELSE 'senior'
       END AS ageGroup
FROM workspace.default.user_profile  
--------------------------------------

SELECT MIN(Age) AS min_age, --- = 0
MAX(Age) AS max_age -- = 114
FROM workspace.default.user_profile

SELECT COUNT(*) AS cnt
FROM workspace.default.user_profile
WHERE age IS NULL;


WITH user_profile AS (
    SELECT 
        UserID,
        CASE
            WHEN Province = ' ' THEN 'Uncategorized'
            WHEN Province = 'None' THEN 'Uncategorized'
            WHEN Province IS NULL THEN 'Uncategorized'
            ELSE Province
        END AS Region,
        age,
        CASE
            WHEN age = 0 THEN 'Infants'
            WHEN age BETWEEN 1 AND 12 THEN 'Kids'
            WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN age BETWEEN 20 AND 35 THEN 'Youth'
            WHEN age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN age BETWEEN 51 AND 65 THEN 'Elder'
            WHEN age > 65 THEN 'Pensioner'
        END AS age_groups,
        -- Fixed logic: Must NOT be null AND NOT be empty space AND NOT be 'None'
        CASE
            WHEN Email IS NOT NULL AND Email != ' ' AND Email != 'None' THEN 1
            ELSE 0
        END AS email_flag,
        -- Fixed logic for social media handle flag
        CASE
            WHEN `Social Media Handle` IS NOT NULL AND `Social Media Handle` != ' ' AND `Social Media Handle` != 'None' THEN 1 
            ELSE 0 
        END AS sm_flag,
        CASE
            WHEN Race = 'other' THEN 'None'
            WHEN Race = ' ' THEN 'None'
            ELSE Race
        END AS Race,
        CASE
            WHEN gender = ' ' THEN 'None'
            ELSE gender
        END AS Gender
    FROM workspace.default.user_profile
),

viewership AS (
    SELECT
        COALESCE(UserID0, userid4) AS userid,
        TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
        TO_DATE(RecordDate2) AS watch_date,
        TO_CHAR(RecordDate2, 'DD') AS day_of_week,
        DAYNAME(RecordDate2) AS day_name,
        CASE
            WHEN DAYNAME(RecordDate2) IN ('Sat', 'Sun') THEN 'weekend'
            ELSE 'weekday'
        END AS day_classification,
        MONTHNAME(RecordDate2) AS month_name,
        CASE
            WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
            WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
            ELSE Channel2
        END AS Tv_channel,
        DATE_FORMAT(RecordDate2, 'HHmmss') AS watch_time,
        CASE
            -- Fixed reference to use the newly created watch_time string
            WHEN DATE_FORMAT(RecordDate2, 'HHmmss') BETWEEN '000000' AND '055959' THEN '01. Midnight'
            WHEN DATE_FORMAT(RecordDate2, 'HHmmss') BETWEEN '060000' AND '115959' THEN '02. Morning'
            WHEN DATE_FORMAT(RecordDate2, 'HHmmss') BETWEEN '120000' AND '165959' THEN '03. Afternoon'
            WHEN DATE_FORMAT(RecordDate2, 'HHmmss') BETWEEN '170000' AND '235959' THEN '04. Evening'
        END AS time_of_day,
        DATE_FORMAT(`Duration 2`, 'HHmmss') AS duration,
        -- Added missing operator (>) below
        CASE
            WHEN DATE_FORMAT(`Duration 2`, 'HHmmss') BETWEEN '000500' AND '003000' THEN '01. Low Usage 30 min'
            WHEN DATE_FORMAT(`Duration 2`, 'HHmmss') BETWEEN '003001' AND '005959' THEN '02. Med Usage 60 min'
            WHEN DATE_FORMAT(`Duration 2`, 'HHmmss') > '005959' THEN '03. High Usage 60 min'
            ELSE '04. No Usage'
        END AS screen_time_bucket,
        HOUR(RecordDate2) AS hour_of_day,
        `Duration 2` -- Kept original duration column for final SELECT
    FROM workspace.default.viewership
)

SELECT 
    COALESCE(A.userid, B.userid) AS sub_id,
    A.month_id,
    A.watch_date,
    A.day_of_week,
    A.day_name,
    A.day_classification,
    A.month_name,
    A.Tv_channel,
    A.time_of_day,
    A.hour_of_day,
    A.screen_time_bucket,
    A.`Duration 2`,
    B.Region,
    B.age_groups,
    B.email_flag,
    B.sm_flag,
    B.Race,
    B.Gender
FROM viewership AS A
LEFT JOIN user_profile AS B
    ON A.userid = B.userid;


