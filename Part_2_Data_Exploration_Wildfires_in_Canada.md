### DATA EXPLORATION



#### Total Number of wildfires per province/territory (Which provinces/territories have the highest number of wildfires?)

```
SELECT PROV_TERRIT, COUNT(PROV_TERRIT) AS NO_OF_WILDFIRES_PERTERR
FROM canwildfireslocdate
GROUP BY PROV_TERRIT
ORDER BY 2 DESC;
```

![1_The_10_Territories_with_the_most_wildfires_1950-2021](https://user-images.githubusercontent.com/123563233/220195031-2b8e3ea7-fd95-4493-b204-42b0ff4aaafe.png)


#### Annual shift of No of fires in 'British Columbia'

```
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
```

![2  Annual Percentage Change in Number of Wildfires in British Columbia](https://user-images.githubusercontent.com/123563233/220195072-c4a7dfc8-d98b-4e94-9f5d-bdb12f6dbfe9.png)


#### Percentage of wildfires per province/territory (Likelihood of wildfire per province/territory)

```
SELECT PROV_TERRIT, (COUNT(PROV_TERRIT) / (SELECT COUNT(*) FROM canwildfireslocdate)*100) AS PERCENTAGE_OF_WILDFIRES_PERTERR
FROM canwildfireslocdate
GROUP BY PROV_TERRIT
ORDER BY 2 DESC;
```

![3  % of each territory's wildfires compared to Total](https://user-images.githubusercontent.com/123563233/220195115-4c27938c-7976-4b09-bdd2-b3f6d5e42e37.png)


#### Total Number of wildfires per year (What is the overall trend in the number of wildfires over time?)

```
SELECT YEAR(REP_DATE) AS YEAR, COUNT(YEAR(REP_DATE)) AS NO_OF_WILDFIRES_PERY
FROM canwildfireslocdate
GROUP BY YEAR(REP_DATE)
ORDER BY 1 DESC;
```

![4  Total No of wildfires per year (1950-2021)](https://user-images.githubusercontent.com/123563233/220195140-feb91914-2bb2-4c31-9926-b02332fc9aac.png)


#### Percentage of wildfires per year

```
SELECT YEAR(REP_DATE) AS YEAR, (COUNT(YEAR(REP_DATE)) / (SELECT COUNT(*) FROM canwildfireslocdate)*100) AS PERCENTAGE_OF_WILDFIRES_PERY
FROM canwildfireslocdate
GROUP BY YEAR(REP_DATE)
ORDER BY 1 DESC;
```

#### Total Number of wildfires per month (Which month is the most dangerous, based on No. of wildfires)

```
SELECT MONTH(REP_DATE) AS MONTH, COUNT(MONTH(REP_DATE)) AS NO_OF_WILDFIRES_PERM
FROM canwildfireslocdate
GROUP BY MONTH(REP_DATE)
ORDER BY 2 DESC;
```

![5  Total No of wildfires per Month (1950-2021)](https://user-images.githubusercontent.com/123563233/220195237-30e817fd-9dfa-4a74-8cc4-2b578d52c179.png)


#### Total area burnt per province/territory (Which provinces/territories have the highest areas burnt from wildfires?)

```
SELECT can_ld.PROV_TERRIT, SUM(can_info.SIZE_HA) AS AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;
```

![6  Total area burnt per territory (ha)](https://user-images.githubusercontent.com/123563233/220194260-17f6a1b4-f953-41bd-9a56-d44081eccf61.png)


#### Percentage of area burnt per province/territory

```
SELECT can_ld.PROV_TERRIT, (SUM(can_info.SIZE_HA) / (SELECT SUM(SIZE_HA) FROM canwildfiresinfo)*100) AS PERCENTAGE_OF_AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;
```

![7  % of area burnt per territory (1950-2021)](https://user-images.githubusercontent.com/123563233/220194493-a6d90c5a-9834-499a-8456-accaf07a2fd9.png)


#### How has the amount of hectares burnt changed over time?

```
SELECT SUM(can_info.SIZE_HA) AS AREA_BURNT_PERY, YEAR(can_ld.REP_DATE) AS YEAR_OF_WILDFIRE
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY YEAR(can_ld.REP_DATE)
ORDER BY 2 DESC;
```

![8  HA of land burnt over time (1950-2021)](https://user-images.githubusercontent.com/123563233/220194622-8d2c5fa6-0a5b-43f7-83b6-01e793b05cae.png)


#### What is the average size of wildfires in each province/territory?

```
SELECT can_ld.PROV_TERRIT, AVG(can_info.SIZE_HA) AS AVERAGE_AREA_BURNT_PERTERR
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
WHERE YEAR(can_ld.REP_DATE) <> 0
GROUP BY can_ld.PROV_TERRIT
ORDER BY 2 DESC;
```

![9  Average Area Burnt on Top 10 territories (1950-2021)](https://user-images.githubusercontent.com/123563233/220194686-c7a7d0ca-3d0e-45b7-b774-46a1414e7807.png)


#### Highest area burnt per province/territory and which year that wildfire happened

```
SELECT can_ld.PROV_TERRIT, MAX(can_info.SIZE_HA) AS HIGHEST_AREA_BURNT_PERTERR, YEAR(can_ld.REP_DATE) AS YEAR_OF_WILDFIRE
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
GROUP BY can_ld.PROV_TERRIT, YEAR(can_ld.REP_DATE)
ORDER BY 2 DESC;
```

![10  MAX area burnt per territory (1950-2021)](https://user-images.githubusercontent.com/123563233/220194830-aa880f19-01ab-46b7-b1ce-e2a6bad4af5a.png)


#### What is the most common cause of wildfires?

```
SELECT CAUSE, COUNT(CAUSE) AS NUMBER_OF_OCCURRENCIES, (COUNT(CAUSE) / (SELECT COUNT(*) FROM canwildfiresinfo))*100 AS PERCENTAGE_OF_EACH_CAUSE
FROM canwildfiresinfo
GROUP BY CAUSE
ORDER BY 3 DESC;
```

![11  Most common causes of wildfire (1950-2021)](https://user-images.githubusercontent.com/123563233/220194889-bd290d40-2f8f-4de8-980b-c99cfeec3699.png)


#### Is there a relationship between the cause of the wildfires and the location or size of the area burnt?

```
SELECT can_info.CAUSE, can_ld.PROV_TERRIT, SUM(can_info.SIZE_HA) AS AREA_BURNT_HA
FROM canwildfireslocdate AS can_ld
JOIN canwildfiresinfo AS can_info
ON can_ld.FID = can_info.FID
WHERE CAUSE <> 'DO_NOT_KNOW'
GROUP BY can_info.CAUSE, can_ld.PROV_TERRIT
ORDER BY 1,2,3 DESC;
```

![12  Territory-AreaBurnt-Cause Relation (1950-2021)](https://user-images.githubusercontent.com/123563233/220194937-3bb7bde6-8117-4b17-882d-0c70dbff0a0c.png)



