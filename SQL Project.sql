use sql_project;

show variables like 'secure_file_priv';
show variables like 'local_infile';
set global local_infile = 'on';
show variables like 'local_infile';
set sql_mode = "";
SET SESSION sql_mode = '';

create table finance_1 
(id int primary key, member_id int, loan_amnt int, funded_amnt int, funded_amnt_inv real, term varchar(255), int_rate real,
installment real, grade varchar(255), sub_grade varchar(255), emp_title varchar(255), emp_length varchar(255), home_ownership varchar(255),
annual_inc int, verification_status varchar(255), issue_id date, loan_status varchar(255), pymnt_plan varchar(255), desc_ text,
purpose varchar(255), title varchar(255), zip_code varchar(255), addr_state varchar(255), dti varchar(255));

select * from finance_1;

select count(*) from finance_1;

load data infile "Finance_1.csv" into table sql_project.finance_1
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

create table finance_2 
(id int primary key, delinq_2yrs int, earliest_cr_line date, inq_last_6mths int, mths_since_last_delinq int, mths_since_last_record int,	
open_acc int, pub_rec int, revol_bal int, revol_util real, total_acc int, initial_list_status varchar(10),	out_prncp int,	
out_prncp_inv int, total_pymnt real, total_pymnt_inv real, total_rec_prncp real, total_rec_int real, total_rec_late_fee real,	
recoveries real, collection_recovery_fee real, last_pymnt_d date, last_pymnt_amnt real, next_pymnt_d date, last_credit_pull_d date,
foreign key (id) references finance_1(id));

select * from finance_2;

select count(*) from finance_2;

load data infile "Finance_2.csv" into table sql_project.finance_2
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

# KPI 1
SELECT YEAR(f2.last_credit_pull_d) AS year, SUM(f1.loan_amnt) AS loan_amnt FROM finance_1 AS f1
JOIN finance_2 AS f2 ON f1.id = f2.id WHERE f2.last_credit_pull_d IS NOT NULL
GROUP BY year
ORDER BY year;

# KPI 2
SELECT f1.grade, f1.sub_grade, SUM(f2.revol_bal) AS revol_bal FROM finance_1 as f1 JOIN finance_2 as f2 on f1.id = f2.id
GROUP BY f1.grade, f1.sub_grade ORDER BY f1.grade, f1.sub_grade;

# KPI 3
# Option 1
SELECT f1.verification_status,
SUM(CASE WHEN f1.verification_status = 'Verified' THEN round(f2.total_pymnt) ELSE 0 END) AS total_payment_for_verified_status,
SUM(CASE WHEN f1.verification_status = 'Not Verified' THEN round(f2.total_pymnt) ELSE 0 END) AS total_payment_for_non_verified_status
FROM finance_1 as f1  JOIN finance_2 as f2 ON f1.id = f2.id GROUP BY f1.verification_status
having f1.verification_status in ('Verified', 'Not Verified');

# Option 2
select f1.verification_status, sum(round(f2.total_pymnt))  as total_pymnt
FROM finance_1 as f1  JOIN finance_2 as f2 ON f1.id = f2.id GROUP BY f1.verification_status 
having f1.verification_status in ('Verified', 'Not Verified');

# Option 3
select f1.verification_status, sum(round(f2.total_pymnt)) as total_pymnt, 
round(SUM(f2.total_pymnt) / (SELECT SUM(total_pymnt) FROM finance_2 WHERE verification_status IN ('Verified', 'Not Verified')) * 100) AS percentage
FROM finance_1 as f1  JOIN finance_2 as f2 ON f1.id = f2.id where f1.verification_status in ('Verified', 'Not Verified')
GROUP BY f1.verification_status;

# KPI 4
SELECT YEAR(f2.last_credit_pull_d) AS year, f1.addr_state, f1.loan_status, COUNT(*) AS count FROM finance_1 AS f1
JOIN finance_2 AS f2 ON f1.id = f2.id WHERE f2.last_credit_pull_d IS NOT NULL
GROUP BY year, f1.addr_state, f1.loan_status
ORDER BY year;

# KPI 5
# Option 1
SELECT f1.home_ownership, YEAR(f2.last_pymnt_d) AS year, COUNT(*) AS count FROM finance_1 AS f1
JOIN finance_2 AS f2 ON f1.id = f2.id WHERE f2.last_pymnt_d IS NOT NULL
GROUP BY f1.home_ownership
ORDER BY f1.home_ownership;

# Option 2
SELECT f1.home_ownership, COUNT(*) AS count FROM finance_1 AS f1
JOIN finance_2 AS f2 ON f1.id = f2.id WHERE f2.last_pymnt_d IS NOT NULL
GROUP BY f1.home_ownership
ORDER BY f1.home_ownership;

