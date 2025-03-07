-- DATA CLEANING 
-- 1. remove duplicates
-- 2. Standardized the data
-- 3. Null Values / blank values
-- 4. Remove unecessary columns 

-- 1. REMOVE DUPLICATES ###################################################

-- create a staging table
CREATE TABLE layoffs_staging
LIKE layoffs;

ALTER TABLE layoffs_staging
ADD COLUMN row_num INT;

-- inserts values for columns
-- assigns row_num value, if row_num > 1 it's a duplicate
INSERT INTO layoffs_staging (
    company, 
    location,
    industry,
    total_laid_off, 
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    row_num
)
SELECT 
    company, 
    location,
    industry,
    total_laid_off, 
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs;

-- delete rows with row_num > 1 (dups)
DELETE
FROM layoffs_staging
WHERE row_num > 1;

-- check if rows with row_num > 1 (dups) are deleted
SELECT *
FROM layoffs_staging;

-- ###############################################################################

-- 2. STANDARDIZING DATA ########################################################
-- Finding issues in data and fixing it

-- TRIM() removes leading and trailing white spaces 
UPDATE layoffs_staging
SET company = TRIM(company);

-- checking if there are similar industries named differently
SELECT DISTINCT(industry)
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging
WHERE industry LIKE 'Crypto%';

-- sets all values in industry with 'Crypto' to be assigned as Crypto 
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging
SET industry = 'Unknown'
WHERE industry = '' OR industry IS NULL;


UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%';

-- change date's data to a different date format
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- change date's data type from text to DATE
 ALTER TABLE layoffs_staging
 MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging;

-- ###############################################################
-- 3. WORKING WITH NULL VALUES

SELECT * 
FROM layoffs_staging
WHERE 
	total_laid_off is NULL AND
    percentage_laid_off IS NULL;
    
-- unifies all the rows with 'Unknown' value
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = 'Unknown';

-- copies the industry value of rows with the same company and location value 
UPDATE layoffs_staging t1
JOIN layoffs_staging AS t2
	ON t1.company = t2.company AND
    t1.location = t2.location
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND
	 t2.industry IS NOT NULL;

-- #######################################################################

-- REMOVE UNNECESSARY ROWS AND COLUMNS

-- since we're looking at laid off data and w/o total_laid_off and percentage_laid_off
-- it is unusable
DELETE
FROM layoffs_staging
WHERE 
	total_laid_off is NULL AND
    percentage_laid_off is NULL;

-- deletes column rw_num since I'm finish using them
ALTER TABLE layoffs_staging
DROP row_num;
    
SELECT *
FROM layoffs_staging;

