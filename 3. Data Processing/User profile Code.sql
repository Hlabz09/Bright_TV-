-- Databricks notebook source
User_profile CODE

-- This is to check what my data looks like.
SELECT *
FROM workspace.default.user_profile
LIMIT 5;
-------------------------------------------
-- Gender Checks
-------------------------------------------
SELECT DISTINCT gender
FROM workspace.default.user_profile;

SELECT DISTINCT
       CASE 
            WHEN gender = 'None' THEN 'unknown' -- Replaces the value None with unknown 
            WHEN gender = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN gender IS NULL THEN 'unknown' -- Replaces the null with unknown 
       ELSE gender -- if gender is male or female return it as it is 
       END AS sex -- new column name
FROM workspace.default.user_profile;
-------------------------------------------
-- Race Checks
-------------------------------------------
SELECT DISTINCT race
FROM workspace.default.user_profile;

SELECT COUNT(DISTINCT userid) AS subscribers,
        CASE 
            WHEN race = 'other' THEN 'unknown' -- Replace other with unknown 
            WHEN race = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN race = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN race IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE race -- keep the race as it is
        END AS ethnicity -- new column name 
FROM workspace.default.user_profile
GROUP BY ethnicity;

-------------------------------------------
-- Province Checks
-------------------------------------------

SELECT DISTINCT province
FROM workspace.default.user_profile;

SELECT DISTINCT
        CASE 
            WHEN province = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN province = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN province IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE province -- keep theprovince as it is
        END AS region -- new column name 
FROM workspace.default.user_profile;

--------------------------------------------
-- Age Checks
--------------------------------------------

SELECT MIN(Age) AS min_age, -- Check the youngest person
       MAX(Age) AS max_age, -- Find the oldest person
       AVG(Age) AS mean_age -- Find the average age between upper bound and lower bound
FROM workspace.default.user_profile;
-- Groupings
SELECT 
        CASE 
            WHEN Age = '0' THEN 'Infant'
            WHEN Age BETWEEN 1 AND 12 THEN 'Child'
            WHEN Age BETWEEN 13 AND 17 THEN 'Teenager'
            WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
            WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN Age > 50 AND Age <= 60 THEN 'Elder' -- Another way of doing a BETWEEN statement using operations
            WHEN Age > 60 THEN 'Pensioner'
        END AS Age_group
FROM workspace.default.user_profile;
----------------------------------------------------------
-- Returning all the columns on the user profile dataset, putting everything under one SELECT statement AND Creating Temporary Table/ View
----------------------------------------------------------
CREATE OR REPLACE TEMPORARY VIEW processed_user_profiles AS(
SELECT 
    UserID,
    CASE 
           WHEN (`Email` IS NOT NULL) AND (`Email` <>' ') AND (`Email` NOT IN ('None', 'other')) THEN 1
            ELSE 0
    END AS email_flag,

    CASE 
            WHEN (`Social Media Handle` IS NOT NULL) AND (`Social Media Handle` <>' ') AND (`Social Media Handle` NOT IN ('None', 'other')) THEN 1
            ELSE 0
    END AS social_media_flag,
      
     CASE 
            WHEN gender = 'None' THEN 'unknown'  
            WHEN gender = ' ' THEN 'unknown'  
            WHEN gender IS NULL THEN 'unknown'  
       ELSE gender  
       END AS sex,

       CASE 
            WHEN race = 'other' THEN 'unknown' -- Replace other with unknown 
            WHEN race = 'None' THEN 'unknown' -- Replaces None with unknown 
            WHEN race = ' ' THEN 'unknown' -- Replaces the empty space with unknown 
            WHEN race IS NULL THEN 'unknown'-- Replaces the null with unknown 
        ELSE race -- keep the race as it is
        END AS ethnicity,
        
        CASE 
            WHEN province = 'None' THEN 'unknown'  
            WHEN province = ' ' THEN 'unknown'  
            WHEN province IS NULL THEN 'unknown'
        ELSE province 
        END AS region, 

        AGE,
        CASE 
            WHEN Age = '0' THEN '01.Infant: 0'
            WHEN Age BETWEEN 1 AND 12 THEN '02.Child: 1-12'
            WHEN Age BETWEEN 13 AND 17 THEN '03.Teenager: 13-17'
            WHEN Age BETWEEN 18 AND 35 THEN '04.Young Adult: 18-35'
            WHEN Age BETWEEN 36 AND 50 THEN '05.Adult: 36-50'
            WHEN Age > 50 AND Age <= 60 THEN '06.Elder: 50-60' 
            WHEN Age > 60 THEN '07.Pensioner: >60'
        END AS Age_group

FROM workspace.default.user_profile);

SELECT *
FROM processed_user_profiles;

-- Checking Active Subscribers
SELECT COUNT(*) AS cnt,
       COUNT(DISTINCT UserID) AS active_subscribers
FROM processed_user_profiles;

-- Checking for duplicates
SELECT COUNT(*) AS cnt,
       UserID
FROM processed_user_profiles
GROUP BY UserID
HAVING COUNT(*)>1; -- if there are any duplicates, it will return a count greater than 1, if not it will return no rows

