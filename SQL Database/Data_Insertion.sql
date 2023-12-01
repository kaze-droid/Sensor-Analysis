USE GoBest_Cab;

DROP TABLE IF EXISTS TempSensors
-- Create a temporary area for all the sensor data to be bulk inserted into
-- Also to remove a certain unwanted columns
CREATE TABLE TempSensors(
	ID INT,
	bookingID BIGINT,
	Accuracy Float,
	Bearing Float,
	acceleration_x Float,
	acceleration_y Float,
	acceleration_z Float,
	gyro_x Float,
	gyro_y Float, 
	gyro_z Float,
	second Float,
	Speed Float
	)

-- Bulk insert the sensors data into the temp table
BULK INSERT TempSensors
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\0_Sensor_DataSet_features_part.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)

-- Bulk insert the sensors data into the temp table
BULK INSERT TempSensors
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\1-Sensor_DataSet_features_part.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)

-- Bulk insert the sensors data into the temp table
BULK INSERT TempSensors
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\2-Sensor_DataSet_features_part.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)

-- Bulk insert the sensors data into the temp table
BULK INSERT TempSensors
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\3_Sensor_DataSet_features_part.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)

-- Bulk insert the sensors data into the temp table
BULK INSERT TempSensors
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\4_Sensor_DataSet_features_part.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '\n'
)

-- Insert Cab_Driver data
BULK INSERT Cab_Driver
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\drivers_dataset.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '0x0a'
)

--Insert Safety_Labels data
BULK INSERT Safety_Labels
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Documents\SP Y2S2\PAI\Assessments\CA1\Datasets\safety_status_dataset.csv'
WITH
(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDTERMINATOR= ',',
ROWTERMINATOR = '0x0a'
)

-- Copy data from temporary table into Sensor_Data table (excluding ID)
INSERT INTO Sensor_Data(bookingID, Accuracy, Bearing, acceleration_x, acceleration_y, acceleration_z, gyro_x, gyro_y, gyro_z, second, Speed)
SELECT bookingID, Accuracy, Bearing, acceleration_x, acceleration_y, acceleration_z, gyro_x, gyro_y, gyro_z, second, Speed
FROM TempSensors;

-- Drop TempSensors table after
DROP TABLE TempSensors;

