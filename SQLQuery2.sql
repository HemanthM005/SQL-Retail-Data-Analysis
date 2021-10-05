

                                                --DATA PREPARATION AND UNDERSTANDING

-- Question 1

select (select count(*) from [dbo].[prod_cat_info]) as  no_of_prod ,
       (select count(*) from [dbo].[Customer]) as no_of_cust ,
	   (select count(*) from [dbo].[Transactions]) as no_of_trans

-- Question 2

select count([transaction_id]) as 'num of returns' from [dbo].[Transactions]
where [Qty] < 0

--Question 3

alter table [dbo].[Customer]
alter column [DOB]  date

alter table [dbo].[Transactions]
alter column [tran_date] date

-- by creating another column
--alter table [dbo].[Customer]
--add DOBs as convert(char , [DOB] , 105)

--alter table [dbo].[Customer]
--drop column [DOBs]

-- Question 4

--select year([tran_date]) as year , month([tran_date]) as month , day([tran_date]) as day from [dbo].[Transactions]
select min([tran_date]) as 'min_date',
       max([tran_date]) as 'max_date',
	   DATEDIFF(day,min([tran_date]),max([tran_date])) as 'number of days',
	   DATEDIFF(month,min([tran_date]),max([tran_date])) as 'number of months',
	   DATEDIFF(year,min([tran_date]),max([tran_date])) as 'number of years'
from [dbo].[Transactions]

-- Question 5

select [prod_cat] from [dbo].[prod_cat_info]
where [prod_subcat] = 'DIY'

                                                 --DATA ANALYSIS

-- Question 1

select top 1 [Store_type] from [dbo].[Transactions]
group by [Store_type] 
order by count([transaction_id]) desc

-- Question 2

select [Gender] , count([customer_Id])[count] from [dbo].[Customer]
group by [Gender]
having [Gender] in ('M','F')   


-- Question 3

select top 1 [city_code] , count([customer_Id])[number of customers] from [dbo].[Customer]
group by [city_code]
order by count([customer_Id]) desc

-- Question 4

select [prod_cat] , count([prod_subcat]) no_of_sub_cat from [dbo].[prod_cat_info]
group by [prod_cat]
having [prod_cat] = 'Books'
 
--(OR)
--select count([prod_subcat])[books_total_sub_cat]  from [dbo].[prod_cat_info]
--where [prod_cat] = 'Books'

-- Questions 5 

select max([Qty]) from [dbo].[Transactions]

-- Questions 6

/*
select sum([total_amt]) from [dbo].[Transactions] T 
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code])
where [prod_cat] = 'Electronics' or [prod_cat] = 'Books'
*/

select [prod_cat] , sum([total_amt])  from [dbo].[prod_cat_info] as p
inner join [dbo].[Transactions] as t on (p.[prod_cat_code]=t.[prod_cat_code]) and (p.[prod_sub_cat_code]=t.[prod_subcat_code])
where [prod_cat] in ('Books' , 'Electronics')
group by [prod_cat]

-- Questions 7

select count(distinct([cust_id])) from [dbo].[Transactions]
where [cust_id] in (select [cust_id] from [dbo].[Transactions]
                    where [Qty] > 0
                    group by [cust_id]
                    having count([transaction_id]) > 10)

-- Question 8

select sum([total_amt]) from [dbo].[Transactions] T 
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code])
where [Store_type] = 'Flagship store' and ([prod_cat] = 'Electronics' or [prod_cat] = 'Clothing')

-- Question 9

select P.[prod_subcat] , sum([total_amt]) [total_rev] from [dbo].[Transactions] T
inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
where C.[Gender]='M' and P.[prod_cat] = 'Electronics'
group by P.[prod_subcat]

-- Question 10

/*
select top 5 P.[prod_subcat] , per_sales = sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<0 then 0 end)*100/sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end),
                               per_returned = sum(case when [Qty]<=0 then (-1)*T.[total_amt] when [Qty]>0 then 0 end)*100/sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end)
--	total = sum(case when [Qty]>0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end)
	from [dbo].[Transactions] T
inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
group by P.[prod_subcat]
order by per_sales desc
*/
select P.[prod_subcat] , per_sales = sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<0 then 0 end)*100/sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end),
                               per_returned = sum(case when [Qty]<=0 then (-1)*T.[total_amt] when [Qty]>0 then 0 end)*100/sum(case when [Qty]>=0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end)
--	total = sum(case when [Qty]>0 then T.[total_amt] when [Qty]<=0 then (-1)*T.[total_amt] end)
	from [dbo].[Transactions] T
inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code])
where P.prod_subcat in (select top 5 P.prod_subcat from [dbo].[prod_cat_info] P
                        inner join [dbo].[Transactions] T on (T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code)
                        group by P.prod_subcat
                        order by SUM(T.[total_amt]) desc) 
group by P.[prod_subcat]
order by per_sales desc

-- Question 11

select sum(T.[total_amt]) from [dbo].[Transactions] T
inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
where DATEDIFF(year , C.[DOB] , T.[tran_date]) between 25 and 35 and T.[tran_date]>=DATEADD(day,-30,

(select top 1 [tran_date] from [dbo].[Transactions] T
inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
group by [tran_date]
order by count([transaction_id]) desc)) and T.[tran_date] <= (select top 1 [tran_date] from [dbo].[Transactions] T
                                                                 inner join [dbo].[Customer] C on C.[customer_Id] = T.[cust_id]
                                                                 inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
                                                                 group by [tran_date]
                                                                 order by count([transaction_id]) desc)


-- Question 12

select top 1 P.prod_cat from [dbo].[prod_cat_info] as P
inner join [dbo].[Transactions] as T on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
where T.[tran_date]>= DATEADD(month,-3,(select max([tran_date]) from [dbo].[Transactions])) and T.[tran_date]<=(select max([tran_date]) from [dbo].[Transactions])
      and T.Qty <0
group by P.prod_cat
order by (-1)*sum(T.total_amt) desc

-- Question 13


select top 1 [Store_type] from [dbo].[Transactions]
where [Store_type] in (select top 1 [Store_type] from [dbo].[Transactions]
                       group by [Store_type]
                       order by sum([Qty]) desc )
group by [Store_type]
order by sum([total_amt]) desc

-- Question 14

select [prod_cat] from [dbo].[Transactions] T
        inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code]) 
         group by [prod_cat]
		 having AVG([total_amt]) > (select AVG([total_amt]) from [dbo].[Transactions])

-- Question 15


select P.[prod_subcat] , AVG([total_amt])[average] , SUM([total_amt])[total] from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code])
where P.[prod_cat] in 
(
select top 5  P.[prod_cat]  from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P on (P.[prod_cat_code] = T.[prod_cat_code] and P.[prod_sub_cat_code] = T.[prod_subcat_code])
group by P.[prod_cat]
order by sum(T.[Qty]) desc
)
group by P.prod_subcat


