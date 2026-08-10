-- STAGE 1: Data extraction
DROP TABLE IF EXISTS reviews_raw;
CREATE TABLE reviews_raw (
    id VARCHAR(50),
    OverallRating VARCHAR(50),
    ReviewHeader TEXT,
    Name VARCHAR(255),
    Datetime VARCHAR(255),
    VerifiedReview VARCHAR(50),
    ReviewBody LONGTEXT,
    TypeOfTraveller VARCHAR(255),
    SeatType VARCHAR(255),
    Route VARCHAR(255),
    DateFlown VARCHAR(255),
    SeatComfort VARCHAR(50),
    CabinStaffService VARCHAR(50),
    GroundService VARCHAR(50),
    ValueForMoney VARCHAR(50),
    Recommended VARCHAR(50),
    Aircraft VARCHAR(255),
    FoodAndBeverages VARCHAR(50),
    InflightEntertainment VARCHAR(50),
    WifiAndConnectivity VARCHAR(50)
);
-- Please change the path to your local path in load data local infile or move the BA_AirlineReviews file to drive C
LOAD DATA LOCAL INFILE 'C:/BA_AirlineReviews.csv'
INTO TABLE reviews_raw
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

CREATE TABLE reviews_staging
LIKE reviews_raw 
;

INSERT reviews_staging
SELECT *
FROM reviews_raw
;


-- STAGE 2: Data cleaning 
	-- PART 1:Duplicates removing

-- Search for duplicates

WITH duplicates AS
(
	SELECT *,
	ROW_NUMBER () OVER (PARTITION BY Name, TRIM(LOWER(ReviewBody)), DateFlown) AS row_num
	FROM reviews_staging
	)
SELECT *
FROM duplicates 
WHERE row_num > 1
; 

-- Creating new staging table
DROP TABLE IF EXISTS reviews_staging2;
CREATE TABLE `reviews_staging2` (
  `id` varchar(50) DEFAULT NULL,
  `OverallRating` varchar(50) DEFAULT NULL,
  `ReviewHeader` text,
  `Name` varchar(255) DEFAULT NULL,
  `Datetime` varchar(255) DEFAULT NULL,
  `VerifiedReview` varchar(50) DEFAULT NULL,
  `ReviewBody` longtext,
  `TypeOfTraveller` varchar(255) DEFAULT NULL,
  `SeatType` varchar(255) DEFAULT NULL,
  `Route` varchar(255) DEFAULT NULL,
  `DateFlown` varchar(255) DEFAULT NULL,
  `SeatComfort` varchar(50) DEFAULT NULL,
  `CabinStaffService` varchar(50) DEFAULT NULL,
  `GroundService` varchar(50) DEFAULT NULL,
  `ValueForMoney` varchar(50) DEFAULT NULL,
  `Recommended` varchar(50) DEFAULT NULL,
  `Aircraft` varchar(255) DEFAULT NULL,
  `FoodAndBeverages` varchar(50) DEFAULT NULL,
  `InflightEntertainment` varchar(50) DEFAULT NULL,
  `WifiAndConnectivity` varchar(50) DEFAULT NULL,
  `RowNumber` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data

INSERT INTO reviews_staging2
SELECT *,
	ROW_NUMBER () OVER (PARTITION BY Name, TRIM(LOWER(ReviewBody)), DateFlown) AS row_num
	FROM reviews_staging;
    
-- Duplicates removing
SELECT *
FROM reviews_staging2
WHERE RowNumber > 1;

DELETE 
FROM reviews_staging2
WHERE RowNumber > 1;


	-- PART 2: Standartising data
-- Trimming

UPDATE reviews_staging2 
SET Name = TRIM(Name),
    ReviewHeader = TRIM(ReviewHeader),
    ReviewBody = TRIM(ReviewBody),
    Datetime = TRIM(Datetime), 
    VerifiedReview = TRIM(VerifiedReview),
    TypeOfTraveller = TRIM(TypeOfTraveller),
    SeatType = TRIM(SeatType),
    Route = TRIM(Route),
    Aircraft = TRIM(Aircraft);

-- Extraction departure, arrival and via place column

CREATE OR REPLACE VIEW PlaceRaw AS
SELECT id, Route,
	TRIM(SUBSTRING_INDEX( REPLACE(Route, ' to ', '-'), '-', 1)) AS DeparturePlaceRaw,
    TRIM(CASE 
			WHEN LOCATE('via', Route) > 0 THEN
            SUBSTRING_INDEX(REPLACE(SUBSTRING_INDEX(Route, 'via', 1), ' to ', '-'), '-', -1)
		ELSE 
			SUBSTRING_INDEX( REPLACE(Route, ' to ', '-'), '-', -1) 
		END) AS ArrivalPlaceRaw,
	TRIM(CASE 
			WHEN LOCATE ('via', Route) > 0 THEN 
				SUBSTRING_INDEX(Route, 'via', -1)
		ELSE 
			NULL
		END) AS ViaRaw
FROM reviews_staging2
        ;
   

-- Typo fixing 
DROP TABLE IF EXISTS typo_map;
CREATE TABLE typo_map (
    typo VARCHAR(255),
    correction VARCHAR(255)
);

INSERT INTO typo_map(typo, correction) VALUES
('doha to londonDoha to London', 'Doha to London'),
('Kiev', 'Kyiv'),
('London Heathrow', 'Heathrow'),
('London Gatwick', 'Gatwick'),
('New York JFK', 'JFK'),
('Mexico City', 'Mexico'),
('St Lucia', 'Saint Lucia'),
('Paris CDG', 'CDG'),
('Tenerife South', 'Tenerife'),
('Athens Greece', 'Athens'),
('Washington Dulles', 'Dulles'),
('Rio De Janeiro', 'Rio de Janeiro'),
('Berlin Tegel', 'Tegel'),
('Venice Marco Polo', 'Marco Polo'),
('Johannesburg OR Tambo', 'O. R. Tambo'),
('Larnaca Cyprus', 'Larnaca'),
('Tokyo Haneda', 'Haneda'),
('Milan Malpensa', 'Malpensa'),
('Düsseldorf', 'Dusseldorf'),
('Santiago de Chile', 'Santiago'),
('São Paulo', 'Sao Paulo'),
('Belfast City', 'Belfast'),
('Paris Orly', 'Orly'),
('Zürich', 'Zurich'),
('London LGW', 'LGW'),
('Tokyo Narita', 'Narita'),
('St Kitts', 'Saint Kitts'),
('Rome FCO', 'FCO'),
('Tampa International', 'Tampa'),
('London LHR', 'LHR'),
('Orlando MCO', 'MCO'),
('San Fransisco', 'San Francisco'),
('Montpelier', 'Montpellier'),
('Los Angesles', 'Los Angeles'),
('Bombay', 'Mumbai'),
('İstanbul', 'Istanbul to London'),
('London City Airport', 'London City'),
('London,', 'London'),
('Dallas Ft Worth', 'Dallas Fort Worth'),
('London Heaathrow', 'Heathrow'),
('London-Heathrow', 'Heathrow'),
('Cuty', 'City'),
('San Jose, CA', 'San Jose'),
('Kraków', 'Krakow'),
('Abuja, Nigeria', 'Abuja'),
('Manchester, UK', 'Manchester'),
('Billund, Denmark', 'Billund'),
('San Jose Costa Rica', 'San Jose'),
('Heathrow (London)', 'Heathrow'),
('JFK (New York City)', 'JFK'),
('lgw', 'LGW'),
('alicante', 'Alicante'),
('VIE return', 'VIE'),
('Singapire', 'Singapore'),
('Vancouver Canada', 'Vancouver'),
('Vancouver return', 'Vancouver'),
('London Heatrow', 'Heathrow'),
('Bangalore', 'Bengaluru'),
('Marrakech', 'Marrakesh'),
('Dallas Fort-Worth', 'Dallas Fort Worth'),
('Orlando, Florida', 'Orlando'),
('Accra, Ghana', 'Accra'),
('Cephalonia', 'Kefalonia'),
('Rome Fiumicino', 'Fiumicino'),
('Edimbourgh', 'Edinburgh'),
('Rio de Janiero', 'Rio de Janeiro'),
('Seoul Incheon', 'Incheon'),
('Zakinthos', 'Zakynthos'),
('Istambul', 'Istanbul'),
('Washington DC', 'Washington'),
('Tirana Rinas', 'Rinas'),
('Arlanda Stockholm', 'Stockholm Arlanda'),
('Abuja Nigeria', 'Abuja'),
('Delhi Airport', 'Indira Gandhi'),
('Duesseldorf', 'Dusseldorf'),
('New Delhi', 'Delhi');

UPDATE reviews_staging2 AS r2
JOIN typo_map AS tm
	ON r2.Route LIKE CONCAT('%', tm.typo, '%')
SET r2.Route = REPLACE(r2.Route, tm.typo, tm.correction);

UPDATE reviews_staging2
SET Route = 'Heathrow to Tenerife'
WHERE id = 515;

UPDATE reviews_staging2
SET Route = 'Manchester to San Francisco via London'
WHERE id = 2826;

UPDATE reviews_staging2
SET Route = 'Sydney to Heathrow via Singapore'
WHERE id = 135;

UPDATE reviews_staging2
SET Route =  'London to Singapore'
WHERE id = 220;

UPDATE reviews_staging2
SET Route =  'Amman to Heathrow'
WHERE id = 280;

UPDATE reviews_staging2
SET Route =  'LHR to BOM'
WHERE id = 2848;

UPDATE reviews_staging2
SET Route =  'Bucharest to Los Angeles via Heathrow '
WHERE id = 992;

UPDATE reviews_staging2
SET Route =  'Los Angeles to Rome via London/Paris'
WHERE id = 2911;

UPDATE reviews_staging2
SET Route =  'Palma de Mallorca to Gatwick'
WHERE id = 231;

UPDATE reviews_staging2
SET Route =  'Palma de Mallorca to Heathrow'
WHERE id = 807;

UPDATE reviews_staging2
SET Route= 'Fuerteventura to LGW'
WHERE id = 2663;

UPDATE reviews_staging2 AS r2
JOIN typo_map AS tm
	ON r2.Route LIKE CONCAT( '%', tm.typo, '%')
SET r2.Route = REPLACE(Route, typo, correction);

-- Standartising date values

UPDATE reviews_staging2
SET Datetime = REGEXP_REPLACE(Datetime, '(st|nd|rd|th)', '');

UPDATE reviews_staging2
SET Datetime = REPLACE(Datetime, 'Augu', 'August')
WHERE Datetime LIKE '% Augu %';

UPDATE reviews_staging2
SET DateFlown = REPLACE(
    DateFlown, 
    SUBSTRING_INDEX(DateFlown, ' ', 1), 
	CASE SUBSTRING_INDEX(DateFlown, ' ', 1)
  WHEN 'January' THEN '01'
  WHEN 'February' THEN '02'
  WHEN 'March' THEN '03'
  WHEN 'April' THEN '04'
  WHEN 'May' THEN '05'
  WHEN 'June' THEN '06'
  WHEN 'July' THEN '07'
  WHEN 'August' THEN '08'
  WHEN 'September' THEN '09'
  WHEN 'October' THEN '10'
  WHEN 'November' THEN '11'
  WHEN 'December' THEN '12'
END)
;
UPDATE reviews_staging2
SET DateFlown = CONCAT('01 ', DateFlown)
WHERE DateFlown IS NOT NULL;


UPDATE reviews_staging2
SET Datetime = REPLACE(
    Datetime, 
    SUBSTRING_INDEX(SUBSTRING_INDEX(Datetime, ' ', 2), ' ', -1), 
    CASE SUBSTRING_INDEX(SUBSTRING_INDEX(Datetime, ' ', 2), ' ', -1)
        WHEN 'January'   THEN '01'
        WHEN 'February'  THEN '02'
        WHEN 'March'     THEN '03'
        WHEN 'April'     THEN '04'
        WHEN 'May'       THEN '05'
        WHEN 'June'      THEN '06'
        WHEN 'July'      THEN '07'
        WHEN 'August'    THEN '08'
        WHEN 'September' THEN '09'
        WHEN 'October'   THEN '10'
        WHEN 'November'  THEN '11'
        WHEN 'December'  THEN '12'
        ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(Datetime, ' ', 2), ' ', -1)
    END
)
WHERE Datetime IS NOT NULL;

-- Converting blank values into NULL

UPDATE reviews_staging2
SET OverallRating = NULL
WHERE OverallRating = '';

UPDATE reviews_staging2
SET ReviewHeader = NULL
WHERE ReviewHeader = '';
    
UPDATE reviews_staging2
SET Name = NULL
WHERE Name = '';

UPDATE reviews_staging2
SET Datetime = NULL
WHERE Datetime = '';

UPDATE reviews_staging2
SET VerifiedReview = NULL
WHERE VerifiedReview = '';

UPDATE reviews_staging2
SET ReviewBody = NULL
WHERE ReviewBody = '';

UPDATE reviews_staging2
SET TypeOfTraveller = NULL
WHERE TypeOfTraveller = '';

UPDATE reviews_staging2
SET SeatType = NULL
WHERE SeatType = '';

UPDATE reviews_staging2
SET Route = NULL
WHERE Route = '';

UPDATE reviews_staging2
SET DateFlown = NULL
WHERE DateFlown = '';

UPDATE reviews_staging2
SET SeatComfort = NULL
WHERE SeatComfort = '';

UPDATE reviews_staging2
SET CabinStaffService = NULL
WHERE CabinStaffService = '';

UPDATE reviews_staging2
SET GroundService = NULL
WHERE GroundService = '';

UPDATE reviews_staging2
SET ValueForMoney = NULL
WHERE ValueForMoney = '';

UPDATE reviews_staging2
SET Recommended = NULL
WHERE Recommended = '';

UPDATE reviews_staging2
SET Aircraft = NULL
WHERE Aircraft = '';

UPDATE reviews_staging2
SET FoodAndBeverages = NULL
WHERE FoodAndBeverages = '';

UPDATE reviews_staging2
SET InflightEntertainment = NULL
WHERE InflightEntertainment = '';

UPDATE reviews_staging2
SET WifiAndConnectivity = NULL
WHERE WifiAndConnectivity = '';

UPDATE reviews_staging2
SET 
    ValueForMoney     = CASE WHEN ValueForMoney IN ('', 'N/A', 'n/a', 'None') THEN NULL ELSE ValueForMoney END,
    SeatComfort       = CASE WHEN SeatComfort IN ('', 'N/A', 'n/a', 'None') THEN NULL ELSE SeatComfort END,
    CabinStaffService = CASE WHEN CabinStaffService IN ('', 'N/A', 'n/a', 'None') THEN NULL ELSE CabinStaffService END,
    GroundService     = CASE WHEN GroundService IN ('', 'N/A', 'n/a', 'None') THEN NULL ELSE GroundService END,
    FoodAndBeverages  = CASE WHEN FoodAndBeverages IN ('', 'N/A', 'n/a', 'None') THEN NULL ELSE FoodAndBeverages END;
    
    
-- Deleting inconvenient data

DROP TABLE IF EXISTS reviews_staging3;
CREATE TABLE `reviews_staging3` (
  `id` int DEFAULT NULL,
  `OverallRating` int DEFAULT NULL,
  `ReviewHeader` text,
  `Name` varchar(255) DEFAULT NULL,
  `Datetime` date DEFAULT NULL,
  `VerifiedReview` varchar(255) DEFAULT NULL,
  `ReviewBody` longtext,
  `TypeOfTraveller` varchar(255) DEFAULT NULL,
  `SeatType` varchar(255) DEFAULT NULL,
  `Route` varchar(255) DEFAULT NULL,
  `DateFlown` date DEFAULT NULL,
  `SeatComfort` int DEFAULT NULL,
  `CabinStaffService` int DEFAULT NULL,
  `GroundService` int DEFAULT NULL,
  `ValueForMoney` int DEFAULT NULL,
  `Recommended` varchar(255) DEFAULT NULL,
  `Aircraft` varchar(255) DEFAULT NULL,
  `FoodAndBeverages` int DEFAULT NULL,
  `InflightEntertainment` varchar(50) DEFAULT NULL,
  `WifiAndConnectivity` varchar(50) DEFAULT NULL,
  `DeparturePlace` varchar(255) DEFAULT NULL,
   `ArrivalPlace` varchar(255) DEFAULT NULL,
   `Via` varchar(255) DEFAULT NULL,
   `DepartureCountry` varchar(255) DEFAULT NULL,
   `DepartureLocality` varchar(255) DEFAULT NULL,
   `ArrivalCountry` varchar(255) DEFAULT NULL,
   `ArrivalLocality` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO reviews_staging3
SELECT r2.id, r2.OverallRating, r2.ReviewHeader, r2.Name, STR_TO_DATE(r2.Datetime, '%e %m %Y') AS Datetime, r2.VerifiedReview, r2.ReviewBody, 
	r2.TypeOfTraveller, r2.SeatType, r2.Route, STR_TO_DATE(r2.DateFlown, '%e %m %Y'), r2.SeatComfort, r2.CabinStaffService, r2.GroundService,
    r2.ValueForMoney, r2.Recommended, r2.Aircraft, r2.FoodAndBeverages, r2.InflightEntertainment, r2.WifiAndConnectivity,
	PR.DeparturePlaceRaw, PR.ArrivalPlaceRaw, PR.ViaRaw, NULL AS DepartureCountry, NULL AS DepartureLocality,
    NULL AS ArrivalCountry, NULL AS ArrivalLocality
FROM reviews_staging2 AS r2
JOIN PlaceRaw AS PR
	ON r2.id = PR.id;


DELETE FROM reviews_staging3
WHERE id = 22 OR id = 791 OR id = 1771 OR id = 2140 OR id = 523;

DELETE FROM reviews_staging3
WHERE Route IS NULL
;

-- Inserting cleaned columns based on Route 

	-- Departure
WITH Departure AS (
    SELECT r3.id, r3.Route,
    COALESCE(rmIATA.Country, rmLoc.Country, rmCN.Country, rmAir.Country) AS DepartureCountry,
    COALESCE(rmIATA.Locality, rmLoc.Locality, rmCN.Locality, rmAir.Locality) AS DepartureLocality
    FROM reviews_staging3 AS r3
    LEFT JOIN airports_roadmap AS rmIATA ON r3.DeparturePlace = rmIATA.IATAcode
    LEFT JOIN airports_roadmap AS rmLoc ON r3.DeparturePlace = rmLoc.Locality
    LEFT JOIN airports_roadmap AS rmCN ON r3.DeparturePlace = rmCN.CountryName
    LEFT JOIN airports_roadmap AS rmAir ON r3.DeparturePlace = rmAir.Airport
)
	-- Doublecheking for NULL Values (Unquote query to run the script)
		-- SELECT *
		-- FROM Departure
		-- WHERE DepartureCountry IS NULL OR DepartureLocality IS NULL
		-- ORDER BY id ASC;
        
UPDATE reviews_staging3 AS r3
JOIN Departure AS d 
	ON r3.id = d.id
SET r3.DepartureCountry = d.DepartureCountry, 
	r3.DepartureLocality = d.DepartureLocality;


	-- Arrival
WITH Arrival AS (
    SELECT r3.id, r3.Route,
    COALESCE(rmIATA.Country, rmLoc.Country, rmCN.Country, rmAir.Country) AS ArrivalCountry,
    COALESCE(rmIATA.Locality, rmLoc.Locality, rmCN.Locality, rmAir.Locality) AS ArrivalLocality
    FROM reviews_staging3 AS r3
    LEFT JOIN airports_roadmap AS rmIATA ON r3.ArrivalPlace = rmIATA.IATAcode
    LEFT JOIN airports_roadmap AS rmLoc ON r3.ArrivalPlace = rmLoc.Locality
    LEFT JOIN airports_roadmap AS rmCN ON r3.ArrivalPlace = rmCN.CountryName
    LEFT JOIN airports_roadmap AS rmAir ON r3.ArrivalPlace = rmAir.Airport
)
	-- Doublecheking for NULL values (Unquote query to run the script)
		-- SELECT *
		-- FROM Arrival
		-- WHERE ArrivalCountry IS NULL OR ArrivalLocality IS NULL
		-- ORDER BY id ASC;

UPDATE reviews_staging3 AS r3
JOIN Arrival AS d 
	ON r3.id = d.id
SET r3.ArrivalCountry = d.ArrivalCountry, 
	r3.ArrivalLocality = d.ArrivalLocality;


DROP TABLE IF EXISTS reviews_cleaned;
CREATE TABLE `reviews_cleaned` (
  `id` int DEFAULT NULL,
  `OverallRating` int DEFAULT NULL,
  `ReviewHeader` text,
  `Name` varchar(255) DEFAULT NULL,
  `Datetime` date DEFAULT NULL,
  `VerifiedReview` varchar(255) DEFAULT NULL,
  `ReviewBody` longtext,
  `TypeOfTraveller` varchar(255) DEFAULT NULL,
  `SeatType` varchar(255) DEFAULT NULL,
  `Route` varchar(255) DEFAULT NULL,
  `DateFlown` date DEFAULT NULL,
  `SeatComfort` int DEFAULT NULL,
  `CabinStaffService` int DEFAULT NULL,
  `GroundService` int DEFAULT NULL,
  `ValueForMoney` int DEFAULT NULL,
  `Recommended` varchar(255) DEFAULT NULL,
  `Aircraft` varchar(255) DEFAULT NULL,
  `FoodAndBeverages` int DEFAULT NULL,
  `InflightEntertainment` int DEFAULT NULL,
  `WifiAndConnectivity` int DEFAULT NULL,
  `DepartureCountry` varchar(255) DEFAULT NULL,
   `DepartureLocality` varchar(255) DEFAULT NULL,
   `ArrivalCountry` varchar(255) DEFAULT NULL,
   `ArrivalLocality` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO reviews_cleaned
SELECT id, OverallRating, ReviewHeader, Name, Datetime, VerifiedReview, ReviewBody, 
	TypeOfTraveller, SeatType, Route, DateFlown, SeatComfort, CabinStaffService, GroundService,
    ValueForMoney, Recommended, Aircraft, FoodAndBeverages, InflightEntertainment, WifiAndConnectivity, 
    DepartureCountry, DepartureLocality, ArrivalCountry, ArrivalLocality
FROM reviews_staging3;


-- Compering how much data was used compared to the original dataset
SELECT ROUND(((SELECT COUNT(*) FROM reviews_cleaned) * 1.0 / (SELECT COUNT(*) FROM reviews_staging)) * 100, 2) AS used_data_percent
;

-- Creating a view without review text in order to correctly extract data
CREATE OR REPLACE VIEW for_tableau AS
SELECT 'id', 'OverallRating', 'Name', 'Datetime', 'VerifiedReview', 'TypeOfTraveller', 'SeatType', 'Route', 'DateFlown',
    'SeatComfort', 'CabinStaffService', 'GroundService', 'ValueForMoney', 'Recommended', 'Aircraft', 'FoodAndBeverages', 'InflightEntertainment',
    'WifiAndConnectivity', 'DepartureCountry', 'DepartureLocality', 'ArrivalCountry', 'ArrivalLocality'
UNION ALL
SELECT 
	r.id, r.OverallRating, r.Name, r.Datetime, r.VerifiedReview, r.TypeOfTraveller, r.SeatType, r.Route, r.DateFlown,
    r.SeatComfort, r.CabinStaffService, r.GroundService, r.ValueForMoney, r.Recommended, r.Aircraft, r.FoodAndBeverages, r.InflightEntertainment,
    r.WifiAndConnectivity, r.DepartureCountry, r.DepartureLocality, r.ArrivalCountry, r.ArrivalLocality
FROM reviews_cleaned AS r;

