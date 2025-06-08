/*
Loading dataset using the PSQLTool in pgAdmin4
1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `world_layoffs` database
3. Right-click `world_layoffs` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    - Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool` (with the CORRECT file path):

SET datestyle = 'MDY';

\copy layoffs FROM 'C:\Work\Data Analysis\SQL\Projects\World_Layoffs_Analysis\Datasets\layoffs.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', NULL 'NULL');

OR

Just run the following query:
*/
\copy layoffs 
FROM 'C:\Work\Data Analysis\SQL\Projects\World_Layoffs_Analysis\Datasets\layoffs.csv' -- Note: This is my path, so you are gonna have to copy the path of layoffs.csv
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

/*
Note: If you get error:
'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'
I highly reccomend you to load the dataset using the PSQLTool in pgAdmin4
*/