SELECT * 
FROM layoffs;

-- CLEANING THE DATASET

-- lists of things to do 
-- 1. Duplicate the dataset to avoid tampering with the original dataset
-- 2. Remove duplicate from the dataset 
-- 3. Standardize the data 
-- 4. Deal with Null or blanck values
-- 5. Remove columns or rows not needed 

-- STEP ONE creating duplicate 
create table layoffs_worksheet
like layoffs;

insert  layoffs_worksheet
select *
from layoffs;

select * 
from layoffs_worksheet;

-- removing duplicate from the dataset 
-- note we don't have any unique row id to identify duplicate, we will use the row number function and match it with all the column 

with duplicate_cte as 
(
select *, 
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
from layoffs_worksheet
)
delete
from duplicate_cte
where row_num > 1;

select * 
from layoffs_worksheet
where company ='Cazoo';

-- we can't delete because we will need a table that is updatable therefore we will create another table to delete
-- note: In the new table, We will have to include row-num cte as a column

CREATE TABLE `layoffs_worksheet2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_worksheet2
where row_num > 1;

insert into layoffs_worksheet2
select *, 
row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
from layoffs_worksheet;

-- since we have created a table with the row number, then we can delete the duplicate 

delete
from layoffs_worksheet2
where row_num > 1;

-- step 3 is to Standardize the data 

select * 
from layoffs_worksheet2;

-- notice we have data that starts with a space and some with irregular 
-- keyword also we will be updating the table as we standardize it 

select company, trim(company)
from layoffs_worksheet2;

update layoffs_worksheet2
set company = trim(company);

select distinct industry
from layoffs_worksheet2
order by industry;

-- notice we have null and enpty column but also the crypto column have 3 different column with different spelling so we will need to sort

select * 
from layoffs_worksheet2;

-- we will need to do a changing in the crypto group into crcypto

update layoffs_worksheet2
set industry  = 'Crypto'
where industry like 'Crypto%';


select distinct country
from layoffs_worksheet2
order by 1;

update layoffs_worksheet2
set country  = 'United States'
where country like 'United States%';

select * 
from layoffs_worksheet2;

-- note the date is in text format therefore we will need to correct it to timestamp format
-- we use the string to date function, for this function year must be in cap while day and mon will be small

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_worksheet2;

update layoffs_worksheet2
set `date`  = str_to_date(`date`, '%m/%d/%Y');

-- note after the operation, the date column is still in text format therefore we convert to date column 
-- we alter the entire table we are workign with 

alter table layoffs_worksheet2

modify column `date` date;

select *
from layoffs_worksheet2
where industry is null
or industry = '';

select *
from layoffs_worksheet2
where company = 'Airbnb';

-- since we have some industry matching,  we can start filling some vaules 
-- first we write a subquary to join both null values and empty columns 
-- first the blank cell, let change it to null

update layoffs_worksheet2
set industry = null
where industry = '';

select t1.industry, t2.industry 
from layoffs_worksheet2 t1
join layoffs_worksheet2 t2 
	on t1.company = t2.company
where t1.industry is null 
and t2.industry is not null;

update layoffs_worksheet2 t1 
join layoffs_worksheet2 t2 
	on t1.company = t2.company
set t1.industry = t2.industry
 where t1.industry is null 
and t2.industry is not null;

select *
from layoffs_worksheet2;

-- step 5: Dealing with Null or blanck values

select * 
from layoffs_worksheet2
where total_laid_off is null
and percentage_laid_off is null;

delete 
from layoffs_worksheet2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs_worksheet2;
 
-- Step 5 Remove columns or rows not needed 

alter table layoffs_worksheet2
drop column row_num;

-- Exploratory Data Analysis

select *
from layoffs_worksheet2;

select max(total_laid_off), max(percentage_laid_off), country
from layoffs_worksheet2
group by 3; 

select company, sum(total_laid_off)
from layoffs_worksheet2
group by 1
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_worksheet2;

select sum(company), sum(total_laid_off), sum(funds_raised_millions)
from layoffs_worksheet2;

select company, count(company) as num_of_apprearance 
from layoffs_worksheet2
group by 1
order by 2 desc;

select company, country, sum(total_laid_off) total_sum, percentage_laid_off as percent
from layoffs_worksheet2
where country like 'Nigeria'
group by company, country, percentage_laid_off
;

with total_not_null as
(select company, country, sum(total_laid_off) total_sum, percentage_laid_off as percent
from layoffs_worksheet2
where country like 'Nigeria'
group by company, country, percentage_laid_off)
select *
from total_not_null
where total_sum is not null
and percent is not null
order by percent desc
;

select company
from layoffs_worksheet2
where company like '2%';

select country, sum(total_laid_off)
from layoffs_worksheet2
group by 1
order by 2 desc; 

select industry, sum(total_laid_off)
from layoffs_worksheet2
group by 1
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_worksheet2
group by 1
order by 2 desc;

select month(`date`) as `month`, sum(total_laid_off)
from layoffs_worksheet2
group by 1
order by 1;

-- OR 

select substring(`date`,1,7) as `month`,sum(total_laid_off)
from layoffs_worksheet2
where substring(`date`,1,7) is not null
group by `month`
order by 1;

with Rolling_Total as
(select substring(`date`,1,7) as `month`,
sum(total_laid_off) as sum_total
from layoffs_worksheet2
where substring(`date`,1,7) is not null
group by `month`
order by 1)
select `month`, sum_total, sum(sum_total) over(order by `month`) as accumulating_total
from Rolling_Total;

select company, year(`date`) `year`, sum(total_laid_off)
from layoffs_worksheet2
group by company, year(`date`)
order by 3 desc;

with company_year (company, years, total_laid_off) as 
(select company, year(`date`), sum(total_laid_off)
from layoffs_worksheet2
group by company, year(`date`)
), company_year_rank as
(select *, dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
and total_laid_off is not null
) 
select *
from company_year_rank
where ranking <= 5
;

