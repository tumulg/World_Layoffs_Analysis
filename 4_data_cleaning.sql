-- ==================================
-- Data Cleaning for Layoffs Dataset
-- ==================================

-- Objective:
-- 1. Remove duplicate records
-- 2. Standardize text formatting
-- 3. Handle missing or inconsistent values
-- 4. Remove unnecessary columns or rows

-- Previewing raw data
SELECT * FROM layoffs;

-- -----------------------------------------
-- Creating a staging table for safe editing
-- -----------------------------------------
-- This backup allows non-destructive cleaning steps
CREATE TABLE layoffs_staging
(LIKE layoffs);

-- Copying all data into the staging table
INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- Confirming data copy
SELECT * 
FROM layoffs_staging;

-- =======================
-- 1. Remove Duplicates
-- =======================

-- Identify duplicates using ROW_NUMBER()
WITH duplicates_cte AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, date, stage, country, funds_raised_millions
            ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

-- Delete duplicate rows by leveraging PostgreSQL's CTID (unique row ID)
DELETE 
FROM layoffs_staging
WHERE ctid IN (
    SELECT ctid FROM (
        SELECT 
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY company, location, industry, total_laid_off, 
                             percentage_laid_off, date, stage, country, funds_raised_millions
                ORDER BY ctid
            ) AS row_num
        FROM layoffs_staging
    ) sub
    WHERE row_num > 1
);

-- ==========================
-- 2. Standardize the Data
-- ==========================

-- Remove extra whitespace from company names
SELECT company, TRIM(company)
FROM layoffs_staging;

UPDATE layoffs_staging
SET company = TRIM(company);

-- Unify similar industry names (e.g., Crypto-related variations)
SELECT DISTINCT(industry)
FROM layoffs_staging
ORDER BY 1;

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Standardize inconsistent country entries
SELECT DISTINCT(country)
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging
WHERE country LIKE 'United States%';

UPDATE layoffs_staging
SET country = 'United States'
WHERE TRIM(LOWER(country)) LIKE 'united states%';

-- ===========================================
-- 3. Handle Null or Inconsistent Text Values
-- ===========================================

-- Clean up invalid 'industry' values represented as strings
SELECT * 
FROM layoffs_staging
WHERE industry = 'NULL' 
OR industry = '';

-- Replace 'NULL' strings and blanks with proper NULLs
UPDATE layoffs_staging
SET industry = NULL 
WHERE industry = 'NULL' OR industry = '';

-- Fill NULL industry values from other non-NULL records of the same company
SELECT ls1.company, ls1.industry AS null_industry, ls2.industry AS valid_industry
FROM layoffs_staging ls1
JOIN layoffs_staging ls2
  ON ls1.company = ls2.company
WHERE ls1.industry IS NULL AND ls2.industry IS NOT NULL;

-- Apply the update using self-join logic
UPDATE layoffs_staging ls1
SET industry = ls2.industry
FROM layoffs_staging ls2
WHERE ls1.company = ls2.company
AND ls1.industry IS NULL
AND ls2.industry IS NOT NULL;

-- ==========================================
-- 4. Convert Data Types for Numeric Columns
-- ==========================================

-- Ensure 'total_laid_off' is stored as INTEGER
ALTER TABLE layoffs_staging 
ALTER COLUMN total_laid_off TYPE INT USING total_laid_off::INT;

-- Convert 'percentage_laid_off' to NUMERIC (supports decimals)
ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off TYPE NUMERIC USING percentage_laid_off::NUMERIC;

-- Convert 'funds_raised_millions' to NUMERIC
ALTER TABLE layoffs_staging
ALTER COLUMN funds_raised_millions TYPE NUMERIC USING funds_raised_millions::NUMERIC;

-- =====================================
-- 5. Drop Rows with Missing Key Metrics
-- =====================================

-- Remove records that have NULLs for both layoff count and percentage
DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- ======================
-- Final Cleaned Dataset
-- ======================
-- Ready for Exploratory Data Analysis (EDA)
SELECT *
FROM layoffs_staging;