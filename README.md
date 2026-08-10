BA AIRLINE REVIEWS
The dataset was taken from Kaggle and contains customer feedback for British Airways, extracted from AirlineQuality through web scraping.
Link: https://www.kaggle.com/datasets/chaudharyanshul/airline-reviews/data


DASHBOARD PREVIEW:

![Preview](<images/Preview 1.png>)
![Preview 2](<images/Preview 2.png>)

Link:
https://public.tableau.com/views/Airline_17858676207880/BAAirlineReviews?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link



GOAL:
The project aims to determine which aspects of the flight have the greatest impact on passengers' overall ratings. Aside from that, the collected data and created dashboard can be used to address a number of other issues or to study a smaller sample rather than the entire population.



INSTRUCTION:
To review the Data Preparation SQL Script, download the original BA_AirlineReviews and make sure that the file is on disk C.
Download the Airports_roadmap csv file.
Then download and open BA_Airline_DataPreparation.



DATA CYCLING STEPS:

Data cleaning steps:

Manual data extraction, since the import wizard did not work correctly due to the format.
Creating a new staging table in order to avoid damaging original data.
Searching for duplicates.
Creating a new staging table to add RowNumber columns.
Removing duplicated rows.
Trimming rows.
Creating separate columns for departure, arrival, and via place based on the Route column.
Creating a glossary table and fixing typos.
Updating specific columns due to inconvenient formatting.
Changing and standardizing the format of DateFlown and Datetime columns.
Converting blank or missing values into NULL.
Creating a new staging table for deleting inconvenient rows and finalizing cleaning.
Deleting inconvenient data.
Inserting cleaned and standardized columns based on Route.
Creating a final, cleaned table. 
Checking how much data remained compared to the original dataset.



Analysis steps:

Creating a view for data export. (Note: Due to the large amount of text containing spaces, commas, and quotation marks, it was decided to export the data without the ReviewHeader and ReviewBody columns so that Tableau could correctly extract the data).
Finding confidence intervals.
Finding the percentage of null values.
Creating trend dynamics.
Adding filters to the dashboard for interactivity.



INSIGHTS:
The metrics most correlating with the overall rating are Seat Type, Cabin Staff Service, Ground Service, and Food and Beverages. All have a t-value over 50 and a p-value at 0.0001 each, which means that this data is not random. Therefore, in order to increase passenger satisfaction with the flight, improving these services must be a top priority.


Note: Wifi and Connectivity and Inflight Entertainment metrics have a percentage of null values above 30 percent; therefore, when attempting to draw conclusions based on this data, it should be interpreted with caution.



INSTRUMENTS:
MySQL - data preparation
Google Sheets - roadmap creation
Tableau Public - visualization



AUTHOR OF THE PROJECT:
Valerii Honcharenko 


