## DATA CLEANING


```
DROP TABLE IF EXISTS canwildfiresinfo;

CREATE TABLE IF NOT EXISTS canwildfiresinfo (
		FID BIGINT(10) NOT NULL,
        SIZE_HA FLOAT(10) NOT NULL,
        CAUSE VARCHAR(20),
        PROTZONE VARCHAR(20),
        ECOZ_NAME VARCHAR(20)
        );
 
 LOAD DATA LOCAL INFILE 'C:\path' INTO TABLE canwildfiresinfo 
 FIELDS TERMINATED BY ',' 
 ENCLOSED BY '"'
 LINES TERMINATED BY '\r\n' 
 IGNORE 1 LINES;
 
SELECT * FROM canwildfiresinfo
 WHERE FID>423750;
 
DROP TABLE IF EXISTS canwildfireslocdate;

CREATE TABLE IF NOT EXISTS canwildfireslocdate (
		FID BIGINT(10) NOT NULL,
		TERRITORIES VARCHAR(100),
        LATITUDE FLOAT(10),
        LONGITUDE FLOAT(10),
        REP_DATE TIMESTAMP
        );

 LOAD DATA LOCAL INFILE 'C:\path' INTO TABLE canwildfireslocdate 
 FIELDS TERMINATED BY ',' 
 ENCLOSED BY '"'
 LINES TERMINATED BY '\r\n' 
 IGNORE 1 LINES;
 
SELECT * FROM canwildfireslocdate
WHERE FID>423750; 
```


### Standardize Date Format



*-- First we allow invalid dates because we had blank dates*

```
SET SQL_MODE='ALLOW_INVALID_DATES';

SELECT REP_DATE, CONVERT(REP_DATE, Date) AS CONV_DATE
FROM canwildfireslocdate;

ALTER TABLE canwildfireslocdate MODIFY REP_DATE Date;
```


### Remove Duplicates



##### Table No.1

*-- 1st we create another column in the table that we will need in order to specify later which row to delete from the duplicates*

```
ALTER TABLE canwildfireslocdate
ADD COLUMN Nos bigint(10) FIRST;

SELECT * FROM canwildfireslocdate;

ALTER TABLE canwildfireslocdate MODIFY COLUMN Nos BIGINT(10) PRIMARY KEY AUTO_INCREMENT;
```

*-- 2nd we creating a CTE named "Dupl" to identify and retrieve duplicate records from the "canwildfireslocdate" table*

```
WITH Dupl AS(
	SELECT *, ROW_NUMBER() OVER(
			PARTITION BY FID,
			 LATITUDE,
             LONGITUDE,
             REP_DATE
             ORDER BY 
					FID
                    ) row_num
FROM canwildfireslocdate
)
SELECT *
FROM canwildfireslocdate AS can
JOIN Dupl
ON can.FID = Dupl.FID
WHERE Dupl.row_num > 1 AND can.Nos < Dupl.Nos;
```

*-- 3rd we change the SELECT statement with the DELETE statement (as it seen below) to delete the duplicated records*

```
-- DELETE can.*
-- FROM canwildfireslocdate AS can
-- JOIN Dupl
-- ON can.FID = Dupl.FID
-- WHERE Dupl.row_num > 1 AND can.Nos < Dupl.Nos;
```

##### Table No.2 (same process)

```
ALTER TABLE canwildfiresinfo
ADD COLUMN Nos BIGINT(10) FIRST;

ALTER TABLE canwildfiresinfo
MODIFY COLUMN Nos BIGINT(10) PRIMARY KEY AUTO_INCREMENT;

SELECT * FROM canwildfiresinfo;

WITH Dupls AS(
		SELECT *, ROW_NUMBER() OVER(
        PARTITION BY FID,
					 SIZE_HA,
                     CAUSE
                     ORDER BY FID
                     ) row_num
FROM canwildfiresinfo
)
SELECT * 
FROM canwildfiresinfo AS can
JOIN Dupls
ON Dupls.FID = can.FID
WHERE Dupls.row_num > 1 AND can.Nos < Dupls.Nos;

-- DELETE can.*
-- FROM canwildfiresinfo AS can
-- JOIN Dupls
-- ON Dupls.FID = can.FID
-- WHERE Dupls.row_num > 1 AND can.Nos < Dupls.Nos; 
```


### Remove unwanted spaces from "Territories" column on the "canwildfireslocdate" table


```
SELECT TRIM(TERRITORIES) 
FROM canwildfireslocdate;

SET SQL_SAFE_UPDATES = 0;  -- we need to place the safe update mode into 0 in order to be able to update our column


UPDATE canwildfireslocdate 
SET 
    TERRITORIES = TRIM(TERRITORIES);

SELECT *
FROM canwildfireslocdate;
```


### Populate "Territories" column on the "canwildfireslocdate" table 
#### (We have some EMPTY values in this column, specifically in the "British Columbia" and "Saskatchewan" Territories)


*-- After experiencing errors with the datatype of "latitude" and "longitude" columns and the null values in the "rep_date" column, we have to proceed*
*-- with the following: changing datatypes from float to decimal, and allowing invalid dates (no_zero_date and no_zero_in_date), respectively*

```
SET SQL_MODE='ALLOW_INVALID_DATES';
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'NO_ZERO_DATE',''));   
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'NO_ZERO_IN_DATE',''));

UPDATE canwildfireslocdate SET REP_DATE = NULL WHERE REP_DATE = '';

ALTER TABLE canwildfireslocdate 
MODIFY COLUMN latitude DECIMAL(10,6),
MODIFY COLUMN longitude DECIMAL(10,6);
```

*-- Next, we are filling a "new_territories" column, which is based on the "territories"column and as for the null values we have as reference*
*-- details of the latitudes and longitudes ranges for the 2 mentioned territories from google maps*

```
SELECT *,
  CASE
    WHEN LATITUDE BETWEEN 48.0 AND 60.0 AND LONGITUDE BETWEEN -138.0 AND -114.0 THEN 'BC, British Columbia, Canada'
    WHEN LATITUDE BETWEEN 49.0 AND 59.0 AND LONGITUDE BETWEEN -110.0 AND -101.0 THEN 'SK, Saskatchewan, Canada'
    ELSE TERRITORIES
  END AS NEW_TERRITORIES
FROM canwildfireslocdate
WHERE TERRITORIES = '';
```

*-- We are now updating the "territories" column's empty values with the above tested conditions*

```
UPDATE canwildfireslocdate
SET TERRITORIES =
  CASE
    WHEN LATITUDE BETWEEN 48.0 AND 60.0 AND LONGITUDE BETWEEN -138.0 AND -114.0 THEN 'BC, British Columbia, Canada'
    WHEN LATITUDE BETWEEN 49.0 AND 59.0 AND LONGITUDE BETWEEN -110.0 AND -101.0 THEN 'SK, Saskatchewan, Canada'
    ELSE TERRITORIES
  END;
```

*-- We are now testing to see if here are more empty values in the "territories" column --> Result: 0 row(s) affected*

```
SELECT * FROM canwildfireslocdate
WHERE TERRITORIES = '';
```


### Removing Numbers from the "territories"column



*-- We 1st investigate if we have numbers in the "territories" column*

```
SELECT TERRITORIES, COUNT(TERRITORIES)
FROM canwildfireslocdate
GROUP BY TERRITORIES;
```

*-- After cofiguring that we have numbers, we update the "territories" column with the right ones without numbers*

```
UPDATE canwildfireslocdate
SET TERRITORIES = REGEXP_REPLACE(TERRITORIES, '[0-9]+', '');
```

*-- We now check to see if the rows affected*

```
SELECT TERRITORIES, COUNT(TERRITORIES)
FROM canwildfireslocdate
GROUP BY TERRITORIES;
```


### Breaking the "territories" column into 3 columns


*-- Checking for placing the right substrings in the new columns*

```
SELECT TERRITORIES,
SUBSTRING_INDEX(TERRITORIES, ',', 1) AS ABBREVIATION,
SUBSTRING_INDEX(SUBSTRING_INDEX(TERRITORIES, ',', 2), ',', -1) AS PROV_TERRIT,
SUBSTRING_INDEX(TERRITORIES, ',', -1) AS COUNTRY
FROM canwildfireslocdate
WHERE FID > 280000;

ALTER TABLE canwildfireslocdate
ADD COLUMN ABBREVIATION VARCHAR(30) AFTER TERRITORIES,
ADD COLUMN PROV_TERRIT VARCHAR(30) AFTER ABBREVIATION,
ADD COLUMN COUNTRY VARCHAR(30) AFTER PROV_TERRIT;

UPDATE canwildfireslocdate
SET ABBREVIATION = SUBSTRING_INDEX(TERRITORIES, ',', 1);

UPDATE canwildfireslocdate
SET PROV_TERRIT = SUBSTRING_INDEX(SUBSTRING_INDEX(TERRITORIES, ',', 2), ',', -1);

UPDATE canwildfireslocdate
SET COUNTRY = SUBSTRING_INDEX(TERRITORIES, ',', -1);

```

*-- Testing if everything was updated correctly*

```
SELECT * FROM canwildfireslocdate
WHERE FID > 400000;
```


### Replacing Lighting and Human with L / H respectively, in "cause" column in "canwildfiresinfo" table for uniformity



*-- Checking what and how many incosistencies we have in this column*

```
SELECT DISTINCT(CAUSE), COUNT(CAUSE)
FROM canwildfiresinfo
GROUP BY CAUSE;

SELECT CAUSE,
CASE
	WHEN CAUSE = 'Lighting' THEN 'L'
    WHEN CAUSE = 'Human'THEN 'H'
    WHEN CAUSE = '' THEN 'DO_NOT_KNOW'
    ELSE CAUSE
END AS UPD_CAUSE
FROM canwildfiresinfo;

UPDATE canwildfiresinfo
SET CAUSE =
	CASE 
		WHEN CAUSE = 'Lighting' THEN 'L'
		WHEN CAUSE = 'Human' THEN 'H'
		WHEN CAUSE = '' THEN 'DO_NOT_KNOW'
        ELSE CAUSE
	END;


SELECT DISTINCT(CAUSE), COUNT(CAUSE)
FROM canwildfiresinfo
GROUP BY CAUSE;
```


### Drop unused columns


```
ALTER TABLE canwildfiresinfo
DROP COLUMN PROTZONE,
DROP COLUMN ECOZ_NAME;

ALTER TABLE canwildfireslocdate
DROP COLUMN TERRITORIES;
```
