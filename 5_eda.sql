-- ====================================
-- World Layoffs Project
-- PostgreSQL Exploratory Data Analysis
-- ====================================

SELECT *
FROM layoffs_staging;

-- Maximum layoffs and layoff percentage in a single record
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging;
-- Insight: One company had a complete 100% layoff, with the maximum number of employees laid off in a single event being 12,000.

-- Top 10 companies with 100% layoffs, sorted by funding
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC
LIMIT 10;
-- Insight: Several well-funded companies across diverse industries, including Transportation, Media, Food, and Finance, have experienced 100% layoffs, indicating that high funding does not guarantee immunity from complete workforce cuts.

-- Total layoffs per company, sorted by highest layoffs
SELECT company, SUM(total_laid_off) as total_layoffs
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_layoffs DESC;
-- Insight: A small number of companies account for the majority of layoffs, indicating that layoffs are heavily concentrated among top employers, which may reflect larger company sizes or severe financial challenges within those organizations.

-- Unique layoff dates
SELECT DISTINCT(date)
FROM layoffs_staging
ORDER BY date;

-- Earliest and latest layoff dates
SELECT MIN(date), MAX(date)
FROM layoffs_staging;
-- Insight: Layoff data spans from March 11, 2020, to March 6, 2023, capturing layoffs primarily during and after the onset of the COVID-19 pandemic, reflecting its significant impact on employment.

-- Total layoffs by industry, sorted by highest
SELECT DISTINCT(industry), SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC;
-- Insight: The Consumer and Retail industries experienced the largest layoffs, with over 43,000 jobs lost each, indicating significant workforce reductions in these sectors compared to others like Finance, Healthcare, and Transportation.

-- Total layoffs by country, sorted by highest
SELECT DISTINCT(country), SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_layoffs DESC;
-- Insight: The United States accounts for the vast majority of layoffs with over 256,000 jobs lost, followed by India with nearly 36,000, showing a significant concentration of layoffs in these two countries compared to others worldwide.

-- Top 10 total layoffs by date, sorted by most layoffs
SELECT DISTINCT(date), SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY date
ORDER BY total_layoffs DESC
LIMIT 10;
-- Insight: The highest layoffs occurred mainly in early 2023, with multiple peak dates in January and November 2022, indicating concentrated waves of layoffs likely linked to economic or industry-specific challenges during that period. The only outlier is May 2020, reflecting an early COVID-19 impact spike.

-- Total layoffs per year
SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE date IS NOT NULL
GROUP BY year;
-- Insight: Layoffs peaked in 2022 with over 160k, nearly double that of 2023’s 125k, while 2020 also saw a high number (around 81k) likely due to the pandemic’s onset, and 2021 had the lowest layoffs by a wide margin, suggesting a temporary recovery before layoffs surged again.

-- Total layoffs by funding stage, sorted by highest
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
GROUP BY stage
ORDER BY total_layoffs DESC;
-- Insight: Most layoffs occur in Post-IPO companies by a wide margin (204k layoffs), indicating that even after going public, firms face significant workforce reductions, followed by companies with Unknown stage and Acquired status; earlier funding stages like Seed and Series A see comparatively fewer layoffs.

-- Total layoffs per month (all-time)
SELECT EXTRACT(MONTH FROM date) AS month, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE date IS NOT NULL
GROUP BY month
ORDER BY total_layoffs DESC;
-- Insight: January records the highest total layoffs overall, followed by November and February, suggesting that layoffs tend to peak at the beginning and near the end of the calendar year.

-- Rolling monthly layoffs since 2020
WITH rolling_total AS (
    SELECT SUBSTRING(date::TEXT, 1, 7) AS month, SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging
    WHERE SUBSTRING(date::TEXT, 1, 7) IS NOT NULL
    GROUP BY month
    ORDER BY month
)
SELECT month, total_layoffs,
       sum(total_layoffs) OVER(ORDER BY month) AS rolling_total
FROM rolling_total;
-- Insight: Since March 2020, layoffs surged sharply in April and May 2020, then declined through late 2020 and early 2021, followed by a steady increase in mid to late 2022, peaking dramatically in late 2022 and January 2023 before tapering off in early 2023.

-- Yearly layoffs by company
SELECT company, EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company, year
ORDER BY company, year ASC;
-- Insight: Companies experience layoffs across multiple years, with some like 8x8 showing repeated layoffs in consecutive years, indicating ongoing restructuring or market challenges.

-- Top 5 companies with most layoffs per year
WITH company_year AS(
    SELECT company, 
            EXTRACT(YEAR FROM date) AS year, 
            SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging
    GROUP BY company, year
),
company_year_rank AS (
    SELECT *, 
        DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS ranking
    FROM company_year
    WHERE year IS NOT NULL
    AND total_layoffs IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
-- Insight: Top layoffs show a clear shift in tech giants leading layoffs over recent years, with companies like Uber and Booking.com dominating 2020, Meta and Amazon in 2022, and Google and Microsoft leading in 2023, reflecting ongoing industry restructuring and economic challenges.
