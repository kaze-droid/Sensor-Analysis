-- Query 1: Retrieve the top 5 driver names, average ratings, driver's age and the car age based on their total ratings
WITH DriverSafety AS (
	SELECT
		cd.driver_id, 
		cd.driver_name,
		SUM(driver_rating) AS total_ratings,
		CAST(AVG(driver_rating) AS decimal(10,2)) AS average_ratings,
		cd.car_brand,
		cd.No_of_Years_driving_exp AS No_of_Driving_Yrs_Exp,
		DATEDIFF(YEAR, CONVERT(DATE,data_of_birth, 101), GETDATE()) AS age_of_driver,
		(YEAR(GETDATE())-car_model_year) AS age_of_car,
		sl.label
	FROM Cab_Driver AS cd
	JOIN Safety_Labels AS sl ON cd.driver_id = sl.driver_id
	GROUP BY 
		cd.driver_id, 
		cd.driver_name, 
		cd.car_brand,
		cd.No_of_Years_driving_exp,
		DATEDIFF(YEAR, CONVERT(DATE,data_of_birth, 101), GETDATE()),
		YEAR(GETDATE())-car_model_year, 
		sl.label
)

SELECT TOP 10
	driver_name,
	total_ratings,
	average_ratings,
	No_of_Driving_Yrs_Exp,
	car_brand,
	age_of_car
FROM DriverSafety
WHERE label = 1 AND No_of_Driving_Yrs_Exp <= 10
ORDER BY total_ratings DESC, average_ratings DESC

-- Query 2: Bins the drivers according to average distance and obtain the average ratings and rate of unsafe trips
WITH DriverTripData AS (
	SELECT
		d.driver_name AS driver_name,
		AVG(s.second * s.speed) AS avg_distance,
		CAST(SUM(sa.label) AS Float)/CAST(COUNT(sa.label) AS Float)*100 AS rate_of_unsafe_trips,
		AVG(d.driver_rating) AS driver_rating
	FROM Sensor_Data s
	JOIN Safety_Labels sa ON sa.bookingID = s.bookingID
	JOIN Cab_Driver d ON sa.driver_id = d.driver_id
	WHERE s.second * s. speed > 0
	GROUP BY d.driver_name, d.driver_id
)

SELECT 
	CASE
		WHEN avg_distance < 5000 THEN 'Group 1. Less than 5,000'
		WHEN avg_distance >=5000 AND avg_distance<=7000 THEN 'Group 2. 5,000 to 7,000'
		WHEN avg_distance >=7000 AND avg_distance<=9000 THEN 'Group 3. 7,000 to 9,000'
		ELSE 'Group 4. Greater than 9,000'
	END AS DistanceGroup,
	CAST(AVG(rate_of_unsafe_trips) AS decimal(4,2)) AS "Rate of Unsafe Trips (%)",
	CAST(AVG(driver_rating) AS decimal(4,2)) AS "Avg Driver Rating"
FROM DriverTripData
GROUP BY CASE
		WHEN avg_distance < 5000 THEN 'Group 1. Less than 5,000'
		WHEN avg_distance >=5000 AND avg_distance<=7000 THEN 'Group 2. 5,000 to 7,000'
		WHEN avg_distance >=7000 AND avg_distance<=9000 THEN 'Group 3. 7,000 to 9,000'
		ELSE 'Group 4. Greater than 9,000'
END
ORDER BY DistanceGroup;

-- Query 3: Filter Safety_Labels table, safety_label = 1, exclude null values
USE GoBest_Cab;

SELECT bookingID
INTO TempSafetyLabels
FROM Safety_Labels
WHERE label = 1
AND driver_id IS NOT NULL
AND bookingID IS NOT NULL;

;WITH SensorStats AS (
    SELECT
        AVG(Accuracy) AS Accuracy_AVG, STDEV(Accuracy) AS Accuracy_STD,
        AVG(Bearing) AS Bearing_AVG, STDEV(Bearing) AS Bearing_STD,
        AVG(acceleration_x) AS acceleration_x_AVG, STDEV(acceleration_x) AS acceleration_x_STD,
        AVG(acceleration_y) AS acceleration_y_AVG, STDEV(acceleration_y) AS acceleration_y_STD,
        AVG(acceleration_z) AS acceleration_z_AVG, STDEV(acceleration_z) AS acceleration_z_STD,
        AVG(gyro_x) AS gyro_x_AVG, STDEV(gyro_x) AS gyro_x_STD,
        AVG(gyro_y) AS gyro_y_AVG, STDEV(gyro_y) AS gyro_y_STD,
        AVG(gyro_z) AS gyro_z_AVG, STDEV(gyro_z) AS gyro_z_STD,
        AVG(Speed) AS Speed_AVG, STDEV(Speed) AS Speed_STD
    FROM Sensor_Data SD
    INNER JOIN TempSafetyLabels FSL ON SD.bookingID = FSL.bookingID
),
Anomalies AS (
    SELECT
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.Accuracy - Accuracy_AVG) > 1.5 * Accuracy_STD) AS Accuracy_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.Bearing - Bearing_AVG) > 1.5 * Bearing_STD) AS Bearing_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.acceleration_x - acceleration_x_AVG) > 1.5 * acceleration_x_STD) AS acceleration_x_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.acceleration_y - acceleration_y_AVG) > 1.5 * acceleration_y_STD) AS acceleration_y_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.acceleration_z - acceleration_z_AVG) > 1.5 * acceleration_z_STD) AS acceleration_z_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.gyro_x - gyro_x_AVG) > 1.5 * gyro_x_STD) AS gyro_x_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.gyro_y - gyro_y_AVG) > 1.5 * gyro_y_STD) AS gyro_y_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.gyro_z - gyro_z_AVG) > 1.5 * gyro_z_STD) AS gyro_z_Anomaly_Count,
        (SELECT COUNT(*) FROM Sensor_Data SD WHERE ABS(SD.Speed - Speed_AVG) > 1.5 * Speed_STD) AS Speed_Anomaly_Count
    FROM SensorStats
),
TotalCounts AS (
    SELECT
        COUNT(*) AS TotalRows
    FROM Sensor_Data SD
    INNER JOIN TempSafetyLabels FSL ON SD.bookingID = FSL.bookingID
)
SELECT
    'Average' AS Statistic,
    Accuracy_AVG AS Accuracy,
    Bearing_AVG AS Bearing,
    acceleration_x_AVG AS acceleration_x,
    acceleration_y_AVG AS acceleration_y,
    acceleration_z_AVG AS acceleration_z,
    gyro_x_AVG AS gyro_x,
    gyro_y_AVG AS gyro_y,
    gyro_z_AVG AS gyro_z,
    Speed_AVG AS Speed
FROM SensorStats
UNION
SELECT
    'Standard Deviation',
    Accuracy_STD,
    Bearing_STD,
    acceleration_x_STD,
    acceleration_y_STD,
    acceleration_z_STD,
    gyro_x_STD,
    gyro_y_STD,
    gyro_z_STD,
    Speed_STD
FROM SensorStats
UNION
SELECT
    'Anomaly Count',
    Accuracy_Anomaly_Count,
    Bearing_Anomaly_Count,
    acceleration_x_Anomaly_Count,
    acceleration_y_Anomaly_Count,
    acceleration_z_Anomaly_Count,
    gyro_x_Anomaly_Count,
    gyro_y_Anomaly_Count,
    gyro_z_Anomaly_Count,
    Speed_Anomaly_Count
FROM Anomalies, TotalCounts
UNION
SELECT
    'Anomaly Percentage',
    round(Accuracy_Anomaly_Count * 100.0 / TotalRows, 2) AS Accuracy,
    round(Bearing_Anomaly_Count * 100.0 / TotalRows, 2) AS Bearing,
    round(acceleration_x_Anomaly_Count * 100.0 / TotalRows, 2) AS acceleration_x,
    round(acceleration_y_Anomaly_Count * 100.0 / TotalRows, 2) AS acceleration_y,
    round(acceleration_z_Anomaly_Count * 100.0 / TotalRows, 2) AS acceleration_z,
    round(gyro_x_Anomaly_Count * 100.0 / TotalRows, 2) AS gyro_x,
    round(gyro_y_Anomaly_Count * 100.0 / TotalRows, 2) AS gyro_y,
    round(gyro_z_Anomaly_Count * 100.0 / TotalRows, 2) AS gyro_z,
    round(Speed_Anomaly_Count * 100.0 / TotalRows, 2) AS Speed
FROM Anomalies, TotalCounts;

-- Drop the temp table
DROP TABLE TempSafetyLabels;
