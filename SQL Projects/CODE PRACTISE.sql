select *
from employee_demographics;

select *
from employee_salary;
-- Inner join 
select sal.employee_id, age, occupation, gender, salary
from employee_demographics demo
inner join employee_salary sal
	on demo.employee_id = sal.employee_id
;

-- OUTER JOINS
select *
from employee_demographics demo
right join employee_salary sal
	on demo.employee_id = sal.employee_id
;

-- self jOIN
select emp1.employee_id,
emp1.first_name AS firstname_santa,
emp1.last_name AS lastname_santa,
emp2.employee_id,
emp2.first_name AS firstname,
emp2.last_name AS lastname
from employee_salary emp1
join employee_salary emp2
	on emp1.employee_id + 1 = emp2.employee_id
;

-- JOINING MULTIPLE TABLE

select *
from employee_demographics demo
inner join employee_salary sal
	on demo.employee_id = sal.employee_id
inner join parks_departments pd
	on pd.department_id = sal.dept_id
;

select gender
from employee_demographics;

-- UNIONS 

select first_name, last_name, age, 'Old Man' as Label
from employee_demographics 
where age > 40 and gender = 'Male'
union
select first_name, last_name, age, 'Old Lady' as Label
from employee_demographics 
where age > 40 and gender = 'Female'
union
select first_name, last_name, salary, 'Highly Paid' as High_Staff
from employee_salary
where salary > '60000'
order by first_name
;

-- CASE STATEMENT 
select concat(dem.first_name,' ', dem.last_name) as full_name,
age, salary,
case
	when age <= 30 and salary > 30000 then 'young' 
    when age between 31 and 45 and salary > 50000 then 'mid'
    when age >= 46 and salary > 70000 then 'old'
    else  not null 
end as filter
from employee_demographics dem
inner join employee_salary sal
	on dem.employee_id = sal.employee_id
    ;
    
SELECT CONCAT(dem.first_name, ' ', dem.last_name) AS full_name,
       age, 
       salary,
       CASE
           WHEN age <= 30 THEN 'young'
           WHEN age BETWEEN 31 AND 45 AND salary > 60000 THEN 'mid'
           WHEN age >= 46 AND salary > 30000 THEN 'old'
           ELSE NULL
       END AS filter
FROM employee_demographics dem
INNER JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id
WHERE CASE
          WHEN age <= 30 THEN 'young'
          WHEN age BETWEEN 31 AND 45 AND salary > 60000 THEN 'mid'
          WHEN age >= 46 AND salary > 30000 THEN 'old'
      END IS NOT NULL
      ;

-- subquaries

SELECT first_name, salary, 
(select avg(salary)
from employee_salary)
FROM employee_salary;

select *
from employee_demographics;

select  avg(max_age)
from 
(select gender, avg(age) as avg_age, 
max(age) as max_age,
min(age) as min_age, 
count(age) as 
count_age
from employee_demographics
group by gender) as aggre_table
;

-- window functions 
select dem.first_name, dem.last_name, gender, salary,
sum(salary) over(partition by gender order by dem.employee_id) as par_sal
from employee_demographics dem
join employee_salary sal 
on dem.employee_id = sal.employee_id
;

select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
row_number() over(partition by gender order by salary desc ) as row_num,
rank() over(partition by gender order by salary desc ) as rank_num,
dense_rank() over(partition by gender order by salary desc ) as dense_rank_num
from employee_demographics dem
join employee_salary sal 
on dem.employee_id = sal.employee_id
;

-- Creating CTE
with cte_example as(
select gender, avg(salary) as avg_sal, max(salary) as max_sal, min(salary) as min_sal, count(salary) as count_sal
from employee_demographics dem
join employee_salary sal 	 
	on dem.employee_id = sal.employee_id
group by gender 
)
select sum(count_sal)
from cte_example
;

-- writign multiple cte 
with cte_example as
(
select employee_id, gender, birth_date 
from employee_demographics 
where birth_date > '1985-01-01'
),
cte_2 as
(
select employee_id, salary
from employee_salary
where salary > 55000
)
select sum(salary)
from cte_example ct1
join cte_2 ct2
	on ct1.employee_id = ct2.employee_id
group by gender
;

-- creating temporary table 
-- there are two way and the first way is to create it then use it in the quary
-- the secodm is to create an duse while writing the quary 
create temporary table temp_table1 
(employee_id int,
first_name varchar(50),
last_name varchar(50),
age int,
fav_movies varchar (100)
);

select *
from temp_table1;

insert into temp_table1
values(1,'Ub','onye',14,'avengers');
select *
from temp_table1;

select *
from employee_demographics dem 
join temp_table1 tem
	on dem.employee_id = tem.employee_id
;

-- method 2 of creating temp table 
-- let assume i want to create a table where sal is abve 50k 

select * 
from employee_salary;

create temporary table salary_over_50k 
select * 
from employee_salary
where salary >= 50000
;

select *
from salary_over_50k;

-- STORED PROCEDURE
create procedure high_end_staff()
select dem.first_name, dem.last_name, age, salary 
from employee_demographics dem 
join employee_salary sal
	on dem.employee_id = sal.employee_id
where age >= 30 and salary >= 50000
;

call high_end_staff();
-- we want to store the two select statement in a cte and we will need to use semi-colon to do that 
-- we will change delimiter 

delimiter $$
create procedure salary_tem()
begin
	select *
	from employee_salary
	where salary >= 50000;
	select *
	from employee_salary
    where salary >= 35000;
end $$
-- after writing then we change back delimiter 
delimiter ;

call salary_tem();
