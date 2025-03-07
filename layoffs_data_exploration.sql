-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging;

-- checks the starting to last date of the dataset 
SELECT 
	MIN(`date`) earliest_date,
    MAX(`date`) latest_date
FROM layoffs_staging;

-- checks the highest amount of laid off employees and percentage of the workforce laid off
SELECT 
	MAX(total_laid_off),
    MAX(percentage_laid_off)
FROM layoffs_staging;

-- checks which industry produced the most to least lay offs in
SELECT 
	industry,
    SUM(total_laid_off) AS total_laid_off_per_industry
FROM layoffs_staging
GROUP BY industry
ORDER BY  total_laid_off_per_industry DESC;

-- checks which country produced the most to least lay offs in (2020-2023)
SELECT 
	country,
    SUM(total_laid_off) AS total_laid_off_per_industry
FROM layoffs_staging
GROUP BY country
ORDER BY  total_laid_off_per_industry DESC;

-- checks which year produced the most to least lay offs in (2020-2023)
SELECT 
	YEAR(`date`) AS data_year,
    SUM(total_laid_off) AS total_laid_off_per_industry
FROM layoffs_staging
GROUP BY data_year
ORDER BY data_year DESC;

-- checks which stage of the company produced the most to least lay offs(Stage A onwards)
SELECT 
	stage,
    SUM(total_laid_off) AS total_laid_off_per_industry
FROM layoffs_staging
GROUP BY stage
ORDER BY total_laid_off_per_industry DESC;

-- Companies that laid off 100% of its employees (2020-2023)
-- arranged from the highest to lowest number of total_laid_off employees
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Companies that laid off 100% of its employees
-- arranged from the highest to lowest amount of fundings in millions
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies that laid off the most to least employees (2020-2023)
-- Also provides the avg percentage of a company's workforce laid off (2020-2023)
SELECT 
	company,
    SUM(total_laid_off) AS overall_total_laid_off,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging
GROUP BY company
ORDER BY overall_total_laid_off DESC;


-- Retrieves total laid off in a month per year - worldwide
-- Retrieves the rolling total per month (2020-2023) - worldwide
WITH Lay_Offs_Per_Month AS (
	SELECT 
		YEAR(`date`) AS date_year,
		MONTH(`date`) AS date_month,
		SUM(total_laid_off) AS total_laid_off_in_month
	FROM layoffs_staging
	GROUP BY 
		date_year,
		date_month
	HAVING
		date_year IS NOT NULL AND
        date_month IS NOT NULL
	ORDER BY 
		date_year,
		date_month
)
SELECT 
	date_year,
    date_month,
    total_laid_off_in_month,
    SUM(total_laid_off_in_month) OVER(ORDER BY date_year, date_month) AS rolling_total
FROM Lay_Offs_Per_Month;

-- retrieves the top 5 companies that laid off the most employees per year
WITH Company_Year(company, years, total_laid_off) AS  -- note: aliases in order
(
	SELECT 
		company,
        YEAR(`date`) date_year,
        SUM(total_laid_off) total_laid_off_per_year
	FROM layoffs_staging
    GROUP BY company, date_year
),
Company_Year_Rank AS
(
	SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS lay_off_ranking 
	FROM Company_Year
	WHERE                        -- NOTE: WHERE is evaluated first before SELECT hence using alias in WHERE causes error (hence you can't do this here: lay_off_ranking <= 5)
		years IS NOT NULL    
)
SELECT *
FROM Company_Year_Rank
WHERE lay_off_ranking <= 5;




