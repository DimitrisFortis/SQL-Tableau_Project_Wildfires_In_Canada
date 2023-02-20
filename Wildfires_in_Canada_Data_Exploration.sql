-- DATA EXPLORATION



-- Total Number of wildfires per province/territory (Which provinces/territories have the highest number of wildfires?)
SELECT PROV_TERRIT, COUNT(PROV_TERRIT) AS NO_OF_WILDFIRES_PERTERR
FROM canwildfireslocdate
GROUP BY PROV_TERRIT
ORDER BY 2 DESC;


-- Annual shift of No of fires in 'British Columbia'
SELECT 
    can1.YEAR, 
    ((can1.count_fires - can2.count_fires) / can2.count_fires) * 100 AS ANNUAL_CHANGE 
FROM (
    SELECT 
        YEAR(REP_DATE) AS YEAR, 
        COUNT(*) AS count_fires 
    FROM 
        canwildfireslocdate 
    WHERE 
        PROV_TERRIT = ' British Columbia' 
    GROUP BY 
        YEAR(REP_DATE) 
) can1
JOIN (
    SELECT 
        YEAR(REP_DATE) AS YEAR, 
        COUNT(*) AS count_fires 
    FROM 
        canwildfireslocdate 
    WHERE 
        PROV_TERRIT = ' British Columbia' 
    GROUP BY 
        YEAR(REP_DATE)
) can2 
ON can1.YEAR = can2.YEAR - 1
ORDER BY 
    can1.YEAR DESC;

-- Percentage of wildfires per province/territory (Likelihood of wildfire per province/territory)
SELECT PROV_TERRIT, (COUNT(PROV_TERRIT) / (SELECT COUNT(*) FROM canwildfireslocdate)*100) AS PERCENTAGE_OF_WILDFIRES_PERTERR
FROM canwildfireslocdate
GROUP BY PROV_TERRIT
ORDER BY 2 DESC;

-- Total Number of wildfires per year (What is the overall trend in the number of wildfires over time?)
SELECT YEAR(REP_DATE) AS YEAR, COUNT(YEAR(REP_DATE)) AS NO_OF_WILDFIRES_PERY
FROM canwildfireslocdate
GROUP BY YEAR(REP_DATE)
ORDER BY 1 DESC;

-- Percentage of wildfires per year
SELECT YEAR(REP_DATE) AS YEAR, (COUNT(YEAR(REP_DATE)) / (SELECT COUNT(*) FROM canwildfireslocdate)*100) AS PERCENTAGE_OF_WILDFIRES_PERY
FROM canwildfireslocdate
GROUP BY YEAR(REP_DATE)
ORDER BY 1 DESC;

-- Total Number of wildfires per month (Which month is the most dangerous, based on No. of wildfires)
SELECT MONTH(REP_DATE) AS MONTH, COUNT(MONTH(REP_DATE)) AS NO_OF_WILDFIRES_PERM
FROM canwildfireslocdate
GROUP BY MONTH(REP_DATE)
ORDER BY 2 DESC;

-- Total area burnt per province/territory (Which provinces/territories have the highest areas burnt from wildfires?)
SELECT can_ld.PROV_TERRIT, SUM(can_info.SIZE_HA) AS AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;

-- Percentage of area burnt per province/territory
SELECT can_ld.PROV_TERRIT, (SUM(can_info.SIZE_HA) / (SELECT SUM(SIZE_HA) FROM canwildfiresinfo)*100) AS PERCENTAGE_OF_AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;

-- How has the amount of hectares burnt changed over time?
SELECT SUM(can_info.SIZE_HA) AS AREA_BURNT_PERY, YEAR(can_ld.REP_DATE) AS YEAR_OF_WILDFIRE
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY YEAR(can_ld.REP_DATE)
ORDER BY 2 DESC;

-- What is the average size of wildfires in each province/territory?
SELECT can_ld.PROV_TERRIT, AVG(can_info.SIZE_HA) AS AVERAGE_AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
WHERE YEAR(can_ld.REP_DATE) <> 0
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;

-- Highest area burnt per province/territory and which year that wildfire happened
SELECT can_ld.PROV_TERRIT, MAX(can_info.SIZE_HA) AS HIGHEST_AREA_BURNT_PERTERR, YEAR(can_ld.REP_DATE) AS YEAR_OF_WILDFIRE
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT, YEAR(can_ld.REP_DATE)
ORDER BY 2 DESC;

-- What is the most common cause of wildfires?
SELECT CAUSE, COUNT(CAUSE) AS NUMBER_OF_OCCURRENCIES, (COUNT(CAUSE) / (SELECT COUNT(*) FROM canwildfiresinfo))*100 AS PERCENTAGE_OF_EACH_CAUSE
FROM canwildfiresinfo
GROUP BY CAUSE
ORDER BY 3 DESC;

-- Is there a relationship between the cause of the wildfires and the location or size of the area burnt?
SELECT can_info.CAUSE, can_ld.PROV_TERRIT, SUM(can_info.SIZE_HA) AS AREA_BURNT_HA
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
WHERE CAUSE <> 'DO_NOT_KNOW'
GROUP BY can_info.CAUSE, can_ld.PROV_TERRIT
ORDER BY 1,2,3 DESC;
