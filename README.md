# World Layoffs (PostgreSQL Project)

## 📌 Introduction

This project explores global layoffs from 2020 to 2023, analyzing patterns across industries, funding stages, companies, and time periods. Using structured data and insights from real layoff events, the goal is to uncover trends such as peak layoff months, top-affected companies, and which funding stages experienced the most workforce cuts. All data transformations and analysis were performed using **PostgreSQL**, with a focus on deriving actionable business insights from the evolving tech employment landscape.

---

## 🧠 Background

The database is built from a single structured dataset:  
- `layoffs.csv`: Contains records of global layoffs with attributes such as company, industry, date, funding stage, and percentage of workforce laid off.

The data was loaded using the following SQL files:  
- `1_create_database.sql`: Creates the PostgreSQL database  
- `2_create_tables.sql`: Builds the required table with constraints  
- `3_modify_tables.sql`: Loads data from the CSV file via pgAdmin4  

Since 2020, tech and startup ecosystems have experienced massive shifts driven by economic uncertainty, overhiring during the pandemic, and changing market dynamics. This dataset allows us to explore layoff trends and ask key questions, such as:
- Which year recorded the highest number of layoffs?
- What industries and companies have been impacted the most?
- Which funding stage companies saw the most job cuts?
- Are there specific months where layoffs peak?

This project answers these questions by analyzing real-world layoff data using SQL.

---

## 🛠️ Tools I Used

- **PostgreSQL (SQL)** – Used to write and execute queries that analyze layoff trends across companies, industries, and time periods.
- **pgAdmin 4** – Served as the database management tool for creating the schema and loading the layoffs dataset from CSV.
- **Visual Studio Code (VSCode)** – Used to develop, organize, and manage SQL scripts and documentation.
- **Git & GitHub** – Enabled version control and seamless sharing of SQL queries and project files.

---

## 📊 The Analysis

This project explores global tech layoffs using SQL queries on a cleaned PostgreSQL database built from the `layoffs.csv` dataset. I investigated layoff patterns across companies, industries, countries, and time periods to uncover broader economic and business trends.

Here's how I approached each question:

### 1️⃣ Maximum layoffs and layoff percentage in a single record

To start, I wanted to identify the most severe single layoff event in terms of number of employees laid off and the highest layoff percentage recorded in the dataset. This helps highlight the biggest impact on the workforce from one company at one time, showing both absolute and relative scale.

```sql
SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM 
    layoffs_staging;
```
| Maximum Total Laid Off | Maximum Layoff Percentage |
| ---------------------- | ------------------------- |
| 12,000                 | 1                         |

#### 💡 Insights:
- The largest single layoff event involved **12,000 employees**, indicating a major workforce reduction.
- The maximum layoff percentage recorded is **100%**, showing some companies had complete workforce cuts in certain events.
- These extremes highlight the significant impact layoffs have had on companies and their employees globally.

### 2️⃣ Top 10 Companies with 100% Layoffs, Sorted by Funding

To understand which fully laid-off companies had significant financial backing, I filtered for records with 100% layoffs and non-null funding amounts. Sorting by funds raised highlights high-profile startup failures or critical collapses.

```sql
SELECT *
FROM 
    layoffs_staging
WHERE 
    percentage_laid_off = 1 AND 
    funds_raised_millions IS NOT NULL
ORDER BY 
    funds_raised_millions DESC
LIMIT 10;
```
| Company          | Location      | Industry      | Total Laid Off | Percentage Laid Off | Date       | Stage          | Country         | Funds Raised (Millions) |
|------------------|---------------|---------------|----------------|---------------------|------------|----------------|-----------------|-------------------------|
| Britishvolt      | London        | Transportation| 206            | 1                   | 2023-01-17 | Unknown        | United Kingdom  | 2400                    |
| Quibi            | Los Angeles   | Media         | NULL           | 1                   | 2020-10-21 | Private Equity | United States   | 1800                    |
| Deliveroo Australia| Melbourne    | Food          | 120            | 1                   | 2022-11-15 | Post-IPO       | Australia       | 1700                    |
| Katerra          | SF Bay Area   | Construction  | 2434           | 1                   | 2021-06-01 | Unknown        | United States   | 1600                    |
| BlockFi          | New York City | Crypto        | NULL           | 1                   | 2022-11-28 | Series E       | United States   | 1000                    |
| Aura Financial   | SF Bay Area   | Finance       | NULL           | 1                   | 2021-01-11 | Unknown        | United States   | 584                     |
| Openpay          | Melbourne     | Finance       | 83             | 1                   | 2023-02-07 | Post-IPO       | Australia       | 299                     |
| Pollen           | London        | Marketing     | NULL           | 1                   | 2022-08-10 | Series C       | United Kingdom  | 238                     |
| Simple Feast     | Copenhagen    | Food          | 150            | 1                   | 2022-09-07 | Unknown        | Denmark         | 173                     |
| Arch Oncology    | Brisbane      | Healthcare    | NULL           | 1                   | 2023-01-13 | Series C       | United States   | 155                     |

#### 💡 Insights:
- Several companies that laid off **100%** of their workforce had raised **significant funding**, indicating **critical failures** despite strong financial backing.
- **Britishvolt** leads with the highest funding of **$2.4 billion** before a full layoff, followed by media startup **Quibi** with **$1.8 billion**.
- The affected companies span diverse industries including **transportation, media, food, crypto, finance, and healthcare**, highlighting **wide-ranging impacts**.

### 3️⃣ Total Layoffs by Industry

To understand which sectors were hardest hit, I aggregated the total number of layoffs grouped by industry. I filtered out null industries to ensure data accuracy and then ordered the results by the highest total layoffs, revealing the industries with the greatest overall impact.

```sql
SELECT 
    DISTINCT(industry), 
    SUM(total_laid_off) AS total_layoffs
FROM 
    layoffs_staging
WHERE 
    industry IS NOT NULL
GROUP BY 
    industry
ORDER BY 
    total_layoffs DESC;
```
| Industry       | Total Layoffs |
| -------------- | ------------: |
| Consumer       |         45182 |
| Retail         |         43613 |
| Other          |         36289 |
| Transportation |         33748 |
| Finance        |         28344 |
| Healthcare     |         25953 |
| Food           |         22855 |
| ...            |           ... |
| Energy         |           802 |
| Aerospace      |           661 |
| Fin-Tech       |           215 |
| Manufacturing  |            20 |

#### 💡 Insights:
- The **Consumer** and **Retail** industries experienced the **highest layoffs**, with over 45,000 and 43,000 jobs lost respectively, highlighting major disruptions in these sectors.
- Significant layoffs also occurred in **Transportation** and **Finance**, indicating widespread economic challenges beyond just retail.
- Industries such as **Manufacturing** and **Fin-Tech** reported **minimal layoffs**, possibly reflecting more stability or limited data coverage in those areas.

### 4️⃣ Rolling monthly layoffs since 2020

To analyze how layoffs evolved over time, I aggregated the total layoffs by month, extracting the year and month from the date. Using a window function, I calculated the cumulative rolling total of layoffs to observe trends and significant spikes throughout the pandemic and after.

```sql
WITH rolling_total AS (
    SELECT 
        SUBSTRING(date::TEXT, 1, 7) AS month, 
        SUM(total_laid_off) AS total_layoffs
    FROM 
        layoffs_staging
    WHERE 
        SUBSTRING(date::TEXT, 1, 7) IS NOT NULL
    GROUP BY 
        month
    ORDER BY 
        month
)
SELECT 
    month, total_layoffs,
    sum(total_layoffs) OVER(ORDER BY month) AS rolling_total
FROM 
    rolling_total;
```
| Month   | Total Layoffs | Rolling Total Layoffs |
| ------- | ------------- | --------------------- |
| 2020-03 | 9,628         | 9,628                 |
| 2020-04 | 26,710        | 36,338                |
| 2020-05 | 25,804        | 62,142                |
| 2020-06 | 7,627         | 69,769                |
| 2020-07 | 7,112         | 76,881                |
| 2020-08 | 1,969         | 78,850                |
| 2020-09 | 609           | 79,459                |
| 2020-10 | 450           | 79,909                |
| 2020-11 | 237           | 80,146                |
| 2020-12 | 852           | 80,998                |
| 2021-01 | 6,813         | 87,811                |
| 2021-02 | 868           | 88,679                |
| 2021-03 | 47            | 88,726                |
| 2021-04 | 261           | 88,987                |
| 2021-06 | 2,434         | 91,421                |
| 2021-07 | 80            | 91,501                |
| 2021-08 | 1,867         | 93,368                |
| 2021-09 | 161           | 93,529                |
| 2021-10 | 22            | 93,551                |
| 2021-11 | 2,070         | 95,621                |
| 2021-12 | 1,200         | 96,821                |
| 2022-01 | 510           | 97,331                |
| 2022-02 | 3,685         | 101,016               |
| 2022-03 | 5,714         | 106,730               |
| 2022-04 | 4,128         | 110,858               |
| 2022-05 | 12,885        | 123,743               |
| 2022-06 | 17,394        | 141,137               |
| 2022-07 | 16,223        | 157,360               |
| 2022-08 | 13,055        | 170,415               |
| 2022-09 | 5,881         | 176,296               |
| 2022-10 | 17,406        | 193,702               |
| 2022-11 | 53,451        | 247,153               |
| 2022-12 | 10,329        | 257,482               |
| 2023-01 | 84,714        | 342,196               |
| 2023-02 | 36,493        | 378,689               |
| 2023-03 | 4,470         | 383,159               |

#### 💡 Insights:
- The **largest spikes** occurred in **November 2022** and **January 2023**, indicating renewed waves of layoffs post-pandemic.
- Initial pandemic months (**Mar–May 2020**) saw a **sharp rise**, reflecting immediate economic impact.
- Layoffs stayed **relatively low throughout 2021** but **increased significantly in late 2022 and early 2023**, pointing to ongoing economic uncertainty.

### 5️⃣ Top 5 Companies with Most Layoffs Per Year

To identify corporate patterns in layoffs, I first extracted the year from the layoff dates and aggregated total layoffs by company per year. Then, using DENSE_RANK(), I ranked companies annually and filtered the top 5 per year to reveal the biggest contributors to workforce reductions over time.

```sql
WITH company_year AS(
    SELECT 
        company, 
        EXTRACT(YEAR FROM date) AS year, 
        SUM(total_laid_off) AS total_layoffs
    FROM 
        layoffs_staging
    GROUP BY 
        company, year
),
company_year_rank AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (
            PARTITION BY 
                year 
            ORDER BY 
                total_layoffs DESC
        ) AS ranking
    FROM 
        company_year
    WHERE 
        year IS NOT NULL AND 
        total_layoffs IS NOT NULL
)
SELECT *
FROM 
    company_year_rank
WHERE 
    ranking <= 5;
```
| Company     | Year | Total Layoffs | Ranking |
| ----------- | ---- | ------------- | ------- |
| Uber        | 2020 | 7525          | 1       |
| Booking.com | 2020 | 4375          | 2       |
| Groupon     | 2020 | 2800          | 3       |
| Swiggy      | 2020 | 2250          | 4       |
| Airbnb      | 2020 | 1900          | 5       |
| Bytedance   | 2021 | 3600          | 1       |
| Katerra     | 2021 | 2434          | 2       |
| Zillow      | 2021 | 2000          | 3       |
| Instacart   | 2021 | 1877          | 4       |
| WhiteHat Jr | 2021 | 1800          | 5       |
| Meta        | 2022 | 11000         | 1       |
| Amazon      | 2022 | 10150         | 2       |
| Cisco       | 2022 | 4100          | 3       |
| Peloton     | 2022 | 4084          | 4       |
| Carvana     | 2022 | 4000          | 5       |
| Philips     | 2022 | 4000          | 5       |
| Google      | 2023 | 12000         | 1       |
| Microsoft   | 2023 | 10000         | 2       |
| Ericsson    | 2023 | 8500          | 3       |
| Salesforce  | 2023 | 8000          | 4       |
| Amazon      | 2023 | 8000          | 4       |
| Dell        | 2023 | 6650          | 5       |

#### 💡 Insights:
- **Tech giants like Google, Meta, and Amazon** topped the layoff charts in recent years, reflecting **massive restructuring** in the tech industry.
- **Recurring appearances** of companies such as **Amazon** in multiple years signal **continued cost-cutting trends** over time.
- In **2020**, companies from the **travel and gig economy** (e.g., Uber, Airbnb) dominated layoffs, showing the **immediate impact of the COVID-19 pandemic**.

---

## ✅ Conclusion
#### 💡 Overall Insights:
**1. Layoffs by Industry and Company:**  
Sectors like Consumer, Retail, and Tech experienced the highest total layoffs, showing the deep impact of macroeconomic changes on demand-heavy industries. Tech giants such as Google, Amazon, and Meta consistently ranked among the top companies laying off employees across multiple years.

**2. Timeline of Layoffs:**  
The data reveals spikes during the pandemic (2020) and again in late 2022 to early 2023, indicating two major waves of workforce reductions—one due to global uncertainty and the other as part of post-pandemic corrections and tech overhiring reversals.

**3. Layoff Patterns and Percentages:**  
Several companies laid off 100% of their workforce, suggesting full shutdowns. Monthly rolling totals helped track evolving layoff patterns, with clear surges aligning with major global events and market downturns.

**4. Geographic Disparity in Layoffs:**  
The dataset highlights that layoffs were heavily concentrated in the United States, especially in major tech hubs. This geographic skew underscores the vulnerability of centralized labor markets and the cascading effect of large tech firms on regional economies.

**5. Company Stage and Layoff Behavior:**  
Layoffs were not limited to failing startups—both early-stage startups and well-established enterprises executed large cuts. However, many late-stage companies and unicorns showed aggressive downsizing after periods of rapid expansion, signaling a shift toward profitability and operational efficiency.

#### Closing Thoughts:

This project provided a comprehensive, data-driven narrative around global layoffs, combining SQL querying, analytical reasoning, and business storytelling. It not only uncovered key workforce trends during volatile periods but also served as a practical demonstration of using structured data analysis to derive real-world insights. An excellent opportunity to turn raw layoff data into an informed perspective on the changing nature of work, business, and resilience.

---