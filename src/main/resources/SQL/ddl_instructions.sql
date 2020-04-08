--DDL TARGET table
CREATE TABLE public.bank_additional_merge (
	age numeric NULL,
	job text NULL,
	marital text NULL,
	education text NULL,
	"default" text NULL,
	housing text NULL,
	loan text NULL,
	contact text NULL,
	"month" text NULL,
	day_of_week text NULL,
	duration numeric NULL,
	campaign numeric NULL,
	pdays numeric NULL,
	previous numeric NULL,
	poutcome numeric NULL,
	"emp.var.rate" numeric NULL,
	"cons.price.idx" numeric NULL,
	"cons.conf.idx" numeric NULL,
	euribor3m numeric NULL,
	"nr.employed" numeric NULL,
	y text NULL,
	valid_from timestamp NULL,
	valid_to timestamp NULL,
	merge_operation text NULL
)
DISTRIBUTED BY (age);

--DDL INC table
CREATE TABLE public.bank_additional_inc (
	age numeric NULL,
	job text NULL,
	marital text NULL,
	education text NULL,
	"default" text NULL,
	housing text NULL,
	loan text NULL,
	contact text NULL,
	"month" text NULL,
	day_of_week text NULL,
	duration numeric NULL,
	campaign numeric NULL,
	pdays numeric NULL,
	previous numeric NULL,
	poutcome numeric NULL,
	"emp.var.rate" numeric NULL,
	"cons.price.idx" numeric NULL,
	"cons.conf.idx" numeric NULL,
	euribor3m numeric NULL,
	"nr.employed" numeric NULL,
	y text NULL,
	valid_from timestamp NULL,
	valid_to timestamp NULL,
	merge_operation text NULL
)
DISTRIBUTED BY (age);

--DDL HIST table
CREATE TABLE public.bank_additional_hist (
	age numeric NULL,
	job text NULL,
	marital text NULL,
	education text NULL,
	"default" text NULL,
	housing text NULL,
	loan text NULL,
	contact text NULL,
	"month" text NULL,
	day_of_week text NULL,
	duration numeric NULL,
	campaign numeric NULL,
	pdays numeric NULL,
	previous numeric NULL,
	poutcome numeric NULL,
	"emp.var.rate" numeric NULL,
	"cons.price.idx" numeric NULL,
	"cons.conf.idx" numeric NULL,
	euribor3m numeric NULL,
	"nr.employed" numeric NULL,
	y text NULL,
	valid_from timestamp NULL,
	valid_to timestamp NULL,
	merge_operation text NULL
)
DISTRIBUTED BY (age);

--INSERT INC
INSERT INTO public.bank_additional_inc
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(37, 'services', 'married', 'high.school', 'no', 'yes', 'no', 'telephone', 'may', 'mon', 155, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-01 10:23:54', null, 'I');

INSERT INTO public.bank_additional_inc
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(59, 'admin.', 'married', 'professional.course', 'no', 'no', 'no', 'telephone', 'may', 'mon', 139, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-01 10:23:54', null, 'I');

INSERT INTO public.bank_additional_inc
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(29, 'blue-collar', 'single', 'high.school', 'no', 'no', 'yes', 'telephone', 'may', 'mon', 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-01 10:23:54', null, 'I');

INSERT INTO public.bank_additional_inc
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(57, 'services', 'married', 'high.school', 'unknown', 'no', 'yes', 'telephone', 'may', 'mon', 149, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-03 10:23:54', null, 'U');

INSERT INTO public.bank_additional_inc
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(45, 'services', 'married', 'basic.9y', 'unknown', 'no', 'no', 'telephone', 'may', 'mon', 149, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-03-27 10:23:54', null, 'I');

--INSERT TARGET
INSERT INTO public.bank_additional_merge
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(29, 'blue-collar', 'single', 'high.school', 'no', 'no', 'yes', 'telephone', 'may', 'mon', 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-02 10:23:54', null, 'I');

INSERT INTO public.bank_additional_merge
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(59, 'admin.', 'married', 'professional.course', 'no', 'no', 'no', 'telephone', 'may', 'mon', 139, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-03-28 10:23:54', null, 'I');

INSERT INTO public.bank_additional_merge
(age, job, marital, education, "default", housing, loan, contact, "month", day_of_week, duration, campaign, pdays, previous, poutcome, "emp.var.rate", "cons.price.idx", "cons.conf.idx", euribor3m, "nr.employed", y, valid_from, valid_to, merge_operation)
VALUES(35, 'blue-collar', 'married', 'basic.6y', 'no', 'yes', 'no', 'telephone', 'may', 'mon', 149, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'no', '2020-04-02 10:23:54', null, 'I');


--SELECT 
select duration, valid_from, valid_to, merge_operation,* from public.bank_additional_inc
order by duration;

select duration, valid_from, valid_to, merge_operation,* from public.bank_additional_merge
order by duration;

select duration, valid_from, valid_to, merge_operation,* from public.bank_additional_hist
order by duration;

--run function
select * from test_merge_with_history();
