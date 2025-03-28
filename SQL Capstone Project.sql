# 1) Data Wrangling


/* 1.1 Build a Database */

create database amazon;

use amazon;


/* 1.2 Create a table and insert the data */

-- Imported the .csv file provided into the DB into the table named amazondata

select * from amazondata;


/* 1.3 Select columns with null values in them. 
There are no null values in our database as in creating the tables, we set NOT NULL for each field, 
hence null values are filtered out. */

select *
from amazondata
where 
    `invoice id` IS NULL OR
    branch IS NULL OR
    city IS NULL OR
    `customer type` IS NULL OR
    gender IS NULL OR
    `product line` IS NULL OR
    `unit price` IS NULL OR
    quantity IS NULL OR
    `tax 5%` IS NULL OR
    total IS NULL OR
    date IS NULL OR
    time IS NULL OR
    payment IS NULL OR
    cogs IS NULL OR
    `gross margin percentage` IS NULL OR
    `gross income` IS NULL OR
    rating IS NULL;
    
-- Query showing that there are no NULL values in the dataset

-- `Backticks` are used for column names with space in them



# 2) Feature Engineering 


/* 2.1  Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
This will help answer the question on which part of the day most sales are made. */

alter table amazondata
add column `TimeOfDay` varchar(20);

-- A new column has been added

update amazondata
set `TimeOfDay` = case
    when hour(str_to_date(`time`, '%H:%i:%s')) >= 6 and hour(str_to_date(`time`, '%H:%i:%s')) < 12 then 'Morning'
    when hour(str_to_date(`time`, '%H:%i:%s')) >= 12 and hour(str_to_date(`time`, '%H:%i:%s')) < 18 then 'Afternoon'
    else 'Evening'
end;

-- Updating the column based on the 'Time' column

select `time`, `TimeOfDay`
from amazondata
limit 5;

-- Verifying if the update is successful


/* 2.2 Add a new column named dayname that contains the extracted days of the week on which the given transaction took place 
(Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest. */

-- Repeating the steps from before

alter table amazondata
add column `DayName` varchar(3);

update amazondata
set `DayName` = date_format(`date`, '%a');

select `date`, `DayName`
from amazondata
limit 5;


# 2.3 Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
# Repeating the steps again

alter table amazondata
add column `MonthName` varchar(3);

update amazondata
set `MonthName` = date_format(`date`, '%b');

select `date`, `MonthName`
from amazondata
limit 10;

select * from amazondata;

-- Checking if the new columns have been added to the table



# 3) Business Questions


/* Question 1: What is the count of distinct cities in the dataset? */

select count(distinct city) as `Distinct City Count`
from amazondata;

-- Comments/Insights/Recommendations
-- The objective of this project is to analyze and gain insight into the sales data of Amazon in three of the (major) cities in Myanmar; Mandalay, Yangon and Naypyitaw. Hence, the count of the distinct cities is 3.


/* Question 2: For each branch, what is the corresponding city? */

select branch, city
from amazondata
group by branch, city;

-- Query to show the corresponding city to each branch; A, B and C. Can be useful for analyzing regional preferences, etc.


/* Question 3: What is the count of distinct product lines in the dataset? */

select count(distinct `product line`) as `Distinct Product Lines Count`
from amazondata;

-- By counting the distinct product lines we can assess how diverse its product offerings are.


/* Question 4: Which payment method occurs most frequently? */

select payment, count(*) as payment_count
from amazondata
group by payment
order by payment_count desc;

-- Ewallet seems to be the the most occured payment method, but it is only one count above cash.
-- This query helps us understand customer preferences when it comes to payment methods and, hence, can be used to improve future payment processes for ease of use.


/* Question 5: Which product line has the highest sales? */

select `product line`, sum(total) as `Total Sales`
from amazondata
group by `product line`
order by `Total Sales` desc;

-- This helps us identify the product line that has the highest sales, which is: Food and Beverages.
-- Which is helpful in gaining insights about various things like customer preferences and inventory management, etc.


/* Question 6: How much revenue is generated each month? */

select month(date) as month, sum(total) as `Monthy Revenue`
from amazondata
group by month(date)
order by month;

-- Helps track revenue on a monthly basis.
-- Which can be useful for seasonal trends, budgeting and also for comparision purposes.


/* Question 7: In which month did the cost of goods sold reach its peak? */

select month(date) as month, sum(cogs) as `Total COGS`
from amazondata
group by month(date)
order by `Total COGS` desc;

-- The cost of total goods peaked in the month of January as per the dataset.
-- Helps better understand and plan operational costs.


/* Question 8: Which product line generated the highest revenue? */

select `product line`, sum(total) as `Total Revenue`
from amazondata
group by `product line`
order by `Total Revenue` desc;

-- Food and Beverages seem to have generated the highest revenue.
-- By knowing which product line generates the most revenue, we can focus on promoting or expanding that product line. Even helps with optimizing inventory.


/* Question 9: In which city was the highest revenue recorded? */

select city, sum(total) as `Total Revenue`
from amazondata
group by city
order by `Total Revenue` desc;

-- The highest revenue recorded was in the city of Naypyitaw.
-- This query might help with understanding and providing regional expansion and resource allocation based on the revenue and sales.


/* Question 10: Which product line incurred the highest Value Added Tax? */

select `product line`, sum(`tax 5%`) as `Total VAT`
from amazondata
group by `product line`
order by `Total VAT` desc;

-- Food and Beverages incurred the highest Value Added Tax.
-- Can with tax optimization and more importantly pricing strategies.


/* Question 11: For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." */

select `product line`, sum(total) as `Total Sales`,
       case
           when sum(total) > (select avg(total) from amazondata) then 'Good'
           else 'Bad'
       end as `Sales Performance`
from amazondata
group by `product line`;

-- All the product lines seem to be selling pretty well.
-- This query can help us with strategies for sales and which lines to focus the marketing on.


/* Question 12: Identify the branch that exceeded the average number of products sold. */

select branch, sum(quantity) as `Total Quantity Sold`
from amazondata
group by branch
having sum(quantity) > (select avg(quantity) from amazondata);

-- All branches seem to have exceeded the average numbers of products sold.
-- This can help us gain insight in how all the branches or a particular branch is performing. It can also help us analyze staff performances.


/* Question 13: Which product line is most frequently associated with each gender? */

select gender, `product line`, count(*) as `Product Line Count`
from amazondata
group by gender, `product line`
order by gender, `Product Line Count` desc;

-- The product line most frequently associated with females is 'Fashion Accessories', while the for makes it is 'Health and Beauty'.
-- It helps us understand gender preferences and also with target marketing (campaigns) aimed at specific genders.


/* Question 14: Calculate the average rating for each product line. */

select `product line`, avg(rating) as `Average Rating`
from amazondata
group by `product line`;

-- This can help us see how to improve and where to improve based on customer feedbacks.


/* Question 15: Count the sales occurrences for each time of day on every weekday. */

select dayname(date) as weekday, `TimeOfDay`, count(*) as `Sales Occurances`
from amazondata
group by weekday, `TimeOfDay`
order by weekday, field(`TimeOfDay`, 'Morning', 'Afternoon', 'Evening');

-- It can help with staffing depending on which time of the day is much busier compared to te other.


/* Question 16: Identify the customer type contributing the highest revenue. */

select `customer type`, sum(total) as `Total Revenue`
from amazondata
group by `customer type`
order by `Total Revenue` desc;

-- Member customers are contributing towards the higher revenue a bit more than Normal customers, though it does not seem to be by a huge margin.
-- It helps with segeregating customers and also identify high value customers.


/* Question 17: Determine the city with the highest VAT (Tax) percentage. */

select city, max(`tax 5%`) as `Highest Tax Percentage`
from amazondata
group by city
order by `Highest Tax Percentage` desc;

-- While the difference isn't huge, the city of Naypyitaw seems to have the highest tax percentage at 49.65%. Yongon is pretty close with 49.49% with only a 0.16% of difference.
-- It can help with taxing strategies and with adapting the pricing in different cities.


/* Question 18: Identify the customer type with the highest VAT (Tax) payments. */

select `customer type`, sum(`tax 5%`) as `Total Payed Tax`
from amazondata
group by `customer type`
order by `Total Payed Tax` desc;

-- Members seem to be paying a little higher tax compared to Normal customers.
-- It can help with tax planning.


/* Question 19: What is the count of distinct customer types in the dataset? */

select count(distinct `customer type`) as `Distinct Customer Types`
from amazondata;

-- There are two types of distinct customers.
-- It can with customer segmentation and tailor strategies accordingly.


/* Question 20: What is the count of distinct payment methods in the dataset? */

select count(distinct `payment`) as `Distinct Payment Methods`
from amazondata;

-- There are three distinct payment methods.
-- It can help with optimizing payment process better depending on customer preferences.


/* Question 21: Which customer type occurs most frequently? */

select `customer type`, count(*) as `Customer Type Count`
from amazondata
group by `customer type`
order by `Customer Type Count` desc
limit 1;

-- Members seem to be appearing more frequently.
-- Can help tailor products and services accordingly.


/* Question 22: Identify the customer type with the highest purchase frequency. */

select `customer type`, count(*) as `Purchase Frequency`
from amazondata
group by `customer type`
order by `Purchase Frequency` desc;

-- Although there isn't a huge difference, members seem to have higher purchase frequency compared to Normal customers.
-- It can help identify loyal and engaged customer base, which, in turn, helps us strategize programs to retain these customer and possibly expand the roaster.


/* Question 23: Determine the predominant gender among customers. */

select `gender`, count(*) as `Gender Count`
from amazondata
group by `gender`
order by `Gender Count` desc;

-- Females seem to be the predominant gender amongst the customers.
-- It can help with better understanding of demographics and can help us strategize better customer engagement.


/* Question 24: Examine the distribution of genders within each branch. */

select branch, gender, count(*) as `Gender Count`
from amazondata
group by branch, gender
order by branch, `Gender Count` desc;

-- Branch A and B seem to have more Male customers while C seems to be the opposite. Although, the difference between the distribution seems to be higher in branch C compared to A and B.
-- We can use this information to tailor branch-specific marketing strategies or personalized campaigns and to cater more effectively in each branch.


/* Question 25: Identify the time of day when customers provide the most ratings. */

select `TimeOfDay`, count(*) as `Rating Count`
from amazondata
where rating is not null
group by `TimeOfDay`
order by `Rating Count` desc;

-- Customers seem to provide the most ratings during the Afternoons compared to Mornings and Evenings, that too by a huge margin.
-- We can use this information to optimize feedback collection and even send surveys to customers during this time of the day.


/* Question 26: Determine the time of day with the highest customer ratings for each branch. */

select branch, `TimeOfDay`, `Rating Count`
from (
    select branch, `TimeOfDay`, count(*) as `Rating Count`,
           row_number() over (partition by branch order by count(*) desc) as rn
    from amazondata
    where rating is not null
    group by branch, `TimeOfDay`
) as subquery
where rn = 1
order by branch;

-- Matching with the previous query, the time of the day with the highest customer ratings seems to be the same (Afternoon) for individual branches too.


/* Question 27: Identify the day of the week with the highest average ratings. */

select `DayName`, avg(rating) as `Average Rating`
from amazondata
where rating is not null
group by `DayName`
order by `Average Rating` desc;

-- The day of the week with highest average rating is Monday.
-- This shows us which day of the week customers tend to provide higher ratings. This is huge for feedback collection as surveys can be sent on these days for better communication.


/* Question 28: Determine the day of the week with the highest average ratings for each branch. */

select branch, `DayName`, avg(`rating`) as `Average Rating`
from (
    select branch, `DayName`, `rating`,
           avg(rating) over (partition by branch, `DayName`) as `Average Rating Per Day`
    from amazondata
    where rating is not null
) as subquery
group by branch, `DayName`
order by branch, `Average Rating` desc;

-- The day of the week with highest average ratings for branch A and C is Friday while B seems to have better feedback on Monday.
-- This information can also be valuable in analyzing branch performance on different days of the week and in better understanding of customer satisfaction.
















